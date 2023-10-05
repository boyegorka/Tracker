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

protocol CategoriesViewModelProtocol {
    var selectedCategoryName: String? { get }
    var categories: [String] { get set }
    var isEmpty: Bool { get }
    func didSelectCategory(_ name: String)
    func getCategories()
    func bindCategories(execute: @escaping ([String]) -> ())
    func bindIsEmpty(execute: @escaping (Bool) -> ())
}

final class CategoriesViewModel: CategoriesViewModelProtocol {
    
    // MARK: - Public Properties
    var selectedCategoryName: String?
    weak var delegate: CategoriesDelegate?
    
    // MARK: - Private Properties
    private let service = TrackerService()
    @Observable var categories: [String] = []
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
    
    func didSelectCategory(_ name: String) {
        delegate?.didSelectCategory(name)
    }
    
    func bindCategories(execute: @escaping ([String]) -> ()) {
        $categories.bind { execute($0) }
    }
    
    func bindIsEmpty(execute: @escaping (Bool) -> ()) {
        $isEmpty.bind { execute($0) }
    }
}
