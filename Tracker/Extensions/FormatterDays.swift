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
}
