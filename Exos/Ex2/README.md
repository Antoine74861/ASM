# Exercice 2

Écrire un programme qui :

* Tire au hasard un entier **secret** compris entre `1` et `100` (inclus).
* Affiche `Devinez le nombre (1..100): ` et lit une ligne depuis l’entrée standard.
* Interprète l’entrée comme un entier ; si elle n’est pas dans `[1..100]`, affiche `Entree invalide (1..100), recommence.` et redemande.
* Affiche `Plus\n` si la proposition est trop petite, `Moins\n` si elle est trop grande.
* Répète jusqu’à trouver la bonne valeur.
* À la réussite, affiche `Gagne en <N> coups!\n` où `<N>` est le nombre de tentatives **valides**, puis se termine proprement.
