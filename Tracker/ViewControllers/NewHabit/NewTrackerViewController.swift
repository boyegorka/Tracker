//
//  NewTrackerViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 28.06.2023.
//

import UIKit

protocol NewTrackerViewControllerProtocol: AnyObject {
    var presenter: NewTrackerPresenterProtocol? { get }
}

final class NewTrackerViewController: UIViewController, NewTrackerViewControllerProtocol {
    
    // MARK: - Enums
    enum Constant {
        static let daysCounterIdentifier = "daysCounter"
        static let textFieldCellIdentifier = "TextFieldCell"
        static let planningCellIdentifier = "PlaningCell"
        static let emojiCellIdentifier = "EmojiCell"
        static let colorCellIdentifier = "ColorCell"
    }
    
    enum Section: Int, CaseIterable {
        case daysCounter
        case textField
        case planning
        case emoji
        case color
        
        enum Row {
            case daysCounter
            case textField
            case category
            case schedule
            case emoji
            case color
        }
    }
    
    // MARK: - Public Properties
    var presenter: NewTrackerPresenterProtocol?
    
    var sections: [Section] {
        switch presenter?.state {
        case .new:
            return [.textField, .planning, .emoji, .color]
        case .edit:
            return [.daysCounter, .textField, .planning, .emoji, .color]
        case nil:
            return []
        }
    }
    
    // MARK: - Private Properties
    private let emojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱", "😇", "😡", "🥶", "🤔", "🙌", "🍔", "🥦", "🏓", "🥇", "🎸", "🏝️", "😪"]
    private let colors: [UIColor] = [.ypSelection1, .ypSelection2, .ypSelection3, .ypSelection4, .ypSelection5, .ypSelection6, .ypSelection7, .ypSelection8, .ypSelection9, .ypSelection10, .ypSelection11, .ypSelection12, .ypSelection13, .ypSelection14, .ypSelection15, .ypSelection16, .ypSelection17, .ypSelection18]
    
    private lazy var tableView: UITableView = {
        let planningTableView = UITableView(frame: .zero, style: .insetGrouped)
        planningTableView.translatesAutoresizingMaskIntoConstraints = false
        planningTableView.separatorStyle = .singleLine
        planningTableView.contentInsetAdjustmentBehavior = .never
        planningTableView.backgroundColor = .ypWhite
        planningTableView.isScrollEnabled = true
        planningTableView.showsVerticalScrollIndicator = false
        planningTableView.dataSource = self
        planningTableView.delegate = self
        planningTableView.allowsSelection = true
        return planningTableView
    }()
    
    private lazy var cancelButton: UIButton = {
        let cancelButton = UIButton()
        cancelButton.layer.cornerRadius = 16
        cancelButton.layer.borderWidth = 1
        cancelButton.layer.borderColor = UIColor.ypRed.cgColor
        cancelButton.backgroundColor = .ypWhite
        cancelButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        cancelButton.setTitleColor(.ypRed, for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelHabitCreation), for: .touchUpInside)
        return cancelButton
    }()
    
    private lazy var createButton: UIButton = {
        let createButton = UIButton()
        createButton.layer.cornerRadius = 16
        createButton.backgroundColor = .ypBlack
        createButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        createButton.setTitleColor(.ypWhite, for: .normal)
        createButton.addTarget(self, action: #selector(createHabit), for: .touchUpInside)
        return createButton
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let buttonsStackView = UIStackView()
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        buttonsStackView.axis = .horizontal
        buttonsStackView.spacing = 8
        buttonsStackView.distribution = .fillEqually
        return buttonsStackView
    }()
    
    // MARK: - View Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNewHabitScreen()
        tableView.reloadData()
    }
    
    // MARK: - Private Methods
    private func setupNewHabitScreen() {
        self.hideKeyboardOnTap()
        view.backgroundColor = .ypWhite
        addSubViews()
        tableView.register(DaysCounterCell.self, forCellReuseIdentifier: Constant.daysCounterIdentifier)
        tableView.register(TextFieldCell.self, forCellReuseIdentifier: Constant.textFieldCellIdentifier)
        tableView.register(TableViewCell.self, forCellReuseIdentifier: Constant.planningCellIdentifier)
        tableView.register(CollectionCell.self, forCellReuseIdentifier: Constant.emojiCellIdentifier)
        tableView.register(CollectionCell.self, forCellReuseIdentifier: Constant.colorCellIdentifier)
        
        setupNavigationBar()
        
        cancelButton.setTitle("cancel.button".localized, for: .normal)
        switch presenter?.state {
        case .edit:
            createButton.setTitle("save.button".localized, for: .normal)
        case .new:
            createButton.setTitle("create.button".localized, for: .normal)
        case .none:
            return
        }
        
        updateButtonState()
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.topItem?.title = presenter?.pageTitle
        }
    }
    
    private func addSubViews() {
        view.addSubview(tableView)
        view.addSubview(buttonsStackView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func rowsForSection(_ type: Section) -> [Section.Row] {
        switch type {
        case .daysCounter:
            return [.daysCounter]
        case .textField:
            return [.textField]
        case .planning:
            switch presenter?.type {
            case .habit:
                return [.category, .schedule]
            case .unregularEvent:
                return [.category]
            case .none:
                return []
            }
        case .emoji:
            return [.emoji]
        case .color:
            return [.color]
        }
    }
    
    private func daysCounterCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.daysCounterIdentifier) as? DaysCounterCell else { return UITableViewCell() }
        cell.text = presenter?.daysCounter?.localizeNumbers("NumberOfDays")
        return cell
    }
    
    private func textFieldCell(at indexPath: IndexPath, placeholder: String) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.textFieldCellIdentifier) as? TextFieldCell else { return UITableViewCell() }
        cell.text = presenter?.trackerName
        cell.placeholder = placeholder
        cell.delegate = self
        return cell
    }
    
    private func planningCell(at indexPath: IndexPath, title: String, subtitle: String?) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.planningCellIdentifier) as? TableViewCell else { return UITableViewCell() }
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = subtitle
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    private func emojiCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.emojiCellIdentifier) as? CollectionCell else { return UITableViewCell() }
        cell.delegate = self
        cell.type = .emoji(items: emojis)
        if let emoji = presenter?.emoji {
            cell.selectedIndex = emojis.firstIndex(of: emoji)
        }
        return cell
    }
    
    private func colorCell(at indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constant.colorCellIdentifier) as? CollectionCell else { return UITableViewCell() }
        cell.delegate = self
        cell.type = .color(items: colors)
        if let color = presenter?.color {
            cell.selectedIndex = colors.map{ $0.hexString }.firstIndex(of: color.hexString)
        }
        return cell
    }
    
    private func showTimeTable() {
        let vc = TimetableViewController()
        let presenter = TimetablePresenter(view: vc, selected: presenter?.schedule ?? [], delegate: self)
        vc.presenter = presenter
        presenter.view = vc
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = true
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
    }
    
    private func showCategory() {
        let viewModel = CategoriesViewModel(selectedCategory: presenter?.selectedCategory, delegate: self)
        let vc = CategoriesViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical
        vc.isModalInPresentation = false
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
    }
    
    private func updateButtonState() {
        createButton.isEnabled = presenter?.isValidForm ?? false
        createButton.backgroundColor = createButton.isEnabled ? .ypBlack : .ypGray
    }
    
    @objc
    private func cancelHabitCreation() {
        dismiss(animated: true)
    }
    
    @objc
    private func createHabit() {
        presenter?.saveTracker()
        dismiss(animated: true)
    }
}

