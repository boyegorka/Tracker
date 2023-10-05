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
    let movedIndexes: [(from: IndexPath, to: IndexPath)]
}

protocol TrackerServiceDelegate: AnyObject {
    func didUpdate()
}

protocol TrackerServiceProtocol {
    var numberOfSections: Int { get }
    func numberOfRowsInSection(_ section: Int) -> Int
    func tracker(at: IndexPath) -> Tracker?
    func categoryName(at section: Int) -> String
    func addTracker(_ traker: Tracker, at category: String) throws
    func deleteTracker(_ tracker: Tracker) throws
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
    private var movedIndexes: [(from: IndexPath, to: IndexPath)] = []

    
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
    private var fetchedPinnedResultsController: NSFetchedResultsController<TrackerCoreData>?

    // MARK: - Initializers
    override init() {
        super.init()
        self.trackerStore = TrackerStore(context: persistentContainer.viewContext)
        self.trackerCategoryStore = TrackerCategoryStore(context: persistentContainer.viewContext)
        self.trackerRecordStore = TrackerRecordStore(context: persistentContainer.viewContext)
    }
    
    // MARK: - Public Methods
    func fetchPinned() {
        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.name, ascending: true)
        ]

        fetchRequest.predicate = NSPredicate(format: "%K == true", #keyPath(TrackerCoreData.isPinned))

        let fetchedController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: persistentContainer.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedController.delegate = self
        fetchedPinnedResultsController = fetchedController
        try? fetchedController.performFetch()
    }
    
    func fetch(search: String, date: Date) {

        let fetchRequest = TrackerCoreData.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(keyPath: \TrackerCoreData.category.name, ascending: true)
        ]

        let weekday = String(date.weekdayIndex)
        let namePredicate = NSPredicate(format: "%K CONTAINS[cd] %@", #keyPath(TrackerCoreData.name), search)

        let datePredicate = NSPredicate(format: "%K CONTAINS[cd] %@ OR %K == ''", #keyPath(TrackerCoreData.schedule), weekday, #keyPath(TrackerCoreData.schedule))

        let pinnedPredicate = NSPredicate(format: "%K == false", #keyPath(TrackerCoreData.isPinned))

        if search.count != 0 {
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [namePredicate, datePredicate, pinnedPredicate])
        } else {
            fetchRequest.predicate = NSCompoundPredicate(type: .and, subpredicates: [datePredicate, pinnedPredicate])
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
    
    func getAllTrackersRecordNumber() -> Int {
        trackerRecordStore?.getAllTrackersRecordNumber() ?? 0
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
    
    private var hasPinned: Bool {
        // возвращает результат, если в закреплённой секции больше одной ячейки
        (fetchedPinnedResultsController?.sections?[0].numberOfObjects ?? 0) > 0
    }

    private func indexFetchSection(_ section: Int) -> Int {
        return hasPinned ? section - 1 : section
    }

    private func isPinnedSection(_ section: Int) -> Bool {
        return section == 0 && hasPinned
    }
    
    var numberOfSections: Int {
        let count = fetchedResultsController?.sections?.count ?? 0
        return hasPinned ? count + 1 : count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        if isPinnedSection(section) {
            return fetchedPinnedResultsController?.sections?[section].numberOfObjects ?? 0
        }
        return fetchedResultsController?.sections?[indexFetchSection(section)].numberOfObjects ?? 0
    }
    
    func tracker(at indexPath: IndexPath) -> Tracker? {
        if isPinnedSection(indexPath.section) {
            guard let fetchedPinnedResultsController else { return nil }
            return trackerStore?.getTrackerFromCoreData(from: fetchedPinnedResultsController.object(at: indexPath))
        }
        guard let fetchedResultsController else { return nil }
        let newIndexPath = IndexPath(row: indexPath.row, section: indexFetchSection(indexPath.section))
        return trackerStore?.getTrackerFromCoreData(from: fetchedResultsController.object(at: newIndexPath))
    }
    
    func categoryName(at section: Int) -> String {
        if isPinnedSection(section) {
            return "pinned".localized
        } else {
            let newIndexPath = IndexPath(row: 0, section: indexFetchSection(section))
            return fetchedResultsController?.object(at: newIndexPath).category.name ?? ""
        }
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
    
    func deleteTracker(_ tracker: Tracker) throws {
        try? trackerStore?.deleteTracker(tracker)
    }

    func pin(_ isPinned: Bool, tracker: Tracker) throws {
        try? trackerStore?.pin(isPinned, tracker: tracker)
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension TrackerService: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        DispatchQueue.main.async {
            self.delegate?.didUpdate()
        }
    }
}
