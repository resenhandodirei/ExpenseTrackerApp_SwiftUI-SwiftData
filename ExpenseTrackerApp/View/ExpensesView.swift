//
//  ExpensesView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    /// Agrupamentos de propriedades de gastos
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ], animation: .snappy) private var allExpenses: [Expense]
 
    @State private var groupedExpenses: [ExpenseGroup] = []
    @State private var addExpense: Bool = false

    var body: some View {
        NavigationStack {
            List {
                // Aqui você pode listar os grupos de despesas
            }
            .navigationTitle("Expenses")
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            // Nova categoria de adicionar button.
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        // Ação ao pressionar o botão de adicionar
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .onChange(of: allExpenses, initial: true) { oldValue, newValue in
                if groupedExpenses.isEmpty {
                    createGroupedExpenses(newValue)
                }
            }
        }
    }

    // Corrigindo a função para agrupar as despesas
    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = Dictionary(grouping: expenses) { expense in
                let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
                return dateComponents
            }

            // Sorting Dictionary in Descending Order
            let sortedDict = groupedDict.sorted {
                let calendar = Calendar.current // Declare o calendário aqui
                let date1 = calendar.date(from: $0.key) ?? Date()
                let date2 = calendar.date(from: $1.key) ?? Date()
                
                return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
            }

            await MainActor.run {
                groupedExpenses = sortedDict.compactMap { dict in
                    return ExpenseGroup(dateComponents: dict.key, expenses: dict.value)
                }
            }

            // Atualiza o estado com o novo agrupamento
            DispatchQueue.main.async {
                self.groupedExpenses = sortedDict.map { ExpenseGroup(dateComponents: $0.key, expenses: $0.value) }
            }
        }
    }
}

struct ExpenseGroup {
    let dateComponents: DateComponents
    let expenses: [Expense]
}

#Preview {
    ExpensesView()
}
