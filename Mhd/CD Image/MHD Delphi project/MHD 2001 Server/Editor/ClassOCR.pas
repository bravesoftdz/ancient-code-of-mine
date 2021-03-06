unit ClassOCR;

interface

uses Controls, Windows, Graphics, Classes;

type PSec = ^TSec;
     TSec = TRect;

     TOcr = class
     private
       Secs : TList;

       procedure FreeSecs;

       procedure FindSections( Bmp : TBitmap );
       function FindSection( Bmp : TBitmap; X , Y : integer ) : TSec;

       function SecToChar( Bmp : TBitmap; Sec : PSec ) : char;
     public
       procedure Recognize( Bmp : TBitmap; Str : TStrings );

       constructor Create( ImageList : TImageList );
       destructor Destroy; override;
     end;

var Ocr : TOcr;

implementation

uses ClassChars;

//==============================================================================
//==============================================================================
//
//                                   Constructor
//
//==============================================================================
//==============================================================================

constructor TOcr.Create( ImageList : TImageList );
begin
  inherited Create;
  Chars := TChars.Create( ImageList );
  Secs := TList.Create;
end;

//==============================================================================
//==============================================================================
//
//                                   Destructor
//
//==============================================================================
//==============================================================================

procedure TOcr.FreeSecs;
var I : integer;
begin
  for I := 0 to Secs.Count-1 do
    Dispose( PSec( Secs[I] ) );
  Secs.Clear;
end;

destructor TOcr.Destroy;
begin
  FreeSecs;

  Secs.Free;
  Chars.Free;
  inherited;
end;

//==============================================================================
//==============================================================================
//
//                                     O C R
//
//==============================================================================
//==============================================================================

function TOcr.FindSection( Bmp : TBitmap; X , Y : integer ) : TSec;

procedure FloodFill( I , J : integer );
begin
  Bmp.Canvas.Pixels[I,J] := clWhite;

  if I < Result.Left then Result.Left := I;
  if I > Result.Right then Result.Right := I;
  if J < Result.Top then Result.Top := J;
  if J > Result.Bottom then Result.Bottom := J;

  //  Doprava
  if (I < Bmp.Width-1) then
    if (Bmp.Canvas.Pixels[I+1,J] = clChar) then
      FloodFill( I+1 , J );

  //  Dolava
  if (I > 0) then
    if (Bmp.Canvas.Pixels[I-1,J] = clChar) then
      FloodFill( I-1 , J );

  //  Dole
  if (J < Bmp.Height-1) then
    if (Bmp.Canvas.Pixels[I,J+1] = clChar) then
      FloodFill( I , J+1 );

  //  Hore
  if (J > 0) then
    if (Bmp.Canvas.Pixels[I,J-1] = clChar) then
      FloodFill( I , J-1 );

  //  Doprava hore
  if (I < Bmp.Width-1) and
     (J > 0) then
    if (Bmp.Canvas.Pixels[I+1,J-1] = clChar) then
      FloodFill( I+1 , J-1 );

  //  Doprava dole
  if (I < Bmp.Width-1) and
     (J < Bmp.Height-1) then
    if (Bmp.Canvas.Pixels[I+1,J+1] = clChar) then
      FloodFill( I+1 , J+1 );

  //  Dolava dole
  if (I > 0) and
     (J < Bmp.Height-1) then
    if (Bmp.Canvas.Pixels[I-1,J+1] = clChar) then
      FloodFill( I-1 , J+1 );

  //  Dolava hore
  if (I > 0) and
     (J > 0) then
    if (Bmp.Canvas.Pixels[I-1,J-1] = clChar) then
      FloodFill( I-1 , J-1 );
end;

begin
  with Result do
    begin
      Left := X;
      Top := Y;
      Right := X;
      Bottom := Y;
    end;

  FloodFill( X , Y );
end;

procedure TOcr.FindSections( Bmp : TBitmap );
var I, J : integer;
    PNewSec : PSec;
begin
  FreeSecs;
  for J := 0 to Bmp.Height-1 do
    for I := 0 to Bmp.Width-1 do
      if Bmp.Canvas.Pixels[I,J] = clChar then
        begin
          New( PNewSec );
          Secs.Add( PNewSec );
          PNewSec^  := FindSection( Bmp , I , J );
        end;
end;

function TOcr.SecToChar( Bmp : TBitmap; Sec : PSec ) : char;
var I : integer;

function IsEqual( Data : TData ) : boolean;
var I, J : integer;
begin
  Result := True;
  for I := 0 to Data.BMP.Width-1 do
    for J := 0 to Data.BMP.Height-1 do
      if ((Data.BMP.Canvas.Pixels[I,J] = clChar) and
          (Bmp.Canvas.Pixels[Sec^.Left+I,Sec^.Top+J] <> clChar)) or
         ((Data.BMP.Canvas.Pixels[I,J] <> clChar) and
          (Bmp.Canvas.Pixels[Sec^.Left+I,Sec^.Top+J] = clChar)) then
        begin
          Result := False;
          exit;
        end;
end;

begin
  Result := #0;
  for I := 0 to Chars.Data.Count-1 do
    if ((Sec^.Right - Sec^.Left)+1 = TData(Chars.Data[I]^).BMP.Width) and
       ((Sec^.Bottom - Sec^.Top)+1 = TData(Chars.Data[I]^).BMP.Height) then
      if IsEqual( TData(Chars.Data[I]^) ) then
        begin
          Result := TData(Chars.Data[I]^).Value;
          exit;
        end;
end;

//==============================================================================
//==============================================================================
//
//                                I N T E R F A C E
//
//==============================================================================
//==============================================================================

procedure TOcr.Recognize( Bmp : TBitmap; Str : TStrings );
var I : integer;
    C : char;
    Zaloha : TBitmap;
    S : string;
begin
  if Bmp = nil then exit;
  Str.Clear;

  Zaloha := TBitmap.Create;
  try
    Zaloha.Assign( Bmp );
    FindSections( Bmp );
    Bmp.Assign( Zaloha );
  finally
    Zaloha.Free;
  end;

  S := '';
  for I := 0 to Secs.Count-1 do
    begin
      C := SecToChar( Bmp , Secs[I] );
      if C <> #0 then
        if I = 0 then S := C
                 else
                   begin
                     if ((TSec( Secs[I]^ ).Top - TSec( Secs[I-1]^ ).Bottom) - 1) > 5 then
                       begin
                         if S <> '' then Str.Add( S );
                         S := '';
                       end;

                     if ((TSec( Secs[I]^ ).Left - TSec( Secs[I-1]^ ).Right) - 1) > 3 then
                       S := S+' '+C
                         else
                       S := S+C;
                   end;
    end;
  if S <> '' then Str.Add( S );
end;

end.
