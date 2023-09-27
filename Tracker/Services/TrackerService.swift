//
//  TrackerService.swift
//  Tracker
//
//  Created by Егор Свистушкин on 11.07.2023.
//

import Foundation
import CoreData

struct TrackerServiceUpdate {
    let insertedIndexes: [IndexPath]
    let deletedIndexes: [IndexPath]
    let updatedIndexes: [IndexPath]
}

protocol TrackerServiceDelegate: AnyObject {
    func didUpdate(_ update: TrackerServiceUpdate)
}

protocol TrackerServiceProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func tracker(at: IndexPath) -> Tracker?
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
    
    private var insertedIndexes: [IndexPath] = []
    private var deletedIndexes: [IndexPath] = []
    private var updatedIndexes: [IndexPath] = []
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Model")
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                print("Ошибка в EmojiMixCoreData")
            }
        }
        return container
    }()
    
    private var fetchedResultsController: NSFetchedResultsController<TrackerCoreData>?
    
    // MARK: - Initializers
    override init() {
        super.init()
        self.trackerStore = TrackerStore(context: persistentContainer.viewContext)
        self.trackerCategoryStore = TrackerCategoryStore(context: persistentContainer.viewContext)
        self.trackerRecordStore = TrackerRecordStore(context: persistentContainer.viewContext)
    }
    
    // MARK: - Public Methods
    func fetch(search: String, date: Date) {

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category.name, ascending: true)
        ]

        let weekday = String(date.weekdayIndex)
        let namePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.name), search)

        let datePredicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K == ''", #keyPath(TrackerCoreData.schedule), weekday, #keyPath(TrackerCoreData.schedule))

        if search.count != 0 {
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate])
        } else {
            fetchRequest.predicate = datePredicate
        }

        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: #keyPath(TrackerCoreData.category.name), cacheName: nil)
        fetchedController.delegate = self
        fetchedResultsController = fetchedController
        try? fetchedController.performFetch()
    }
    
    func getAllCategories() -> [String] {
        trackerCategoryStore?.getCategoryNames() ?? []
    }
    
    func addNewCategory(name: String) throws {
        try trackerCategoryStore?.addCategory(name: name)
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
}

// MARK: - TrackerServiceProtocol

extension TrackerService: TrackerServiceProtocol {
    
    var numberOfSections: Int {
        fetchedResultsController?.sections?.count ?? 0
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        fetchedResultsController?.sections?[section].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        guard let fetchedResultsController else { return nil}
        return trackerStore?.getTrackerFromCoreData(from: fetchedResultsController.object(at: indexPath))
    }
    
    func categoryName(at section: Int) -> String {
        fetchedResultsController?.object(at: IndexPath(item: 0, section: section)).category.name ?? ""
    }
    
    func addTracker(_ traker: Tracker, at category: String) throws {
        if let categoryCoreData = trackerCategoryStore?.getCategoryWithName(category) {
            try? trackerStore?.addNewTracker(traker, at: categoryCoreData)
        }
    }
    
    func saveTracker(_ tracker: Tracker, at category: String) throws {
        if let categoryCoreData = trackerCategoryStore?.getCategoryWithName(category) {
            try? trackerStore?.saveTracker(tracker, at: categoryCoreData)
        }
    }
    
    func deleteTracker(at indexPath: IndexPath) throws {
        if let traker = fetchedResultsController?.object(at: indexPath) {
            try? trackerStore?.deleteTracker(traker)
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerService: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        insertedIndexes = []
        deletedIndexes = []
        updatedIndexes = []
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        let insert = insertedIndexes
        let delete = deletedIndexes
        let update = updatedIndexes
        DispatchQueue.main.async {
            self.delegate?.didUpdate(TrackerServiceUpdate(
                insertedIndexes: insert,
                deletedIndexes: delete,
                updatedIndexes: update
            )
            )
        }
        
        insertedIndexes = []
        deletedIndexes = []
        updatedIndexes = []
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .delete:
            if let indexPath = indexPath {
                deletedIndexes.append(indexPath)
            }
        case .insert:
            if let indexPath = newIndexPath {
                print(indexPath)
                insertedIndexes.append(indexPath)
            }
        case .update:
            if let indexPath = indexPath {
                print(indexPath)
                updatedIndexes.append(indexPath)
            }
        default:
            break
        }
    }
}
