% Exercice 1
pere(jean, pierre).
pere(jean, jacques).
pere(pierre, paul).
pere(jacques, remi).

grandpere(X, Z) :- pere(X, Y), parent(Y, Z).
grandperepaternel(X, Z) :- pere(X, Y), pere(Y, Z).

parent(X, Y) :- pere(X, Y).
parent(X, Y) :- mere(X, Y).

% Exercice 2
age(paul, 20).
age(pierre, 30).
age(julie, 15).

plus_vieux(X, Y) :- age(X, A), age(Y, B), B > A.

% Exercice 3
fact(0, 1).
fact(N, R) :- N > 0, M is N - 1, fact(M, R2), R is R2*N.

% Exercice 4
non(P) :- P, !, fail.
non(P).
diff(A,B) :- non(A==B).

% Exercice 5
element(X, [X|Q]).
element(X, [T|Q]) :- element(X, Q).

% Exercice 6
concat([], L, L).
concat([T|Q], L, [T|R]) :- concat(Q,L,R).

% Exercice 7
longueur([], 0).
longueur([T|Q], N) :- longueur(Q, N1), N is N1 + 1.

% Exercice 8
elementliste([T|Q], 1, T).
elementliste([T|Q], N, E) :- elementliste(Q, M, E), N is M + 1.