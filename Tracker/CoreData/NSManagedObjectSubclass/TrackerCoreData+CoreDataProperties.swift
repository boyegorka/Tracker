//
//  TrackerCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Егор Свистушкин on 07.08.2023.
//
//

import Foundation
import CoreData


extension TrackerCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCoreData> {
        return NSFetchRequest<TrackerCoreData>(entityName: "TrackerCoreData")
    }

    @NSManaged public var color: String
    @NSManaged public var emoji: String
    @NSManaged public var trackerId: UUID
    @NSManaged public var name: String
    @NSManaged public var schedule: String
    @NSManaged public var isPinned: Bool
    @NSManaged public var category: TrackerCategoryCoreData
    @NSManaged public var records: NSSet

}

// MARK: Generated accessors for records
extension TrackerCoreData {

    @objc(addRecordsObject:)
    @NSManaged public func addToRecords(_ value: TrackerRecordCoreData)

    @objc(removeRecordsObject:)
    @NSManaged public func removeFromRecords(_ value: TrackerRecordCoreData)

    @objc(addRecords:)
    @NSManaged public func addToRecords(_ values: NSSet)

    @objc(removeRecords:)
    @NSManaged public func removeFromRecords(_ values: NSSet)

}

extension TrackerCoreData : Identifiable {

}
