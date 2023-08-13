//
//  TrackerStore.swift
//  Tracker
//
//  Created by Егор Свистушкин on 29.07.2023.
//

import Foundation
import CoreData

enum TrackerStoreError: Error {
    case decodingErrorInvalidTrackerData
}

class TrackerStore: NSObject {
    
    // MARK: - Private Properties
    private let colorMarshalling = СolorMarshalling()
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
                       color: colorMarshalling.color(from: trackerCoreData.color),
                       emoji: trackerCoreData.emoji,
                       schedule: scheduleConverter.convertToArray(string: trackerCoreData.schedule)
        )
    }
    
    func addNewTracker(_ tracker: Tracker, at category: TrackerCategoryCoreData) throws {
        let trackerCoreData = TrackerCoreData(context: context)
        updateTrackers(trackerCoreData, tracker)
        trackerCoreData.category = category
        try context.save()
    }
    
    // MARK: - Private Methods
    private func updateTrackers(_ trackerCoreData: TrackerCoreData, _ tracker: Tracker) {
        trackerCoreData.trackerId = tracker.id
        trackerCoreData.name = tracker.name
        trackerCoreData.color = colorMarshalling.hexString(from: tracker.color)
        trackerCoreData.emoji = tracker.emoji
        trackerCoreData.schedule = scheduleConverter.convertToString(array: tracker.schedule)
    }
}
