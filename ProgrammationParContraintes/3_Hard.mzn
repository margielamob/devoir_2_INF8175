% NOM_ETUDIANT_1 (MATRICULE_1)
% NOM_ETUDIANT_2 (MATRICULE_2)

include "globals.mzn";

% Énumérations des équipes participant au tournoi
enum equipes = {CO, TA, HO, DA, NA, MU, AL, UT};

% Lieux de rencontres des equipes (0 = pas de rencontre).
% Tout lieu i, tel que 0 < i <= card(equipes), 
% est designé comme le domicile de l'équipe associée par la relation to_enum(equipe, i)
set of int: terrains = 0..card(equipes);

% Étendue du tournoi (en jours)
int: d = 16;
set of int: jours = 1..d;

% Calendrier de placement des matchs
array[equipes, jours] of var terrains: calendrier;

% Nombres de rencontres entre deux equipes
array[equipes, equipes] of var 0..2: rencontres;

% Tuples des dates de match entre deux équipes
array[equipes, equipes] of var tuple (0..d, 0..d): dates;

% Variable objectif à maximiser
var int: objectif_match_espaces;

%-----------------------------------------------------------------------------%
% Partie étudiant
%-----------------------------------------------------------------------------%
% contrainte #1
constraint forall(e1,e2 in equipes where e1!=e2)(
    calendrier[e1,dates[e1,e2].1] = calendrier[e2,dates[e1,e2].1] 
    /\
    calendrier[e1,dates[e1,e2].2] = calendrier[e2,dates[e1,e2].2]
);
% contrainte #2
constraint forall(e1,e2 in equipes where e1!=e2)(
    (to_enum(equipes,calendrier[e1,dates[e1,e2].1]) = e1 \/
     to_enum(equipes,calendrier[e2,dates[e1,e2].1]) = e2)
    /\
    (to_enum(equipes,calendrier[e1,dates[e1,e2].2]) = e1 \/ 
     to_enum(equipes,calendrier[e2,dates[e1,e2].2]) = e2)
);
% contrainte 3
constraint forall(j in jours,t in terrains where t>0)(
              sum(e in equipes)(calendrier[e,j]=t) <= 2);

% contrainte 4
constraint forall(e in equipes, j in jours where
    sum(e2 in equipes where e2 != e) ( if (dates[e, e2].1 = j \/ dates[e, e2].2 = j) then 1 else 0 endif )=0)(
    calendrier[e, j] = 0
);


% contrainte 5
constraint forall(e in equipes)(sum(j in jours)(to_enum(equipes, calendrier[e,j])=e) <= 7);

% contrainte 6
% définir rencontre en premier
constraint forall(e1, e2 in equipes where e1!=e2)(
  rencontres[e1, e2] = (if calendrier[e1,dates[e1,e2].1]>0 then 1 else 0 endif) +
                       (if calendrier[e1,dates[e1,e2].2]>0 then 1 else 0 endif)
);

constraint forall(e1,e2 in equipes where e1 != e2)(rencontres[e1,e2]=2);

% contrainte 7
constraint forall(e1, e2 in equipes)(
   dates[e1, e2].2 - dates[e1, e2].1 > 3
);

% contrainte 8
constraint forall(e1, e2 in equipes where e1 != e2)(
    calendrier[e1,dates[e1,e2].1] != calendrier[e1,dates[e1,e2].2]
);

constraint objectif_match_espaces = sum(e1, e2 in equipes where e1 > e2)
                                       (if abs(dates[e1, e2].2 - dates[e1, e2].1) > 6 then 1 else 0 endif);
                                       
solve maximize objectif_match_espaces;
%-----------------------------------------------------------------------------%

% Affichage du calendrier par equipes et par jours puis du résultat de la fonction objectif.
% Lorsqu'une équipe ne joue pas, l'emplacement de match reste vide sinon elle contient le nom de l'équipie adverse.
% Si une équipe ne joue pas à domicile, un "@" précède le nom de l'équipe adverse.
output 
["Calendrier:\n"]
++
[if j = 1 then "   " else "" endif ++ if j < 10 then "  j" ++ show(j) else " j" ++ show(j) endif ++ if j = d then "\n" else "" endif | j in jours ]
++
[if j = 1 then show(e1) ++ ":" else "" endif ++ if fix(calendrier[e1,j]) = 0 then "    " else if fix(calendrier[e1,j]) = e1 then "  " ++ concat([if e1 != e2 /\ fix(calendrier[e2,j]) = e1 then show(e2) else "" endif | e2 in equipes])  else " @" ++ show(to_enum(equipes, calendrier[e1,j])) endif endif ++ if j = d then "\n" else "" endif | e1 in equipes, j in jours ]
++
["\nMatchs retour espacés de 6 jours ou plus = " ++ show(objectif_match_espaces) ++ "\n"]
;
