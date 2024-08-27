//
//  ExpensesView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ], animation: .snappy) private var allExpenses: [Expense]
 
    @State private var groupedExpenses: [ExpenseGroup] = []
    @State private var addExpense: Bool = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedExpenses) { group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            // Card View
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
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

    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = groupExpensesByDate(expenses)
            let sortedDict = sortGroupedExpenses(groupedDict)
            await updateGroupedExpenses(sortedDict)
        }
    }

    func groupExpensesByDate(_ expenses: [Expense]) -> [DateComponents: [Expense]] {
        return Dictionary(grouping: expenses) { expense in
            return Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
        }
    }

    func sortGroupedExpenses(_ groupedExpenses: [DateComponents: [Expense]]) -> [(key: DateComponents, value: [Expense])] {
        let calendar = Calendar.current
        return groupedExpenses.sorted {
            let date1 = calendar.date(from: $0.key) ?? Date()
            let date2 = calendar.date(from: $1.key) ?? Date()
            return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
        }
    }

    @MainActor
    func updateGroupedExpenses(_ sortedExpenses: [(key: DateComponents, value: [Expense])]) async {
        groupedExpenses = sortedExpenses.map { ExpenseGroup(dateComponents: $0.key, expenses: $0.value) }
    }
}

struct ExpenseGroup: Identifiable {
    let id = UUID()
    let dateComponents: DateComponents
    let expenses: [Expense]

    var groupTitle: String {
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

#Preview {
    ExpensesView()
}
