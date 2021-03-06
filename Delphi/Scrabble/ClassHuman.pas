unit ClassHuman;

interface

uses ClassBoard, ClassLetterBoard, ClassLetters, ClassLetterStack,
     ClassPlayer, Classes, ExtCtrls;

type THuman = class( TPlayer )
     private
       FLtrBoard   : TLetterBoard;

       procedure   OnBoardClick( X, Y : integer );
     public
       constructor Create( Letters : TLetters; Board : TBoard; LtrBoard : TLetterBoard );

       procedure   MakeMove( FirstMove : boolean ); override;
       function    EndMove : boolean; override;
       procedure   ChangeSomeLetters; override;
     end;

implementation

constructor THuman.Create( Letters : TLetters; Board : TBoard; LtrBoard : TLetterBoard );
begin
  inherited Create( Letters , Board );

  FLtrBoard := LtrBoard;
end;

//==============================================================================
// P R I V A T E
//==============================================================================

procedure THuman.OnBoardClick( X, Y : integer );
var LegalMove  : boolean;
    I          : integer;
    J, K, L    : integer;
    Min        : integer;
    Ltr        : TLetter;
begin
  // Take back move
  for I := 0 to Length( FLastMove )-1 do
    if ((FLastMove[I].X = X) and
        (FLastMove[I].Y = Y)) then
      begin
        FLtrBoard.UnMark;
        FLtrBoard.TakeBack( FLastMove[I].Letter );
        FBoard.RemoveLetter( FLastMove[I].X , FLastMove[I].Y );

        for J := I to Length( FLastMove )-2 do
          FLastMove[J] := FLastMove[J+1];
        SetLength( FLastMove , Length( FLastMove ) - 1 );

        exit;
      end;

  if (FLtrBoard.Marked.C <> #0) then
    begin
      if (Length( FLastMove ) = 0) then
        LegalMove := true
      else
        begin
          J := 0;
          K := 0;

          for I := 0 to Length( FLastMove )-1 do
            if ((J = 0) and
                (K = 0)) then
              begin
                J := FLastMove[I].X;
                K := FLastMove[I].Y;
              end
            else
              if (FLastMove[I].X = J) then
                K := 0
              else
                J := 0;

          LegalMove := false;

          if (X = J) then
            begin
              Min := CNumRows;
              for I := 0 to Length( FLastMove )-1 do
                if (FLastMove[I].Y < Min) then
                  Min := FLastMove[I].Y;

              if (Y < Min) then
                Min := Y;

              L := Length( FLastMove );
              repeat
                if ((FBoard.Letters[Min,X].Letter.C = #0) and
                    (Min <> Y)) then
                  break;

                if ((FBoard.Letters[Min,X].ThisTurn) or
                    (Min = Y)) then
                  begin
                    Dec( L );
                    if (L = -1) then
                      begin
                        LegalMove := true;
                        break;
                      end;
                  end;

                Inc( Min );
              until (Min > CNumRows);
            end;

          if (Y = K) then
            begin
              Min := CNumCols;
              for I := 0 to Length( FLastMove )-1 do
                if (FLastMove[I].X < Min) then
                  Min := FLastMove[I].X;

              if (X < Min) then
                Min := X;

              L := Length( FLastMove );
              repeat
                if ((FBoard.Letters[Y,Min].Letter.C = #0) and
                    (Min <> X)) then
                  break;

                if ((FBoard.Letters[Y,Min].ThisTurn) or
                    (Min = X)) then
                  begin
                    Dec( L );
                    if (L = -1) then
                      begin
                        LegalMove := true;
                        break;
                      end;
                  end;

                Inc( Min );
              until (Min > CNumCols);
            end;
        end;

      if (not LegalMove) then
        exit;

      Ltr := FLtrBoard.Marked;
      if (FBoard.AddLetter( X , Y , Ltr )) then
        begin
          SetLength( FLastMove , Length( FLastMove ) + 1 );
          FLastMove[Length( FLastMove )-1].Letter := Ltr;
          FLastMove[Length( FLastMove )-1].X      := X;
          FLastMove[Length( FLastMove )-1].Y      := Y;

          FLtrStack.PopStack( [FLtrBoard.Marked] );
          FLtrBoard.RemoveMarked;
        end;
    end;
end;

//==============================================================================
// P U B L I C
//==============================================================================

procedure THuman.MakeMove( FirstMove : boolean );
begin
  SetLength( FLastMove , 0 );
  FBoard.OnClick := OnBoardClick;
end;

function THuman.EndMove : boolean;
var I, Count : integer;
begin
  FLtrStack.TakeNew;
  FBoard.OnClick := nil;
  FBoard.EndMove;

  Count := 0;
  for I := 1 to 7 do
    if (FLtrStack.Stack[I].C <> #0) then
      Inc( Count );

  if (Count = 0) then
    Result := true
  else
    Result := false;
end;

procedure THuman.ChangeSomeLetters;
begin
  FLtrStack.ChangeSomeLetters( FLtrBoard.GetBottomTiles );
end;

end.
