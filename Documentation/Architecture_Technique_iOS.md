# Architecture Technique iOS (SwiftUI)

Cette architecture est conçue pour le MVP de DealFlow, en privilégiant la simplicité, la performance et la maintenabilité, tout en posant des bases solides pour les évolutions futures (V1.5 et V2).

## 1. Principes Directeurs

-   **100% Natif SwiftUI & iOS 17+** : Pour une performance optimale, une intégration parfaite à l'écosystème Apple et l'utilisation des dernières APIs.
-   **Local-First avec SwiftData** : Toutes les données sont stockées localement sur l'appareil. L'application est entièrement fonctionnelle hors ligne. SwiftData est choisi pour sa simplicité et son intégration profonde avec SwiftUI.
-   **Architecture en Couches Claires** : Une séparation nette entre la Donnée (Data), la Logique Métier (Domain) et la Présentation (UI/Features) pour faciliter les tests, la maintenance et l'évolution.
-   **Domain Métier Pur et Testable** : Les moteurs de calcul (`FinancialEngine`, `VerdictEngine`) sont des `structs` pures, sans dépendances à SwiftUI ou SwiftData. Ils prennent des valeurs en entrée et retournent des résultats, ce qui les rend facilement testables unitairement.
-   **UI Conçue pour l'Efficacité** : Les vues sont simples et optimisées pour une interaction rapide sur le terrain (gros boutons, navigation claire).
-   **Pas de ViewModels Complexes pour le MVP** : Pour le MVP, les vues interagissent directement avec les modèles SwiftData et les moteurs du domaine. Cela simplifie le code et évite la complexité de l'injection de dépendances (`ModelContext`) dans des `ObservableObjects`. Une refactorisation vers des `Stores` ou `ViewModels` plus robustes est prévue pour les versions futures si le besoin s'en fait sentir.

## 2. Structure des Dossiers Xcode

L'organisation des fichiers dans Xcode suivra une structure claire par fonctionnalité et par couche.

```text
DealFlow/
  ├─ App/
  │  ├─ DealFlowApp.swift       # Point d'entrée de l'app
  │  ├─ AppContainer.swift      # Conteneur SwiftData partagé
  │  └─ Theme/                  # Couleurs, polices, formatters
  │     ├─ Theme.swift
  │     └─ Formatters.swift
  │
  ├─ Data/
  │  ├─ SwiftDataModels/        # Modèles de données SwiftData
  │  │  ├─ Visit.swift
  │  │  ├─ Room.swift
  │  │  ├─ VisitItem.swift
  │  │  ├─ PhotoRef.swift
  │  │  └─ Enums.swift
  │  └─ Repositories/           # (Optionnel pour V1) Abstraction des accès data
  │     └─ VisitRepository.swift
  │
  ├─ Domain/
  │  ├─ Financial/              # Moteur de calcul financier
  │  │  ├─ FinancialEngine.swift
  │  │  └─ FinancialSnapshot.swift
  │  ├─ Verdict/                # Moteur de calcul du verdict
  │  │  ├─ VerdictEngine.swift
  │  │  └─ VerdictSnapshot.swift
  │  └─ Checklist/              # Logique des checklists
  │     └─ ChecklistTemplates.swift
  │
  ├─ Features/                 # Dossiers par fonctionnalité (écran)
  │  ├─ Dashboard/
  │  │  ├─ DashboardView.swift
  │  │  └─ VisitCardRow.swift
  │  ├─ Setup/
  │  │  └─ SetupView.swift
  │  ├─ Visit/
  │  │  ├─ VisitCockpitView.swift
  │  │  └─ MiniScoreboard.swift
  │  ├─ Room/
  │  │  ├─ RoomDetailView.swift
  │  │  ├─ ChecklistItemRow.swift
  │  │  └─ ItemDetailSheet.swift
  │  └─ Verdict/
  │     ├─ VerdictView.swift
  │     ├─ ScoreCard.swift
  │     └─ KPIGrid.swift
  │
  ├─ Services/
  │  ├─ Storage/                # Service de stockage des images
  │  │  └─ ImageStore.swift
  │  └─ PDF/                    # Service de génération de PDF
  │     └─ PDFExporter.swift
  │
  └─ Resources/
     └─ Assets.xcassets
```

