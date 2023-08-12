//
//  TableViewCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 04.07.2023.
//

import UIKit

final class TableViewCell: UITableViewCell {
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupSubviews()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setupSubviews() {
        backgroundColor = .ypBackground
        textLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        textLabel?.textColor = .ypBlack
        detailTextLabel?.font = .systemFont(ofSize: 17, weight: .regular)
        detailTextLabel?.textColor = .ypGray
        selectionStyle = .default
    }
}
