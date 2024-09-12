//
//  ExpensesView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI
import SwiftData

struct ExpensesView: View {
    @Binding var currentTab: String
    @Query(sort: [
        SortDescriptor(\Expense.date, order: .reverse)
    ], animation: .snappy) private var allExpenses: [Expense]
    @Environment(\.modelContext) private var context
    
    @State private var groupedExpenses: [ExpenseGroup] = []
    @State private var originalGroupedExpenses: [ExpenseGroup] = []
    @State private var addExpense: Bool = false
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedExpenses) { group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            ExpenseCardView(expense: expense)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        deleteExpense(expense, from: group)
                                    } label: {
                                        Image(systemName: "trash")
                                    }
                                    .tint(.red)
                                }
                        }
                    }
                }
            }
            .navigationTitle("Expenses")
            .searchable(text: $searchText, placement: .navigationBarDrawer, prompt: Text("Search"))
            .overlay {
                if allExpenses.isEmpty || groupedExpenses.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    addButton
                }
            }
            .onChange(of: allExpenses) { oldExpenses, newExpenses in
                processExpenses(with: newExpenses)
            }
            .onChange(of: searchText) { oldExpenses, newText in
                if newText.isEmpty {
                    groupedExpenses = originalGroupedExpenses
                } else {
                    filterExpenses(for: newText)
                }
            }
            .sheet(isPresented: $addExpense) {
                AddExpenseView()
                    .interactiveDismissDisabled()
                    .environment(\.modelContext, context)
            }
        }
    }

    private var addButton: some View {
        Button {
            addExpense.toggle()
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title3)
        }
    }

    private func deleteExpense(_ expense: Expense, from group: ExpenseGroup) {
        context.delete(expense)
        withAnimation {
            let updatedGroup = ExpenseGroup(
                dateComponents: group.dateComponents,
                expenses: group.expenses.filter { $0.id != expense.id }
            )
            
            if updatedGroup.expenses.isEmpty {
                groupedExpenses.removeAll { $0.id == group.id }
            } else {
                if let index = groupedExpenses.firstIndex(where: { $0.id == group.id }) {
                    groupedExpenses[index] = updatedGroup
                }
            }
        }
    }

    private func processExpenses(with expenses: [Expense]) {
        Task.detached(priority: .high) {
            let sortedExpenses = expenses.sorted { $0.date > $1.date }
            await MainActor.run {
                createGroupedExpenses(sortedExpenses)
            }
        }
    }

    private func filterExpenses(for searchText: String) {
        Task.detached(priority: .high) {
            let query = searchText.lowercased()
            let filteredExpenses = originalGroupedExpenses.compactMap { group -> ExpenseGroup? in
                let expenses = group.expenses.filter { $0.title.lowercased().contains(query) }
                return expenses.isEmpty ? nil : ExpenseGroup(dateComponents: group.dateComponents, expenses: expenses)
            }
            await MainActor.run {
                groupedExpenses = filteredExpenses
            }
        }
    }

    private func createGroupedExpenses(_ expenses: [Expense]) {
        let groupedDict = Dictionary(grouping: expenses) { expense -> DateComponents in
            Calendar.current.dateComponents([.day, .month, .year], from: expense.date)
        }
        let sortedDict = groupedDict.sorted {
            let calendar = Calendar.current
            let date1 = calendar.date(from: $0.key) ?? Date()
            let date2 = calendar.date(from: $1.key) ?? Date()
            return date1 > date2
        }
        groupedExpenses = sortedDict.compactMap { dict in
            ExpenseGroup(dateComponents: dict.key, expenses: dict.value)
        }
        originalGroupedExpenses = groupedExpenses
    }
}

struct ExpenseGroup: Identifiable {
    let id = UUID()
    let dateComponents: DateComponents
    var expenses: [Expense]

    var groupTitle: String {
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct ExpensesView_Previews: PreviewProvider {
    static var previews: some View {
        ExpensesView(currentTab: .constant("Expenses"))
            .modelContainer(for: Expense.self, inMemory: true)
    }
}

