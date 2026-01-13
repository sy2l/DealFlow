//
//  ItemDetailSheet.swift
//  DealFlow
//
//  Sheet de détail d'un item de checklist
//

import SwiftUI
import SwiftData
import PhotosUI

struct ItemDetailSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var item: VisitItem
    
    @State private var pickerItem: PhotosPickerItem?
    @State private var costText: String = ""
    @State private var showCamera = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Section Statut
                Section("Statut") {
                    Picker("État", selection: $item.status) {
                        Text("Non vérifié").tag(VisitStatus.unknown)
                        Text("Bon").tag(VisitStatus.good)
                        Text("Moyen").tag(VisitStatus.average)
                        Text("Mauvais").tag(VisitStatus.bad)
                    }
                    .pickerStyle(.segmented)
                }
                
                // Section Notes
                Section("Notes") {
                    TextEditor(text: $item.notes)
                        .frame(minHeight: 80)
                }
                
                // Section Coût travaux
                Section {
                    HStack {
                        Text("Coût estimé")
                        Spacer()
                        TextField("0", text: $costText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: costText) { _, newValue in
                                item.estimatedCost = parseDouble(newValue)
                            }
                        Text("€")
                            .foregroundStyle(.secondary)
                    }
                } header: {
                    Text("Travaux")
                } footer: {
                    if item.status != .bad {
                        Text("💡 Le coût est principalement utile si l'item est marqué \"Mauvais\".")
                    }
                }
                
                // Section Photos
                Section("Photos") {
                    if item.photos.isEmpty {
                        Text("Aucune photo")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(item.photos) { photo in
                            PhotoRow(photo: photo) {
                                deletePhoto(photo)
                            }
                        }
                    }
                    
                    // Boutons d'ajout
                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("Depuis la galerie", systemImage: "photo.on.rectangle")
                    }
                    .onChange(of: pickerItem) { _, newItem in
                        Task {
                            await loadPhoto(from: newItem)
                        }
                    }
                }
                
                // Section Réinitialisation
                Section {
                    Button(role: .destructive) {
                        resetItem()
                    } label: {
                        Label("Réinitialiser l'item", systemImage: "arrow.counterclockwise")
                    }
                }
            }
            .navigationTitle(item.label)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Fermer") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button("OK") {
                        try? modelContext.save()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                costText = item.estimatedCost > 0 ? "\(Int(item.estimatedCost))" : ""
            }
        }
    }
    
    // MARK: - Actions
    
    private func loadPhoto(from pickerItem: PhotosPickerItem?) async {
        guard let pickerItem else { return }
        
        do {
            if let data = try await pickerItem.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                let fileName = try ImageStore.shared.saveJPEG(uiImage)
                let photoRef = PhotoRef(fileName: fileName)
                item.photos.append(photoRef)
                try? modelContext.save()
            }
        } catch {
            // MVP: ignorer les erreurs silencieusement
            print("Erreur lors du chargement de la photo: \(error)")
        }
        
        // Reset le picker
        self.pickerItem = nil
    }
    
    private func deletePhoto(_ photo: PhotoRef) {
        ImageStore.shared.delete(photo.fileName)
        item.photos.removeAll { $0.id == photo.id }
        try? modelContext.save()
    }
    
    private func resetItem() {
        // Supprimer les photos
        for photo in item.photos {
            ImageStore.shared.delete(photo.fileName)
        }
        
        // Réinitialiser les valeurs
        item.status = .unknown
        item.estimatedCost = 0
        item.notes = ""
        item.photos.removeAll()
        costText = ""
        
        try? modelContext.save()
    }
    
    private func parseDouble(_ string: String) -> Double {
        let cleaned = string.replacingOccurrences(of: ",", with: ".")
            .replacingOccurrences(of: " ", with: "")
        return Double(cleaned) ?? 0
    }
}

// MARK: - Photo Row

struct PhotoRow: View {
    let photo: PhotoRef
    let onDelete: () -> Void
    
    @State private var image: UIImage?
    
    var body: some View {
        HStack {
            // Miniature
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 50, height: 50)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            } else {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 50, height: 50)
                    .overlay {
                        Image(systemName: "photo")
                            .foregroundStyle(.secondary)
                    }
            }
            
            // Informations
            VStack(alignment: .leading) {
                Text(photo.fileName)
                    .font(.caption)
                    .lineLimit(1)
                
                Text(photo.createdAt.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            // Bouton supprimer
            Button(role: .destructive) {
                onDelete()
            } label: {
                Image(systemName: "trash")
            }
        }
        .onAppear {
            image = ImageStore.shared.load(photo.fileName)
        }
    }
}

// MARK: - Preview

#Preview {
    let item = VisitItem(templateKey: "kitchen.plumbing", label: "Plomberie / Évier")
    return ItemDetailSheet(item: item)
        .modelContainer(for: VisitItem.self, inMemory: true)
}
