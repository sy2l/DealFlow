//
//  PhotoRef.swift
//  DealFlow
//
//  Modèle représentant une référence vers une photo stockée sur le disque
//  Note: On ne stocke pas l'image binaire dans SwiftData pour des raisons de performance
//

import SwiftData
import Foundation

@Model
final class PhotoRef {
    // MARK: - Identifiants
    
    @Attribute(.unique) var id: UUID
    var createdAt: Date
    
    // MARK: - Référence fichier
    
    /// Nom du fichier image (stocké dans Documents/photos/)
    var fileName: String
    
    /// Nom du fichier miniature (optionnel, pour V1.5)
    var thumbFileName: String?
    
    /// Légende de la photo (optionnel)
    var caption: String?
    
    // MARK: - Relations
    
    var item: VisitItem?
    
    // MARK: - Initialisation
    
    init(fileName: String, thumbFileName: String? = nil, caption: String? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.fileName = fileName
        self.thumbFileName = thumbFileName
        self.caption = caption
    }
}
