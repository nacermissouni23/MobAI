"""
Service d'optimisation du stockage pour MobAI
- Charge la grille depuis gridItem.json
- Reçoit l'état des slots depuis la base de données (occupation réelle)
- Assigne les emplacements de stockage optimaux en fonction de la distance à la réception et du poids
- Calcule le chemin depuis l'ascenseur (10,30) de l'étage du slot
- Sortie : assignations + chemins détaillés
"""

import json
import heapq
import math
from typing import List, Dict, Tuple, Optional

# Constantes pour les déplacements (8 directions)
DIRECTIONS = [
    (1, 0), (-1, 0), (0, 1), (0, -1),   # 4 directions cardinales
    (1, 1), (1, -1), (-1, 1), (-1, -1)  # 4 directions diagonales
]

class StorageOptimizer:
    """
    Optimiseur de stockage principal.
    Utilise une grille (JSON) et l'état des slots (BDD) pour assigner les produits.
    """

    def __init__(self, grid_file: str, 
                 receiving_point: Tuple[int, int, int],
                 slots_from_db: Dict[Tuple[int, int, int], Dict] = None):
        """
        Initialise l'optimiseur.

        Args:
            grid_file: chemin vers le fichier JSON de la grille (ex: "gridItem.json")
            receiving_point: point de réception (x, y, floor) utilisé pour le score
            slots_from_db: dictionnaire optionnel contenant l'état actuel des slots.
                           Format: {(floor, x, y): {'product_id': id or None, 'quantite': int}}
                           Si non fourni, les données sont lues depuis le JSON.
        """
        self.grid_file = grid_file
        self.receiving_point = receiving_point
        self.grid = {}           # (x, y, floor) -> cellule
        self.roads = {}          # floor -> set de (x,y) routes
        self.elevators = {}      # floor -> set de (x,y) ascenseurs
        self.slot_usage = {}     # (floor, x, y) -> {'product_id': id or None, 'quantite': int}
        self.width = 0
        self.height = 0
        self.load_grid(slots_from_db)

        # Pré-calcul des distances depuis la réception (pour le score)
        self.dist_from_receipt = self.precompute_distances(receiving_point)

        # Ascenseur fixe (10,30) pour chaque étage (supposé présent)
        self.elevator_points = {}
        for floor in range(1, 5):  # étages 1 à 4
            if floor in self.elevators:
                self.elevator_points[floor] = (10, 30, floor)
        # Pré-calcul des distances depuis chaque ascenseur (pour les chemins)
        self.dist_from_elevator = {floor: self.precompute_distances(self.elevator_points[floor]) 
                                   for floor in self.elevator_points}

    def load_grid(self, slots_from_db: Optional[Dict] = None):
        """Charge la grille depuis le fichier JSON et initialise les structures."""
        with open(self.grid_file, 'r', encoding='utf-8') as f:
            data = json.load(f)

        self.width = data['width']
        self.height = data['height']
        cells = data['cells']

        # Regrouper les cellules par étage
        floors = {}
        for cell in cells:
            floor = cell['floor']
            if floor not in floors:
                floors[floor] = []
            floors[floor].append(cell)

        for floor, cells_floor in floors.items():
            self.roads[floor] = set()
            self.elevators[floor] = set()
            for cell in cells_floor:
                x, y = cell['x'], cell['y']
                key = (x, y, floor)
                self.grid[key] = cell

                if cell.get('is_road'):
                    self.roads[floor].add((x, y))
                if cell.get('is_elevator'):
                    self.elevators[floor].add((x, y))
                if cell.get('is_slot'):
                    # Utiliser les données BDD si fournies, sinon celles du JSON
                    if slots_from_db is not None:
                        db_key = (floor, x, y)
                        if db_key in slots_from_db:
                            self.slot_usage[db_key] = slots_from_db[db_key]
                        else:
                            self.slot_usage[db_key] = {'product_id': None, 'quantite': 0}
                    else:
                        if cell.get('is_occupied'):
                            prod_id = cell.get('product_id')
                            qty = cell.get('quantity', 0)
                            self.slot_usage[(floor, x, y)] = {'product_id': prod_id, 'quantite': qty}
                        else:
                            self.slot_usage[(floor, x, y)] = {'product_id': None, 'quantite': 0}

        print(f"Grille chargée : {len(self.grid)} cellules sur les étages {sorted(floors.keys())}")
        for f in sorted(floors.keys()):
            nb_slots = len([k for k in self.slot_usage if k[0] == f])
            print(f"  Étage {f} : {nb_slots} slots")

    # ==================== Pathfinding ====================

    def is_walkable(self, cell: dict) -> bool:
        """Vérifie si une cellule est praticable (route, slot, ascenseur, non obstacle)."""
        if cell.get('is_obstacle'):
            return False
        if cell.get('is_road') or cell.get('is_slot') or cell.get('is_elevator'):
            return True
        return False

    def get_walkable_neighbors(self, pos: Tuple[int, int, int]) -> List[Tuple[int, int, int]]:
        """
        Retourne les voisins accessibles (routes et ascenseurs) pour le pré-calcul.
        """
        x, y, floor = pos
        neighbors = []
        for dx, dy in DIRECTIONS:
            nx, ny = x + dx, y + dy
            if 0 <= nx < self.width and 0 <= ny < self.height:
                key = (nx, ny, floor)
                cell = self.grid.get(key)
                if cell and (cell.get('is_road') or cell.get('is_elevator')):
                    neighbors.append(key)
        # Ascenseurs inter-étages
        if (x, y) in self.elevators.get(floor, set()):
            for other_floor in self.elevators.keys():
                if other_floor != floor and (x, y) in self.elevators[other_floor]:
                    neighbors.append((x, y, other_floor))
        return neighbors

    def precompute_distances(self, start: Tuple[int, int, int]) -> Dict[Tuple[int, int, int], float]:
        """
        Calcule les distances minimales depuis start vers toutes les cellules walkable (routes/ascenseurs).
        Utilise Dijkstra.
        """
        if start not in self.grid or not (self.grid[start].get('is_road') or self.grid[start].get('is_elevator')):
            # Si le point de départ n'est pas walkable, impossible de calculer
            return {}

        dist = {start: 0.0}
        pq = [(0.0, start)]
        visited = set()

        while pq:
            d, current = heapq.heappop(pq)
            if current in visited:
                continue
            visited.add(current)
            for nb in self.get_walkable_neighbors(current):
                dx = nb[0] - current[0]
                dy = nb[1] - current[1]
                dz = nb[2] - current[2]
                if dz != 0:
                    move_cost = 1.0  # ascenseur
                else:
                    move_cost = 1.0 if dx == 0 or dy == 0 else math.sqrt(2)
                new_d = d + move_cost
                if nb not in dist or new_d < dist[nb]:
                    dist[nb] = new_d
                    heapq.heappush(pq, (new_d, nb))
        return dist

    def nearest_road(self, slot_key: Tuple[int, int, int]) -> Optional[Tuple[int, int, int]]:
        """Trouve la route adjacente la plus proche d'un slot. Retourne None si aucune."""
        floor, x, y = slot_key
        for dx, dy in [(1,0), (-1,0), (0,1), (0,-1)]:
            nx, ny = x + dx, y + dy
            if (nx, ny) in self.roads.get(floor, set()):
                return (nx, ny, floor)
        return None

    def distance_to_slot(self, dist_map: Dict[Tuple[int, int, int], float], slot_key: Tuple[int, int, int]) -> float:
        """
        Calcule la distance depuis un point (via dist_map) jusqu'au slot.
        dist_map doit contenir les distances vers les routes.
        """
        road = self.nearest_road(slot_key)
        if road is None or road not in dist_map:
            return float('inf')
        return dist_map[road] + 1.0

    def path_to_slot(self, from_pos: Tuple[int, int, int], slot_key: Tuple[int, int, int]) -> Tuple[Optional[List[Tuple[int, int, int]]], float]:
        """
        Retourne le chemin complet depuis from_pos (qui doit être sur une route/ascenseur) jusqu'au slot.
        """
        road = self.nearest_road(slot_key)
        if road is None:
            return None, float('inf')
        path, dist = self._astar_path(from_pos, road)
        if path is None:
            return None, float('inf')
        # Ajouter le slot à la fin
        path.append((slot_key[1], slot_key[2], slot_key[0]))  # (x,y,floor)
        return path, dist + 1.0

    def _astar_path(self, start: Tuple[int, int, int], goal: Tuple[int, int, int]) -> Tuple[Optional[List[Tuple[int, int, int]]], float]:
        """A* pour obtenir le chemin complet entre deux points (doivent être des routes/ascenseurs)."""
        if start == goal:
            return [start], 0.0

        open_set = []
        counter = 0
        heapq.heappush(open_set, (0, counter, start))
        g_score = {start: 0.0}
        came_from = {}

        while open_set:
            _, _, current = heapq.heappop(open_set)
            if current == goal:
                path = []
                while current in came_from:
                    path.append(current)
                    current = came_from[current]
                path.append(start)
                path.reverse()
                return path, g_score[goal]

            for neighbor in self.get_walkable_neighbors(current):
                dx = neighbor[0] - current[0]
                dy = neighbor[1] - current[1]
                dz = neighbor[2] - current[2]
                if dz != 0:
                    move_cost = 1.0
                else:
                    move_cost = 1.0 if dx == 0 or dy == 0 else math.sqrt(2)
                tentative_g = g_score[current] + move_cost
                if neighbor not in g_score or tentative_g < g_score[neighbor]:
                    g_score[neighbor] = tentative_g
                    f = tentative_g + self.heuristic(neighbor, goal)
                    counter += 1
                    heapq.heappush(open_set, (f, counter, neighbor))
                    came_from[neighbor] = current
        return None, float('inf')

    def heuristic(self, a: Tuple[int, int, int], b: Tuple[int, int, int]) -> float:
        dx = abs(a[0] - b[0])
        dy = abs(a[1] - b[1])
        return max(dx, dy) + (math.sqrt(2) - 1) * min(dx, dy) + 10 * abs(a[2] - b[2])

    # ==================== Score et assignation ====================

    def compute_slot_score(self, product: dict, slot_key: Tuple[int, int, int]) -> float:
        """
        Calcule le score d'un slot en utilisant la distance à la réception et la pénalité d'étage.
        Plus le score est bas, meilleur est l'emplacement.
        """
        dist_receipt = self.distance_to_slot(self.dist_from_receipt, slot_key)
        if dist_receipt == float('inf'):
            return float('inf')
        floor_penalty = slot_key[0] * product['poids']
        alpha = 1.0
        gamma = 0.5
        return alpha * dist_receipt + gamma * floor_penalty

    def assign_storage(self, products: List[Dict]) -> List[Dict]:
        """
        Assigne des emplacements de stockage aux produits.

        Args:
            products: liste de dictionnaires, chacun avec les clés :
                - 'id' (str) : identifiant produit
                - 'poids' (float) : poids en kg par unité
                - 'volume' (float) : volume en m³ par unité
                - 'fragile' (bool) : True si ne peut pas être empilé
                - 'quantite' (int) : nombre d'unités à stocker
                - 'frequence' (int) : priorité (1-3, 3 = plus fréquent)

        Returns:
            Liste de dictionnaires, chacun avec :
                - 'product_id' (str)
                - 'slot' (x, y, floor)
                - 'quantite' (int)
                - 'path' (List[Tuple[int,int,int]]) : chemin depuis l'ascenseur de l'étage
                - 'path_cost' (float)
        """
        # Trier par fréquence décroissante (priorité)
        sorted_products = sorted(products, key=lambda p: p['frequence'], reverse=True)
        assignments = []

        for prod in sorted_products:
            prod_id = prod['id']
            qte_totale = prod['quantite']
            volume_unitaire = prod['volume']
            fragile = prod.get('fragile', False)

            # Capacité maximale d'un slot en unités
            if fragile:
                capacite_max = 1
            else:
                capacite_max = int(4.0 // volume_unitaire) if volume_unitaire > 0 else 1
                if capacite_max < 1:
                    capacite_max = 1

            qte_restante = qte_totale
            while qte_restante > 0:
                # Construire la liste des candidats (slot_key, type, quantite_presente)
                candidats = []
                for slot_key, usage in self.slot_usage.items():
                    if usage['product_id'] is None:
                        candidats.append((slot_key, 'vide', 0))
                    elif usage['product_id'] == prod_id:
                        if fragile:
                            continue
                        volume_utilise = usage['quantite'] * volume_unitaire
                        if volume_utilise < 4.0 - 1e-6:
                            candidats.append((slot_key, 'meme', usage['quantite']))

                if not candidats:
                    raise Exception(f"Plus de slot disponible pour le produit {prod_id}")

                # Calcul des scores avec bonus de regroupement
                best_slot = None
                best_score = float('inf')
                for slot_key, typ, qte_presente in candidats:
                    score = self.compute_slot_score(prod, slot_key)
                    if score == float('inf'):
                        continue
                    bonus = 5 * qte_presente if typ == 'meme' else 0
                    score_avec_bonus = score - bonus
                    if score_avec_bonus < best_score:
                        best_score = score_avec_bonus
                        best_slot = slot_key

                if best_slot is None:
                    raise Exception(f"Aucun slot accessible pour {prod_id}")

                usage = self.slot_usage[best_slot]
                if usage['product_id'] is None:
                    qte_possible = capacite_max
                else:
                    volume_utilise = usage['quantite'] * volume_unitaire
                    qte_possible = int((4.0 - volume_utilise) // volume_unitaire)
                qte_a_mettre = min(qte_restante, qte_possible)

                if qte_a_mettre <= 0:
                    continue

                # Mise à jour du slot
                if usage['product_id'] is None:
                    usage['product_id'] = prod_id
                    usage['quantite'] = qte_a_mettre
                else:
                    usage['quantite'] += qte_a_mettre

                # Point de départ : ascenseur de l'étage
                floor = best_slot[0]
                if floor not in self.elevator_points:
                    raise Exception(f"Pas d'ascenseur défini pour l'étage {floor}")
                start_elev = self.elevator_points[floor]

                path, cost = self.path_to_slot(start_elev, best_slot)
                if path is None:
                    raise Exception(f"Chemin impossible vers le slot {best_slot}")

                assignments.append({
                    'product_id': prod_id,
                    'slot': (best_slot[1], best_slot[2], best_slot[0]),
                    'quantite': qte_a_mettre,
                    'path': path,
                    'path_cost': cost
                })
                qte_restante -= qte_a_mettre

        return assignments


# ==================== Exemple d'utilisation ====================
if __name__ == "__main__":
    # Configuration
    GRID_FILE = "gridItem.json"
    RECEIVING_POINT = (10, 30, 1)  # point de réception

    # Simulation de données BDD : état actuel des slots
    # En production, ces données viendraient d'une requête SQL
    slots_from_db = {
        (1, 22, 3): {'product_id': '31761', 'quantite': 16},
        (1, 5, 11): {'product_id': '31761', 'quantite': 99},
        (1, 21, 17): {'product_id': '31761', 'quantite': 54},
        (1, 24, 25): {'product_id': '31761', 'quantite': 25},
        (1, 13, 34): {'product_id': '31761', 'quantite': 63},
        (1, 18, 40): {'product_id': '31761', 'quantite': 168},
        (2, 12, 7): {'product_id': '31761', 'quantite': 45},
        (2, 26, 13): {'product_id': '31761', 'quantite': 63},
        (2, 12, 21): {'product_id': '31761', 'quantite': 12},
    }

    # Produits à stocker
    PRODUCTS = [
        {'id': '31761', 'poids': 10, 'volume': 0.01, 'fragile': False, 'quantite': 5, 'frequence': 3},
        {'id': 'P003', 'poids': 20, 'volume': 0.8, 'fragile': False, 'quantite': 2, 'frequence': 2},
        {'id': 'P002', 'poids': 5,  'volume': 1.2, 'fragile': True,  'quantite': 3, 'frequence': 1},
    ]

    # Instanciation et exécution
    optimizer = StorageOptimizer(GRID_FILE, RECEIVING_POINT, slots_from_db)
    try:
        result = optimizer.assign_storage(PRODUCTS)
        # Affichage des résultats (à adapter selon les besoins)
        print("\n" + "="*60)
        print("ASSIGNATIONS DE STOCKAGE")
        print("="*60)
        for r in result:
            print(f"Produit {r['product_id']:<10} -> slot {r['slot']} avec quantité {r['quantite']}")
        print("\n" + "="*60)
        print("CHEMINS DÉTAILLÉS")
        print("="*60)
        for r in result:
            print(f"\nProduit {r['product_id']} -> slot {r['slot']}")
            print(f"  Départ ascenseur étage {r['slot'][2]} : {r['path'][0]}")
            print(f"  Chemin ({len(r['path'])} étapes) : {r['path']}")
            print(f"  Coût total : {r['path_cost']:.2f}")
    except Exception as e:
        print(f"Erreur : {e}")