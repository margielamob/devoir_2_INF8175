include "globals.mzn";

var 1000..9999: nombre;

array[1..4] of var 0..9: chiffres = [nombre div 1000, (nombre div 100) mod 10, (nombre div 10) mod 10, nombre mod 10];

constraint nombre mod 2 == 0;
constraint forall(i in 1..(length(chiffres) - 1)) (chiffres[i] != 0);
constraint all_different(chiffres);
constraint chiffres[1] > chiffres[2]; 
constraint chiffres[2] < chiffres[4];  
constraint chiffres[2] > chiffres[3]; 
constraint sum(chiffres) > 15;
var 0..999: produit = chiffres[2] * chiffres[3] * chiffres[4];
solve minimize produit;

output [
  show(nombre)
];

