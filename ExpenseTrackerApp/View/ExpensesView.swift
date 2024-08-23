//
//  ExpensesView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI

struct ExpensesView: View {
    ///Agrupamentos de propriedades de gastos
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ], animation: .snappy) private var allExpenses: [Expense]
    
    @State private var groupedExpenses: [GroupedExpense] = []
    var body: some View {
        NavigationStack {
            List {
                
            }
            .navigationTitle("Expenses")
        
            // Nova categoria de adicionar button.
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
        }
    }
}

#Preview {
    ExpensesView()
}
