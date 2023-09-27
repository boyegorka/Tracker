//
//  TabBarController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 16.06.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    // MARK: - Private Properties
    private var analytics: AnalyticsService = AnalyticsService()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewControllers = [getTrackersViewController(), getStatisticViewController()]
    }
    
    // MARK: - Private Methods
    private func getTrackersViewController() -> UINavigationController {
        let vc = TrackersViewController()
        let presenter = TrackersPresenter()
        presenter.view = vc
        vc.presenter = presenter
        
        let trackers = UINavigationController(rootViewController: vc)
        trackers.tabBarItem = UITabBarItem(title: "trackers".localized, image: UIImage(systemName: "record.circle.fill"), selectedImage: nil)
        analytics.report(event: "click", params: ["item":"open_trackers_screen"])
        return trackers
    }
    
    private func getStatisticViewController() -> UINavigationController {
        let statistic = UINavigationController(rootViewController: StatisticsViewController())
        statistic.tabBarItem = UITabBarItem(title: "statistics".localized, image: UIImage(systemName: "hare.fill"), selectedImage: nil)
        analytics.report(event: "click", params: ["item":"open_statistics_screen"])
        return statistic
    }
}
