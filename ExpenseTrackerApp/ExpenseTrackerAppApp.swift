//
//  ExpenseTrackerAppApp.swift
//  ExpenseTrackerApp
//
//  Created by Larissa Martins Correa on 22/08/24.
//

import SwiftUI

@main
struct ExpenseTrackerAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        
        // Configurando o container
        .modelContainer(for: [Expense.self, Category.self])
    }
}
