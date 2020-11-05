%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Sudoku

:- include('listes.pl').
:- include('debug.pl').

:- dynamic(grille/1).
grille([]).

:- dynamic(solution/1).
solution([]).

:- dynamic(nombres/1).
nombres([]).

modificationGrille(X) :- retractall(grille(_)), assertz(grille(X)).
modificationSolution(X) :- retractall(solution(_)), assertz(solution(X)).
modificationNombres(X) :- retractall(nombres(_)), assertz(nombres(X)).

initGrille :- retractall(grille(_)), assertz(grille([])).
initSolution :- retractall(solution(_)), assertz(solution([])).

/** Affichage d'un élément d'une liste : si c'est un chiffre valide, on l'affiche, sinon on affiche un espace
 *  E : élément à afficher
 */
affichageElement(E) :-
    existence(E, [1,2,3,4,5,6,7,8,9]),
    write(E), 
    !.
affichageElement(_) :-
    write('.'),
    !.

/** Affichage d'une grille
 *  A : nombre d'éléments par ligne ; lorsqu'il vaut 0, on a affiché une ligne entière, et on reprend l'affichage en-dessous
 *  B : racine de A ; lorsqu'il vaut 1, on affiche le chiffre, puis des espaces pour marquer le changement de bloc sur une ligne = L
 *  C : racine de A ; lorsqu'il vaut 1 et que A vaut 0, on a affiché une ligne entière et des blocs complets, on saute 2 lignes pour marquer le changement de bloc = H
 *  N : on garde en mémoire le nombre d'éléments par ligne tout au long de la procédure pour les réinitialisations
 *  L : on garde en mémoire la largeur d'un bloc tout au long de la procédure pour les réinitialisations
 *  H : on garde en mémoire la hauteur d'un bloc tout au long de la procédure pour les réinitialisations
 *  R : reste de la grille de Sudoku à afficher
 */ 
affichage(_, _, _, _, _, _, []) :- nl.
affichage(A, _, C, N, L, H, R) :- % Cas 1 : nouvelle ligne
    A =:= 0,  
    C > 1,
    C1 is C - 1,
    A1 is N,
    nl,
    affichage(A1, L, C1, N, L, H, R).
affichage(A, _, C, N, L, H, R) :- % Cas 2 : 2 nouvelles lignes car changement de bloc 
    A =:= 0,
    C =:= 1,
    A1 is N,
    nl,
    nl,
    affichage(A1, L, H, N, L, H, R).
affichage(A, B, C, N, L, H, [T|Q]) :- % Cas 3 : triple espace car changement de bloc
    A > 0,
    B =:= 1,
    A1 is A - 1,
    affichageElement(T),
    write('   '),
    affichage(A1, L, C, N, L, H, Q).
affichage(A, B, C, N, L, H, [T|Q]) :- % Cas 4 : espace simple
    A > 0,
    B > 1,
    A1 is A - 1,
    B1 is B - 1,
    affichageElement(T),
    write(' '),
    affichage(A1, B1, C, N, L, H, Q).
affichage(Grille) :-
    taille(Grille, N),
    tailleBloc(N, L, H),
    affichage(N, L, H, N, L, H, Grille),
    !.

/** Taille d'une grille de Sudoku (9 si 9x9, 6 si 6x6 etc.)
 *  Grille : grille de Sudoku représentée par une liste
 *  Taille : taille de la grille
 */
taille(Grille, Taille) :-
    longueur(Grille, T),
    Taille is floor(sqrt(T)).

/** Taille des blocs adaptée à la taille de la grille (3x3 si 9x9, 3*2 si 6*6, etc.)
 *  Taille : taille de la grille de Sudoku
 *  Largeur : largeur d'un bloc
 *  Hauteur : hauteur d'un bloc
 */
tailleBloc(Taille, Largeur, Hauteur) :-
    Taille = TailleBloc,
    Hauteur is floor(sqrt(Taille)),
    Largeur is ceiling(sqrt(Taille)),
    TailleBloc is Largeur * Hauteur.

/** Extraction des blocs d'une grille
 *  Grille : grille de Sudoku représentée par une liste
 *  Blocs : blocs de la grille
 */
extractionBlocs(Grille, Blocs) :-
    taille(Grille, Taille),
    tailleBloc(Taille, Largeur, Hauteur),
    partition(Taille, Grille, Lignes),
    extractionBlocs(Lignes, Largeur, Hauteur, Blocs).
extractionBlocs([], _, _, []) :- !.
extractionBlocs(Lignes, Largeur, Hauteur, Blocs) :-
    extractionElements(Hauteur, Lignes, Ligne, Reste), % Ligne : une ligne de blocs
    t(Ligne, T),
    flatten(T, F),
    Taille is Largeur * Hauteur,
    partition(Taille, F, S),
    extractionBlocs(Reste, Largeur, Hauteur, BlocsSuivants),
    concat(S, BlocsSuivants, Blocs).

/** Prédicat générant la liste des nombres devant apparaître dans une ligne/colonne/bloc en fonction de la taille de la grille
 *  N : taille de la grille
 *  L : liste des nombres
 */
