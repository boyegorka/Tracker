//
//  SupplementaryView.swift
//  Tracker
//
//  Created by Егор Свистушкин on 15.07.2023.
//

import UIKit

class SupplementaryView: UICollectionReusableView {
    
    // MARK: - Public Properties
    let title = UILabel()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(title)
        title.font = .systemFont(ofSize: 19, weight: .bold)
        title.textColor = .ypBlack
        title.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            title.topAnchor.constraint(equalTo: topAnchor),
            title.bottomAnchor.constraint(equalTo: bottomAnchor),
            title.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 12),
            title.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: 12)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
