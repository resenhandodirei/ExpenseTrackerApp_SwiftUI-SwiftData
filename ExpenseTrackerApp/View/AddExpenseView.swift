//
//  AddExpenseView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 23/08/24.
//

import SwiftUI
import SwiftData

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext  // Contexto do SwiftData
    
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var date: Date = Date()
    @State private var amount: Double = 0.0
    @State private var category: Category?
    
    @State private var allCategories: [Category] = []

    var body: some View {
        NavigationStack {
            List {
                Section("Title") {
                    TextField("Magic Keyboard", text: $title)
                }
                
                Section("Description") {
                    HStack(spacing: 4) {
                        Text("$")
                            .fontWeight(.semibold)
                        TextField("0.0", value: $amount, format: .currency(code: "USD"))
                    }
                }
                
                Section("Date") {
                    DatePicker("", selection: $date, displayedComponents: [.date])
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                }
                
                if !allCategories.isEmpty {
                    Section("Category") {
                        Menu {
                            ForEach(allCategories) { category in
                                Button(category.categoryName) {
                                    self.category = category
                                }
                            }
                            Button("None") {
                                category = nil
                            }
                        } label: {
                            if let categoryName = category?.categoryName {
                                Text(categoryName)
                            } else {
                                Text("None")
                            }
                        }
                    }
                }
            }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add") {
                        addExpense()
                    }
                    .foregroundColor(.blue)
                    .disabled(isAddButtonDisabled)
                }
            }
        }
    }
    
    var isAddButtonDisabled: Bool {
        return title.isEmpty || amount == 0.0
    }
    
    func addExpense() {
        let expense = Expense(title: title, subTitle: subTitle, amount: amount, date: date, category: category)
        modelContext.insert(expense)
        
        do {
            try modelContext.save()
            print("Despesa adicionada: \(title), \(subTitle), \(amount), \(date), \(category?.categoryName ?? "Nenhuma categoria")")
            dismiss()
        } catch {
            print("Erro ao salvar a despesa: \(error.localizedDescription)")
        }
    }
}

struct AddExpenseView_Previews: PreviewProvider {
    static var previews: some View {
        AddExpenseView()
            .modelContainer(for: Expense.self, inMemory: true)
    }
}