nombres(N, L) :- nombres(N, [], L).
nombres(0, L, L) :- !.
nombres(N, R, L) :- N > 0, N1 is N - 1, nombres(N1, [N|R], L).

/** Vérification du respect des règles du Sudoku pour une ligne, une colonne ou un bloc
 *  [T|Q] : ligne de lignes, colonnes ou blocs
 *  Nombres : liste des nombres devant apparaître dans une ligne/colonne/bloc
 */
validation([], _).
validation([T|Q], Nombres) :-
    permut(Nombres, T),
    validation(Q, Nombres).

/** Extraction lignes, colonnes et blocs d'une grille de Sudoku 
 *  Grille : grille de Sudoku
 *  Lignes : liste des lignes du Sudoku
 *  Colonnes : liste des colonnes du Sudoku
 *  Blocs : liste des blocs du Sudoku
 */
extraction(Grille, Lignes, Colonnes, Blocs) :-
    taille(Grille, N),
    partition(N, Grille, Lignes),
    t(Lignes, Colonnes),
    extractionBlocs(Grille, Blocs).

/** Résolution automatique d'une grille de Sudoku
 *  Grille : grille de Sudoku représentée par une liste
 */
resolution(Grille) :-
    taille(Grille, N),
    nombres(N, Nombres),
    extraction(Grille, Lignes, Colonnes, Blocs),
    validation(Lignes, Nombres),
    validation(Colonnes, Nombres),
    validation(Blocs, Nombres),
    write('Solution :'), nl, nl,
    affichage(Grille),
    nl.

/** Variante du repeat classique, lorsque l'on veut un certain nombre de répétitions
 *  N : nombre de répétitions
 */
repeat(N) :-
    integer(N),
    N > 0,
    repeat1(N).
repeat1(1) :- !.
repeat1(_).
repeat1(N) :- 
    M is N - 1,
    repeat1(M).

/** Validation d'une modification apportée à une grille de Sudoku partielle
 *  Indice : indice dans la grille de l'élément à modifier
 *  Valeur : nouvelle valeur
 *  Grille : grille de Sudoku
 */
validationModification(Indice, Valeur, Grille) :-
    I is Indice // 9,
    J is Indice mod 9,
    K is floor((Indice mod 9) / 3) + 3 * floor(Indice / (9 * 3)),
    extraction(Grille, Lignes, Colonnes, Blocs),
    I1 is I + 1,
    J1 is J + 1,
    K1 is K + 1,
    element(Lignes, I1, Ligne),
    element(Colonnes, J1, Colonne),
    element(Blocs, K1, Bloc),
    \+ existence(Valeur, Ligne),
    \+ existence(Valeur, Colonne),
    \+ existence(Valeur, Bloc).

/** Prédicat donnant une permutation de la liste des nombres allant de 1 à 9 sous la forme de plusieurs solutions (utile pour le backtracking lors de la génération d'une grille)
 *  Valeur : nombre aléatoire compris entre 1 et 9
 */
nombreAleatoire(Valeur) :-
    modificationNombres([1,2,3,4,5,6,7,8,9]),
    repeat(9),
    nombres(Nombres),
    elementAleatoire(Nombres, Valeur),
    suppression(Valeur, Nombres, Nombres1),
    modificationNombres(Nombres1).

/** Génération d'une grille de Sudoku complète, placée dans la variable dynamique 'solution' 
 */
generationGrilleComplete(GrilleComplete, Indice) :- 
    Indice < 0,
    modificationSolution(GrilleComplete).
generationGrilleComplete(Grille, Indice) :-
    Indice >= 0,
    nombreAleatoire(Valeur), 
    debug(Grille),
    validationModification(Indice, Valeur, Grille),
    modificationElement(Grille, Indice, Valeur, Grille1),
    Indice1 is Indice - 1,
    generationGrilleComplete(Grille1, Indice1).
generationGrilleComplete :-
    GrilleVide = [_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_],
    generationGrilleComplete(GrilleVide, 80),
    !.

/** Génération d'une grille de Sudoku partiellement remplie selon un niveau de difficulté
 *  Niveau : niveau de difficulté de la grille (1, 2 ou 3)
 */
generationGrille(Niveau) :-
    initGrille,
    initSolution,
    generationGrilleComplete,
    solution(Solution),
    modificationGrille(Solution),
    ajoutVides(Niveau).

/** Ajout de vides dans une grille de Sudoku complète 
 */
ajoutVides(0) :- random(2, 3, N), ajoutVides(N, 1). % pour la démo
ajoutVides(1) :- random(35, 46, N), ajoutVides(N, 1). % facile
ajoutVides(2) :- random(46, 50, N), ajoutVides(N, 1). % intermédiaire
ajoutVides(3) :- random(50, 57, N), ajoutVides(N, 1). % difficile
ajoutVides(N, N) :- !.
ajoutVides(N, Compteur) :-
    suppressionAleatoire,
    Compteur1 is Compteur + 1,
    ajoutVides(N, Compteur1).

