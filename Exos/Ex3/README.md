# Exercice 3

Écrire un programme qui :

* Affiche `Choisissez [p]ierre, [f]euille, [c]iseaux (q pour quitter): ` puis lit une ligne.
* Interprète l’entrée utilisateur (`p`, `f`, `c`), sinon affiche `Entree invalide, recommence.` et redemande.
* Tire au hasard le choix de l’ordinateur parmi `p/f/c` (distribution uniforme).
* Affiche le résultat de la manche sous la forme `Vous: <X> | CPU: <Y> — Gagné / Perdu / Égalité\n`.
* Joue en **série** “premier à 3 points” (ne compte pas les égalités), affiche le **score courant** après chaque manche.
* À la fin, affiche `Score final: <vous>-<cpu>. Merci d’avoir joué!\n` et se termine proprement.

> Contraintes : syscalls uniquement (`read`, `write`, `exit`), tampon borné, gestion de `\n`/`\r\n`, `q` ou EOF quittent proprement.
