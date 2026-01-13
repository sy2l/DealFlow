//
//  ImageStore.swift
//  DealFlow
//
//  Service de stockage des images sur le système de fichiers
//  Les images sont stockées en JPEG dans Documents/photos/
//

import UIKit

final class ImageStore {
    
    // MARK: - Singleton
    
    static let shared = ImageStore()
    private init() {}
    
    // MARK: - Configuration
    
    /// Répertoire de base pour le stockage des photos
    private var baseURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("photos", isDirectory: true)
    }
    
    // MARK: - Gestion du répertoire
    
    /// S'assure que le répertoire de photos existe
    func ensureFolder() throws {
        if !FileManager.default.fileExists(atPath: baseURL.path) {
            try FileManager.default.createDirectory(
                at: baseURL,
                withIntermediateDirectories: true,
                attributes: nil
            )
        }
    }
    
    // MARK: - Sauvegarde
    
    /// Sauvegarde une image en JPEG
    /// - Parameters:
    ///   - image: L'image UIImage à sauvegarder
    ///   - quality: Qualité de compression JPEG (0.0 à 1.0)
    /// - Returns: Le nom du fichier créé
    /// - Throws: Erreur si la sauvegarde échoue
    func saveJPEG(_ image: UIImage, quality: CGFloat = 0.85) throws -> String {
        try ensureFolder()
        
        let name = UUID().uuidString + ".jpg"
        let url = baseURL.appendingPathComponent(name)
        
        guard let data = image.jpegData(compressionQuality: quality) else {
            throw ImageStoreError.compressionFailed
        }
        
        try data.write(to: url, options: .atomic)
        return name
    }
    
    // MARK: - Chargement
    
    /// Charge une image depuis le stockage
    /// - Parameter fileName: Nom du fichier à charger
    /// - Returns: L'image UIImage ou nil si non trouvée
    func load(_ fileName: String) -> UIImage? {
        let url = baseURL.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: url.path)
    }
    
    /// Retourne l'URL complète d'un fichier image
    /// - Parameter fileName: Nom du fichier
    /// - Returns: URL du fichier
    func url(for fileName: String) -> URL {
        return baseURL.appendingPathComponent(fileName)
    }
    
    // MARK: - Suppression
    
    /// Supprime une image du stockage
    /// - Parameter fileName: Nom du fichier à supprimer
    func delete(_ fileName: String) {
        let url = baseURL.appendingPathComponent(fileName)
        try? FileManager.default.removeItem(at: url)
    }
    
    /// Supprime toutes les images orphelines (non référencées)
    /// Note: À implémenter pour V1.5 avec un scan des PhotoRef
    func cleanupOrphans() {
        // TODO: V1.5 - Scanner les PhotoRef et supprimer les fichiers non référencés
    }
}

// MARK: - Erreurs

enum ImageStoreError: Error, LocalizedError {
    case compressionFailed
    case saveFailed
    
    var errorDescription: String? {
        switch self {
        case .compressionFailed:
            return "Impossible de compresser l'image"
        case .saveFailed:
            return "Impossible de sauvegarder l'image"
        }
    }
}
