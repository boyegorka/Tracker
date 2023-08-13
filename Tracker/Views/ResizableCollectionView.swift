//
//  ResizableCollectionView.swift
//  Tracker
//
//  Created by Егор Свистушкин on 23.07.2023.
//

import UIKit

class ResizableCollectionView: UICollectionView {
    
    // MARK: - Public Properties
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height + contentInset.top + contentInset.bottom)
    }
}
