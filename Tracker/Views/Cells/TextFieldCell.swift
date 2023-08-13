//
//  TextFieldCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 04.07.2023.
//

import UIKit

protocol TextFieldCellDelegate: AnyObject {
    func didTextChange(text: String?)
}

final class TextFieldCell: UITableViewCell {
    
    // MARK: - Public Properties
    weak var delegate: TextFieldCellDelegate?
    
    var placeholder: String? {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    
    // MARK: - Private Properties
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.clearButtonMode = .always
        textField.delegate = self
        return textField
    }()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        addSubviews()
        constraintSubviews()
        backgroundColor = .ypBackground
        selectionStyle = .none
    }
    
    private func addSubviews() {
        contentView.addSubview(textField)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            textField.centerYAnchor.constraint(equalTo: centerYAnchor),
            textField.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            textField.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
}

// MARK: - UITextFieldDelegate
extension TextFieldCell: UITextFieldDelegate {
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.didTextChange(text: textField.text)
    }
}
