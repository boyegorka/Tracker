//
//  CollectionCell.swift
//  Tracker
//
//  Created by Егор Свистушкин on 21.07.2023.
//

import UIKit

protocol CollectionCellDelegate: AnyObject {
    func didEmojiSet(emoji: String?)
    func didColorSet(color: UIColor?)
}

final class CollectionCell: UITableViewCell {
    
    // MARK: - Enums
    enum CollectionCellType {
        case emoji(items: [String])
        case color(items: [UIColor?])
    }
    
    enum Contstants {
        static let colorCellIdentifier = "ColorsCollectionViewCell"
        static let emojiCellIdentifier = "EmojisCollectionViewCell"
        static let headerIdentifier = "EmojisCellHeader"
        static let contentInsets: CGFloat = 16
        static let spacing: CGFloat = 0
        static let cellCountInline = 6
        static let headerHeight: CGFloat = 30
        static let topInsetsSection: CGFloat = 16
    }
    
    // MARK: - Public Properties
    weak var delegate: CollectionCellDelegate?
    
    var selectedIndex: Int? {
        didSet {
            guard let selectedIndex else { return }
            collectionView.selectItem(at: IndexPath.init(row: selectedIndex, section: 0), animated: true, scrollPosition: .centeredVertically)
        }
    }
    
    var type: CollectionCellType = .emoji(items: []) {
        didSet {
            collectionView.reloadData()
            updateSize()
        }
    }
    
    // MARK: - Private Properties
    private var cellHeight: NSLayoutConstraint?
    
    private var cellSize: CGFloat {
        let size = ((UIScreen.main.bounds.width - Contstants.contentInsets * 2) / CGFloat(Contstants.cellCountInline)).rounded(.down)
        return size - CGFloat(Contstants.cellCountInline)
    }
    
    private lazy var collectionView: ResizableCollectionView = {
        let collectionView = ResizableCollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .ypWhite
        collectionView.showsVerticalScrollIndicator = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.allowsSelection = true
        collectionView.allowsMultipleSelection = false
        collectionView.register(EmojisCollectionViewCell.self, forCellWithReuseIdentifier: Contstants.emojiCellIdentifier)
        collectionView.register(ColorsCollectionViewCell.self, forCellWithReuseIdentifier: Contstants.colorCellIdentifier)
        collectionView.register(SupplementaryView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: Contstants.headerIdentifier)
        return collectionView
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
    
    // MARK: - View Life Cycles
    override func layoutSubviews() {
        super.layoutSubviews()
        updateSize()
    }
    
    // MARK: - Private Methods
    private func updateSize() {
        collectionView.layoutIfNeeded()
    }
    
    private func setupSubviews() {
        addSubviews()
        constraintSubviews()
        backgroundColor = .ypWhite
        selectionStyle = .none
    }
    
    private func addSubviews() {
        contentView.addSubview(collectionView)
    }
    
    private func constraintSubviews() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
    }
}

// MARK: - UICollectionViewDataSource
extension CollectionCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch type {
        case .emoji(let items):
            return items.count
        case .color(let items):
            return items.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        switch type {
            
        case .emoji(let items):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Contstants.emojiCellIdentifier, for: indexPath) as? EmojisCollectionViewCell else { return UICollectionViewCell() }
            cell.emoji = items[indexPath.row]
            return cell
        case .color(let items):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Contstants.colorCellIdentifier, for: indexPath) as? ColorsCollectionViewCell else { return UICollectionViewCell() }
            cell.color = items[indexPath.row]
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate
extension CollectionCell: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: Contstants.headerIdentifier, for: indexPath) as? SupplementaryView else { return UICollectionReusableView() }
        
        switch type {
            
        case .emoji:
            view.title.text = "emoji".localized
        case .color:
            view.title.text = "color".localized
        }
        return view
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        switch type {
        case .emoji:
            guard let cell = collectionView.cellForItem(at: indexPath) as? EmojisCollectionViewCell else { return }
            delegate?.didEmojiSet(emoji: cell.emoji)
        case .color:
            guard let cell = collectionView.cellForItem(at: indexPath) as? ColorsCollectionViewCell else { return }
            delegate?.didColorSet(color: cell.color)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CollectionCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: cellSize, height: cellSize)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return Contstants.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return Contstants.spacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: Contstants.headerHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: Contstants.topInsetsSection, left: 0, bottom: 0, right: 0)
    }
}
