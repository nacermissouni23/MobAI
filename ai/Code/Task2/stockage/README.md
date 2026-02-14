## Description
Ce module attribue des emplacements de stockage optimaux aux produits reçus, en tenant compte de :

la distance depuis le point de réception (ascenseur)

le poids du produit (pénalité d’étage)

le volume (capacité 4 m³ par slot)

la fragilité (pas d’empilement)

la fréquence de demande (priorité)

le regroupement des mêmes produits dans un même slot

Il calcule également le chemin détaillé depuis l’ascenseur de l’étage jusqu’à chaque slot assigné, pour guider l’opérateur.

##  Modèle utilisé
Graphe de l’entrepôt : chaque cellule est un nœud, les routes et ascenseurs sont des arêtes pondérées (coût 1 pour les déplacements cardinaux, √2 pour les diagonales, 1 pour les changements d’étage).

Pré‑calcul des distances : Dijkstra depuis chaque ascenseur d’étage.

Fonction de score (plus le score est bas, meilleur est l’emplacement) :


score = α·distance_réception + γ·étage·poids – β·quantité_existante
avec α=1.0, γ=0.5, β=5.0 (valeurs ajustables).

Assignation gloutonne : les produits les plus fréquents sont traités en premier ; pour chaque lot, on choisit le slot (vide ou déjà occupé par le même produit) ayant le meilleur score.

Chemin final : A* (8 directions) pour reconstituer le parcours complet de l’ascenseur au slot.

## Installation

 Aucune dépendance externe nécessaire (uniquement la bibliothèque standard Python 3.7+)

##  Utilisation
python storage_optimizer.py <grid_file.json> <db_state.json> <products.json> <output.json>

OR 
Run :   ## app.ipynb