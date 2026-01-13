# DealFlow

**DealFlow** est une application iOS native conçue pour accompagner les investisseurs immobiliers pendant leurs visites de biens. Elle permet de qualifier rapidement un bien et de décider s'il mérite d'aller plus loin.

*Visite. Observe. Décide.*

## Vision

DealFlow est un **outil de terrain** qui permet de :
- Structurer l'inspection d'un bien immobilier pièce par pièce
- Capturer des notes, photos et estimations de travaux de manière organisée
- Calculer en temps réel le cashflow et la rentabilité
- Obtenir un verdict clair (GO / À creuser / STOP) pour prendre une décision immédiate

## Fonctionnalités MVP

### Modes de visite
- **Investir** (mode par défaut) : Calcul du cashflow et de la rentabilité pour investissement locatif
- **Acheter** : Estimation de la mensualité pour résidence principale
- **Louer** : Checklist de vivabilité pour locataires

### Parcours utilisateur
1. Créer une visite avec les informations de base (prix, surface, loyer)
2. Ajouter des pièces à inspecter
3. Remplir les checklists avec statuts (Bon/Moyen/Mauvais)
4. Ajouter des notes et photos pour chaque point
5. Estimer les coûts de travaux
6. Consulter le verdict et les KPIs financiers
7. Exporter un rapport PDF

### Caractéristiques techniques
- 100% **offline** (local-first avec SwiftData)
- Pas de compte utilisateur requis
- Interface optimisée pour utilisation à une main
- Export PDF avec watermark (version gratuite)

## Architecture

```
DealFlow/
├── App/                    # Point d'entrée et configuration
│   ├── DealFlowApp.swift
│   ├── AppContainer.swift
│   └── Theme/
├── Data/                   # Modèles SwiftData
│   └── SwiftDataModels/
├── Domain/                 # Logique métier pure
│   ├── Financial/
│   ├── Verdict/
│   └── Checklist/
├── Features/               # Vues par fonctionnalité
│   ├── Dashboard/
│   ├── Setup/
│   ├── Visit/
│   ├── Room/
│   └── Verdict/
├── Services/               # Services techniques
│   ├── Storage/
│   └── PDF/
└── Documentation/          # Documentation du projet
```

## Prérequis

- iOS 17.0+
- Xcode 15.0+
- Swift 5.9+

## Installation

1. Cloner le repository
2. Ouvrir le projet dans Xcode
3. Créer un nouveau projet iOS App avec SwiftUI
4. Copier les fichiers du dossier `DealFlow/` dans votre projet
5. Build et Run

## Documentation

- [Compréhension du Projet](Documentation/Comprehension_Projet.md)
- [Architecture Fonctionnelle](Documentation/Architecture_Fonctionnelle.md)
- [Architecture Technique iOS](Documentation/Architecture_Technique_iOS.md)

## Roadmap

### V1.5 - Pro Investisseur
- Score global du bien (A/B/C/D)
- Scénarios pessimiste/réaliste/optimiste
- Dossier bancaire PDF structuré
- Historique et comparaison de biens
- Suppression du watermark (payant)

### V2 - Business / Scale
- Synchronisation cloud (CloudKit)
- Multi-appareils
- Partage de visites
- Marque blanche PDF
- Paramètres avancés de scoring

## Licence

Projet privé - Tous droits réservés

---

*Développé avec SwiftUI et SwiftData*
