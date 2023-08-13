//
//  TrackerCategoryStore.swift
//  Tracker
//
//  Created by Егор Свистушкин on 29.07.2023.
//

import Foundation
import CoreData

enum TrackerCategoryStoreError: Error {
    case decodingErrorInvalidTrackerCategoryData
    case createCategoryError
}

class TrackerCategoryStore: NSObject {
    
    // MARK: - Private Properties
    private let context: NSManagedObjectContext
    
    // MARK: - Initializers
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
    }
    
    // MARK: - Public Methods
    func getCategoryNames() -> [String] {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        request.propertiesToFetch = ["name"]
        let categoryNames = try? context.fetch(request)
        return categoryNames?.map { $0.name } ?? []
    }
    
    func getCategoryWithName(_ name: String) -> TrackerCategoryCoreData? {
        let request = NSFetchRequest<TrackerCategoryCoreData>(entityName: "TrackerCategoryCoreData")
        let namePredicate = NSPredicate(format: "%K == %@", #keyPath(TrackerCategoryCoreData.name), name)
        request.predicate = namePredicate
        return try? context.fetch(request).first
    }
    
    func addCategory(name: String) throws {
        do {
            let trackerCategoryCoreData = TrackerCategoryCoreData(context: context)
            trackerCategoryCoreData.name = name
            trackerCategoryCoreData.trackers = []
            try context.save()
        } catch {
            print(error)
            throw TrackerCategoryStoreError.createCategoryError
        }
    }
}
