//
//  TrackerStore.swift
//  Tracker
//
//  Created by Егор Свистушкин on 29.07.2023.
//

import UIKit
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidTrackerData
}

class TrackerStore: NSObject {
    
    // MARK: - Private Properties
    private let scheduleConverter = ScheduleConverter()
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods
    func getTrackerFromCoreData(from trackerCoreData: TrackerCoreData) -> Tracker {
        return Tracker(id: trackerCoreData.trackerId,
                       name: trackerCoreData.name,
                       color: UIColor.color(from: trackerCoreData.color),
                       emoji: trackerCoreData.emoji,
                       schedule: scheduleConverter.convertToArray(string: trackerCoreData.schedule),
                       isPinned: trackerCoreData.isPinned
        )
    }
    
    func addNewTracker(_ tracker: Tracker, at category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTracker(trackerCoreData, tracker)
        trackerCoreData.category = category
        try context.save()
    }
    
    func saveTracker(_ tracker: Tracker, at category: TrackerCategoryCoreData) throws {
        if let trackerCoreData = getTrackerWithID(tracker.id) {
            updateTracker(trackerCoreData, tracker)
            trackerCoreData.category = category
            try context.save()
        }
    }

    func pin(_ isPinned: Bool, tracker: Tracker) throws {
        if let trackerCoreData = getTrackerWithID(tracker.id) {
            trackerCoreData.isPinned = isPinned
            try context.save()
        }
    }
    
    func getTrackerWithID(_ id: UUID) -> TrackerCoreData? {
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), id as CVarArg)
        request.predicate = idPredicate
        return try? context.fetch(request).first
    }
    
    func deleteTracker(_ tracker: TrackerCoreData) throws {
        context.delete(tracker)
        try context.save()
    }
    
    // MARK: - Private Methods
    private func updateTracker(_ trackerCoreData: TrackerCoreData, _ tracker: Tracker) {
        trackerCoreData.trackerId = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = tracker.color.hexString
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = scheduleConverter.convertToString(array: tracker.schedule)
        trackerCoreData.isPinned = tracker.isPinned
    }
}
