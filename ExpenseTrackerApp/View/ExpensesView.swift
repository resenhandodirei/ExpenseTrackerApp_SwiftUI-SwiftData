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
    //Grouped Expenses
    // This will also be used for filtering purpose.
    @State private var groupedExpenses: [ExpenseGroup] = []
    @State private var originalgroupedExpenses: [ExpenseGroup] = []
    @State private var addExpense: Bool = false
    // Search Text
    @State private var searchText: String = ""

    var body: some View {
        NavigationStack {
            List {
                ForEach(groupedExpenses) { $group in
                    Section(group.groupTitle) {
                        ForEach(group.expenses) { expense in
                            // Card View
                            ExpenseCardView(expense: expense)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        context.delete(expense)
                                        withAnimation {
                                            group.expense.removeAll(where: { $0.id == expense.id })
                                        } // Removendo o grupo se não tiver mais nenhum gasto presente.
                                        if group.expenses.isEmpty {
                                            groupedExpenses.removeAll(where: { $0.id == group.id })
                                        }
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
            // Search Bar
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
                    Button {
                        addExpense.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .onChange(of: allExpenses, initial: true) { oldValue, newValue in
                if newValue.count > oldValue.count || groupedExpenses.isEmpty || currentTab == "Categories" {
                    createGroupedExpenses(newValue)
                }
            }
            
            .onChange(of: searchText, initial: false) { oldValue, newValue in
                if  !newValue.isEmpty {
                    filterExpenses(newValue)
                } else {
                    groupedExpense = originalGroupedExpenses
                }
            }
            .sheet(isPresent: $addExpense) {
                AddExpenseView()
                    .interactiveDismissDisabled()
            }
        }
        func filterExpenses(_text: String) {
            Task.detached(priority: .high) {
                let query = text.lowercased()
                let filteredExpenses = originalgroupedExpenses.compactMap {
                    group -> GroupedExpenses? in
                    let expenses = group.expenses.filter({ $0.title.lowercased().contain(query) })
                    if expenses.isEmpty {
                        return nil
                    }
                    return .init(date: group.date, expenses: expenses)
                }
                
                await MainActor.run {
                    groupedExpenses = filteredExpenses
                }
            }
        }

    func createGroupedExpenses(_ expenses: [Expense]) {
        Task.detached(priority: .high) {
            let groupedDict = groupExpensesByDate(expenses)
            let dateComponents = Calendar.current.dateComponents([.day, .month, .year], from:
                                                                    expense.date)
            return dateComponents
        }
    }

    let sortedDict = grouppedDict.sorted {
        let calendar = Calendar.current
        let date1 = calendar.date(from: $0.key) ?? Date()
        let date2 = calendar.date(from: $1.key) ?? Date()
        return calendar.compare(date1, to: date2, toGranularity: .day) == .orderedDescending
    }

    

    await @MainActor.run {
            groupedExpenses = sortedDict.compactMap ({ dict in
                let date = Calendar.current.date(from: dict.key) ?? .init()
                return .init(date: date, expenses: dict.value)
                )}
                originalgroupedExpenses = groupedExpenses
        
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
    ContentView()
}
