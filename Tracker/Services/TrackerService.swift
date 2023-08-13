//
//  TrackerService.swift
//  Tracker
//
//  Created by Егор Свистушкин on 11.07.2023.
//

import Foundation
import CoreData

struct TrackerServiceUpdate {
    let insertedIndexes: IndexSet
    let deletedIndexes: IndexSet
}

protocol TrackerServiceDelegate: AnyObject {
    func didUpdate(_ update: TrackerServiceUpdate)
}

protocol TrackerServiceProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func tracker(at: IndexPath) -> Tracker
    func categoryName(at section: Int) -> String
    func addTracker(_ traker: Tracker, at category: String) throws
    func deleteTracker(at indexPath: IndexPath) throws
}

final class TrackerService: NSObject {
    
    // MARK: - Public Properties
    weak var delegate: TrackerServiceDelegate?
    
    // MARK: - Private Properties
    private var trackerStore: TrackerStore?
    private var trackerCategoryStore: TrackerCategoryStore?
    private var trackerRecordStore: TrackerRecordStore?
    
    private var insertedIndexes: IndexSet?
    private var deletedIndexes: IndexSet?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Ошибка в EmojiMixCoreData")
            }
        }
        return container
    }()
    
    private lazy var fetchedResultsController: NSFetchedResultsController<TrackerCoreData> = {
        
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCategoryCoreData.name, ascending: true)
        ]
        
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: "category.name", cacheName: nil)
        controller.delegate = self
        try? controller.performFetch()
        return controller
    }()
    
    // MARK: - Initializers
    override init() {
        super.init()
        self.trackerStore = TrackerStore(context: persistentContainer.viewContext)
        self.trackerCategoryStore = TrackerCategoryStore(context: persistentContainer.viewContext)
        self.trackerRecordStore = TrackerRecordStore(context: persistentContainer.viewContext)
        addTestCategory()
    }
    
    // MARK: - Public Methods
    func updatePredicate(search: String, date: Date) {
        let weekday = String(date.weekdayIndex)
        let namePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.name), search)
        let datePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.schedule), weekday)
        
//        if search.count != 0 {
//            fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate])
//        } else {
//            fetchedResultsController.fetchRequest.predicate = datePredicate
//        }
        
        // на данный момент все нерегулярные привычки показываются только "сегодня" оставил закомментированный код выше, чтобы мог быстро вернуть всё обратно. Напишите пожалуйста, в какой момент нерегулярные привычки должны показываться? В макете в фигме непонятно.
        
        if date.onlyDate == Date().onlyDate {
            if search.count != 0 {
                fetchedResultsController.fetchRequest.predicate = namePredicate
            } else {
                fetchedResultsController.fetchRequest.predicate = NSPredicate(value: true)
            }
        } else {
            if search.count != 0 {
                fetchedResultsController.fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate])
            } else {
                fetchedResultsController.fetchRequest.predicate = datePredicate
            }
        }
        try? fetchedResultsController.performFetch()
    }
    
    func getAllCategories() -> [String] {
        trackerCategoryStore?.getCategoryNames() ?? []
    }
    
    func getTrackerRecord(tracker: Tracker, date: Date) -> TrackerRecord? {
        trackerRecordStore?.getTrackerRecordFromCoreData(tracker: tracker, date: date)
    }
    
    func getTrackersNumber(tracker: Tracker) -> Int {
        trackerRecordStore?.getTrackerRecordsNumber(tracker: tracker) ?? 0
    }
    
    func addToCompletedTrackers(tracker: Tracker, date: Date) throws {
        try trackerRecordStore?.addNewTrackerRecord(tracker, date: date)
    }
    
    func removeFromCompletedTrackers(tracker: Tracker, date: Date) throws {
        try trackerRecordStore?.deleteTrackerRecord(tracker, date: date)
    }
    
    // MARK: - Private Methods
    private func addTestCategory() {
        if fetchedResultsController.sections?.count ?? 0 == 0 {
            do {
                try trackerCategoryStore?.addCategory(name: "test")
                try trackerCategoryStore?.addCategory(name: "test2")
                let tracker1 = Tracker(id: UUID(), name: "Поливать растения", color: .ypSelection18 ?? .gray, emoji: "❤️", schedule: [2])
                try addTracker(tracker1, at: "test")
                let tracker2 = Tracker(id: UUID(), name: "Поливать растения2", color: .ypSelection18 ?? .gray, emoji: "❤️", schedule: [0,1,2,3,4,5,6])
                try addTracker(tracker2, at: "test2")
            } catch {
                
            }
        }
    }
}

// MARK: - TrackerServiceProtocol

extension TrackerService: TrackerServiceProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker {
        trackerStore?.getTrackerFromCoreData(from: fetchedResultsController.object(at: indexPath)) ?? Tracker(id: UUID(), name: "test", color: .gray, emoji: "", schedule: [])
    }
    
    func categoryName(at section: Int) -> String {
        fetchedResultsController.object(at: IndexPath(item: 0, section: section)).category.name
    }
    
    func addTracker(_ traker: Tracker, at category: String) throws {
        if let categoryCoreData = trackerCategoryStore?.getCategoryWithName(category) {
            try? trackerStore?.addNewTracker(traker, at: categoryCoreData)
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        // let traker = fetchedResultsController.object(at: indexPath)
        // try? trackerStore.delete(traker)
    }
    
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerService: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = IndexSet()
        deletedIndexes = IndexSet()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.didUpdate(TrackerServiceUpdate(
            insertedIndexes: insertedIndexes ?? IndexSet(),
            deletedIndexes: deletedIndexes ?? IndexSet()
        )
        )
        insertedIndexes = nil
        deletedIndexes = nil
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes?.insert(indexPath.item)
            }
        case .insert:
            if let indexPath = newIndexPath {
                insertedIndexes?.insert(indexPath.item)
            }
        default:
            break
        }
    }
}
