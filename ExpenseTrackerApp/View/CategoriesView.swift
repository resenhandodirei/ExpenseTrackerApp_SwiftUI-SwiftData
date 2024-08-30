//
//  CategoriesView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI
import SwiftData

struct CategoriesView: View {
    @Query(animation: .snappy) private var allCategories: [Category]
    @Environment(\.modelContext) private var context
    var body: some View {
        // Propriedades da View
        @State private var addCategory: Bool = false
        @State private var categoryName: String = ""
        
        // Category Delete Request
        @State private var deleteRequest: Bool = false
        @State private var requestedCategory: Category?
        NavigationStack {
            List {
                ForEach(allCategories.sorted(by: {
                    ($0.expenses?.count ?? 0) > ($1.expenses?.count ?? 0)
                })) { category in
                    DisclosureGroup {
                        if let expenses = category.expenses, !expenses.isEmpty {
                            ForEach(expenses) { expense in
                                ExpenseCardView(expense: expense, displayTag: false)
                            }
                        }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    deleteRequest.toggle()
                                    requestedCategory = category
                                    
                                } label: {
                                    Image(systemName: "trash")
                                }
                                .tint(.red)
                            }
                    } else {
                        ContentUnavailableView {
                            Label("No Expenses", systemImage: "tray.fill")
                        }
                    }
                } label: {
                    Text(category.categoryName)
                }
                
            }
            .navigationTitle("Categories")
            .overlay {
                if allCategories.isEmpty {
                    ContentUnavailableView {
                        Label("No Expenses", systemImage: "tray.fill")
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        addCategory.toggle()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $addCategory) {
                categoryName = ""
                
            } context: {
                NavigationStack {
                    Link {
                        Section("Title") {
                            TextField("General", text: $categoryName)
                        }
                        
                    }
                    .navigationTitle("Category Name")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) {
                            Button("Cancel") {
                                let category = Category(categoryName: categoryName)
                                context.insert(category)
                                categoryName = ""
                                addCategory = false
                            }
                            .tint(.red)
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Add") {
                            }
                            .disabled(categoryName.isEmpty)
                        }
                    }
                }
                .presentationDetents([.height(180)])
                .presentationCornerRadius(20)
                .interactiveDismissDisabled()
            }
        }
    }
        .alert("If you delete a category, all the associated expenses will be deleted too.", isPresented: $deleteRequest) {
            Button(role: .destructive) {
                if let requestedCategory {
                    context.delete(requestedCategory)
                    self.requestedCategory = nil
                }
            } label: {
                Text("Delete")
            }
            Button(role: .cancel) {
                requestedCategory = nil
            } label: {
                Text("Cancel")
            }
        }
}

#Preview {
    CategoriesView()
}
