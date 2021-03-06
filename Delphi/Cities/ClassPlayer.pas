unit ClassPlayer;

interface

const XMAX = 75;
      YMAX = 52;

type TPos = record
       X, Y : integer;
     end;

     TTable = array[1..XMAX,1..YMAX] of integer;
     { -1 - prazdne
       0 - player 1
       1 - player 2
       2 - forbidden}

     TPlayer = class
     public
       Finish : boolean;
       function MakeMove( Table : TTable ) : TPos; virtual; abstract;
     end;

implementation

end.

