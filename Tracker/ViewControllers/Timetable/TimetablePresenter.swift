//
//  TimetablePresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 15.07.2023.
//

import Foundation

protocol TimetablePresenterProtocol {
    var view: TimetableViewControllerProtocol { get }
    var selectedWeekdays: [Int] { get set }
    var weekdays: [String] { get }
    func done()
}

protocol TimetableDelegate {
    func didSelect(weekdays: [Int])
}

class TimetablePresenter: TimetablePresenterProtocol {
    
    var view: TimetableViewControllerProtocol
    var delegate: TimetableDelegate
    
    var selectedWeekdays: [Int]
    let weekdays = FormatterDays.weekdays
    
    init(view: TimetableViewControllerProtocol, selected: [Int], delegate: TimetableDelegate) {
        self.view = view
        self.delegate = delegate
        self.selectedWeekdays = selected
    }
    
    func done() {
        delegate.didSelect(weekdays: selectedWeekdays)
        print(selectedWeekdays)
    }
}
