//
//  MiniScoreboard.swift
//  DealFlow
//
//  Bandeau de score affiché en haut du cockpit de visite
//

import SwiftUI

struct MiniScoreboard: View {
    let visit: Visit
    let snapshot: FinancialSnapshot
    let verdict: VerdictSnapshot
    
    var body: some View {
        HStack(spacing: 16) {
            // Verdict
            VStack(alignment: .leading, spacing: 4) {
                Text("Verdict")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                HStack(spacing: 6) {
                    Circle()
                        .fill(Theme.verdictColor(verdict.color))
                        .frame(width: 10, height: 10)
                    
                    Text(verdictLabel)
                        .font(.subheadline.weight(.semibold))
                }
            }
            
            Divider()
                .frame(height: 32)
            
            // Cashflow (mode invest uniquement)
            if visit.mode == .invest {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cashflow")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Text(cashflowText)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(cashflowColor)
                }
                
                Divider()
                    .frame(height: 32)
            }
            
            // Coût total
            VStack(alignment: .leading, spacing: 4) {
                Text("Coût total")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(Formatters.eur(snapshot.totalCost))
                    .font(.subheadline.weight(.semibold))
            }
            
            Spacer()
        }
        .padding(12)
        .background(Theme.verdictColor(verdict.color).opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
    
    // MARK: - Computed Properties
    
    private var verdictLabel: String {
        switch verdict.color {
        case .green: return "GO"
        case .orange: return "À creuser"
        case .red: return "STOP"
        }
    }
    
    private var cashflowText: String {
        let value = Int(snapshot.monthlyCashflow)
        if value >= 0 {
            return "+\(value) €/mois"
        } else {
            return "\(value) €/mois"
        }
    }
    
    private var cashflowColor: Color {
        if snapshot.monthlyCashflow > 0 {
            return .green
        } else if snapshot.monthlyCashflow >= -150 {
            return .orange
        } else {
            return .red
        }
    }
}

// MARK: - Preview

#Preview {
    MiniScoreboard(
        visit: Visit(
            title: "Test",
            mode: .invest,
            purchasePrice: 150000,
            surfaceM2: 45,
            monthlyRent: 650
        ),
        snapshot: FinancialSnapshot(
            totalCost: 165000,
            borrowedAmount: 165000,
            monthlyPayment: 850,
            monthlyCashflow: -200,
            netYieldPercent: 4.5,
            worksTotal: 5000,
            notaryFees: 12000
        ),
        verdict: VerdictSnapshot(color: .orange, message: "Effort modéré")
    )
    .padding()
}
