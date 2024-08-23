 //
//  AddExpenseView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 23/08/24.
//

import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.dismiss) private var context
    
    @State private var title: String = ""
    @State private var subTitle: String = ""
    @State private var date: Date = .init()
    @State private var amount: CGFloat = 0
    @State private var category: Category?
    @Query(animation: .snappy) private var allCategories: [Category]
     

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
                        TextField("0.0", value: $amount, format: .currency(code: "US")  )
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
                            ForEach(allCategories) {
                                Text($0.categoryName)
                                    .tag($0)
                            }
                        }
                        .pickerStyle(.menu)
                        .labelsHidden()
                    }
                }
            }
            .navigationTitle("Add Expense")
            .toolbar {
                // Button de cancelar e de adicionar
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .tint(.red)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Add", action: addExpense ) {
                    }
            
                }
            }
        }
    
    }
    func addExpense() {
        
    }
}

#Preview {
    AddExpenseView()
}
