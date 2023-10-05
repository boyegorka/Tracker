//
//  TrackerModel.swift
//  Tracker
//
//  Created by Егор Свистушкин on 28.06.2023.
//

import UIKit

struct Tracker {
    let id: UUID
    let name: String
    let color: UIColor
    let emoji: String
    let schedule: [Int]
    let isPinned: Bool
}

extension Tracker {
    var type: TrackerType {
        schedule.isEmpty ? .unregularEvent : .habit
    }
}
