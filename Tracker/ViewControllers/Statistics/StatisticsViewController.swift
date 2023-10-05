//
//  StatisticsViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 17.06.2023.
//

import UIKit

protocol StatisticsViewControllerProtocol: AnyObject {
    var presenter: StatisticsPresenterProtocol? { get }
    func setupEmptyScreen()
}

final class StatisticsViewController: UIViewController, StatisticsViewControllerProtocol {
    
    // MARK: - Enums
    private enum Contstant {
        static let statisticsCellIdentifier = "statisticsCell"
    }
    
    private enum StatisticsType: Int, CaseIterable {
        case completedTrackers
    }
    
    // MARK: - Public Properties
    var presenter: StatisticsPresenterProtocol?
    
    // MARK: - Private Properties
    private var analytics: AnalyticsService = AnalyticsService()

    private lazy var statisticsTableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .none
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .clear
        tableView.isScrollEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        tableView.layer.cornerRadius = 16
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: Contstant.statisticsCellIdentifier)
        return tableView
    }()
    
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyScreenSmileCrying")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "statistics.empty.screen.label".localized
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenText)
        
        NSLayoutConstraint.activate([
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            emptyScreenText.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenText.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        statisticsTableView.reloadData()
        analytics.report(event: "open", params: ["screen":"statistics_screen"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analytics.report(event: "close", params: ["screen":"statistics_screen"])
    }
    
    // MARK: - Public Methods
    func setupEmptyScreen() {
            let emptyStats = StatisticsType.allCases.count <= 0
            let zeroStats = presenter?.completedTrackerCount == 0
            let isEmpty = !emptyStats && zeroStats
            emptyScreenView.isHidden = !isEmpty
            statisticsTableView.isHidden = isEmpty
        }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.topItem?.title = "statistics".localized
            navigationBar.prefersLargeTitles = true
            navigationBar.topItem?.largeTitleDisplayMode = .always
        }
    }
    
    private func setupScreen() {
        self.tabBarController?.delegate = self
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        addSubviews()
        contstraintSubviews()
        presenter?.getAllTrackersStat()
    }
    
    private func addSubviews() {
        view.addSubview(statisticsTableView)
        view.addSubview(emptyScreenView)
    }
    
    private func contstraintSubviews() {
        NSLayoutConstraint.activate([
            
            statisticsTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statisticsTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            statisticsTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            statisticsTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setDataToCell(_ name: String, _ statisticsNumber: String) {
        guard let cell = statisticsTableView.dequeueReusableCell(withIdentifier: Contstant.statisticsCellIdentifier) as? StatisticsCell
        else { return }
        cell.statisticsNumber = statisticsNumber
        cell.statisticsName = name
    }
}

extension StatisticsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let number = StatisticsType.allCases.count
        return number
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Contstant.statisticsCellIdentifier) as? StatisticsCell,
              let presenter,
              let cellType = StatisticsType(rawValue: indexPath.row)
        else { return UITableViewCell() }
        
        switch cellType {
        case .completedTrackers:
            cell.statisticsName = "completed.trackers".localized
            cell.statisticsNumber = "\(presenter.completedTrackerCount ?? 0)"
        }
        return cell
    }
}

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

extension StatisticsViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        presenter?.getAllTrackersStat()
    }
}
