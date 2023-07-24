//
//  EmojisCollectionViewCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 21.07.2023.
//

import UIKit

class EmojisCollectionViewCell: UICollectionViewCell {
    
    var emoji: String? {
        didSet {
            emojiLabel.text = emoji
        }
    }
    
    private var emojiLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 32, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var emojiBackground: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.backgroundColor = .ypLightGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        addSubviews()
        constraintSubviews()
        backgroundColor = .ypWhite
        
        self.selectedBackgroundView = emojiBackground
    }
    
    private func addSubviews() {
        contentView.addSubview(emojiLabel)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            emojiLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            emojiLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
}
