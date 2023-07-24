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
    var selectedCategory: TrackerCategory? { get }
    var schedule: [Int] { get set }
    var isValidForm: Bool { get }
    var sheduleString: String { get }
    var categoryName: String? { get }
    var emoji: String? { get set }
    var color: UIColor? { get set }
    func createNewTracker()
}

protocol NewHabitDelegate {
    func didCreateTracker(_ tracker: Tracker, at category: TrackerCategory)
}

final class NewHabitPresenter: NewHabitPresenterProtocol {
    
    var delegate: NewHabitDelegate?
    var trackerName: String?
    var subtitleForCategory: String = ""
    var categories: [TrackerCategory]
    var selectedCategory: TrackerCategory? {
        didSet {
            
        }
    }
    var emoji: String? {
        didSet {
            print(emoji)
        }
    }
    var color: UIColor? {
        didSet {
            print(color)
        }
    }
    weak var view: NewHabitViewControllerProtocol?
    var type: TrackerType
    var schedule: [Int] = []
    var isValidForm: Bool {
        selectedCategory != nil && trackerName != nil && !schedule.isEmpty && emoji != nil && color != nil
    }
    var sheduleString: String {
        if schedule.count == FormatterDays.weekdays.count {
            return "Каждый день"
        } else {
            return schedule.map { FormatterDays.shortWeekday(at: $0)}.joined(separator: ", ")
        }
    }
    var categoryName: String? {
        selectedCategory?.name
    }
    
    init(type: TrackerType, categories: [TrackerCategory]) {
        self.type = type
        self.selectedCategory = categories.first
        self.categories = categories
    }
    
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
