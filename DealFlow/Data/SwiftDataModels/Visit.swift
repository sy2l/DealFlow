//
//  Visit.swift
//  DealFlow
//
//  Modèle principal représentant une visite immobilière
//

import SwiftData
import Foundation

@Model
final class Visit {
    // MARK: - Identifiants
    
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    var title: String
    
    // MARK: - Mode de visite
    
    var modeRaw: String
    var mode: VisitMode {
        get { VisitMode(rawValue: modeRaw) ?? .invest }
        set { modeRaw = newValue.rawValue }
    }
    
    // MARK: - Informations du bien (Setup express)
    
    var purchasePrice: Double
    var surfaceM2: Double
    var monthlyRent: Double        // Loyer mensuel (utile pour mode invest)
    var monthlyCharges: Double     // Charges non récupérables
    var propertyTaxYearly: Double  // Taxe foncière annuelle
    
    // MARK: - Frais annexes
    
    var agencyFees: Double
    var notaryIsNew: Bool          // Bien neuf = frais notaire réduits
    var notaryOverride: Double?    // Override manuel des frais de notaire
    var manualWorksOverride: Double? // Override manuel du budget travaux
    
    // MARK: - Financement
    
    var downPaymentValue: Double   // Apport en €
    var interestRate: Double       // Taux annuel en %
    var loanYears: Int             // Durée du prêt en années
    
    // MARK: - Verdict (pour affichage dans la liste)
    
    var verdictColorRaw: String
    var verdictColor: VerdictColor {
        get { VerdictColor(rawValue: verdictColorRaw) ?? .orange }
        set { verdictColorRaw = newValue.rawValue }
    }
    
    // MARK: - Relations
    
    @Relationship(deleteRule: .cascade) var rooms: [Room]
    
    // MARK: - Initialisation
    
    init(
        title: String,
        mode: VisitMode,
        purchasePrice: Double,
        surfaceM2: Double,
        monthlyRent: Double
    ) {
        self.id = UUID()
        self.createdAt = Date()
        self.title = title
        self.modeRaw = mode.rawValue
        
        // Informations du bien
        self.purchasePrice = purchasePrice
        self.surfaceM2 = surfaceM2
        self.monthlyRent = monthlyRent
        self.monthlyCharges = 0
        self.propertyTaxYearly = 0
        
        // Frais annexes
        self.agencyFees = 0
        self.notaryIsNew = false
        self.notaryOverride = nil
        self.manualWorksOverride = nil
        
        // Financement (valeurs par défaut)
        self.downPaymentValue = 0
        self.interestRate = 4.0
        self.loanYears = 20
        
        // Verdict initial
        self.verdictColorRaw = VerdictColor.orange.rawValue
        self.rooms = []
    }
}
