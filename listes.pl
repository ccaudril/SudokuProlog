%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Prédicats utiles pour la manipulation de listes

/** Longueur d'une liste
 *  [T|Q] : liste
 *  N : longueur de la liste
 */
longueur([], 0).
longueur([_|Q], N) :- longueur(Q, N1), N is N1 + 1.

/** Concaténation de deux listes
 *  [T|R] : concaténation de [T|Q] et L
 *  [T|Q] : une liste
 *  L : une liste
 */
concat([], L, L).
concat([T|Q], L, [T|R]) :- concat(Q, L, R).

/** Extraction des premiers éléments d'une liste
 *  K : nombre d'éléments à extraire
 *  [T|Q] : liste dont on extrait les éléments
 *  [T|S] : liste des éléments extraits
 *  R : reste de la liste
 */
extractionElements(0, L, [], L) :- !.
extractionElements(K, [T|Q], [T|S], R) :-
    K > 0,
    K1 is K - 1,
    extractionElements(K1, Q, S, R).

/** Partitionnement d'une liste
 *  K : nombre d'éléments par partition
 *  L : liste à partitionner
 *  [T|Q] : liste des partitions
 */
partition(_, [], []) :- !.
partition(K, L, [T|Q]) :-
    extractionElements(K, L, T, R),
    partition(K, R, Q).

/** Premier élément d'une liste 
 */
premier([T|Q], T, Q).

/** Prédicat utile pour la transposition d'une matrice
 *  [T|Q] : Matrice
 *  [Premier|P] : premiers éléments des lignes de la matrice
 *  [Reste|R] : reste
 */
t_premier([], [], []) :- !.
t_premier([T|Q], [Premier|P], [Reste|R]) :-
    premier(T, Premier, Reste),
    t_premier(Q, P, R).

/** Transposition d'une matrice
 *  Idée : la première ligne de la matrice transposée est composée des premiers éléments des lignes de la matrice (t_premier donne ces éléments dans Premier)
 *  Matrice : matrice à transposer (liste de listes)
 *  [Premier|P] : matrice transposée
 */
t([], []) :- !.
t([[]|_], []) :- !.
t(Matrice, [Premier|P]) :-
    t_premier(Matrice, Premier, Reste),
    t(Reste, P).

/** Permutations d'une liste
 *  L : liste
 *  [T|Q] : permutation de L
 */
permut([], []) :- !.
permut(L, [T|Q]) :- 
    concat(V, [T|U], L), 
    concat(V, U, W), 
    permut(W, Q).

/** Recopie d'une liste et modification d'un élément
 *  [H|T] : liste à modifier 
 *  I : indice de l'élément à modifier
 *  X : valeur qui doit remplacer la valeur à modifier
 *  [H|R] : copie de [H|T] comportant l'élément modifié
 */
modificationElement([_|T], 0, X, [X|T]) :- !.
modificationElement([H|T], I, X, [H|R]) :-
    I > 0,
    I1 is I - 1,
    modificationElement(T, I1, X, R).

/** Recherche du i-ème élément d'une liste
 *  [_|Q] : une liste
 *  N : position de l'élément recherché
 *  E : i-ème élément
 */
element([T|_], 1, T) :- !.
element([_|Q], N, E) :- N > 1, M is N - 1, element(Q, M, E).

/** Vérification de l'existence d'un élément dans une liste
 *  E : élément recherché
 *  [_|Q] : une liste
 */ 
existence(_, []) :- !, fail.
existence(E, [T|_]) :- E == T, !.
existence(E, [_|Q]) :- existence(E, Q).

/** Suppression d'un élément dans une liste
 *  X : élément à supprimer
 *  [T|Q] : une liste supposée contenir l'élément
 *  Y : copie de la liste sans l'élément supprimé
 */
suppression(_, [], []) :- !.
suppression(X, [X|Q], Y) :- !, suppression(X, Q, Y).
suppression(X, [T|Q], Y) :- !, suppression(X, Q, Y2), concat([T], Y2, Y).

/** Sélection aléatoire d'un élément dans une liste
 *  L : une liste
 *  E : élement retourné aléatoirement
 */
elementAleatoire([], []).
elementAleatoire(L, E) :-
    longueur(L, Longueur),
    Longueur1 is Longueur + 1,
    random(1, Longueur1, N),
    element(L, N, E).