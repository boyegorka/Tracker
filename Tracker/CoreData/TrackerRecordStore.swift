//
//  TrackerRecordStore.swift
//  Tracker
//
//  Created by Егор Свистушкин on 29.07.2023.
//

import Foundation
import CoreData

enum TrackerRecordStoreError: Error {
    case getRecordError
    case createRecordError
    case deleteRecordError
}

class TrackerRecordStore: NSObject {
    
    private let context: NSManagedObjectContext
    private let colorMarshalling = СolorMarshalling()
    private let scheduleConverter = ScheduleConverter()
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    func getTrackerRecordFromCoreData(tracker: Tracker, date: Date) -> TrackerRecord? {
        var trackerToReturn: TrackerRecord? = nil
        guard let date = date.onlyDate else { return nil }
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker.trackerId), tracker.id.uuidString)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), date as NSDate)
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [idPredicate, datePredicate])
        do {
            guard let existingTrackerRecord = try context.fetch(request).first else { return nil }
            trackerToReturn = TrackerRecord(id: existingTrackerRecord.tracker.trackerId, date: date)
        } catch let error as NSError {
            print("Error fetching tracker record: \(error.localizedDescription)")
        }
        return trackerToReturn ?? nil
    }
    
    func getTrackerRecordsNumber(tracker: Tracker) -> Int {
        var count = 0
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        request.resultType = .countResultType
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker.trackerId), tracker.id.uuidString)
        request.predicate = idPredicate
        do {
            count = try context.count(for: request)
        } catch let error as NSError {
            print("Error fetching tracker record number: \(error.localizedDescription)")
        }
        return count
    }
    
    func addNewTrackerRecord(_ tracker: Tracker, date: Date) throws {
        let newTrackerRecord = TrackerRecordCoreData(context: context)
        guard let date = date.onlyDate else { return }
        let request = NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCoreData.trackerId), tracker.id.uuidString)
        request.predicate = idPredicate
        do {
            if let existingTracker = try? context.fetch(request).first {
                newTrackerRecord.tracker = existingTracker
                newTrackerRecord.date = date
            }
            try context.save()
        } catch {
            throw TrackerRecordStoreError.createRecordError
        }
    }
    
    func deleteTrackerRecord(_ tracker: Tracker, date: Date) throws {
        let request = NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
        guard let date = date.onlyDate else { return }
        let idPredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.tracker.trackerId), tracker.id.uuidString)
        let datePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerRecordCoreData.date), date as NSDate)
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [idPredicate, datePredicate])
        
        if let existingTracker = try? context.fetch(request).first {
            do {
                context.delete(existingTracker)
                try context.save()
            } catch {
                throw TrackerRecordStoreError.deleteRecordError
            }
        }
    }
}
