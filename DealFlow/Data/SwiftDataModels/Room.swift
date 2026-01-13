//
//  Room.swift
//  DealFlow
//
//  Modèle représentant une pièce dans une visite
//

import SwiftData
import Foundation

@Model
final class Room {
    // MARK: - Identifiants
    
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    
    // MARK: - Informations de la pièce
    
    var name: String            // Nom affiché (ex: "Cuisine", "Chambre 1")
    var typeKey: String         // Clé du type (ex: "kitchen", "bedroom")
    var orderIndex: Int         // Ordre d'affichage dans la visite
    
    // MARK: - Relations
    
    @Relationship(deleteRule: .cascade) var items: [VisitItem]
    var visit: Visit?
    
    // MARK: - Initialisation
    
    init(name: String, typeKey: String, orderIndex: Int) {
        self.id = UUID()
        self.createdAt = Date()
        self.name = name
        self.typeKey = typeKey
        self.orderIndex = orderIndex
        self.items = []
    }
}
