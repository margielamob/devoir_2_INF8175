import random
from uflp import UFLP
from typing import List, Tuple
import math
""" 
    Binome 1 : El Shami Ahmed 2077075
    Binome 2 : Hogues Sebastien 2087357
    Description succinte de l'implementation :
    ...
"""

def combined_strategy(problem: UFLP, max_restarts: int, initial_temp: float, cooling_rate: float, min_temp: float) -> Tuple[List[int], List[int]]:
    best_solution = None
    best_cost = float('inf')
    
    for restart in range(max_restarts):
        current_solution = initialize_solution(problem)
        current_cost = problem.calculate_cost(*current_solution)
        temp = initial_temp
        
        while temp > min_temp:
            neighbors = get_neighbors(current_solution, problem)
            neighbor = random.choice(neighbors)
            neighbor_cost = problem.calculate_cost(*neighbor)
            cost_diff = neighbor_cost - current_cost

            if cost_diff < 0 or math.exp(-cost_diff / temp) > random.uniform(0, 1):
                current_solution = neighbor
                current_cost = neighbor_cost

            temp *= cooling_rate

        if current_cost < best_cost:
            best_solution = current_solution
            best_cost = current_cost

    return best_solution

def solve(problem: UFLP) -> Tuple[List[int], List[int]]:
    max_restarts = 10
    initial_temp = 10000.0
    cooling_rate = 0.95
    min_temp = 1

    return combined_strategy(problem, max_restarts, initial_temp, cooling_rate, min_temp)

def initialize_solution(problem):
    main_stations_opened = [0 for _ in range(problem.n_main_station)]
    main_stations_opened[random.randint(0, problem.n_main_station - 1)] = 1

    satellite_stations_association = [None for _ in range(problem.n_satellite_station)]
    for sat in range(problem.n_satellite_station):
        distances = [problem.get_association_cost(main, sat) if main_stations_opened[main] == 1 else float('inf') for main in range(problem.n_main_station)]
        satellite_stations_association[sat] = distances.index(min(distances))

    return main_stations_opened, satellite_stations_association

def get_neighbors(current_solution: Tuple[List[int], List[int]], problem: UFLP) -> List[Tuple[List[int], List[int]]]:
    neighbors = []
    main_stations_opened, satellite_stations_association = current_solution

    for sat in range(problem.n_satellite_station):
        for main in range(problem.n_main_station):
            if main_stations_opened[main] == 1: 
                new_association = satellite_stations_association.copy()
                new_association[sat] = main
                neighbors.append((main_stations_opened.copy(), new_association))
    
    for i in range(problem.n_main_station):
        new_main_stations = main_stations_opened.copy()
        new_main_stations[i] = 1 - new_main_stations[i]  
        if sum(new_main_stations) > 0:  
            new_association = satellite_stations_association.copy()
            if new_main_stations[i] == 0:
                for sat in range(problem.n_satellite_station):
                    if new_association[sat] == i:
                        distances = [problem.get_association_cost(main, sat) if new_main_stations[main] == 1 else float('inf') for main in range(problem.n_main_station)]
                        new_association[sat] = distances.index(min(distances))
            neighbors.append((new_main_stations, new_association))
    
    return neighbors
