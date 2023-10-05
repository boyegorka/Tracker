//
//  FiltersPresenter.swift
//  Tracker
//
//  Created by Егор Свистушкин on 04.10.2023.
//

import Foundation

protocol FiltersDelegate: AnyObject {
    func didSelectFilter(_ name: String)
}

protocol FiltersPresenterProtocol {
    var view: FiltersViewControllerProtocol? { get set }
    var selectedCategory: String? { get set }
}

final class FiltersPresenter: FiltersPresenterProtocol {
    
    var selectedFilter: String?
    var selectedCategory: String?
    weak var view: FiltersViewControllerProtocol?
    weak var delegate: FiltersDelegate?

    init(selectedFilter: String?, delegate: FiltersDelegate) {
        self.selectedFilter = selectedFilter
        self.delegate = delegate
    }
    
}