## 3. Couche de Données (Data Layer)

-   **Framework** : **SwiftData**.
-   **Modèles Principaux** :
    -   `Visit`: L'objet racine. Contient les informations générales de la visite (prix, mode, etc.) et une relation vers ses pièces.
    -   `Room`: Représente une pièce inspectée (ex: Cuisine). Contient une relation vers ses items de checklist.
    -   `VisitItem`: Un point de contrôle dans une pièce (ex: État de la plomberie). Contient son statut, notes, coût et une relation vers ses photos.
    -   `PhotoRef`: Ne stocke pas l'image binaire dans la base de données pour des raisons de performance. Il contient uniquement une **référence (nom de fichier)** vers l'image stockée sur le disque.
-   **Stockage des Images** : Les photos sont enregistrées sous forme de fichiers JPEG dans le répertoire `Documents` de l'application, géré par le service `ImageStore`.

## 4. Couche Métier (Domain Layer)

Cette couche est le cœur de la logique de l'application. Elle est totalement indépendante de l'UI et de la persistance.

-   `FinancialEngine`: Une `struct` avec des méthodes statiques pour tous les calculs financiers (mensualité de prêt, frais de notaire, coût total, cashflow, rentabilité). Elle prend des nombres en entrée et retourne une `FinancialSnapshot`.
-   `VerdictEngine`: Une `struct` avec une méthode statique qui prend le cashflow en entrée et retourne un `VerdictSnapshot` (couleur et message).
-   `ChecklistTemplates`: Fournit les listes de points de contrôle par défaut pour chaque type de pièce.

## 5. Couche de Présentation (Features/UI)

-   **Framework** : **SwiftUI**.
-   **Navigation** : Une `NavigationStack` principale est utilisée pour gérer le flux de navigation entre le `Dashboard`, le `VisitCockpit` et les autres vues.
-   **Gestion de l'État** : L'état est principalement géré par les wrappers de propriété de SwiftUI (`@State`, `@Environment`) et les modèles SwiftData qui sont nativement observables.
-   **Vues Clés** :
    -   `DashboardView`: Utilise `@Query` pour afficher la liste des visites.
    -   `SetupView`: Un formulaire simple présenté en `sheet` pour créer une nouvelle visite.
    -   `VisitCockpitView`: L'écran central qui agrège les informations et permet la navigation vers les pièces et le verdict.
    -   `RoomDetailView`: Affiche la checklist d'une pièce. Utilise des gestes (`onTapGesture`, `onLongPressGesture`) pour une interaction rapide.
    -   `ItemDetailSheet`: Un `sheet` pour éditer les détails d'un item (notes, coût, photos).
    -   `VerdictView`: Affiche les KPIs finaux et le bouton d'export PDF.

## 6. Services

-   `ImageStore`: Un singleton responsable de la sauvegarde, du chargement et de la suppression des images sur le système de fichiers. Il garantit que le répertoire des photos existe.
-   `PDFExporter`: Un service avec une méthode statique pour générer le rapport de visite en PDF en utilisant `UIGraphicsPDFRenderer`. Il s'exécute sur un thread d'arrière-plan pour ne pas bloquer l'UI.

## 7. Scalabilité et Évolutions Futures

L'architecture actuelle est prête à évoluer :

-   **V1.5 (Pro)** : 
    -   De nouveaux modèles SwiftData (`ChecklistTemplate`, `DealFlowIndex`) peuvent être ajoutés sans impacter l'existant.
    -   Le `PDFExporter` sera étendu pour générer un format "Dossier Bancaire".
    -   Un service `StoreManager` (utilisant StoreKit 2) sera ajouté pour gérer l'achat in-app.
-   **V2 (Scale)** :
    -   **Synchronisation Cloud** : L'utilisation de SwiftData facilite grandement l'intégration future de CloudKit. Le `ModelConfiguration` sera simplement mis à jour pour activer la synchronisation.
    -   **Collaboration** : Le partage de visites pourra être implémenté en utilisant les fonctionnalités de partage de CloudKit.

Cette architecture modulaire et découplée garantit que l'ajout de nouvelles fonctionnalités se fera de manière propre et maîtrisée, sans nécessiter de refonte majeure.
