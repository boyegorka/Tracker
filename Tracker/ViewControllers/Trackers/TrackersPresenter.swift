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
    func numberOfSections() -> Int?
    func numberOfItemsInSection(section: Int) -> Int
    func titleInSection(section: Int) -> String
    func updateCategories()
    func completeTracker(_ complete: Bool, tracker: Tracker)
    func trackerViewModel(at indexPath: IndexPath) -> TrackerCellViewModel
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
    
    func updateCategories() {
        service.updatePredicate(search: search, date: currentDate)
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
    
    func titleInSection(section: Int) -> String {
        service.categoryName(at: section)
    }
    
    func numberOfSections() -> Int? {
        view?.setupEmptyScreen()
        return service.numberOfSections
    }
    
    func numberOfItemsInSection(section: Int) -> Int {
        service.numberOfRowsInSection(section)
    }
    
    func trackerViewModel(at indexPath: IndexPath) -> TrackerCellViewModel {
        let tracker = service.tracker(at: indexPath)
        return TrackerCellViewModel(tracker: tracker, isCompleted: isCompletedTracker(tracker), daysCounter: countRecordsTracker(tracker), isComplitionEnable: currentDate <= Date())
    }
}

// MARK: - TrackerServiceDelegate
extension TrackersPresenter: TrackerServiceDelegate {
    
    func didUpdate(_ update: TrackerServiceUpdate) {
        guard let view else { return }
        
        let count = view.trackersCollectionView.numberOfSections
        let newSection: IndexSet = IndexSet(update.insertedIndexes.filter({$0.section >= count}).map{ $0.section })
        
        view.trackersCollectionView.performBatchUpdates {
            let insertedIndexPaths = update.insertedIndexes
            let deletedIndexPaths = update.deletedIndexes
            
            
            
            if !insertedIndexPaths.isEmpty {
                view.trackersCollectionView.insertSections(newSection)
                view.trackersCollectionView.insertItems(at: insertedIndexPaths)
            }
            if !deletedIndexPaths.isEmpty {
                view.trackersCollectionView.deleteItems(at: deletedIndexPaths)
            }
        }
        //view.trackersCollectionView.reloadData()
    }
}
