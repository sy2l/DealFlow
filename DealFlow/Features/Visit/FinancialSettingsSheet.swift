//
//  FinancialSettingsSheet.swift
//  DealFlow
//
//  Sheet pour modifier les paramètres financiers d'une visite
//

import SwiftUI
import SwiftData

struct FinancialSettingsSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var visit: Visit
    
    // State pour les champs texte
    @State private var purchasePriceText: String = ""
    @State private var rentText: String = ""
    @State private var chargesText: String = ""
    @State private var taxText: String = ""
    @State private var agencyFeesText: String = ""
    @State private var downPaymentText: String = ""
    @State private var interestRateText: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Section Prix
                Section("Prix et revenus") {
                    HStack {
                        Text("Prix d'achat")
                        Spacer()
                        TextField("0", text: $purchasePriceText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                    
                    if visit.mode == .invest {
                        HStack {
                            Text("Loyer mensuel")
                            Spacer()
                            TextField("0", text: $rentText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                            Text("€")
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                
                // Section Charges
                Section("Charges") {
                    HStack {
                        Text("Charges mensuelles")
                        Spacer()
                        TextField("0", text: $chargesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Taxe foncière annuelle")
                        Spacer()
                        TextField("0", text: $taxText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Section Frais
                Section("Frais d'acquisition") {
                    HStack {
                        Text("Frais d'agence")
                        Spacer()
                        TextField("0", text: $agencyFeesText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                    
                    Toggle("Bien neuf (frais notaire réduits)", isOn: $visit.notaryIsNew)
                }
                
                // Section Financement
                Section("Financement") {
                    HStack {
                        Text("Apport")
                        Spacer()
                        TextField("0", text: $downPaymentText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("Taux d'intérêt")
                        Spacer()
                        TextField("4.0", text: $interestRateText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                        Text("%")
                            .foregroundStyle(.secondary)
                    }
                    
                    Stepper("Durée: \(visit.loanYears) ans", value: $visit.loanYears, in: 5...30)
                }
            }
            .navigationTitle("Paramètres financiers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Annuler") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Enregistrer") {
                        saveChanges()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                loadValues()
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadValues() {
        purchasePriceText = visit.purchasePrice > 0 ? "\(Int(visit.purchasePrice))" : ""
        rentText = visit.monthlyRent > 0 ? "\(Int(visit.monthlyRent))" : ""
        chargesText = visit.monthlyCharges > 0 ? "\(Int(visit.monthlyCharges))" : ""
        taxText = visit.propertyTaxYearly > 0 ? "\(Int(visit.propertyTaxYearly))" : ""
        agencyFeesText = visit.agencyFees > 0 ? "\(Int(visit.agencyFees))" : ""
        downPaymentText = visit.downPaymentValue > 0 ? "\(Int(visit.downPaymentValue))" : ""
        interestRateText = String(format: "%.1f", visit.interestRate)
    }
    
    private func saveChanges() {
        visit.purchasePrice = parseDouble(purchasePriceText)
        visit.monthlyRent = parseDouble(rentText)
        visit.monthlyCharges = parseDouble(chargesText)
        visit.propertyTaxYearly = parseDouble(taxText)
        visit.agencyFees = parseDouble(agencyFeesText)
        visit.downPaymentValue = parseDouble(downPaymentText)
        visit.interestRate = parseDouble(interestRateText)
        
        try? modelContext.save()
    }
    
    private func parseDouble(_ string: String) -> Double {
        let cleaned = string.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        return Double(cleaned) ?? 0
    }
}

// MARK: - Preview

#Preview {
    FinancialSettingsSheet(visit: Visit(
        title: "Test",
        mode: .invest,
        purchasePrice: 150000,
        surfaceM2: 45,
        monthlyRent: 650
    ))
    .modelContainer(for: Visit.self, inMemory: true)
}
