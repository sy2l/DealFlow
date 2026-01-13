//
//  VerdictEngine.swift
//  DealFlow
//
//  Moteur de calcul du verdict - Logique métier pure et testable
//

import Foundation

struct VerdictEngine {
    
    // MARK: - Seuils de verdict (configurables pour V1.5)
    
    /// Seuil de cashflow pour verdict vert (autofinancement)
    private static let greenThreshold: Double = 0
    
    /// Seuil de cashflow pour verdict orange (effort modéré)
    private static let orangeThreshold: Double = -150
    
    // MARK: - Calcul du verdict
    
    /// Détermine le verdict basé sur le cashflow mensuel
    /// - Parameter cashflow: Cashflow mensuel en euros
    /// - Returns: Un VerdictSnapshot avec couleur et message
    static func verdict(forCashflow cashflow: Double) -> VerdictSnapshot {
        if cashflow > greenThreshold {
            return VerdictSnapshot(
                color: .green,
                message: "Autofinancement ✅"
            )
        } else if cashflow >= orangeThreshold {
            return VerdictSnapshot(
                color: .orange,
                message: "Effort d'épargne modéré"
            )
        } else {
            return VerdictSnapshot(
                color: .red,
                message: "Cashflow négatif ⚠️"
            )
        }
    }
    
    /// Verdict par défaut pour les modes non-investissement
    static func defaultVerdict() -> VerdictSnapshot {
        return VerdictSnapshot(
            color: .orange,
            message: "À compléter"
        )
    }
}
