{$A+,B-,E-,F+,N-,O-,V-,X+,I-}
unit MUpCase;

interface

function MyUpCase(Ch: Char): Char;

implementation

uses PackLng, Language;

function MyUpCase(Ch: Char): Char;
var
  P: byte;
  LatUp: String[50];
begin
  Ch := UpCase(Ch);
  LatUp := Ph(phLatUp);
  P := Pos(Ch, Ph(phCyrLow));
  if P > 0 then Ch := LatUp[P];
  P := Pos(Ch, Ph(phCyrUp));
  if P > 0 then Ch := LatUp[P];
  MyUpCase := Ch;
end;

end.
