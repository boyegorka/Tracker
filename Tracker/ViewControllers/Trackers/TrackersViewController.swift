//
//  TrackersViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 25.05.2023.
//

import UIKit

protocol TrackersViewControllerProtocol: AnyObject {
    var presenter: TrackersPresenterProtocol? { get }
    var trackersCollectionView: UICollectionView { get }
    func setupEmptyScreen()
}

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    
    enum Contstants {
        static let cellIdentifier = "TrackerCell"
        static let headerIdentifier = "TrackersHeader"
        static let contentInsets: CGFloat = 16
        static let spacing: CGFloat = 9
    }
    
    // MARK: - Public Properties
    var presenter: TrackersPresenterProtocol?
    
    lazy var trackersCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.contentInset = UIEdgeInsets(top: 24, left: Contstants.contentInsets, bottom: 24, right: Contstants.contentInsets)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: Contstants.cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Contstants.headerIdentifier)
        return collectionView
    }()
    
    // MARK: - Private Properties
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyScreenStar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Что будем отслеживать?"
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
    
    private lazy var datePickerButton: UIBarButtonItem = {
        
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .compact
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(setDateForTrackers), for: .valueChanged)
        let dateButton = UIBarButtonItem(customView: datePicker)
        
        return dateButton
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.updateCategories()
        setupTrackersScreen()
    }
    
    // MARK: - Public Methods
    func setupEmptyScreen() {
        let isSearch = presenter?.search.isEmpty ?? true
        let isEmpty = presenter?.isEmpty ?? true
        emptyScreenImage.image = isSearch ? UIImage(named: "EmptyScreenStar") : UIImage(named: "EmptyScreenSmileThinking")
        emptyScreenText.text = isSearch ? "Что будем отслеживать?" : "Ничего не найдено"
        emptyScreenView.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushTrackerTypeViewController))
        leftButton.tintColor = .ypBlack
        navigationBar.topItem?.setLeftBarButton(leftButton, animated: true)
        
        navigationBar.topItem?.title = "Трекеры"
        navigationBar.prefersLargeTitles = true
        navigationBar.topItem?.largeTitleDisplayMode = .always
        
        let searchController = UISearchController(searchResultsController: nil)
        searchController.searchBar.delegate = self
        navigationBar.topItem?.searchController = searchController
        
        navigationBar.topItem?.setRightBarButton(datePickerButton, animated: true)
    }
    
    private func setupTrackersScreen() {
        view.backgroundColor = .ypWhite
        setupNavigationBar()
        addSubviews()
        contstraintSubviews()
    }
    
    private func addSubviews() {
        view.addSubview(trackersCollectionView)
        view.addSubview(emptyScreenView)
    }
    
    private func contstraintSubviews() {
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    @objc
    private func pushTrackerTypeViewController() {
        let vc = TrackerTypeViewController()
        let presenter = TrackerTypePresenter()
        
        vc.presenter = presenter
        presenter.view = vc
        
        presenter.delegate = self
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .formSheet
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
    }
    
    @objc
    private func setDateForTrackers(_ sender: UIDatePicker) {
        presenter?.currentDate = sender.date
        trackersCollectionView.reloadData()
    }
}

// MARK: - TrackerTypeDelegate
extension TrackersViewController: TrackerTypeDelegate {
    
    func didSelectType(_ type: TrackerType) {
        let vc = NewTrackerViewController()
        let presenter = NewTrackerPresenter(type: type, categories: presenter?.caregories ?? [])
        
        vc.presenter = presenter
        presenter.view = vc
        
        presenter.delegate = self
        
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = true
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
    }
}

// MARK: - NewHabitDelegate
extension TrackersViewController: NewHabitDelegate {
    
    func didCreateTracker(_ tracker: Tracker, at category: String) {
        presenter?.addTracker(tracker, at: category)
    }
}

// MARK: - TrackerCollectionViewCellDelegate
extension TrackersViewController: TrackerCollectionViewCellDelegate {
    
    func didComplete(_ complete: Bool, tracker: Tracker) {
        presenter?.completeTracker(complete, tracker: tracker)
    }
}

// MARK: - UICollectionViewDataSource
extension TrackersViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        presenter?.numberOfSections() ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        presenter?.numberOfItemsInSection(section: section) ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Contstants.cellIdentifier, for: indexPath) as? TrackerCollectionViewCell,
              let presenter
        else { return UICollectionViewCell() }
        
        cell.viewModel = presenter.trackerViewModel(at: indexPath)
        cell.delegate = self
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension TrackersViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Contstants.headerIdentifier, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        view.title.text = presenter?.titleInSection(section: indexPath.section)
        return view
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.bounds.width - Contstants.contentInsets * 2 - Contstants.spacing) / 2 , height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return Contstants.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 0, bottom: 16, right: 0)
    }
}

// MARK: - UISearchBarDelegate
extension TrackersViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        presenter?.search = searchText
        trackersCollectionView.reloadData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.search = ""
        trackersCollectionView.reloadData()
    }
}
