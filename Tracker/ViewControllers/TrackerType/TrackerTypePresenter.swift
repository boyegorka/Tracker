//
//  TrackerTypePresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 10.07.2023.
//

import Foundation

protocol TrackerTypePresenterProtocol {
    var view: TrackerTypeViewControllerProtocol? { get set }
    func selectType(_ type: TrackerType)
}

protocol TrackerTypeDelegate {
    func didSelectType(_ type: TrackerType)
}

final class TrackerTypePresenter: TrackerTypePresenterProtocol {
    
    // MARK: - Public Properties
    var delegate: TrackerTypeDelegate?
    weak var view: TrackerTypeViewControllerProtocol?
    
    // MARK: - Public Methods
    func selectType(_ type: TrackerType) {
        delegate?.didSelectType(type)
    }
}
