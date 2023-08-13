//
//  TrackerRecordCoreData+CoreDataProperties.swift
//  Tracker
//
//  Created by Егор Свистушкин on 07.08.2023.
//
//

import Foundation
import CoreData


extension TrackerRecordCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerRecordCoreData> {
        return NSFetchRequest<TrackerRecordCoreData>(entityName: "TrackerRecordCoreData")
    }

    @NSManaged public var date: Date
    @NSManaged public var tracker: TrackerCoreData

}

extension TrackerRecordCoreData : Identifiable {

}
