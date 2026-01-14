//
//  ItemDetailSheet.swift
//  DealFlow
//
//  Sheet de détail d'un item de checklist.
//
//  Cette vue permet de :
//  - Modifier le statut de l'item (Non vérifié, Bon, Moyen, Mauvais)
//  - Ajouter des notes textuelles libres
//  - Estimer le coût des travaux si nécessaire
//  - Prendre une photo directement avec l'appareil photo
//  - Importer une photo depuis la galerie
//  - Visualiser et supprimer les photos associées
//  - Réinitialiser l'item à son état initial
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
                    
                    // Bouton prise de photo avec l'appareil
                    Button {
                        showCamera = true
                    } label: {
                        Label("Prendre une photo", systemImage: "camera")
                    }
                    
                    // Bouton import depuis la galerie
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
            .fullScreenCover(isPresented: $showCamera) {
                CameraPicker { image in
                    savePhoto(image)
                }
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
            print("Erreur lors du chargement de la photo: \(error)")
        }
        
        self.pickerItem = nil
    }
    
    private func savePhoto(_ image: UIImage) {
        do {
            let fileName = try ImageStore.shared.saveJPEG(image)
            let photoRef = PhotoRef(fileName: fileName)
            item.photos.append(photoRef)
            try? modelContext.save()
        } catch {
            print("Erreur lors de la sauvegarde de la photo: \(error)")
        }
    }
    
    private func deletePhoto(_ photo: PhotoRef) {
        ImageStore.shared.delete(photo.fileName)
        item.photos.removeAll { $0.id == photo.id }
        try? modelContext.save()
    }
    
    private func resetItem() {
        for photo in item.photos {
            ImageStore.shared.delete(photo.fileName)
        }
        
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

// MARK: - Camera Picker

/// Wrapper UIViewControllerRepresentable pour UIImagePickerController
/// Permet de prendre une photo directement avec l'appareil photo sans quitter l'app
struct CameraPicker: UIViewControllerRepresentable {
    let onCapture: (UIImage) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraPicker
        
        init(_ parent: CameraPicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onCapture(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}

// MARK: - Photo Row

/// Ligne affichant une photo avec miniature, informations et bouton de suppression
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
