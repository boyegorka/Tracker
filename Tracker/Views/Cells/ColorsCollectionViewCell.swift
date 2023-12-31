//
//  ColorsCollectionViewCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 23.07.2023.
//

import UIKit

final class ColorsCollectionViewCell: UICollectionViewCell {
    
    // MARK: - Public Properties
    var color: UIColor? {
        didSet {
            colorView.backgroundColor = color
            colorBackground.layer.borderColor = color?.withAlphaComponent(alphaOfColor).cgColor
        }
    }
    
    // MARK: - Private Properties
    private let alphaOfColor: CGFloat = 0.3
    
    private var colorView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var colorBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.borderWidth = 3
        
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        addSubviews()
        constraintSubviews()
        backgroundColor = .ypWhite
        
        self.selectedBackgroundView = colorBackground
    }
    
    private func addSubviews() {
        contentView.addSubview(colorView)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            colorView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            colorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            colorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            colorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6),
        ])
    }
}
