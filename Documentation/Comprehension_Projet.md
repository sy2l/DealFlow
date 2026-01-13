# Compréhension du Projet : DealFlow

## Vision du Produit

**DealFlow** est conçu comme un **outil de terrain** pour les investisseurs immobiliers. Sa mission est de permettre une **qualification rapide et efficace d'un bien immobilier pendant la visite**, afin de prendre une décision éclairée sur la pertinence de poursuivre ou non l'opportunité.

Le slogan interne qui résume cette vision est : *Visite. Observe. Décide.*

## Problématique Ciblée

L'application s'attaque à un problème concret et récurrent pour les investisseurs immobiliers :

- **Surcharge d'informations** : Visites de nombreux biens, entraînant l'oubli de détails techniques importants.
- **Désorganisation** : Prise de notes et de photos de manière non structurée, rendant l'analyse post-visite difficile.
- **Calculs tardifs ou imprécis** : Les calculs de rentabilité sont souvent faits après la visite, de manière approximative, ce qui retarde la prise de décision.
- **Incapacité à décider sur le terrain** : L'investisseur ne peut pas déterminer immédiatement si le bien justifie une offre ou une analyse plus poussée.

L'enjeu principal n'est pas tant la précision des calculs que la capacité à **décider rapidement et sereinement sur place**, en réduisant la charge mentale.

## Promesse de DealFlow

> **DealFlow permet de savoir, en 15 minutes et pendant la visite, si un bien mérite d’aller plus loin… ou d’être écarté.**

L'application se positionne comme un **compagnon de visite**, et non comme un simple tableur mobile ou un outil fiscal complexe.

## Fonctionnalités Clés et Expérience Utilisateur

L'expérience est centrée sur l'efficacité pendant la visite, avec une interface conçue pour une utilisation à une main.

### Modes de Visite

Pour clarifier l'usage sans complexifier l'application, un **mode de visite** est choisi à la création de chaque visite. Ce mode adapte l'interface (check-lists, champs financiers, verdict) sans altérer le flux principal.

| Mode | Cible | Fonctionnalités Spécifiques |
| :--- | :--- | :--- |
| **Investir / Faire louer** | Investisseurs locatifs (Cœur de cible) | Check-list orientée coût/risque, estimation des travaux, calcul de **cashflow et rentabilité**, verdict **GO / À CREUSER / STOP**. |
| **Acheter** | Résidence principale (Cible secondaire) | Check-list technique renforcée, estimation globale des travaux, calcul de la **mensualité**, verdict orienté **risque/renégociation**. |
| **Louer** | Locataires (Grand public) | Check-list de "vivabilité", prise de photos et notes, verdict basé sur l'état général uniquement (aucun calcul financier). |

### Cœur de l'Expérience

1.  **Visite Structurée** : L'utilisateur crée une "Visite" et ajoute des pièces (Cuisine, Chambre, etc.) au fur et à mesure. Chaque pièce dispose d'une check-list pré-remplie.
2.  **Capture Contextualisée** : Pour chaque item de la check-list, l'utilisateur peut assigner un statut (✅ Bon, ⚠️ Moyen, ❌ Mauvais), prendre une photo, ajouter une note et estimer un coût de travaux si nécessaire. Les coûts sont agrégés automatiquement.
3.  **Calcul Financier en Temps Réel** : Les données financières (prix, loyer, charges) sont saisies et l'application calcule instantanément le cashflow, la rentabilité ou l'effort mensuel, sans action manuelle de l'utilisateur.
4.  **Verdict Visuel** : Un indicateur tricolore (🟢, 🟠, 🔴), basé principalement sur le cashflow pour le mode investisseur, fournit une décision claire et immédiate.
5.  **Export PDF Professionnel** : Un rapport de visite structuré (résumé, photos, chiffres clés, verdict) peut être généré et partagé. Une version gratuite inclut un watermark "Analysé via DealFlow", qui sert de boucle de croissance (growth loop).

## Périmètre du MVP (Version 1)

L'objectif du MVP est d'être **utile dès la première visite**, en se concentrant sur les fonctionnalités essentielles :

- **Technologie** : Application 100% native iOS (SwiftUI), fonctionnant **hors ligne** (local-first avec SwiftData), sans création de compte utilisateur.
- **Parcours** : Création de visite, choix du mode, ajout de pièces, remplissage des check-lists, capture de notes/photos, et consultation du verdict.
- **Moteur Financier Simplifié** : Calcul du cashflow brut et de la rentabilité nette simplifiée.
- **Export PDF** : Génération du rapport de visite avec watermark.

Les fonctionnalités volontairement exclues du MVP incluent la fiscalité avancée, la synchronisation cloud, la collaboration et toute forme d'IA.

## Évolution Future

- **V1.5 (Pro Investisseur)** : Introduction d'un score de bien, de scénarios financiers (pessimiste/optimiste), d'un dossier bancaire PDF, d'un historique de biens, et d'une offre payante pour supprimer le watermark.
- **V2 (Business / Scale)** : Ajout de la synchronisation cloud (multi-appareils), du partage de visites, et de la personnalisation avancée.

## Mon Analyse

Le projet DealFlow est **extrêmement bien défini et pertinent**. Il répond à un besoin clair et douloureux pour les investisseurs immobiliers. La vision est précise, le périmètre du MVP est intelligent et maîtrisé, ce qui maximise les chances de succès en se concentrant sur la valeur fondamentale.

Les points forts sont :
- La **clarté du problème résolu**.
- Le **focus sur l'expérience terrain** (offline, rapide, simple).
- La **stratégie de MVP "local-first"** qui permet de livrer de la valeur rapidement sans la complexité d'un backend.
- La **boucle de croissance virale** intégrée via l'export PDF.
- La **roadmap d'évolution logique** qui construit sur des bases solides.

L'approche technique proposée (SwiftUI, SwiftData) est parfaitement alignée avec les contraintes et objectifs du projet. C'est un projet solide, réaliste et à fort potentiel.
