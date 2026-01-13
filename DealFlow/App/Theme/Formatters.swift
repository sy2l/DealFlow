//
//  Formatters.swift
//  DealFlow
//
//  Utilitaires de formatage pour l'affichage
//

import Foundation

enum Formatters {
    
    // MARK: - Devise
    
    /// Formatter pour les montants en euros
    static let currency: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "fr_FR")
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    /// Formate un montant en euros
    /// - Parameter value: Montant à formater
    /// - Returns: Chaîne formatée (ex: "150 000 €")
    static func eur(_ value: Double) -> String {
        currency.string(from: NSNumber(value: value)) ?? "\(Int(value)) €"
    }
    
    // MARK: - Pourcentage
    
    /// Formate un pourcentage avec une décimale
    /// - Parameter value: Valeur en pourcentage
    /// - Returns: Chaîne formatée (ex: "4.5%")
    static func pct1(_ value: Double) -> String {
        String(format: "%.1f%%", value)
    }
    
    /// Formate un pourcentage sans décimale
    /// - Parameter value: Valeur en pourcentage
    /// - Returns: Chaîne formatée (ex: "5%")
    static func pct0(_ value: Double) -> String {
        String(format: "%.0f%%", value)
    }
    
    // MARK: - Surface
    
    /// Formate une surface en m²
    /// - Parameter value: Surface en m²
    /// - Returns: Chaîne formatée (ex: "45 m²")
    static func surface(_ value: Double) -> String {
        "\(Int(value)) m²"
    }
    
    // MARK: - Date
    
    /// Formatter pour les dates courtes
    static let shortDate: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        formatter.locale = Locale(identifier: "fr_FR")
        return formatter
    }()
    
    /// Formate une date en format court
    /// - Parameter date: Date à formater
    /// - Returns: Chaîne formatée (ex: "13 janv. 2026")
    static func date(_ date: Date) -> String {
        shortDate.string(from: date)
    }
}
