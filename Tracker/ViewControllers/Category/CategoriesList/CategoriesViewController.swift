//
//  CategoriesViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 27.08.2023.
//

import UIKit

protocol CategoriesUpdateTableViewDelegate: AnyObject {
    func updateTableView()
}

final class CategoriesViewController: UIViewController {
    
    // MARK: - Enums
    enum Contstant {
        static let categoryCellIdentifier = "CategoryCell"
    }
    
    // MARK: - Public Properties
    private var viewModel: CategoriesViewModel!
    
    // MARK: - Private Properties
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
        tableView.register(TableViewCell.self, forCellReuseIdentifier: Contstant.categoryCellIdentifier)
        return tableView
    }()
    
    private lazy var addNewCategoryButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("Добавить категорию", for: .normal)
        button.backgroundColor = .ypBlack
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.isEnabled = true
        button.addTarget(self, action: #selector(showNewCategoryScreen), for: .touchUpInside)
        return button
    }()
    
    private lazy var emptyScreenImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "EmptyScreenStar")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var emptyScreenLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Привычки и события \n можно объединить по смыслу"
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        return label
    }()
    
    private lazy var emptyScreenView: UIView = {
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyScreenImage)
        view.addSubview(emptyScreenLabel)
        
        NSLayoutConstraint.activate([
            emptyScreenImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyScreenImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyScreenLabel.topAnchor.constraint(equalTo: emptyScreenImage.bottomAnchor, constant: 8),
            emptyScreenLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        return view
    }()
    
    
    // MARK: - View Life Cycles
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
        viewModel?.getCategories()
    }
    
    // MARK: - Private Methods
    private func setupScreen() {
        view.backgroundColor = .ypWhite
        addSubviews()
        contstraintSubviews()
        setupNavigationBar()
        bind()
    }
    
    private func addSubviews() {
        view.addSubview(categoriesTableView)
        view.addSubview(emptyScreenView)
        view.addSubview(addNewCategoryButton)
    }
    
    private func contstraintSubviews() {
        NSLayoutConstraint.activate([
            categoriesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            categoriesTableView.bottomAnchor.constraint(equalTo: addNewCategoryButton.topAnchor, constant: -24),
            categoriesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            categoriesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            addNewCategoryButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            addNewCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addNewCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addNewCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            addNewCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            
            emptyScreenView.topAnchor.constraint(equalTo: view.topAnchor),
            emptyScreenView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            emptyScreenView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            emptyScreenView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.topItem?.title = "Категория"
        }
    }
    
    private func bind() {
        guard let viewModel else { return }
        
        viewModel.$categories.bind { [weak self] _ in
            self?.categoriesTableView.reloadData()
        }
        
        viewModel.$isEmpty.bind { [weak self] value in
            self?.emptyScreenView.isHidden = !value
            self?.categoriesTableView.isHidden = value
        }
    }
    
    @objc
    private func showNewCategoryScreen() {
        let viewModel = NewCategoryViewModel(delegate: self)
        let vc = NewCategoryViewController(viewModel: viewModel)
        vc.modalPresentationStyle = .formSheet
        vc.modalTransitionStyle = .coverVertical
        let navigationController = UINavigationController(rootViewController: vc)
        self.present(navigationController, animated: true)
        
    }
    
    @objc
    private func updateCategoriesTableView() {
        categoriesTableView.reloadData()
    }
}

// MARK: - UITableViewDataSource
extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.categories.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Contstant.categoryCellIdentifier) as? TableViewCell
        else { return UITableViewCell() }
        
        let category = viewModel?.categories[indexPath.row]
        
        cell.tintColor = .ypBlue
        cell.backgroundColor = .ypBackground
        cell.textLabel?.text = category
        
        
        if category == viewModel?.selectedCategoryName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedCategory = viewModel?.selectedCategoryName,
           let index = viewModel?.categories.firstIndex(of: selectedCategory){
            let cell = tableView.cellForRow(at: IndexPath(row: index, section: 0) )
            cell?.accessoryType = .none
        }
        
        let cell = tableView.cellForRow(at: indexPath)
        
        guard let category = viewModel?.categories[indexPath.row] else { return }
        
        cell?.accessoryType = .checkmark
        
        viewModel?.delegate?.didSelectCategory(category)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        self.dismiss(animated: true)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.accessoryType = .none
    }
}

// MARK: - NewCategoryDelegate
extension CategoriesViewController: NewCategoryDelegate {
    func didCreateCategory() {
        viewModel?.getCategories()
    }
}
