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
    func updateView()
}

final class TrackersViewController: UIViewController, TrackersViewControllerProtocol {
    
    private enum Contstants {
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
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.alwaysBounceVertical = true
        collectionView.contentInset = UIEdgeInsets(top: 24, left: Contstants.contentInsets, bottom: 24, right: Contstants.contentInsets)
        collectionView.register(TrackerCollectionViewCell.self, forCellWithReuseIdentifier: Contstants.cellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Contstants.headerIdentifier)
        return collectionView
    }()
    
    // MARK: - Private Properties
    private var alertPresenter: AlertPresenter = AlertPresenter()
    private var analytics: AnalyticsService = AnalyticsService()
    
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyScreenStar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "trackers.empty.screen.label".localized
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
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton()
        button.setTitle("filters".localized, for: .normal)
        button.layer.cornerRadius = 16
        button.backgroundColor = .ypBlue
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(pushFiltersViewController), for: .touchUpInside)
        return button
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter?.updateCategories()
        presenter?.updatePinned()
        setupTrackersScreen()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        analytics.report(event: "open", params: ["screen":"trackers_screen"])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        analytics.report(event: "close", params: ["screen":"trackers_screen"])
    }
    
    // MARK: - Public Methods
    func setupEmptyScreen() {
        let isSearch = presenter?.search.isEmpty ?? true
        let isEmpty = presenter?.isEmpty ?? true
        emptyScreenImage.image = isSearch ? UIImage(named: "EmptyScreenStar") : UIImage(named: "EmptyScreenSmileThinking")
        emptyScreenText.text = isSearch ? "trackers.empty.screen.label".localized : "nothing.found".localized
        emptyScreenView.isHidden = !isEmpty
        trackersCollectionView.isHidden = isEmpty
        filtersButton.isHidden = isEmpty
    }
    
    func updateView() {
        trackersCollectionView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else { return }
        
        let leftButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(pushTrackerTypeViewController))
        leftButton.tintColor = .ypBlack
        navigationBar.topItem?.setLeftBarButton(leftButton, animated: true)
        
        navigationBar.topItem?.title = "trackers".localized
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
        alertPresenter.viewController = self
    }
    
    private func addSubviews() {
        view.addSubview(trackersCollectionView)
        view.addSubview(emptyScreenView)
        view.addSubview(filtersButton)
    }
    
    private func contstraintSubviews() {
        NSLayoutConstraint.activate([
            trackersCollectionView.topAnchor.constraint(equalTo: view.topAnchor),
            trackersCollectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            trackersCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            trackersCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            filtersButton.topAnchor.constraint(greaterThanOrEqualTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
        ])
    }
    
    private func showNewTracker(state: NewTrackerPresenter.ScreenState, type: TrackerType) {
        let vc = NewTrackerViewController()
        let presenter = NewTrackerPresenter(state: state, type: type, categories: presenter?.caregories ?? [])
        
        vc.presenter = presenter
        presenter.view = vc
        
        presenter.delegate = self
        
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = true
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
    }
    
    private func editTracker(_ tracker: Tracker, indexPath: IndexPath) {
        guard let viewModel = presenter?.trackerViewModel(at: indexPath),
              let category = presenter?.categoryName(section: indexPath.section)
        else { return }
        let state = NewTrackerPresenter.ScreenState.edit(tracker: tracker, category: category, daysCounter: viewModel.daysCounter)
        showNewTracker(state: state, type: viewModel.tracker.type)
    }
    
    private func pinTracker(_ tracker: Tracker) {
        presenter?.pinTracker(tracker: tracker)
    }
    
    @objc
    private func pushFiltersViewController() {
        let vc = FiltersViewController()
        let presenter = FiltersPresenter(selectedFilter: presenter?.selectedFilter, delegate: self)
        
        vc.presenter = presenter
        presenter.view = vc
        
        vc.modalTransitionStyle = .coverVertical
        vc.modalPresentationStyle = .formSheet
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
        analytics.report(event: "click", params: ["screen":"trackers_screen", "item":"filters"])
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
        analytics.report(event: "click", params: ["screen":"trackers_screen", "item":"add_track"])
    }
    
    @objc
    private func setDateForTrackers(_ sender: UIDatePicker) {
        presenter?.currentDate = sender.date
    }
}

// MARK: - TrackerTypeDelegate
extension TrackersViewController: TrackerTypeDelegate {
    
    func didSelectType(_ type: TrackerType) {
        showNewTracker(state: .new, type: type)
    }
}

// MARK: - NewHabitDelegate
extension TrackersViewController: NewHabitDelegate {
    
    func saveTracker(_ tracker: Tracker, at category: String) {
        presenter?.saveTracker(tracker, at: category)
    }
    
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
        view.title.text = presenter?.categoryName(section: indexPath.section)
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemsAt indexPaths: [IndexPath], point: CGPoint) -> UIContextMenuConfiguration? {
        
        guard !indexPaths.isEmpty,
              let tracker = presenter?.trackerViewModel(at: indexPaths[0])?.tracker else { return nil }
        
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { (action) -> UIMenu? in
            
            let pin = UIAction(title: tracker.isPinned ? "unpin".localized : "pin".localized,
                               image: UIImage(systemName: "pin"),
                               identifier: nil,
                               discoverabilityTitle: nil,
                               state: .off) { [weak self] (_) in
                guard let self = self else { return }
                self.pinTracker(tracker)
            }
            let edit = UIAction(title: "edit".localized,
                                image: UIImage(systemName: "square.and.pencil"),
                                identifier: nil,
                                discoverabilityTitle: nil,
                                state: .off) { [weak self] (_) in
                guard let self = self else { return }
                self.editTracker(tracker, indexPath: indexPaths[0])
                analytics.report(event: "click", params: ["screen":"trackers_screen", "item":"edit"])
            }
            let delete = UIAction(title: "delete".localized,
                                  image: UIImage(systemName: "trash"),
                                  identifier: nil,
                                  discoverabilityTitle: nil,
                                  attributes: .destructive,
                                  state: .off) { [weak self] (_) in
                guard let self = self else { return }
                
                let viewModel = AlertModel(alertStyle: .actionSheet, title: "Уверены что хотите удалить трекер?", message: nil, buttonText: "Удалить") { [weak self] in
                    guard let self = self else { return }
                    self.presenter?.deleteTracker(tracker)
                }
                self.alertPresenter.show(result: viewModel)
                analytics.report(event: "click", params: ["screen":"trackers_screen", "item":"delete"])
            }
            
            return UIMenu(title: "", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [pin,edit,delete])
            
        }
        return context
    }
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfiguration configuration: UIContextMenuConfiguration, highlightPreviewForItemAt indexPath: IndexPath) -> UITargetedPreview? {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? TrackerCollectionViewCell else { return nil }
        
        return UITargetedPreview(view: cell.rectangleView)
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
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        presenter?.search = ""
    }
}

extension TrackersViewController: FiltersDelegate {
    func didSelectFilter(_ name: String) {
        presenter?.selectedFilter = name
    }
}
