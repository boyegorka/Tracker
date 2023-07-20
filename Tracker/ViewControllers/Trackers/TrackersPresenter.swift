//
//  TrackersPresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 10.07.2023.
//

import UIKit

protocol TrackersPresenterProtocol {
    var view: TrackersViewControllerProtocol? { get }
    var currentDate: Date { get set }
    var categories: [TrackerCategory] { get }
    var search: String { get set }
    func addTracker(_ tracker: Tracker, at category: TrackerCategory)
    func numberOfSections() -> Int?
    func numberOfItemsInSection(section: Int) -> Int
    func updateCategories()
    func completeTracker(_ complete: Bool, tracker: Tracker)
    func trackerViewModel(at indexPath: IndexPath) -> TrackerCellViewModel
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    var categories: [TrackerCategory] = []
    weak var view: TrackersViewControllerProtocol?
    private let service = TrackerService()
    
    var search: String = "" {
        didSet {
            updateCategories()
        }
    }
    var currentDate: Date = Date() {
        didSet {
            updateCategories()
        }
    }
    
    
    
    func addTracker(_ tracker: Tracker, at category: TrackerCategory) {
        service.addTracker(tracker, at: category)
        updateCategories()
    }
    
    func updateCategories() {
        categories = service.getCategoriesFor(date: currentDate, search: search)
    }
    
    func completeTracker(_ complete: Bool, tracker: Tracker) {
        if complete {
            service.addToCompletedTrackers(tracker: tracker, date: currentDate)
        } else {
            service.removeFromCompletedTrackers(tracker: tracker, date: currentDate)
        }
    }
    
    func isCompletedTracker(_ tracker: Tracker) -> Bool {
        service.completedTrackers.first(where: { $0.id == tracker.id && $0.date == currentDate }) != nil
    }
    
    func countRecordsTracker(_ tracker: Tracker) -> Int {
        service.completedTrackers.filter({ $0.id == tracker.id }).count
    }
    
    func numberOfSections() -> Int? {
        view?.setupEmptyScreen()
        return categories.count
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        categories[section].trackers.count
    }
    
    func trackerViewModel(at indexPath: IndexPath) -> TrackerCellViewModel {
        let tracker = categories[indexPath.section].trackers[indexPath.row]
        return TrackerCellViewModel(tracker: tracker, isCompleted: isCompletedTracker(tracker), daysCounter: countRecordsTracker(tracker), isComplitionEnable: currentDate <= Date())
    }
}
