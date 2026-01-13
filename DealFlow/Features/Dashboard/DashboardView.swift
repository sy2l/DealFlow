//
//  DashboardView.swift
//  DealFlow
//
//  Vue principale - Liste des visites
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Visit.createdAt, order: .reverse) private var visits: [Visit]
    
    @State private var showSetup = false
    @State private var selectedVisit: Visit?
    
    var body: some View {
        NavigationStack {
            Group {
                if visits.isEmpty {
                    emptyState
                } else {
                    listState
                }
            }
            .navigationTitle("DealFlow")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSetup = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showSetup) {
                SetupView { visit in
                    modelContext.insert(visit)
                    try? modelContext.save()
                    selectedVisit = visit
                    showSetup = false
                }
            }
            .navigationDestination(item: $selectedVisit) { visit in
                VisitCockpitView(visit: visit)
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.and.flag")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            
            Text("Aucune visite")
                .font(.title2.weight(.semibold))
            
            Text("Démarrez votre première inspection immobilière.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            
            Button {
                showSetup = true
            } label: {
                Label("Nouvelle visite", systemImage: "plus.circle.fill")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(32)
    }
    
    // MARK: - List State
    
    private var listState: some View {
        List {
            ForEach(visits) { visit in
                Button {
                    selectedVisit = visit
                } label: {
                    VisitCardRow(visit: visit)
                }
                .buttonStyle(.plain)
            }
            .onDelete(perform: deleteVisits)
        }
    }
    
    // MARK: - Actions
    
    private func deleteVisits(_ indexSet: IndexSet) {
        for index in indexSet {
            let visit = visits[index]
            // Supprimer les photos associées
            for room in visit.rooms {
                for item in room.items {
                    for photo in item.photos {
                        ImageStore.shared.delete(photo.fileName)
                    }
                }
            }
            modelContext.delete(visit)
        }
        try? modelContext.save()
    }
}

// MARK: - Visit Card Row

struct VisitCardRow: View {
    let visit: Visit
    
    var body: some View {
        HStack(spacing: 12) {
            // Indicateur de verdict
            VerdictDot(color: visit.verdictColor)
            
            // Informations principales
            VStack(alignment: .leading, spacing: 4) {
                Text(visit.title)
                    .font(.headline)
                    .lineLimit(1)
                
                Text(visit.createdAt.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Badge du mode
            Text(visit.mode.displayName.uppercased())
                .font(.caption.weight(.medium))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(.thinMaterial)
                .clipShape(Capsule())
        }
        .padding(.vertical, 6)
    }
}

// MARK: - Verdict Dot

struct VerdictDot: View {
    let color: VerdictColor
    
    var body: some View {
        Circle()
            .fill(Theme.verdictColor(color))
            .frame(width: 12, height: 12)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .modelContainer(for: Visit.self, inMemory: true)
}
