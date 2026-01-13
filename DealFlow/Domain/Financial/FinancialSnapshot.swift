//
//  FinancialSnapshot.swift
//  DealFlow
//
//  Structure immuable représentant un instantané des calculs financiers
//

import Foundation

struct FinancialSnapshot: Equatable {
    /// Coût total de l'opération (prix + frais + travaux)
    let totalCost: Double
    
    /// Montant emprunté (coût total - apport)
    let borrowedAmount: Double
    
    /// Mensualité du crédit
    let monthlyPayment: Double
    
    /// Cashflow mensuel (loyer - charges - mensualité)
    let monthlyCashflow: Double
    
    /// Rentabilité nette en pourcentage
    let netYieldPercent: Double
    
    /// Total des travaux estimés
    let worksTotal: Double
    
    /// Frais de notaire
    let notaryFees: Double
}
