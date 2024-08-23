 //
//  AddExpenseView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 23/08/24.
//
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var date: Date = .init()
    @State private var amount: CGFloat = 0
    @State private var category: Category?

    // Supondo que allCategories venha de uma fonte de dados, como uma variável de estado
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
                    HStack {
                        Text("Category")
                        Spacer()
                        Picker("", selection: $category) {
                            ForEach(allCategories) { category in
                                Text(category.categoryName)
                                    .tag(category as Category?)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                // Botões de cancelar e adicionar
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
                }
            }
        }
    }
    
    func addExpense() {
        // Função para adicionar a despesa
    }
}

#Preview {
    AddExpenseView()
}
