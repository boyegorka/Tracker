//
//  StatisticsPresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 28.09.2023.
//

import Foundation

protocol StatisticsPresenterProtocol {
    var view: StatisticsViewControllerProtocol? { get }
    var completedTrackerCount: Int? { get }
    func getAllTrackersStat()
}

final class StatisticsPresenter: StatisticsPresenterProtocol {
    
    // MARK: - Public Properties
    var view: StatisticsViewControllerProtocol?
    var completedTrackerCount: Int? {
        didSet {
            view?.setupEmptyScreen()
        }
    }
    
    // MARK: - Private Properties
    private var trackerService = TrackerService()
    
    // MARK: - Private Methods
    func getAllTrackersStat() {
        completedTrackerCount = trackerService.getAllTrackersRecordNumber()
    }
}
