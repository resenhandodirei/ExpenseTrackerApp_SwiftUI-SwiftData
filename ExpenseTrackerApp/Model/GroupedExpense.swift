//
//  GroupedExpense.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI

struct GroupedExpense: Identifiable {
    var id: UUID = .init()
    var date: Date
    var expenses: [Expense]
}
