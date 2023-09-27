//
//  NewTrackerPresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 10.07.2023.
//

import UIKit

protocol NewTrackerPresenterProtocol {
    var state: NewTrackerPresenter.ScreenState { get }
    var view: NewTrackerViewControllerProtocol? { get }
    var trackerName: String? { get set }
    var subtitleForCategory: String { get set }
    var type: TrackerType { get set }
    var selectedCategory: String? { get set }
    var schedule: [Int] { get set }
    var isValidForm: Bool { get }
    var sheduleString: String { get }
    var emoji: String? { get set }
    var color: UIColor? { get set }
    var pageTitle: String { get }
    var daysCounter: Int? { get }
    func saveTracker()
}

protocol NewHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, at category: String)
    func saveTracker(_ tracker: Tracker, at category: String)
}

final class NewTrackerPresenter: NewTrackerPresenterProtocol {
    
    enum ScreenState {
        case new
        case edit(tracker: Tracker, category: String, daysCounter: Int)
    }
    
    // MARK: - Public Properties
    weak var delegate: NewHabitDelegate?
    weak var view: NewTrackerViewControllerProtocol?
    let state: ScreenState
    var trackerId: UUID = UUID()
    var daysCounter: Int?
    var trackerName: String?
    var subtitleForCategory: String = ""
    var selectedCategory: String?
    var emoji: String?
    var color: UIColor?
    var type: TrackerType
    var schedule: [Int] = []
    var isValidForm: Bool {
        switch type {
        case .habit:
            return selectedCategory != nil && trackerName != nil && !schedule.isEmpty && emoji != nil && color != nil
        case .unregularEvent:
            return selectedCategory != nil && trackerName != nil && emoji != nil && color != nil
        }
    }
    var sheduleString: String {
        if schedule.count == FormatterDays.weekdays.count {
            return "timetable.subtitle".localized
        } else {
            return schedule.map { FormatterDays.shortWeekday(at: $0)}.joined(separator: ", ")
        }
    }
    var pageTitle: String {
        switch state {
        case .new:
            switch type {
            case .habit:
                return "new.habit".localized
            case .unregularEvent:
                return "new.unregular.event".localized
            }
        case .edit:
            switch type {
            case .habit:
                return "edit.habit".localized
            case .unregularEvent:
                return "edit.unregular.event".localized
            }
        }
    }
    
    // MARK: - Private Properties
    private var categories: [String]
    
    // MARK: - Initializers
    init(state: ScreenState, type: TrackerType, categories: [String]) {
        self.state = state
        self.type = type
        self.categories = categories
        
        if case .edit(let tracker, let category, let daysCounter) = state {
            self.trackerId = tracker.id
            self.trackerName = tracker.name
            self.schedule = tracker.schedule
            self.color = tracker.color
            self.emoji = tracker.emoji
            self.selectedCategory = category
            self.daysCounter = daysCounter
        }
    }
    
    // MARK: - Public Methods
    func saveTracker() {
        guard let name = trackerName,
              let selectedCategory,
              let emoji,
              let color
        else { return }
        let newTracker = Tracker(id: trackerId, name: name, color: color, emoji: emoji, schedule: schedule)
        switch state {
        case .new:
            delegate?.didCreateTracker(newTracker, at: selectedCategory)
        case .edit:
            delegate?.saveTracker(newTracker, at: selectedCategory)
        }
    }
}
