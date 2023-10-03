//
//  StatisticsCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 28.09.2023.
//

import UIKit

final class StatisticsCell: UITableViewCell {
    
    // MARK: - Public Properties
    var statisticsNumber: String? {
        get { counterLabel.text }
        set { counterLabel.text = newValue }
    }
    
    var statisticsName: String? {
        get { nameLabel.text }
        set { nameLabel.text = newValue }
    }
    
    // MARK: - Private Properties
    private lazy var counterLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .ypBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        var label = UILabel()
        label.font = .systemFont(ofSize: 12, weight: .medium)
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
        contentView.addSubview(counterLabel)
        contentView.addSubview(nameLabel)
        
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            counterLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            counterLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -12),
            counterLabel.topAnchor.constraint(equalTo: topAnchor, constant: 12),
            counterLabel.bottomAnchor.constraint(equalTo: nameLabel.topAnchor, constant: -7),
            
            nameLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: -12),
            nameLabel.topAnchor.constraint(equalTo: counterLabel.bottomAnchor, constant: 7),
            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -12),
        ])
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        let insetBounds = bounds.insetBy(dx: 1, dy: 5)
        let borderPath = UIBezierPath(roundedRect: insetBounds, cornerRadius: 16)
        let borderLayer = CAShapeLayer()
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.ypSelection1.cgColor, UIColor.ypSelection9.cgColor, UIColor.ypSelection3.cgColor]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        layer.addSublayer(gradient)
        layer.cornerRadius = 16
        borderLayer.path = borderPath.cgPath
        borderLayer.fillColor = nil
        borderLayer.strokeColor = UIColor.black.cgColor
        gradient.frame = bounds.insetBy(dx: -1/3, dy: 2)
        gradient.mask = borderLayer
    }
}
