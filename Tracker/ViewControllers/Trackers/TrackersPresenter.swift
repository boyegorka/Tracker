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
    func addTracker(_ tracker: Tracker, at category: String)
    func saveTracker(_ tracker: Tracker, at category: String)
    func deleteTracker(_ indexPath: IndexPath)
    func numberOfSections() -> Int?
    func numberOfItemsInSection(section: Int) -> Int
    func categoryName(section: Int) -> String
    func updateCategories()
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
    
    func deleteTracker(_ indexPath: IndexPath) {
        do {
            try service.deleteTracker(at: indexPath)
        } catch {
            print(error)
        }
    }
    
    func updateCategories() {
        service.fetch(search: search, date: currentDate)
        view?.updateView()
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
    
    func didUpdate(_ update: TrackerServiceUpdate) {
        guard let view else { return }

        let count = view.trackersCollectionView.numberOfSections
        let newSections: IndexSet = IndexSet(update.insertedIndexes.filter({$0.section >= count}).map { $0.section })
        let toDeleteSections: IndexSet = IndexSet(update.deletedIndexes.filter({$0.section <= count}).map { $0.section })


        view.trackersCollectionView.performBatchUpdates {

            view.trackersCollectionView.insertSections(newSections)
            view.trackersCollectionView.deleteSections(toDeleteSections)

            view.trackersCollectionView.insertItems(at: update.insertedIndexes)
            view.trackersCollectionView.deleteItems(at: update.deletedIndexes)
            view.trackersCollectionView.reloadItems(at: update.updatedIndexes)
        }
    }
}
