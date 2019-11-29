:- set_prolog_flag(double_quotes,atom).
:- [adventure].

% Helper functions for Look and Study
list_connect(R):- write("Connected Rooms:"), door(R, C), nl, write(C),
                    short_desc(C, S), write("- "), write(S), fail.
list_connect(R):- door(C, R), nl, write(C), short_desc(C, S), write("- "), write(S), fail.
list_connect(_R).

list_obj(R):- location(O, R), name(O, N), short_desc(O, S), nl, write(N), write("- "), write(S), false.
list_obj(_R).

%Look at a location
% Display long description, connections, contents (one level deep only)
look_nc(R):- room(R), name(R, N), write(N), nl, long_desc(R, D), write(D),
          nl, nl, (list_connect(R)), nl, nl, write("Opjects: "), list_obj(R).

look(R):- here(R), look_nc(R).

%Study an object
% Display long description, contents
study_nc(O):- long_desc(O, L), write(L), nl, list_obj(O).

study(O):- here(R), location(O, R), study_nc(O).

%Display names of all items in inventory
inventory_nc:- has(S), name(S, N), write(N), nl, fail.
inventory_nc.
inventory:- inventory_nc.

%Move player to given location
move_nc(N):- here(R),retract(here(R)),asserta(here(N)).

check_c(R, N):- door(R,N), !, move_nc(N).
check_c(R, N):- door(N,R), !, move_nc(N). 
move(N):- here(R), !, check_c(R,N). 

%Take item into player inventory
take_nc(O):- retract(location(O,_)), asserta(has(O)). 

take(O):- here(R), location(O, R), not(heavy(O)), retract(location(O,R)), asserta(has(O)).

%Make item from recipe with equipment
make_nc(I):- create_recipe(_, _, I), asserta(has(I)). 

remove_used(N):- member(X, N), retract(has(X)), fail.
remove_used(_N).
make(I):- here(L), location(E, L), create_recipe(E, N, I), remove_used(N), asserta(has(I)).

%Put item from inventory into current location
put_nc(O,L):- asserta(location(O,L)).

put(O):- here(L), has(O), retract(has(O)), put_nc(O,L).

%Transfer a disk in towers of Hanoi puzzle
transfer_nc(D, P):- retract(location(D,_)), asserta(location(D,P)).

transfer(small_disk, P):- retract(location(small_disk,_)),
                          asserta(location(small_disk,P)).
transfer(medium_disk, P):- location(medium_disk, I),
                           not(location(small_disk, I)),
                           not(location(small_disk, P)),
                           retract(location(medium_disk, I)),
                           asserta(location(medium_disk, P)).
transfer(large_disk, P):- location(large_disk, I),
                          not(location(small_disk, I)),
                          not(location(small_disk, P)),
                          not(location(medium_disk, I)),
                          not(location(medium_disk, P)),
                          retract(location(large_disk, I)),
                          asserta(location(large_disk, P)).

%Predicate that is true if the game has been won.
win:- location(small_disk, pylon_c), location(medium_disk, pylon_c), location(large_disk, pylon_c).