/** Suppression d'une case aléatoirement choisie dans une grille complète
 */
suppressionAleatoire :-
    rechercheCaseNonVide(Indice),
    grille(Grille),
    modificationElement(Grille, Indice, _, Grille1),
    modificationGrille(Grille1).

/** Recherche d'une case non vide dans une grille pour la suppression aléatoire
 *  Indice : indice de la case qui sera supprimée
 */
rechercheCaseNonVide(Indice) :-
    grille(Grille),
    random(0, 81, Indice),
    caseRemplie(Grille, Indice, 0),
    !.
rechercheCaseNonVide(Indice) :- rechercheCaseNonVide(Indice).

/** Vérifie si une case est déjà remplie dans une grille
 *  [T|Q] : une grille
 *  Indice : indice de la case à vérifier
 *  Compteur : compteur permettant le parcours de la grille
 */
caseRemplie([T|_], Indice, Indice) :- existence(T, [1,2,3,4,5,6,7,8,9]), !.
caseRemplie([_|Q], Indice, Compteur) :- Compteur1 is Compteur + 1, caseRemplie(Q, Indice, Compteur1).

/** Menu du programme
 */
menu :-
    repeat,
    nl,
    write('------------------------'), nl,
    write('| IA02 P2018 -- Sudoku |'), nl,
    write('------------------------'), nl, nl,
    write('1. Résolution d\'une grille donnée'), nl,
    write('2. Génération d\'une grille 9x9 et gestion du jeu'), nl,
    write('Entrez un choix'), nl,
    read(Choix), nl, 
    choixMenu(Choix),
    !.

choixMenu(1) :- 
    !,
    write('Entrez la grille à résoudre :'), nl,
    read(Grille), nl,
    resolution(Grille),
    fail.
choixMenu(2) :- 
    !,
    write('Choisissez la difficulté du jeu :'), nl,
    write('1. Facile'), nl,
    write('2. Intermédiaire'), nl,
    write('3. Difficile'), nl,
    read(Choix), nl,
    choixNiveau(Choix),
    nl,
    fail.
choixMenu(_) :- write('Vous avez mal choisi !'), nl, fail.

choixNiveau(0) :- !, generationGrille(0), gestionJeu, fail.
choixNiveau(1) :- !, generationGrille(1), gestionJeu, fail.
choixNiveau(2) :- !, generationGrille(2), gestionJeu, fail.
choixNiveau(3) :- !, generationGrille(3), gestionJeu, fail.
choixNiveau(_) :- write('Vous avez mal choisi !'), nl, fail.

/** Prédicat gérant le déroulement du jeu
 */
gestionJeu :-
    repeat,
    grille(Grille),
    \+grilleRemplie(Grille),
    affichage(Grille), nl,
    write('Entrez le numéro de la ligne (entre 1 et 9) de la case à modifier :'), nl,
    read(I), nl,
    \+entreeInvalide(I),
    write('Entrez le numéro de la colonne (entre 1 et 9) de la case à modifier :'), nl,
    read(J), nl,
    \+entreeInvalide(J),
    Indice is (J-1) + (I-1) * 9,
    \+caseDejaRemplie(Indice),
    write('Entrez la valeur à insérer (entre 1 et 9) :'), nl,
    read(Valeur), nl,
    \+entreeInvalide(Valeur),
    \+mauvaiseValeur(Valeur, Indice),
    modificationElement(Grille, Indice, Valeur, Grille1),
    modificationGrille(Grille1),
    nl.

/** Vérifie si une grille est remplie
 *  [T|Q] : une grille
 */
grilleRemplie([]) :- write('La grille est complète, bravo !'), nl, nl, menu.
grilleRemplie([T|Q]) :-
    existence(T, [1,2,3,4,5,6,7,8,9]),
    grilleRemplie(Q).

/** Vérifie si une certaine case est déjà remplie
 *  Indice : indice de la case
 */
caseDejaRemplie(Indice) :-
    Indice1 is Indice + 1,
    grille(Grille),
    element(Grille, Indice1, E),
    existence(E, [1,2,3,4,5,6,7,8,9]),
    write('La case choisie est déjà remplie !'), nl, nl.

/** Vérifie si une valeur correspond à la valeur dans la grille courante à un indice donné
 *  Valeur : valeur qu'il faut vérifier
 *  Indice : indice où doit se trouver Valeur dans la grille courante
 */
mauvaiseValeur(Valeur, Indice) :-
    solution(Solution),
    Indice1 is Indice + 1,
    element(Solution, Indice1, E),
    E =\= Valeur,
    write('Cette valeur n\'est pas la bonne.'), nl, nl.

/** Vérifie si une entrée de l'utilisateur est valide
 *  Entree : valeur saisie par l'utilisateur
 */
entreeInvalide(Entree) :-
    \+ existence(Entree, [1,2,3,4,5,6,7,8,9]),
    write('Vous devez saisir des chiffres entre 1 et 9 !!'), nl, nl.