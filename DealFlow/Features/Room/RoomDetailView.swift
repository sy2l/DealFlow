//
//  RoomDetailView.swift
//  DealFlow
//
//  Vue de détail d'une pièce avec sa checklist
//

import SwiftUI
import SwiftData
import PhotosUI

struct RoomDetailView: View {
    @Environment(\.modelContext) private var modelContext
    
    let visit: Visit
    let room: Room
    
    @State private var selectedItem: VisitItem?
    
    var body: some View {
        List {
            // Section principale avec les items
            Section {
                ForEach(room.items) { item in
                    ChecklistItemRow(item: item)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            cycleStatus(item)
                        }
                        .onLongPressGesture {
                            selectedItem = item
                        }
                }
            } header: {
                Text("Points de contrôle")
            } footer: {
                Text("Appuyez pour changer le statut. Appui long pour les détails.")
                    .font(.caption)
            }
            
            // Résumé de la pièce
            Section("Résumé") {
                HStack {
                    Text("Points vérifiés")
                    Spacer()
                    Text("\(checkedCount)/\(room.items.count)")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Problèmes détectés")
                    Spacer()
                    Text("\(badCount)")
                        .foregroundStyle(badCount > 0 ? .red : .secondary)
                }
                
                if estimatedWorks > 0 {
                    HStack {
                        Text("Travaux estimés")
                        Spacer()
                        Text(Formatters.eur(estimatedWorks))
                            .foregroundStyle(.orange)
                    }
                }
            }
        }
        .navigationTitle(room.name)
        .sheet(item: $selectedItem) { item in
            ItemDetailSheet(item: item)
        }
    }
    
    // MARK: - Computed Properties
    
    private var checkedCount: Int {
        room.items.filter { $0.status != .unknown }.count
    }
    
    private var badCount: Int {
        room.items.filter { $0.status == .bad }.count
    }
    
    private var estimatedWorks: Double {
        room.items.filter { $0.status == .bad }.reduce(0) { $0 + $1.estimatedCost }
    }
    
    // MARK: - Actions
    
    private func cycleStatus(_ item: VisitItem) {
        switch item.status {
        case .unknown: item.status = .good
        case .good: item.status = .average
        case .average: item.status = .bad
        case .bad: item.status = .unknown
        }
        try? modelContext.save()
        
        // Mettre à jour le verdict de la visite
        updateVisitVerdict()
    }
    
    private func updateVisitVerdict() {
        if visit.mode == .invest {
            let snapshot = computeFinancialSnapshot()
            let verdict = VerdictEngine.verdict(forCashflow: snapshot.monthlyCashflow)
            visit.verdictColor = verdict.color
            try? modelContext.save()
        }
    }
    
    private func computeFinancialSnapshot() -> FinancialSnapshot {
        let works = visit.manualWorksOverride ?? visit.rooms.flatMap(\.items)
            .filter { $0.status == .bad }
            .reduce(0) { $0 + $1.estimatedCost }
        
        let notaryFees = visit.notaryOverride ?? FinancialEngine.estimateNotaryFees(
            purchasePrice: visit.purchasePrice,
            isNew: visit.notaryIsNew
        )
        
        return FinancialEngine.compute(
            purchasePrice: visit.purchasePrice,
            agencyFees: visit.agencyFees,
            notaryFees: notaryFees,
            works: works,
            downPayment: visit.downPaymentValue,
            annualRatePercent: visit.interestRate,
            loanYears: visit.loanYears,
            monthlyRent: visit.monthlyRent,
            monthlyCharges: visit.monthlyCharges,
            propertyTaxYearly: visit.propertyTaxYearly
        )
    }
}

// MARK: - Checklist Item Row

struct ChecklistItemRow: View {
    @Bindable var item: VisitItem
    
    var body: some View {
        HStack(spacing: 12) {
            // Pill de statut
            StatusPill(status: item.status)
            
            // Informations
            VStack(alignment: .leading, spacing: 4) {
                Text(item.label)
                    .font(.headline)
                
                // Sous-titre contextuel
                if item.status == .bad && item.estimatedCost > 0 {
                    Text("Travaux: \(Formatters.eur(item.estimatedCost))")
                        .font(.subheadline)
                        .foregroundStyle(.orange)
                } else if !item.notes.isEmpty {
                    Text(item.notes)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Indicateur de photos
            if !item.photos.isEmpty {
                HStack(spacing: 2) {
                    Image(systemName: "photo.fill")
                    Text("\(item.photos.count)")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Status Pill

struct StatusPill: View {
    let status: VisitStatus
    
    var body: some View {
        Text(status.displayEmoji)
            .font(.caption.weight(.semibold))
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Theme.statusColor(status).opacity(0.15))
            .foregroundStyle(Theme.statusColor(status))
            .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        RoomDetailView(
            visit: Visit(
                title: "Test",
                mode: .invest,
                purchasePrice: 150000,
                surfaceM2: 45,
                monthlyRent: 650
            ),
            room: Room(name: "Cuisine", typeKey: "kitchen", orderIndex: 0)
        )
    }
    .modelContainer(for: Visit.self, inMemory: true)
}
