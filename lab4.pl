startBoard([(white,d,4),(black,e,4),(black,d,5),(white,e,5)]).


% Converting X values to numbers
xval(a,1).
xval(b,2).
xval(c,3).
xval(d,4).
xval(e,5).
xval(f,6).
xval(g,7).
xval(h,8).

max(X, Y, X) :- X > Y, !.
max(X, Y, Y) :- X =< Y.

isMemberOfBoard((X1,Y1), [(_,X2,Y2)|T]) :- (X1=X2,Y1=Y2); member((X1,Y1), T).

distanceFrom((X1,Y1),(X2,Y2),Distance):-
  xval(X1,X1n),
  xval(X2,X2n),
  between(1,8,Y1),
  between(1,8,Y2),
  A is abs(X1n-X2n),
  B is abs(Y1-Y2),
  max(A,B,Distance).

pruneEmptyPositions([],[],[]).
pruneEmptyPositions([(X,Y)|Positions],[(Color,X2,Y2)|Board],[(Color2,X3,Y3)|PrunedBoard]):-



% Removes
positionListFromBoard(Board,PosList).

% legalmove(Color, Board, X, Y).
% open('output.txt',write,Stream), 
% write(Stream,Hogwarts),nl(Stream), 
% close(Stream),