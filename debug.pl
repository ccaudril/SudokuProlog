debug(_, _, _, _, _, _, []).
debug(A, _, C, N, L, H, R) :-
    A =:= 0,  
    C > 1,
    C1 is C - 1,
    A1 is N,
    debug(A1, L, C1, N, L, H, R).
debug(A, _, C, N, L, H, R) :-
    A =:= 0,
    C =:= 1,
    A1 is N,
    debug(A1, L, H, N, L, H, R).
debug(A, B, C, N, L, H, [_|Q]) :-
    A > 0,
    B =:= 1,
    A1 is A - 1,
    debug(A1, L, C, N, L, H, Q).
debug(A, B, C, N, L, H, [_|Q]) :-
    A > 0,
    B > 1,
    A1 is A - 1,
    B1 is B - 1,
    debug(A1, B1, C, N, L, H, Q).
debug(Grille) :-
    taille(Grille, N),
    tailleBloc(N, L, H),
    debug(N, L, H, N, L, H, Grille).