from uflp import UFLP
from typing import List, Tuple
import random

""" 
    Binome 1 : El Shami Ahmed 2077075
    Binome 2 : Hogues Sebastien 2087357
    Description succinte de l'implementation :
    We generate a random initial solution and then we iterate to explore the solution space to minimize the total cost and stop when our score beats the secret score.
"""
random.seed(2)  

secret_player_scores = {
    "instance_A_4_6": 187.06494521726978,
    "instance_B_25_50": 1757.9431857942498,
    "instance_C_50_75": 3383.65597024572,
}

def init_solution(problem: UFLP) -> Tuple[List[int], List[int]]:
    """
    Initialize a solution by randomly opening main stations and associating each satellite station to the nearest main station.
    Args:
        problem (UFLP): the problem instance to solve.
    Returns:
        Tuple[List[int], List[int]]: a tuple containing the list of opened main stations and the list of associated main stations for each satellite station.
    """
     # Randomly open or close each station, make sure at least one main station is open
    main_stations_opened = [random.choice([0, 1]) for _ in range(problem.n_main_station)]
    if sum(main_stations_opened) == 0:
        main_stations_opened[random.randint(0, problem.n_main_station - 1)] = 1
    
    satellite_stations_association = []
    for satellite in range(problem.n_satellite_station):
        # Create a list of possible associations for this satellite with open main stations and their cost.
        possible_assignments = [(problem.get_association_cost(main, satellite), main) 
                                for main in range(problem.n_main_station) if main_stations_opened[main] == 1]
        # Find the nearest open station for this satellite.
        nearest_open_main = min(possible_assignments, key=lambda x: x[0])[1]
        satellite_stations_association.append(nearest_open_main)
    # Return the list of open main stations and their associated satellite stations.
    return main_stations_opened, satellite_stations_association

def evaluate_solution(problem: UFLP, solution: Tuple[List[int], List[int]]) -> float:
    return problem.calculate_cost(solution[0], solution[1])  

def improve_solution(problem: UFLP, current_solution: Tuple[List[int], List[int]]) -> Tuple[List[int], List[int], float]:
    """
    Try to improve the current solution by changing the status of each main station and reassigning each satellite station to the nearest main station.
    Args:
        problem (UFLP): the problem instance to solve.
        current_solution (Tuple[List[int], List[int]]): the current solution to improve.
    Returns:
        Tuple[List[int], List[int], float]: a tuple containing the improved list of opened main stations, the improved list of associated main stations for each satellite station 
        and the cost of the improved solution.
    """
    current_main_stations, current_satellite_assignations = current_solution
    best_cost = evaluate_solution(problem, current_solution)
    best_solution = current_solution

    # Iterate through each main station to consider toggling its open/closed state.
    for i in range(len(current_main_stations)):
        # Toggle the state of the ith main station.
        new_main_stations = current_main_stations.copy()
        new_main_stations[i] = 1 - new_main_stations[i]
        
        # Initialize a list for the new satellite assignments.
        new_satellite_assignments = [None] * problem.n_satellite_station
        for satellite in range(problem.n_satellite_station):
            # Find the nearest open main station for this satellite in the new configuration.
            min_cost = float('inf')
            best_main = None
            for main in range(problem.n_main_station):
                if new_main_stations[main] == 1: 
                    cost = problem.get_association_cost(main, satellite)
                    if cost < min_cost:
                        min_cost = cost
                        best_main = main
            new_satellite_assignments[satellite] = best_main

        # Create the new solution and calculate its cost.
        new_solution = (new_main_stations, new_satellite_assignments)
        new_cost = evaluate_solution(problem, new_solution)

        # If the new solution is better, update the best solution and its cost.
        if new_cost < best_cost:
            best_solution = new_solution
            best_cost = new_cost

    best_main_stations, best_satellite_assignments = best_solution
    return best_main_stations, best_satellite_assignments, best_cost



def solve(problem: UFLP) -> Tuple[List[int], List[int]]:
    """
    Solve the problem instance using a local search algorithm.
    Args:
        problem (UFLP): the problem instance to solve.
    Returns:
        Tuple[List[int], List[int]]: a tuple containing the list of opened main stations and the list of associated main stations for each satellite station.
    """
    # The target score for the problem instance that we aim to beat.
    score_to_beat = secret_player_scores[problem.instance_name]
    best_solution = ([], [])
    best_score = float('inf')

    # Generate an initial solution and evaluate its score.
    current_solution = init_solution(problem)
    current_score = evaluate_solution(problem, current_solution)
    if current_score < best_score:
        best_solution, best_score = current_solution, current_score

    # Iteratively improve the solution up to 1000 times (chosen randomly) or until beating the score to beat.
    for _ in range(1000):  
        improved_solution, improved_association, improved_score = improve_solution(problem, best_solution)
        # Update the best solution and its score if an improvement is found.
        if improved_score < best_score:
            best_solution = (improved_solution, improved_association)
            best_score = improved_score
            # Stop the loop if the score to beat is surpassed.
            if best_score < score_to_beat:
                break  

    return best_solution
