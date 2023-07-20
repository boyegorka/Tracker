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
    var selectedCategory: TrackerCategory?
    var view: NewHabitViewControllerProtocol?
    var type: TrackerType
    var schedule: [Int] = []
    var isValidForm: Bool {
        selectedCategory != nil && trackerName != nil && !schedule.isEmpty
    }
    
    init(type: TrackerType, categories: [TrackerCategory]) {
        self.type = type
        self.selectedCategory = categories.first
        self.categories = categories
    }
    
    
    func createNewTracker() {
        guard let name = trackerName,
              let selectedCategory
        else { return }
        let newTracker = Tracker(id: UUID(), name: name, color: .ypSelection2 ?? .black, emoji: "🌺", schedule: schedule)
        delegate?.didCreateTracker(newTracker, at: selectedCategory)
    }
}
