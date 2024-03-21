% Sébastien Hogues (2087357)
% Ahmed El Shami (MATRICULE_2)

include "globals.mzn";

% Nombre de fréquences à placer
int: m;
% Placements possibles selon le nombre de fréquences
int: n = m*m;

% Définition de la plage de fréquences 
array[1..m] of var 0..n: frequences;

% Calcul des distances entre les différentes fréquences
array[1..(m*(m-1)) div 2] of var 0..n: distances = [ frequences[j] - frequences[i] | i in 1..m, j in i+1..m];

% Variable objectif à minimiser
var int: longueur;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%
constraint frequences[1] = 0;
constraint longueur = frequences[m];
constraint alldifferent(distances);
constraint forall(i in 1..(length(frequences) - 1)) (
    frequences[i] < frequences[i + 1]
);
solve minimize longueur;
%-----------------------------------------------------------------------------%

output 
  [show(frequences)]
  ++
  ["\nLongueur de la plage = ", show(longueur)];
