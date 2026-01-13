//
//  VerdictSnapshot.swift
//  DealFlow
//
//  Structure immuable représentant le verdict d'une visite
//

import Foundation

struct VerdictSnapshot: Equatable {
    /// Couleur du verdict (feu tricolore)
    let color: VerdictColor
    
    /// Message explicatif du verdict
    let message: String
}
