//
//  AppContainer.swift
//  DealFlow
//
//  Conteneur principal de l'application
//  Gère le ModelContainer SwiftData et les services partagés
//

import SwiftData
import Foundation

@MainActor
final class AppContainer {
    
    // MARK: - Singleton
    
    static let shared = AppContainer()
    
    // MARK: - SwiftData
    
    /// Container SwiftData pour la persistance des données
    let modelContainer: ModelContainer
    
    // MARK: - Services
    
    /// Templates de checklists
    let templates = ChecklistTemplates()
    
    // MARK: - Initialisation
    
    private init() {
        // Définition du schéma SwiftData
        let schema = Schema([
            Visit.self,
            Room.self,
            VisitItem.self,
            PhotoRef.self
        ])
        
        // Configuration du stockage (persistant sur disque)
        let config = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        // Création du container
        do {
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [config]
            )
        } catch {
            // En cas d'erreur fatale, crash avec message explicite
            fatalError("Impossible d'initialiser SwiftData: \(error.localizedDescription)")
        }
    }
}
