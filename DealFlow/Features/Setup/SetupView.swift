//
//  SetupView.swift
//  DealFlow
//
//  Vue de création d'une nouvelle visite (Setup Express)
//

import SwiftUI

struct SetupView: View {
    let onCreate: (Visit) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - State
    
    @State private var mode: VisitMode = .invest
    @State private var title: String = ""
    @State private var purchasePriceText: String = ""
    @State private var surfaceText: String = ""
    @State private var rentText: String = ""
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                // Section Mode
                Section {
                    Picker("Mode de visite", selection: $mode) {
                        Text("Investir").tag(VisitMode.invest)
                        Text("Acheter").tag(VisitMode.buy)
                        Text("Louer").tag(VisitMode.rent)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("Mode")
                } footer: {
                    Text(modeDescription)
                        .font(.caption)
                }
                
                // Section Informations
                Section("Informations du bien") {
                    TextField("Nom (ex: T2 Centre-ville)", text: $title)
                    
                    HStack {
                        Text("Prix")
                        Spacer()
                        TextField("0", text: $purchasePriceText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Surface")
                        Spacer()
                        TextField("0", text: $surfaceText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("m²")
                            .foregroundStyle(.secondary)
                    }
                    
                    if mode == .invest {
                        HStack {
                            Text("Loyer estimé")
                            Spacer()
                            TextField("0", text: $rentText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("€/mois")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Bouton de création
                Section {
                    Button {
                        createVisit()
                    } label: {
                        Text("Démarrer la visite")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!isValid)
                }
            }
            .navigationTitle("Nouvelle visite")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var modeDescription: String {
        switch mode {
        case .invest:
            return "Calcul du cashflow et de la rentabilité pour un investissement locatif."
        case .buy:
            return "Estimation de la mensualité et des travaux pour une résidence principale."
        case .rent:
            return "Checklist de vivabilité pour évaluer un logement à louer."
        }
    }
    
    private var isValid: Bool {
        parseDouble(purchasePriceText) > 0
    }
    
    // MARK: - Actions
    
    private func createVisit() {
        let visit = Visit(
            title: title.isEmpty ? "Nouvelle visite" : title,
            mode: mode,
            purchasePrice: parseDouble(purchasePriceText),
            surfaceM2: parseDouble(surfaceText),
            monthlyRent: mode == .invest ? parseDouble(rentText) : 0
        )
        onCreate(visit)
    }
    
    // MARK: - Helpers
    
    private func parseDouble(_ string: String) -> Double {
        let cleaned = string.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        return Double(cleaned) ?? 0
    }
}

// MARK: - Preview

#Preview {
    SetupView { visit in
        print("Created visit: \(visit.title)")
    }
}
