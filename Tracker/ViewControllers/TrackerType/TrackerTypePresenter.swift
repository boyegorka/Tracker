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
    
    weak var view: TrackerTypeViewControllerProtocol?
    var delegate: TrackerTypeDelegate?
    func selectType(_ type: TrackerType) {
        delegate?.didSelectType(type)
    }
}
