//
//  NewCategoryViewController.swift
//  Tracker
//
//  Created by Егор Свистушкин on 05.09.2023.
//

import UIKit

protocol NewCategoryViewControllerProtocol: AnyObject {
    var viewModel: NewCategoryViewModelProtocol { get }
}

final class NewCategoryViewController: UIViewController, NewCategoryViewControllerProtocol {
    
    // MARK: - Public Properties
    var viewModel: NewCategoryViewModelProtocol
    
    // MARK: - Private Properties
    private lazy var newCategoryNameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .always
        textField.placeholder = "category.name.placeholder".localized
        textField.delegate = self
        return textField
    }()
    
    private lazy var readyButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 16
        button.setTitle("ready.button".localized, for: .normal)
        button.backgroundColor = .ypGray
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.ypWhite, for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(addNewCategory), for: .touchUpInside)
        return button
    }()
    
    private lazy var textFieldView: UIView = {
        var view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypBackground
        view.addSubview(newCategoryNameTextField)
        NSLayoutConstraint.activate([
            
            newCategoryNameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            newCategoryNameTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            newCategoryNameTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            newCategoryNameTextField.heightAnchor.constraint(equalToConstant: 30)
            
        ])
        
        return view
    }()
    
    // MARK: - View Life Cycles
    
    init(viewModel: NewCategoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScreen()
    }
    
    // MARK: - Private Methods
    private func setupScreen() {
        view.backgroundColor = .ypWhite
        self.hideKeyboardOnTap()
        addSubViews()
        contstraintSubviews()
        setupNavigationBar()
        bind()
    }
    
    private func addSubViews() {
        view.addSubview(readyButton)
        view.addSubview(textFieldView)
    }
    
    private func contstraintSubviews() {
        NSLayoutConstraint.activate([
            
            textFieldView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            textFieldView.heightAnchor.constraint(equalToConstant: 75),
            
            readyButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            readyButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            readyButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            readyButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            readyButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    private func setupNavigationBar() {
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.topItem?.title = "new.category".localized
        }
    }
    
    private func bind() {
        viewModel.bindIsValidForm { [weak self] value in
            guard let self else { return }
            readyButton.isEnabled = value
            readyButton.backgroundColor = readyButton.isEnabled ? .ypBlack : .ypGray
        }
    }
    
    @objc
    private func addNewCategory() throws {
        try viewModel.createNewCategory()
        dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
extension NewCategoryViewController: UITextFieldDelegate {
    
    // Может быть такое, что в симуляторе на мак будет пропадать последняя буква в поле ввода, на телефоне всё нормально - оно не работает только на симуляторе mac 2019
    // https://developer.apple.com/forums/thread/727715
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let text = textField.text, let textRange = Range(range, in: text) {
            viewModel.categoryName = text.replacingCharacters(in: textRange, with: string)
            return true
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
        return true
    }
}
