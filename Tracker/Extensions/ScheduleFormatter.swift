//
//  ScheduleConverter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 06.08.2023.
//

import Foundation

class ScheduleConverter {
    
    func convertToString(array: [Int]) -> String {
        array.map { String($0) }.joined()
    }
    
    func convertToArray(string: String) -> [Int] {
        string.map { Int(String($0)) ?? 9 }
    }
}
