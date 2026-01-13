//
//  VisitCockpitView.swift
//  DealFlow
//
//  Vue principale de pilotage d'une visite
//

import SwiftUI
import SwiftData

struct VisitCockpitView: View {
    @Environment(\.modelContext) private var modelContext
    
    let visit: Visit
    private let templates = ChecklistTemplates()
    
    @State private var showAddRoom = false
    @State private var selectedRoom: Room?
    @State private var showVerdict = false
    @State private var showFinancialSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Mini Scoreboard en haut
            MiniScoreboard(
                visit: visit,
                snapshot: financialSnapshot(),
                verdict: verdictSnapshot()
            )
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 6)
            
            // Liste des pièces
            List {
                // Bouton d'ajout de pièce
                Section {
                    Button {
                        showAddRoom = true
                    } label: {
                        Label("Ajouter une pièce", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                }
                
                // Liste des pièces
                Section("Pièces") {
                    if sortedRooms.isEmpty {
                        Text("Ajoutez une pièce pour commencer l'inspection.")
                            .foregroundStyle(.secondary)
                            .font(.subheadline)
                    } else {
                        ForEach(sortedRooms) { room in
                            Button {
                                selectedRoom = room
                            } label: {
                                RoomRow(room: room)
                            }
                            .buttonStyle(.plain)
                        }
                        .onDelete(perform: deleteRooms)
                    }
                }
            }
        }
        .navigationTitle(visit.title)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        showVerdict = true
                    } label: {
                        Label("Verdict", systemImage: "chart.bar.fill")
                    }
                    
                    Button {
                        showFinancialSettings = true
                    } label: {
                        Label("Paramètres financiers", systemImage: "eurosign.circle")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showAddRoom) {
            AddRoomSheet { typeKey, name in
                addRoom(typeKey: typeKey, name: name)
            }
        }
        .sheet(isPresented: $showFinancialSettings) {
            FinancialSettingsSheet(visit: visit)
        }
        .navigationDestination(item: $selectedRoom) { room in
            RoomDetailView(visit: visit, room: room)
        }
        .navigationDestination(isPresented: $showVerdict) {
            VerdictView(visit: visit)
        }
        .onAppear {
            updateVerdict()
        }
    }
    
    // MARK: - Computed Properties
    
    private var sortedRooms: [Room] {
        visit.rooms.sorted { $0.orderIndex < $1.orderIndex }
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
    
    private func addRoom(typeKey: String, name: String) {
        let order = (visit.rooms.map(\.orderIndex).max() ?? -1) + 1
        let room = Room(name: name, typeKey: typeKey, orderIndex: order)
        
        // Ajouter les items de checklist depuis le template
        room.items = templates.items(for: typeKey, mode: visit.mode)
            .map { VisitItem(templateKey: $0.key, label: $0.label) }
        
        visit.rooms.append(room)
        try? modelContext.save()
    }
    
    private func deleteRooms(_ indexSet: IndexSet) {
        let roomsToDelete = indexSet.map { sortedRooms[$0] }
        for room in roomsToDelete {
            // Supprimer les photos associées
            for item in room.items {
                for photo in item.photos {
                    ImageStore.shared.delete(photo.fileName)
                }
            }
            visit.rooms.removeAll { $0.id == room.id }
        }
        try? modelContext.save()
    }
    
    private func updateVerdict() {
        visit.verdictColor = verdictSnapshot().color
        try? modelContext.save()
    }
}

// MARK: - Room Row

struct RoomRow: View {
    let room: Room
    
    var body: some View {
        HStack(spacing: 12) {
            // Icône du type de pièce
            Image(systemName: iconForRoomType(room.typeKey))
                .font(.title3)
                .foregroundStyle(.secondary)
                .frame(width: 32)
            
            // Informations
            VStack(alignment: .leading, spacing: 4) {
                Text(room.name)
                    .font(.headline)
                
                Text(statusSummary)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Indicateur de progression
            ProgressCircle(progress: completionProgress)
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
    
    private var statusSummary: String {
        let total = room.items.count
        let checked = room.items.filter { $0.status != .unknown }.count
        return "\(checked)/\(total) vérifiés"
    }
    
    private var completionProgress: Double {
        guard !room.items.isEmpty else { return 0 }
        let checked = room.items.filter { $0.status != .unknown }.count
        return Double(checked) / Double(room.items.count)
    }
    
    private func iconForRoomType(_ typeKey: String) -> String {
        switch typeKey {
        case "bedroom": return "bed.double"
        case "living": return "sofa"
        case "kitchen": return "fork.knife"
        case "bathroom": return "shower"
        case "wc": return "toilet"
        case "entry": return "door.left.hand.open"
        case "outside": return "tree"
        default: return "square.grid.2x2"
        }
    }
}

// MARK: - Progress Circle

struct ProgressCircle: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.secondary.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(progressColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: 24, height: 24)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return .green
        } else if progress >= 0.5 {
            return .orange
        } else {
            return .secondary
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        VisitCockpitView(visit: Visit(
            title: "Appartement Test",
            mode: .invest,
            purchasePrice: 150000,
            surfaceM2: 45,
            monthlyRent: 650
        ))
    }
    .modelContainer(for: Visit.self, inMemory: true)
}
