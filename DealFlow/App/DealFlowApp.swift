//
//  DealFlowApp.swift
//  DealFlow
//
//  Point d'entrée de l'application
//

import SwiftUI
import SwiftData

@main
struct DealFlowApp: App {
    
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(AppContainer.shared.modelContainer)
    }
}
