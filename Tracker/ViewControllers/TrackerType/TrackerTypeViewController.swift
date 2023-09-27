//
//  TrackerTypeViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 17.06.2023.
//

import UIKit

protocol TrackerTypeViewControllerProtocol: AnyObject {
    var presenter: TrackerTypePresenterProtocol? { get }
}

final class TrackerTypeViewController: UIViewController, TrackerTypeViewControllerProtocol {
    
    // MARK: - Public Properties
    var presenter: TrackerTypePresenterProtocol?
    
    // MARK: - Private Properties
    private var analytics: AnalyticsService = AnalyticsService()
    
    private lazy var newHabitButton: UIButton = {
        let newHabitButton = UIButton()
        newHabitButton.layer.cornerRadius = 16
        newHabitButton.backgroundColor = .ypBlack
        newHabitButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        newHabitButton.setTitleColor(.ypWhite, for: .normal)
        newHabitButton.addTarget(self, action: #selector(pushNewHabitViewController), for: .touchUpInside)
        return newHabitButton
    }()
    
    private lazy var newUnregularEventButton: UIButton = {
        let newUnregularEventButton = UIButton()
        newUnregularEventButton.layer.cornerRadius = 16
        newUnregularEventButton.backgroundColor = .ypBlack
        newUnregularEventButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        newUnregularEventButton.setTitleColor(.ypWhite, for: .normal)
        newUnregularEventButton.addTarget(self, action: #selector(pushUnregularEventViewController), for: .touchUpInside)
        return newUnregularEventButton
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView()
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(newHabitButton)
        buttonsStackView.addArrangedSubview(newUnregularEventButton)
        buttonsStackView.axis = .vertical
        buttonsStackView.spacing = 16
        buttonsStackView.distribution = .fillEqually
        return buttonsStackView
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTrackerTypeScreen()
    }
    
    // MARK: - Private Methods
    private func setupTrackerTypeScreen() {
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        addSubViews()
        newHabitButton.setTitle("habit.button".localized, for: .normal)
        newUnregularEventButton.setTitle("unregular.event.button".localized, for: .normal)
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.topItem?.title = "tracker.creation".localized
        }
    }
    
    private func addSubViews() {
        view.addSubview(newHabitButton)
        view.addSubview(newUnregularEventButton)
        view.addSubview(buttonsStackView)
        NSLayoutConstraint.activate([
            buttonsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 136)
        ])
    }
    
    @objc
    private func pushNewHabitViewController(sender: UIButton) {
        dismiss(animated: true) {
            self.presenter?.selectType(.habit)
            self.analytics.report(event: "click", params: ["screen":"trackers_type_screen", "item":"open_new_habit_screen"])
        }
    }
    
    @objc
    private func pushUnregularEventViewController(sender: UIButton) {
        dismiss(animated: true) {
            self.presenter?.selectType(.unregularEvent)
            self.analytics.report(event: "click", params: ["screen":"trackers_type_screen", "item":"open_new_unregular_event_screen"])
        }
    }
}
