//
//  TrackerTests.swift
//  TrackerTests
//
//  Created by Егор Свистушкин on 28.09.2023.
//

import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    
    func testTrackerViewControllerDark() {
        let vc = TrackersViewController()
        
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .light)))
        assertSnapshot(matching: vc, as: .image(traits: .init(userInterfaceStyle: .dark)))
        
    }
}
