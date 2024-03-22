% NOM_ETUDIANT_1 (MATRICULE_1)
% NOM_ETUDIANT_2 (MATRICULE_2)

include "globals.mzn";

% États possibles pour une case du terrain
% V = Vide
% B = Tour bleue
% R = Tour rouge
enum etat = {V, B, R};

% Dimension du terrain (carré)
int: n;
set of int: dim = 1..n;

% État du terrain
array[dim, dim] of var etat: terrain;

% Variable objectif à maximiser
var int: total_commun;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%
var int: frequencyB = count(terrain, B);
var int: frequencyR = count(terrain, R);

constraint frequencyB = frequencyR;

constraint forall(i in dim) ( (sum(j in dim)(terrain[i,j]=R)) * (sum(j in dim)(terrain[i,j]=B)) = 0);
constraint forall(j in dim) ( (sum(i in dim)(terrain[i,j]=R)) * (sum(i in dim)(terrain[i,j]=B)) = 0);

constraint forall(k in 3..(2*n-1)) ( (sum(i in dim)(if k-i in dim then terrain[i,k-i]=R else 0 endif)) * 
                                     (sum(i in dim)(if k-i in dim then terrain[i,k-i]=B else 0 endif)) = 0);
                                     
constraint forall(k in (2-n)..(n-2)) ( (sum(i in dim)(if i-k in dim then terrain[i,i-k]=R else 0 endif)) * 
                                       (sum(i in dim)(if i-k in dim then terrain[i,i-k]=B else 0 endif)) = 0);
                                       
% constrainte de symétrie


constraint total_commun = frequencyR;

solve maximize total_commun;
%-----------------------------------------------------------------------------%
output 
["Terrain :\n"]
++
[if j = 1 then "["  endif ++ if fix(terrain[i,j]) == V then "_" else show(terrain[i,j]) endif ++ if j = n then "]\n" else "," endif | i in 1..n, j in 1..n]
++
["\n"]
++
["Total de tours commun: " ++ show(total_commun)]
