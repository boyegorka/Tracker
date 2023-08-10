//
//  String+Extension.swift
//  Tracker
//
//  Created by Егор Свистушкин on 16.07.2023.
//

import Foundation

class FormatterDays {
    
    private static let dateFormatter = DateFormatter()
    static let weekdays = Calendar.current.weekdaySymbols
    
    static func shortWeekday(at index: Int) -> String {
        dateFormatter.shortWeekdaySymbols[index]
    }
}

extension Date {
    
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
