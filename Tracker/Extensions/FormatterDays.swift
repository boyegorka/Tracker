//
//  String+Extension.swift
//  Tracker
//
//  Created by Егор Свистушкин on 16.07.2023.
//

import Foundation

class FormatterDays {
    
    // MARK: - Public Properties
    static let weekdays = Calendar.current.weekdaySymbols
    
    // MARK: - Private Properties
    private static let dateFormatter = DateFormatter()
    
    // MARK: - Public Methods
    static func shortWeekday(at index: Int) -> String {
        dateFormatter.shortWeekdaySymbols[index]
    }
}

extension Date {
    
    // MARK: - Public Properties
    var weekdayIndex: Int {
        Calendar.current.component(.weekday, from: self) - 1
    }
    
    var onlyDate: Date? {
        get {
            let calender = Calendar.current
            var dateComponents = calender.dateComponents([.year, .month, .day], from: self)
            dateComponents.timeZone = NSTimeZone.system
            return calender.date(from: dateComponents)
        }
    }
}
