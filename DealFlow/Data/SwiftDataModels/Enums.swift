//
//  Enums.swift
//  DealFlow
//
//  Énumérations partagées pour les modèles de données
//

import Foundation

// MARK: - VisitMode

/// Mode de visite choisi par l'utilisateur à la création
enum VisitMode: String, Codable, CaseIterable {
    case invest = "invest"
    case buy = "buy"
    case rent = "rent"
    
    var displayName: String {
        switch self {
        case .invest: return "Investir"
        case .buy: return "Acheter"
        case .rent: return "Louer"
        }
    }
}

// MARK: - VisitStatus

/// Statut d'un item de checklist
enum VisitStatus: String, Codable, CaseIterable {
    case unknown = "unknown"
    case good = "good"
    case average = "average"
    case bad = "bad"
    
    var displayEmoji: String {
        switch self {
        case .unknown: return "—"
        case .good: return "✅"
        case .average: return "⚠️"
        case .bad: return "❌"
        }
    }
}

// MARK: - VerdictColor

/// Couleur du verdict (feu tricolore)
enum VerdictColor: String, Codable {
    case green = "green"
    case orange = "orange"
    case red = "red"
}
