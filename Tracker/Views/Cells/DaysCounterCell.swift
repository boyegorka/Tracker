//
//  DaysCounterCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 26.09.2023.
//

import UIKit

class DaysCounterCell: UITableViewCell {
    
    // MARK: - Public Properties
    var text: String? {
        get { daysCounterLabel.text }
        set { daysCounterLabel.text = newValue }
    }
    
    // MARK: - Private Properties
    private lazy var daysCounterLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
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
        backgroundColor = .ypWhite
        selectionStyle = .none
    }
    
    private func addSubviews() {
        contentView.addSubview(daysCounterLabel)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            daysCounterLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            daysCounterLabel.centerXAnchor.constraint(equalTo: centerXAnchor)
        ])
    }
}