// MARK: - TimetableDelegate
extension NewTrackerViewController: TimetableDelegate {
    
    func didSelect(weekdays: [Int]) {
        presenter?.schedule = weekdays
        updateButtonState()
        let section = Section.planning
        if let row = rowsForSection(section).firstIndex(of: Section.Row.schedule) {
            tableView.reloadRows(at: [IndexPath(row: row, section: section.rawValue)], with: .none)
        }
    }
}

// MARK: - CategoriesDelegate
extension NewTrackerViewController: CategoriesDelegate {
    func didSelectCategory(_ name: String) {
        presenter?.selectedCategory = name
        updateButtonState()
        let section = Section.planning
        if let row = rowsForSection(section).firstIndex(of: Section.Row.category) {
            tableView.reloadRows(at: [IndexPath(row: row, section: section.rawValue)], with: .none)
        }
    }
}

// MARK: - TextFieldCellDelegate
extension NewTrackerViewController: TextFieldCellDelegate {
    
    func didTextChange(text: String?) {
        guard let text else { return }
        if !text.isEmpty {
            presenter?.trackerName = text
        } else {
            presenter?.trackerName = nil
        }
        updateButtonState()
    }
}

// MARK: - CollectionCellDelegate
extension NewTrackerViewController: CollectionCellDelegate {
    
    func didEmojiSet(emoji: String?) {
        presenter?.emoji = emoji
        updateButtonState()
    }
    
    func didColorSet(color: UIColor?) {
        presenter?.color = color
        updateButtonState()
    }
}

// MARK: - UITableViewDataSource
extension NewTrackerViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsForSection(sections[section]).count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch rowsForSection(sections[indexPath.section])[indexPath.row] {
        case .daysCounter:
            return daysCounterCell(at: indexPath)
        case .textField:
            return textFieldCell(at: indexPath, placeholder: "Введите название трекера")
        case .category:
            return planningCell(at: indexPath, title: "Категория", subtitle: presenter?.selectedCategory)
        case .schedule:
            return planningCell(at: indexPath, title: "Расписание", subtitle: presenter?.sheduleString)
        case .emoji:
            return emojiCell(at: indexPath)
        case .color:
            return colorCell(at: indexPath)
        }
    }
}

// MARK: - UITableViewDelegate
extension NewTrackerViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch rowsForSection(sections[indexPath.section])[indexPath.row] {
        case .category:
            showCategory()
        case .schedule:
            showTimeTable()
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch rowsForSection(sections[indexPath.section])[indexPath.row] {
        case .daysCounter:
            switch presenter?.state {
            case .new:
                return 0
            case .edit:
                return 50
            case nil:
                return 0
            }
        case .textField, .category, .schedule:
            return 75
        case .emoji, .color:
            return UITableView.automaticDimension
        }
    }
}
