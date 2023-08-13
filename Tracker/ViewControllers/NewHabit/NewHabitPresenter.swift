//
//  NewHabitPresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 10.07.2023.
//

import UIKit

protocol NewHabitPresenterProtocol {
    var view: NewHabitViewControllerProtocol? { get }
    var trackerName: String? { get set }
    var subtitleForCategory: String { get set }
    var type: TrackerType { get set }
    var selectedCategory: String? { get }
    var schedule: [Int] { get set }
    var isValidForm: Bool { get }
    var sheduleString: String { get }
    var emoji: String? { get set }
    var color: UIColor? { get set }
    var pageTitle: String { get }
    func createNewTracker()
}

protocol NewHabitDelegate: AnyObject {
    func didCreateTracker(_ tracker: Tracker, at category: String)
}

final class NewHabitPresenter: NewHabitPresenterProtocol {
    
    // MARK: - Public Properties
    weak var delegate: NewHabitDelegate?
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
            return "Каждый день"
        } else {
            return schedule.map { FormatterDays.shortWeekday(at: $0)}.joined(separator: ", ")
        }
    }
    var pageTitle: String {
        switch type {
        case .habit:
            return "Новая привычка"
        case .unregularEvent:
            return "Новое нерегулярное событие"
        }
    }
    
    weak var view: NewHabitViewControllerProtocol?
    
    // MARK: - Private Properties
    private var categories: [String]
    
    // MARK: - Initializers
    init(type: TrackerType, categories: [String]) {
        self.type = type
        self.selectedCategory = categories.first
        self.categories = categories
    }
    
    // MARK: - Public Methods
    func createNewTracker() {
        guard let name = trackerName,
              let selectedCategory,
              let emoji,
              let color
        else { return }
        let newTracker = Tracker(id: UUID(), name: name, color: color, emoji: emoji, schedule: schedule)
        delegate?.didCreateTracker(newTracker, at: selectedCategory)
    }
}
