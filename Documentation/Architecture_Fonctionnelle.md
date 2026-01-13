# Architecture Fonctionnelle de DealFlow

L'architecture fonctionnelle de DealFlow est conçue pour être simple, intuitive et centrée sur l'utilisateur final : l'investisseur immobilier sur le terrain. Elle se décompose en plusieurs modules logiques qui interagissent pour offrir une expérience fluide, de la création d'une visite à la décision finale.

## 1. Diagramme Général des Fonctionnalités

```mermaid
graph TD
    A[Utilisateur] --> B{Démarrer l'Application};
    B --> C[Dashboard des Visites];
    C --> D{Créer une Nouvelle Visite};
    C --> E[Consulter/Supprimer Ancienne Visite];
    D --> F[1. Setup Express];
    F --> G[2. Cockpit de Visite];
    E --> G;
    G --> H[Ajouter/Gérer Pièces];
    G --> I[Consulter Mini-Scoreboard];
    G --> J[Accéder au Verdict];
    H --> K[3. Inspection de Pièce];
    K --> L[Gérer Items de Checklist];
    L --> M[4. Détail d'un Item];
    M --> N[Noter (Bon/Moyen/Mauvais)];
    M --> O[Ajouter Note Texte];
    M --> P[Estimer Coût Travaux];
    M --> Q[Prendre/Gérer Photos];
    J --> R[5. Vue Verdict];
    R --> S[Consulter KPIs Financiers];
    R --> T[Exporter Rapport PDF];

    subgraph "Gestion des Données (Local)"
        U[Modèles SwiftData] -- Stocke --> F;
        U -- Stocke --> K;
        U -- Stocke --> M;
    end

    subgraph "Moteurs de Calcul (Domain)"
        V[FinancialEngine] -- Calcule --> I;
        V -- Calcule --> S;
        W[VerdictEngine] -- Détermine --> I;
        W -- Détermine --> R;
    end
```

## 2. Description des Modules Fonctionnels

### Module 1 : Gestion des Visites (Dashboard)

-   **Objectif** : Point d'entrée de l'application. Permet à l'utilisateur de voir toutes ses visites passées et d'en créer une nouvelle.
-   **Fonctionnalités** :
    -   Affichage de la liste des visites existantes, triées par date de création (la plus récente en premier).
    -   Pour chaque visite : affichage du titre, de la date et d'un indicateur visuel du verdict (couleur).
    -   Possibilité de supprimer une visite (swipe-to-delete).
    -   Un bouton "+" proéminent pour lancer le processus de création d'une nouvelle visite.
    -   Un état vide (empty state) pour guider l'utilisateur lors de sa première utilisation.

### Module 2 : Création et Configuration d'une Visite (Setup Express)

-   **Objectif** : Capturer les informations minimales mais essentielles pour démarrer une visite en moins de 30 secondes.
-   **Fonctionnalités** :
    -   **Choix du Mode de Visite** : `Investir`, `Acheter`, ou `Louer` via un sélecteur segmenté. Le mode `Investir` est sélectionné par défaut.
    -   **Saisie des Informations Clés** :
        -   Titre de la visite (ex: "Appartement 3 pièces, centre-ville").
        -   Prix du bien.
        -   Surface en m².
        -   Loyer mensuel estimé (uniquement pour le mode `Investir`).
    -   Un bouton "Démarrer la visite" qui devient actif uniquement lorsque les informations minimales (prix) sont saisies.

### Module 3 : Pilotage de la Visite (Cockpit de Visite)

-   **Objectif** : Écran principal pendant l'inspection. Offre une vue d'ensemble et un accès rapide à toutes les fonctionnalités de capture d'information.
-   **Fonctionnalités** :
    -   **Mini-Scoreboard** : Un bandeau supérieur affichant en permanence les indicateurs clés mis à jour en temps réel :
        -   Le verdict de couleur (🟢, 🟠, 🔴).
        -   Le cashflow mensuel (pour le mode `Investir`).
        -   Le coût total estimé (incluant travaux).
    -   **Gestion des Pièces** : 
        -   Liste des pièces déjà ajoutées à la visite.
        -   Bouton pour "Ajouter une pièce" (ouvre un sélecteur de type de pièce : chambre, cuisine, etc.).
        -   Navigation vers l'écran d'inspection pour chaque pièce.
    -   **Accès au Verdict Détaillé** : Un bouton pour naviguer vers l'écran de verdict complet.

### Module 4 : Inspection d'une Pièce

-   **Objectif** : Structurer la collecte d'informations pour une pièce donnée (ex: la cuisine).
-   **Fonctionnalités** :
    -   Affichage d'une **checklist pré-remplie** basée sur le type de pièce (ex: pour une cuisine : Plomberie, Électricité, Meubles, etc.).
    -   Pour chaque item de la checklist, l'utilisateur peut :
        -   **Changer le statut** par un simple appui (tap) : `Unknown` -> `Bon` -> `Moyen` -> `Mauvais` -> `Unknown`.
        -   **Accéder aux détails** par un appui long (long press) pour ajouter des notes, un coût ou des photos.

### Module 5 : Détail d'un Item de Checklist

-   **Objectif** : Permettre une qualification fine d'un point de contrôle spécifique (ex: l'état de la plomberie).
-   **Fonctionnalités** :
    -   Modification du statut.
    -   **Ajout de notes textuelles**.
    -   **Estimation du coût des travaux** si l'item est jugé "Mauvais". Ce coût remontera automatiquement dans le calcul financier global.
    -   **Ajout de photos** depuis la galerie ou l'appareil photo pour documenter visuellement l'état de l'item.

### Module 6 : Verdict et Analyse Financière

-   **Objectif** : Fournir une synthèse claire, visuelle et chiffrée pour aider à la décision finale.
-   **Fonctionnalités** :
    -   **Carte de Score (ScoreCard)** : Met en évidence le verdict principal (ex: "Autofinancement ✅") et le cashflow.
    -   **Grille de KPIs** : Affiche les chiffres clés de l'opération :
        -   Coût total d'acquisition.
        -   Montant des travaux.
        -   Mensualité du crédit.
        -   Rentabilité nette.
    -   **Export PDF** : Bouton pour générer et partager un rapport de visite complet.

### Module 7 : Export et Partage

-   **Objectif** : Permettre à l'utilisateur de partager ses conclusions avec des tiers (banquier, associé, agent immobilier) et créer une boucle de croissance pour l'application.
-   **Fonctionnalités** :
    -   Génération d'un document PDF structuré.
    -   Le PDF contient : le titre de la visite, un résumé des KPIs, les photos clés, et le verdict.
    -   Pour la version gratuite (MVP), un **watermark "Analysé via DealFlow"** est ajouté au PDF.
    -   Utilisation du menu de partage natif d'iOS pour envoyer le fichier.
