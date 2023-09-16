//
//  CategoriesViewModel.swift
//  Tracker
//
//  Created by Егор Свистушкин on 03.09.2023.
//

import Foundation

protocol CategoriesDelegate: AnyObject {
    func didSelectCategory(_ name: String)
}

final class CategoriesViewModel {
    
    // MARK: - Public Properties
    var selectedCategoryName: String?
    weak var delegate: CategoriesDelegate?
    
    // MARK: - Private Properties
    private let service = TrackerService()
    @Observable private(set) var categories: [String] = []
    @Observable private(set) var isEmpty: Bool = true
    
    // MARK: - View Life Cycles
    init(selectedCategory: String?, delegate: CategoriesDelegate) {
        self.selectedCategoryName = selectedCategory
        self.delegate = delegate
    }
    
    // MARK: - Public Methods
    func getCategories() {
        categories = service.getAllCategories()
        isEmpty = categories.isEmpty
    }
}
