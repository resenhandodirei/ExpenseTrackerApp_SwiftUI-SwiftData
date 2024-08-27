//
//  Category.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI
import SwiftData

@Model

class Category {
    var categoryName: String
    
    // Categorias de expenses(gastos)
    @Relationship(deleteRule: .cascade, inverse: \Expense.category)
    
    var expenses: [Expense]? 
    
    init(categoryName: String) {
        self.categoryName = categoryName
    }
}
