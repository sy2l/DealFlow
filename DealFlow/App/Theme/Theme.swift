//
//  Theme.swift
//  DealFlow
//
//  Thème et couleurs de l'application
//

import SwiftUI

enum Theme {
    
    // MARK: - Couleurs du verdict
    
    /// Retourne la couleur SwiftUI correspondant à un VerdictColor
    static func verdictColor(_ color: VerdictColor) -> Color {
        switch color {
        case .green:
            return .green
        case .orange:
            return .orange
        case .red:
            return .red
        }
    }
    
    /// Retourne la couleur UIKit correspondant à un VerdictColor
    static func verdictUIColor(_ color: VerdictColor) -> UIColor {
        switch color {
        case .green:
            return .systemGreen
        case .orange:
            return .systemOrange
        case .red:
            return .systemRed
        }
    }
    
    // MARK: - Couleurs des statuts
    
    /// Retourne la couleur correspondant à un VisitStatus
    static func statusColor(_ status: VisitStatus) -> Color {
        switch status {
        case .unknown:
            return .secondary
        case .good:
            return .green
        case .average:
            return .orange
        case .bad:
            return .red
        }
    }
    
    // MARK: - Couleurs principales
    
    static let primaryColor = Color.blue
    static let secondaryColor = Color.gray
    static let backgroundColor = Color(.systemBackground)
    static let cardBackground = Color(.secondarySystemBackground)
}
