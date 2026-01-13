//
//  VerdictView.swift
//  DealFlow
//
//  Vue de verdict final avec KPIs et export PDF
//

import SwiftUI
import SwiftData

struct VerdictView: View {
    @Environment(\.modelContext) private var modelContext
    
    let visit: Visit
    
    @State private var pdfURL: URL?
    @State private var isGenerating = false
    @State private var showShareSheet = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Carte de score principale
                ScoreCard(verdict: verdictSnapshot(), cashflow: financialSnapshot().monthlyCashflow)
                
                // Grille de KPIs
                KPIGrid(snapshot: financialSnapshot())
                
                // Section Travaux
                WorksSummaryCard(
                    worksFromChecklist: worksFromChecklist(),
                    worksTotal: worksTotal()
                )
                
                // Bouton d'export
                VStack(spacing: 12) {
                    if isGenerating {
                        ProgressView("Génération du PDF…")
                            .padding()
                    } else {
                        Button {
                            generatePDF()
                        } label: {
                            Label("Générer le rapport PDF", systemImage: "doc.fill")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    if let pdfURL {
                        ShareLink(item: pdfURL) {
                            Label("Partager le rapport", systemImage: "square.and.arrow.up")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .padding(.top, 8)
                
                Spacer(minLength: 32)
            }
            .padding()
        }
        .navigationTitle("Verdict")
        .onAppear {
            updateVerdict()
        }
    }
    
    // MARK: - Financial Calculations
    
    private func worksFromChecklist() -> Double {
        visit.rooms.flatMap(\.items).reduce(0) { sum, item in
            sum + (item.status == .bad ? item.estimatedCost : 0)
        }
    }
    
    private func worksTotal() -> Double {
        visit.manualWorksOverride ?? worksFromChecklist()
    }
    
    private func notaryFees() -> Double {
        if let override = visit.notaryOverride { return max(0, override) }
        return FinancialEngine.estimateNotaryFees(
            purchasePrice: visit.purchasePrice,
            isNew: visit.notaryIsNew
        )
    }
    
    private func financialSnapshot() -> FinancialSnapshot {
        FinancialEngine.compute(
            purchasePrice: visit.purchasePrice,
            agencyFees: visit.agencyFees,
            notaryFees: notaryFees(),
            works: worksTotal(),
            downPayment: visit.downPaymentValue,
            annualRatePercent: visit.interestRate,
            loanYears: visit.loanYears,
            monthlyRent: visit.mode == .invest ? visit.monthlyRent : 0,
            monthlyCharges: visit.monthlyCharges,
            propertyTaxYearly: visit.propertyTaxYearly
        )
    }
    
    private func verdictSnapshot() -> VerdictSnapshot {
        if visit.mode == .invest {
            return VerdictEngine.verdict(forCashflow: financialSnapshot().monthlyCashflow)
        } else {
            return VerdictEngine.defaultVerdict()
        }
    }
    
    // MARK: - Actions
    
    private func updateVerdict() {
        visit.verdictColor = verdictSnapshot().color
        try? modelContext.save()
    }
    
    private func generatePDF() {
        isGenerating = true
        pdfURL = nil
        
        let snap = financialSnapshot()
        let lines: [String] = [
            "Mode: \(visit.mode.displayName)",
            "Prix d'achat: \(Formatters.eur(visit.purchasePrice))",
            "Frais de notaire: \(Formatters.eur(snap.notaryFees))",
            "Travaux estimés: \(Formatters.eur(snap.worksTotal))",
            "Coût total: \(Formatters.eur(snap.totalCost))",
            "",
            "Apport: \(Formatters.eur(visit.downPaymentValue))",
            "Montant emprunté: \(Formatters.eur(snap.borrowedAmount))",
            "Mensualité: \(Formatters.eur(snap.monthlyPayment))",
            "",
            "Loyer mensuel: \(Formatters.eur(visit.monthlyRent))",
            "Charges mensuelles: \(Formatters.eur(visit.monthlyCharges))",
            "Cashflow: \(Int(snap.monthlyCashflow)) €/mois",
            "Rentabilité nette: \(Formatters.pct1(snap.netYieldPercent))"
        ]
        
        // Récupérer les 4 premières photos
        let images: [UIImage] = visit.rooms
            .flatMap(\.items)
            .flatMap(\.photos)
            .prefix(4)
            .compactMap { ImageStore.shared.load($0.fileName) }
        
        // Génération en arrière-plan
        DispatchQueue.global(qos: .userInitiated).async {
            let url = try? PDFExporter.exportVisitReport(
                visitTitle: visit.title,
                summaryLines: lines,
                images: images,
                watermark: "Analysé via DealFlow" // MVP: toujours watermark
            )
            
            DispatchQueue.main.async {
                self.pdfURL = url
                self.isGenerating = false
            }
        }
    }
}

// MARK: - Score Card

struct ScoreCard: View {
    let verdict: VerdictSnapshot
    let cashflow: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Décision")
                    .font(.headline)
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Circle()
                    .fill(Theme.verdictColor(verdict.color))
                    .frame(width: 16, height: 16)
            }
            
            Text(verdict.message)
                .font(.title2.weight(.bold))
            
            Text("Cashflow estimé: \(Int(cashflow)) €/mois")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.verdictColor(verdict.color).opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

// MARK: - KPI Grid

struct KPIGrid: View {
    let snapshot: FinancialSnapshot
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                KPICard(title: "Coût total", value: Formatters.eur(snapshot.totalCost))
                KPICard(title: "Emprunté", value: Formatters.eur(snapshot.borrowedAmount))
            }
            
            HStack(spacing: 12) {
                KPICard(title: "Mensualité", value: Formatters.eur(snapshot.monthlyPayment))
                KPICard(title: "Renta nette", value: Formatters.pct1(snapshot.netYieldPercent))
            }
        }
    }
}

// MARK: - KPI Card

struct KPICard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            
            Text(value)
                .font(.headline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Works Summary Card

struct WorksSummaryCard: View {
    let worksFromChecklist: Double
    let worksTotal: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Travaux")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            HStack {
                Text("Depuis la checklist")
                Spacer()
                Text(Formatters.eur(worksFromChecklist))
            }
            .font(.subheadline)
            
            if worksTotal != worksFromChecklist {
                HStack {
                    Text("Total (override)")
                    Spacer()
                    Text(Formatters.eur(worksTotal))
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VerdictView(visit: Visit(
            title: "Appartement Test",
            mode: .invest,
            purchasePrice: 150000,
            surfaceM2: 45,
            monthlyRent: 650
        ))
    }
    .modelContainer(for: Visit.self, inMemory: true)
}
