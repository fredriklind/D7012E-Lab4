startBoard(X):-
  X = ([(white,d,4),(black,e,4),(black,d,5),(white,e,5)]),
  outputBoard(X).

% Converting X values to numbers
xval(a,1).
xval(b,2).
xval(c,3).
xval(d,4).
xval(e,5).
xval(f,6).
xval(g,7).
xval(h,8).

flipStone(white,black).
flipStone(black,white).
placeBlack(blank,black).
placeWhite(blank,white).

max(X, Y, X) :- X > Y, !.
max(X, Y, Y) :- X =< Y.

countStones(Color,Board,N):-
  findall(Color,member((Color,_,_),Board),L),
  length(L,N).

distanceFrom((X1,Y1),(X2,Y2),Distance):-
  xval(X1,X1n),
  xval(X2,X2n),
  between(1,8,Y1),
  between(1,8,Y2),
  A is abs(X1n-X2n),
  B is abs(Y1-Y2),
  max(A,B,Distance).

rowsFromPosition(Pos,L):-
  setof(Z,inCorridorOfPosition(Pos,Z),L).

% Gets/Checks if a position is within diagonal
% or straight rows from another position
inCorridorOfPosition((X1,Y1),(X2,Y2)):-
  xval(X1,X1n),
  xval(X2,X2n),
  between(1,8,X1n),
  between(1,8,X2n),
  between(1,8,Y1),
  between(1,8,Y2),
  not((X1n=X2n,Y1=Y2)),
  (
    X1n-Y1 =:= X2n-Y2;
    X1n+Y1 =:= X2n+Y2;
    X1n    =:= X2n;
    Y1     =:= Y2
  ).

% Predicates for checking and generating positions 
% that relate to eachother by direction
north((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 = X2,
  Y1 @> Y2.

northEast((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 @< X2,
  Y1 @> Y2.

east((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 @< X2,
  Y1 = Y2.

southEast((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 @< X2,
  Y1 @< Y2.

south((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 = X2,
  Y1 @< Y2.

southWest((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 @> X2,
  Y1 @< Y2.

west((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 @> X2,
  Y1 = Y2.

northWest((X1,Y1),(X2,Y2)):-
  inCorridorOfPosition((X1,Y1),(X2,Y2)),
  X1 @> X2,
  Y1 @> Y2.

% Intersects a list of positions with stones on a board
onlyStones(Positions,Board,Stones):-
  member(X,Positions),
  findall((Color,X),member((Color,X),Board),Stones).
  %intersection(Positions,L,Intersection),
  %exclude(member(X)).

%onlyStones([(d,4),(a,1),(e,4)],[(white,d,4),(black,e,4),(black,d,5),(white,e,5)],Y).

% Gets all positions left, right, top down, 
% originating in a single point, Pos
positionsInCorridor(Pos,DirectionPred,L):-
  ( 
    DirectionPred = north;
    DirectionPred = northEast;
    DirectionPred = east;
    DirectionPred = southEast;
    DirectionPred = south;
    DirectionPred = southWest;
    DirectionPred = west;
    DirectionPred = northWest
  ),
  setof(X,call(DirectionPred,Pos,X),L1),
  between(1,8,Z),
  setof(Y,distanceFrom(Pos,Y,Z),L2),
  intersection(L1,L2,[L|_]).

% Backtracks over all corridors of a position Pos, reverses the order of
% north, southWest, west and northWest corridors to get the order of the positions
% to always go from the source Pos.
%
% Reversing not currently working, it returns to many lists.
corridorForPosition(Pos,L):-
  setof(X,positionsInCorridor(Pos,_,X),Corridor),
  (
    isLeftSideCorridor(Pos,Corridor) -> reverse(Corridor,L)
    ;
    L = Corridor
  ).

allCorridorsForPosition(Pos,L):-
  setof(X,corridorForPosition(Pos,X),L).
  %outputBoard(L).

% Checks if a corridor is to the left or top of a position.
% This is needed because in the predicate above it needs to reverse
% these corridors to make them start at the position in question 
% (going outward from the position)
isLeftSideCorridor(Pos,[FirstPos|_]):-
  ( 
    DirectionPred = north;
    DirectionPred = southWest;
    DirectionPred = west;
    DirectionPred = northWest
  ),
  Pred =.. [(DirectionPred),Pos,FirstPos],
  Pred -> true ; false.

% Color is the opposite of the color that was placed in the 
% move preceeding this predicate.
% Row is a list of stones on the board.
flipRow(Color,Row,Flips):-
  
  % Generate a list, like black,black,black,white
  flipList(Color,FlipList,[]),
  
  % Get lengths
  length(Row,RowLength),
  length(FlipList,FlipListLength),
  
  FlipListLength >= RowLength ,!,
  
  % Does the generated list match Row?
  prefix(FlipList,Row),

  % Delete last and bind to Flips
  last(FlipList,Last),
  delete(FlipList,Last,Flips).

flipManyRows(Color,[Row|Rows],[Flip|Flips]):-
  flipRow(Color,Row,Flip),
  flipManyRows(Color,Rows,Flips).
flipManyRows(_,_,[]).

flipManyRowsComplete(Color,Rows,Flips):-
  setof(X,flipManyRows(Color,Rows,X),L),
  flatten(L,L2),
  list_to_set(L2,Flips).

% Converts lists of lists of positions to lists of lists 
% containing stones on the Board
manyPositionRowsToStoneRows([Row|Rows],Board,[BoardRow|BoardRows]):-
  onlyStones(Row,Board,BoardRow),
  manyPositionRowsToStoneRows(Rows,Board,BoardRows).
manyPositionRowsToStoneRows(_,_,[]).

% Use DCG to generate/check for lists that are of the form
% either black, black black, white
% or
% white, white, white, black
flipList(_) --> [].
flipList(Color) --> sColor(Color),{flipStone(Color,InvColor)},[(InvColor,_)].
sColor(Color) --> [(Color,_)].
sColor(Color) --> [(Color,_)], sColor(Color).

flipsForMove(Color,Board,(X,Y),Flips):-
  flipStone(Color,InvColor),
  %xval(X,Xval),
  %between(1,8,Xval),
  %between(1,8,Y),
  allCorridorsForPosition((X,Y),Rows),
  manyPositionRowsToStoneRows(Rows,Board,StonesInRows),
  %outputBoard(StonesInRows),
  flipManyRowsComplete(InvColor,StonesInRows,Flips).

legalmove(Color, Board, X, Y):-
  outputBoard(Board),

  % Make sure no stone is at X,Y
  not(member((_,X,Y),Board)),
  
  %Make sure move results in at least one flip.
  flipsForMove(Color,Board,(X,Y),Flips),
  %write(Flips),
  length(Flips,NFlips),
  NFlips > 0.

/*
------- Board output -------
This outputs the board as a string to a text file "output.txt"
This file is then watched by a node.js server that sends a websocket 
message to an html page that then updates the graphical representation 
of the board.

See server.js for the node.js server. Run "node server.js to start the server".
"pusher" and "chokidar" node.js plugins must be installed to run the server.
*/

outputBoard(Board):-
  flatten(Board,B),
  open('output.txt',write,Stream),
  write(Stream,B),
  close(Stream).