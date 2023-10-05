//
//  FiltersViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 04.10.2023.
//

import UIKit

protocol FiltersViewControllerProtocol: AnyObject {
    var presenter: FiltersPresenterProtocol? { get }
}

final class FiltersViewController: UIViewController, FiltersViewControllerProtocol {
    
    private enum Contstants {
        static let filterCellIdentifier = "filterCell"
    }
    
    enum Filters: Int, CaseIterable {
        case allTrackers
        case trackersForToday
        case completedTrackers
        case uncompletedTrackers
    }
    
    var presenter: FiltersPresenterProtocol?
    
    private lazy var categoriesTableView: UITableView = {
        var tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.separatorStyle = .singleLine
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .ypWhite
        tableView.isScrollEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.layer.cornerRadius = 16
        tableView.register(TableViewCell.self, forCellReuseIdentifier: Contstants.filterCellIdentifier)
        return tableView
    }()
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    // MARK: - Private Methods
    private func setupScreen() {
        view.backgroundColor = .ypWhite
        addSubviews()
        contstraintSubviews()
        setupNavigationBar()
    }
    
    private func addSubviews() {
        view.addSubview(categoriesTableView)
    }
    
    private func contstraintSubviews() {
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.topItem?.title = "filters".localized
        }
    }
}

// MARK: - UITableViewDataSource
extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Filters.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Contstants.filterCellIdentifier) as? TableViewCell
        else { return UITableViewCell() }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}
