//
//  ContentView.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI

struct ContentView: View {
    @State private var currentTab: String = "Expenses"
    var body: some View {
        TabView(selection: $currentTab) {
            ExpensesView(currentTab: $currentTab)
            .tag("Expenses")
            .tabItem{
                Image(systemName: "credicard.fill")
                Text("Expenses")
            }
            
            CategoriesView()
            .tag("Categories")
            .tabItem{
                Image(systemName: "list.clipboard.fill")
                Text("Categories")
            }
        }
        
    }
}

#Preview {
    ContentView()
}

