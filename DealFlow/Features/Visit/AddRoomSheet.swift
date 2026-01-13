//
//  AddRoomSheet.swift
//  DealFlow
//
//  Sheet pour ajouter une nouvelle pièce à la visite
//

import SwiftUI

struct AddRoomSheet: View {
    let onAdd: (_ typeKey: String, _ name: String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var typeKey: String = "bedroom"
    @State private var name: String = "Chambre"
    
    // Types de pièces disponibles
    private let roomTypes: [(key: String, label: String, icon: String)] = [
        ("bedroom", "Chambre", "bed.double"),
        ("living", "Salon", "sofa"),
        ("kitchen", "Cuisine", "fork.knife"),
        ("bathroom", "Salle de bain", "shower"),
        ("wc", "WC", "toilet"),
        ("entry", "Entrée", "door.left.hand.open"),
        ("outside", "Extérieur", "tree"),
        ("other", "Autre", "square.grid.2x2")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                // Sélection du type
                Section("Type de pièce") {
                    ForEach(roomTypes, id: \.key) { roomType in
                        Button {
                            typeKey = roomType.key
                            name = roomType.label
                        } label: {
                            HStack {
                                Image(systemName: roomType.icon)
                                    .frame(width: 24)
                                    .foregroundStyle(.secondary)
                                
                                Text(roomType.label)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                if typeKey == roomType.key {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.blue)
                                }
                            }
                        }
                    }
                }
                
                // Nom personnalisé
                Section("Nom affiché") {
                    TextField("Ex: Chambre 1", text: $name)
                }
                
                // Bouton d'ajout
                Section {
                    Button {
                        onAdd(typeKey, name.isEmpty ? "Pièce" : name)
                        dismiss()
                    } label: {
                        Text("Ajouter")
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .navigationTitle("Ajouter une pièce")
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
}

// MARK: - Preview

#Preview {
    AddRoomSheet { typeKey, name in
        print("Added room: \(name) (\(typeKey))")
    }
}
