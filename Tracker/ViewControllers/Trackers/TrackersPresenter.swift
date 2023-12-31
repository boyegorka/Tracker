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
    var caregories: [String] { get }
    var search: String { get set }
    var isEmpty: Bool { get }
    var selectedFilter: String? { get set }
    func addTracker(_ tracker: Tracker, at category: String)
    func saveTracker(_ tracker: Tracker, at category: String)
    func pinTracker(tracker: Tracker)
    func deleteTracker(_ tacker: Tracker)
    func numberOfSections() -> Int?
    func numberOfItemsInSection(section: Int) -> Int
    func categoryName(section: Int) -> String
    func updateCategories()
    func updatePinned()
    func completeTracker(_ complete: Bool, tracker: Tracker)
    func trackerViewModel(at indexPath: IndexPath) -> TrackerCellViewModel?
}

final class TrackersPresenter: TrackersPresenterProtocol {
    
    // MARK: - Public Properties
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
    
    var caregories: [String] {
        service.getAllCategories()
    }
    
    var isEmpty: Bool {
        service.numberOfSections == 0
    }
    
    var selectedFilter: String?
    
    weak var view: TrackersViewControllerProtocol?
    
    // MARK: - Private Properties
    private let service = TrackerService()
    
    // MARK: - Initializers
    init() {
        service.delegate = self
    }
    
    // MARK: - Public Methods
    func addTracker(_ tracker: Tracker, at category: String) {
        do {
            try service.addTracker(tracker, at: category)
        } catch {
            print(error)
        }
    }
    
    func saveTracker(_ tracker: Tracker, at category: String) {
        do {
            try service.saveTracker(tracker, at: category)
        } catch {
            print(error)
        }
    }
    
    func deleteTracker(_ tracker: Tracker) {
        do {
            try service.deleteTracker(tracker)
        } catch {
            print(error)
        }
    }
    
    func updateCategories() {
        service.fetch(search: search, date: currentDate)
        view?.updateView()
    }
    
    func updatePinned() {
        service.fetchPinned()
    }

    func pinTracker(tracker: Tracker) {
        do {
            try service.pin(!tracker.isPinned, tracker: tracker)
        } catch {
            print(error)
        }
    }
    
    func completeTracker(_ complete: Bool, tracker: Tracker) {
        do {
            if complete {
                try service.addToCompletedTrackers(tracker: tracker, date: currentDate)
            } else {
                try service.removeFromCompletedTrackers(tracker: tracker, date: currentDate)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func isCompletedTracker(_ tracker: Tracker) -> Bool {
        guard let completedTracker = service.getTrackerRecord(tracker: tracker, date: currentDate) else { return false }
        guard let currentDate = currentDate.onlyDate else { return false }
        if (completedTracker.id == tracker.id && completedTracker.date == currentDate ) {
            return true
        } else {
            print("Ошибка в isCompletedTracker")
            return false
        }
    }
    
    func countRecordsTracker(_ tracker: Tracker) -> Int {
        service.getTrackersNumber(tracker: tracker)
    }
    
    func categoryName(section: Int) -> String {
        service.categoryName(at: section)
    }
    
    func numberOfSections() -> Int? {
        view?.setupEmptyScreen()
        return service.numberOfSections
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        service.numberOfRowsInSection(section)
    }
    
    func trackerViewModel(at indexPath: IndexPath) -> TrackerCellViewModel? {
        guard let tracker = service.tracker(at: indexPath) else { return nil }
        return TrackerCellViewModel(tracker: tracker, isCompleted: isCompletedTracker(tracker), daysCounter: countRecordsTracker(tracker), isComplitionEnable: currentDate <= Date())
    }
}

// MARK: - TrackerServiceDelegate
extension TrackersPresenter: TrackerServiceDelegate {
    
    func didUpdate() {
        guard let view else { return }
        view.trackersCollectionView.reloadData()
    }
}
