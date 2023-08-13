//
//  TimetablePresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 15.07.2023.
//

import Foundation

protocol TimetablePresenterProtocol {
    var view: TimetableViewControllerProtocol? { get }
    var selectedWeekdays: [Int] { get set }
    var weekdays: [String] { get }
    func done()
}

protocol TimetableDelegate: AnyObject {
    func didSelect(weekdays: [Int])
}

final class TimetablePresenter: TimetablePresenterProtocol {
    
    // MARK: - Public Properties
    weak var view: TimetableViewControllerProtocol?
    weak var delegate: TimetableDelegate?
    var selectedWeekdays: [Int]
    let weekdays = FormatterDays.weekdays
    
    // MARK: - Initializers
    init(view: TimetableViewControllerProtocol, selected: [Int], delegate: TimetableDelegate) {
        self.view = view
        self.delegate = delegate
        self.selectedWeekdays = selected
    }
    
    // MARK: - Public Methods
    func done() {
        delegate?.didSelect(weekdays: selectedWeekdays)
        print(selectedWeekdays)
    }
}
