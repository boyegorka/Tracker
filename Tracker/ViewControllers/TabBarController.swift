//
//  TabBarController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 16.06.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewControllers = [getTrackersViewController(), getStatisticViewController()]
    }
    
    private func getTrackersViewController() -> UINavigationController {
        let vc = TrackersViewController()
        let presenter = TrackersPresenter()
        presenter.view = vc
        vc.presenter = presenter
        
        let trackers = UINavigationController(rootViewController: vc)
        trackers.tabBarItem = UITabBarItem(title: "Трекеры", image: UIImage(systemName: "record.circle.fill"), selectedImage: nil)
        return trackers
    }
    
    private func getStatisticViewController() -> UINavigationController {
        let statistic = UINavigationController(rootViewController: StatisticsViewController())
        statistic.tabBarItem = UITabBarItem(title: "Статистика", image: UIImage(systemName: "hare.fill"), selectedImage: nil)
        return statistic
    }
}
