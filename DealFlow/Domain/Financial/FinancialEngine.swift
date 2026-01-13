//
//  FinancialEngine.swift
//  DealFlow
//
//  Moteur de calcul financier - Logique métier pure et testable
//

import Foundation

struct FinancialEngine {
    
    // MARK: - Frais de notaire
    
    /// Estime les frais de notaire selon le type de bien
    /// - Parameters:
    ///   - purchasePrice: Prix d'achat du bien
    ///   - isNew: true si le bien est neuf (frais réduits)
    /// - Returns: Montant estimé des frais de notaire
    static func estimateNotaryFees(purchasePrice: Double, isNew: Bool) -> Double {
        // Règle simplifiée MVP:
        // - Neuf: ~2.5% (TVA incluse dans le prix)
        // - Ancien: ~8% (droits de mutation + émoluments)
        let rate = isNew ? 0.025 : 0.08
        return max(0, purchasePrice * rate)
    }
    
    // MARK: - Calcul de mensualité
    
    /// Calcule la mensualité d'un prêt amortissable
    /// - Parameters:
    ///   - amount: Montant emprunté
    ///   - annualRatePercent: Taux annuel en pourcentage (ex: 4.0 pour 4%)
    ///   - years: Durée du prêt en années
    /// - Returns: Mensualité du prêt
    static func monthlyLoanPayment(amount: Double, annualRatePercent: Double, years: Int) -> Double {
        let months = max(1, years * 12)
        let r = max(0, annualRatePercent) / 100.0 / 12.0
        
        // Si taux = 0, simple division
        if r == 0 {
            return amount / Double(months)
        }
        
        // Formule de mensualité: M = P * [r(1+r)^n] / [(1+r)^n - 1]
        let powVal = pow(1 + r, Double(months))
        return amount * (r * powVal) / (powVal - 1)
    }
    
    // MARK: - Calcul complet
    
    /// Calcule l'ensemble des indicateurs financiers
    /// - Parameters:
    ///   - purchasePrice: Prix d'achat
    ///   - agencyFees: Frais d'agence
    ///   - notaryFees: Frais de notaire
    ///   - works: Budget travaux
    ///   - downPayment: Apport personnel
    ///   - annualRatePercent: Taux d'intérêt annuel en %
    ///   - loanYears: Durée du prêt en années
    ///   - monthlyRent: Loyer mensuel
    ///   - monthlyCharges: Charges mensuelles non récupérables
    ///   - propertyTaxYearly: Taxe foncière annuelle
    /// - Returns: Un snapshot complet des indicateurs financiers
    static func compute(
        purchasePrice: Double,
        agencyFees: Double,
        notaryFees: Double,
        works: Double,
        downPayment: Double,
        annualRatePercent: Double,
        loanYears: Int,
        monthlyRent: Double,
        monthlyCharges: Double,
        propertyTaxYearly: Double
    ) -> FinancialSnapshot {
        
        // Coût total de l'opération
        let totalCost = max(0, purchasePrice + agencyFees + notaryFees + works)
        
        // Montant à emprunter
        let borrowed = max(0, totalCost - max(0, downPayment))
        
        // Mensualité du crédit
        let payment = monthlyLoanPayment(
            amount: borrowed,
            annualRatePercent: annualRatePercent,
            years: loanYears
        )
        
        // Taxe foncière mensuelle
        let taxMonthly = max(0, propertyTaxYearly) / 12.0
        
        // Cashflow mensuel = Loyer - (Charges + Taxe foncière mensuelle + Mensualité)
        let cashflow = monthlyRent - (monthlyCharges + taxMonthly + payment)
        
        // Rentabilité nette simplifiée
        // = (Loyer annuel - Charges annuelles - Taxe foncière) / Coût total * 100
        let annualNet = (monthlyRent - monthlyCharges) * 12.0 - max(0, propertyTaxYearly)
        let yieldPct = totalCost > 0 ? (annualNet / totalCost) * 100.0 : 0
        
        return FinancialSnapshot(
            totalCost: totalCost,
            borrowedAmount: borrowed,
            monthlyPayment: payment,
            monthlyCashflow: cashflow,
            netYieldPercent: yieldPct,
            worksTotal: works,
            notaryFees: notaryFees
        )
    }
}
