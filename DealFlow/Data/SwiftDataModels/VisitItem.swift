//
//  VisitItem.swift
//  DealFlow
//
//  Modèle représentant un item de checklist dans une pièce
//

import SwiftData
import Foundation

@Model
final class VisitItem {
    // MARK: - Identifiants
    
    @Attribute(.unique) var id: UUID
    
    // MARK: - Template
    
    /// Clé du template pour relier à un template stable (ex: "kitchen.sink")
    /// Important pour V1.5/V2 : permet de faire évoluer les labels sans perdre les données
    var templateKey: String
    
    /// Texte affiché à l'utilisateur
    var label: String
    
    // MARK: - État de l'item
    
    var statusRaw: String
    var status: VisitStatus {
        get { VisitStatus(rawValue: statusRaw) ?? .unknown }
        set { statusRaw = newValue.rawValue }
    }
    
    // MARK: - Données utilisateur
    
    var estimatedCost: Double   // Coût estimé des travaux
    var notes: String           // Notes libres
    
    // MARK: - Relations
    
    @Relationship(deleteRule: .cascade) var photos: [PhotoRef]
    var room: Room?
    
    // MARK: - Initialisation
    
    init(templateKey: String, label: String) {
        self.id = UUID()
        self.templateKey = templateKey
        self.label = label
        self.statusRaw = VisitStatus.unknown.rawValue
        self.estimatedCost = 0
        self.notes = ""
        self.photos = []
    }
}
