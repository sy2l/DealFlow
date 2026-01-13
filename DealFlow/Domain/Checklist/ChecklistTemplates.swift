//
//  ChecklistTemplates.swift
//  DealFlow
//
//  Templates de checklists par type de pièce
//  MVP: Templates en dur dans le code
//  V1.5: Pourra évoluer vers JSON externe ou SwiftData
//

import Foundation

struct ChecklistTemplates {
    
    // MARK: - Types
    
    struct TemplateItem {
        let key: String
        let label: String
    }
    
    // MARK: - Méthode principale
    
    /// Retourne les items de checklist pour un type de pièce et un mode de visite
    /// - Parameters:
    ///   - roomTypeKey: Clé du type de pièce (ex: "kitchen", "bedroom")
    ///   - mode: Mode de visite actuel
    /// - Returns: Liste des items de checklist
    func items(for roomTypeKey: String, mode: VisitMode) -> [TemplateItem] {
        switch roomTypeKey {
        case "bedroom":
            return bedroomItems(mode: mode)
        case "living":
            return livingItems(mode: mode)
        case "kitchen":
            return kitchenItems(mode: mode)
        case "bathroom":
            return bathroomItems(mode: mode)
        case "wc":
            return wcItems(mode: mode)
        case "entry":
            return entryItems(mode: mode)
        case "outside":
            return outsideItems(mode: mode)
        default:
            return defaultItems(roomTypeKey: roomTypeKey, mode: mode)
        }
    }
    
    // MARK: - Templates par pièce
    
    private func bedroomItems(mode: VisitMode) -> [TemplateItem] {
        var items = [
            TemplateItem(key: "bedroom.walls", label: "Murs / Peinture"),
            TemplateItem(key: "bedroom.floor", label: "Sol"),
            TemplateItem(key: "bedroom.window", label: "Fenêtre / Isolation"),
            TemplateItem(key: "bedroom.electric", label: "Prises / Électricité"),
            TemplateItem(key: "bedroom.humidity", label: "Humidité")
        ]
        
        // Items supplémentaires pour mode locataire
        if mode == .rent {
            items.append(TemplateItem(key: "bedroom.noise", label: "Bruit extérieur"))
            items.append(TemplateItem(key: "bedroom.light", label: "Luminosité naturelle"))
        }
        
        return items
    }
    
    private func livingItems(mode: VisitMode) -> [TemplateItem] {
        var items = [
            TemplateItem(key: "living.walls", label: "Murs / Peinture"),
            TemplateItem(key: "living.floor", label: "Sol"),
            TemplateItem(key: "living.window", label: "Fenêtres / Isolation"),
            TemplateItem(key: "living.electric", label: "Prises / Électricité"),
            TemplateItem(key: "living.heating", label: "Chauffage")
        ]
        
        if mode == .rent {
            items.append(TemplateItem(key: "living.noise", label: "Bruit extérieur"))
            items.append(TemplateItem(key: "living.light", label: "Luminosité naturelle"))
        }
        
        return items
    }
    
    private func kitchenItems(mode: VisitMode) -> [TemplateItem] {
        return [
            TemplateItem(key: "kitchen.plumbing", label: "Plomberie / Évier"),
            TemplateItem(key: "kitchen.vent", label: "Ventilation / Hotte"),
            TemplateItem(key: "kitchen.electric", label: "Prises / Tableaux"),
            TemplateItem(key: "kitchen.furniture", label: "Meubles / État"),
            TemplateItem(key: "kitchen.window", label: "Fenêtre / Isolation"),
            TemplateItem(key: "kitchen.appliances", label: "Électroménager")
        ]
    }
    
    private func bathroomItems(mode: VisitMode) -> [TemplateItem] {
        return [
            TemplateItem(key: "bathroom.plumbing", label: "Plomberie / Robinetterie"),
            TemplateItem(key: "bathroom.shower", label: "Douche / Baignoire"),
            TemplateItem(key: "bathroom.vent", label: "Ventilation / VMC"),
            TemplateItem(key: "bathroom.humidity", label: "Humidité / Moisissures"),
            TemplateItem(key: "bathroom.tiles", label: "Carrelage / Joints"),
            TemplateItem(key: "bathroom.electric", label: "Électricité")
        ]
    }
    
    private func wcItems(mode: VisitMode) -> [TemplateItem] {
        return [
            TemplateItem(key: "wc.toilet", label: "WC / Chasse d'eau"),
            TemplateItem(key: "wc.plumbing", label: "Plomberie"),
            TemplateItem(key: "wc.vent", label: "Ventilation"),
            TemplateItem(key: "wc.general", label: "État général")
        ]
    }
    
    private func entryItems(mode: VisitMode) -> [TemplateItem] {
        return [
            TemplateItem(key: "entry.door", label: "Porte d'entrée"),
            TemplateItem(key: "entry.intercom", label: "Interphone / Digicode"),
            TemplateItem(key: "entry.floor", label: "Sol"),
            TemplateItem(key: "entry.electric", label: "Électricité / Tableau")
        ]
    }
    
    private func outsideItems(mode: VisitMode) -> [TemplateItem] {
        var items = [
            TemplateItem(key: "outside.facade", label: "Façade / Ravalement"),
            TemplateItem(key: "outside.roof", label: "Toiture"),
            TemplateItem(key: "outside.common", label: "Parties communes")
        ]
        
        // Items spécifiques investisseur
        if mode == .invest || mode == .buy {
            items.append(TemplateItem(key: "outside.parking", label: "Parking / Garage"))
            items.append(TemplateItem(key: "outside.garden", label: "Jardin / Extérieur"))
        }
        
        return items
    }
    
    private func defaultItems(roomTypeKey: String, mode: VisitMode) -> [TemplateItem] {
        return [
            TemplateItem(key: "\(roomTypeKey).general", label: "État général"),
            TemplateItem(key: "\(roomTypeKey).walls", label: "Murs / Peinture"),
            TemplateItem(key: "\(roomTypeKey).floor", label: "Sol"),
            TemplateItem(key: "\(roomTypeKey).electric", label: "Électricité"),
            TemplateItem(key: "\(roomTypeKey).humidity", label: "Humidité")
        ]
    }
}
