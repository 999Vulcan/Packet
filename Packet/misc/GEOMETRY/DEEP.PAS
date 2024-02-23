{$N+,E+}
Program Deep;

uses crt, Geometry;

const
  CountPoints = 100;

var
  i: Integer;
  A: TPoint;
  S: TPointsSet;
  x, y: TReal;

  MinX, MaxX, MinY, MaxY: TReal;

function
  GetDeep(var M: TPoint; var S: TPointsSet; DrawFlag: boolean): Integer;
var
  i, Deep: Integer;
  Shell: PPolygon;
begin
  Deep := 0;
  Shell := nil;
  if DrawFlag then S.Draw(0, Yellow, 1);
  S.AddPoint(M.X, M.Y);
  if DrawFlag
    then begin
      M.Draw(0, White, 3);
      Pause;
    end;
  repeat
    if Assigned(Shell) then Dispose(Shell, Done);
    S.GetMinSalientShell(Shell);
    if DrawFlag
      then begin
        Shell^.Draw(LightGreen, LightGreen, 2);
        Pause;
      end;
    i := 1;
    Inc(Deep);
    while i <= S.CountPoints do
      if Inside(S.GetPoint(i)^, Shell^)
        then Inc(i)
      else S.DeletePoint(i);
  until not InsidePPol(M, Shell^);
  Dispose(Shell, Done);
  GetDeep := Deep - 1;
end;

begin
  ClrScr;
  DirectVideo := False;
  Randomize;
  S.Init;
  for i := 1 to CountPoints do
    S.AddPoint(Random, Random);
  A.Init(Random, Random);
{  
  S.FindMinMax(MinX, MinY, MaxX, MaxY);
  A.Init((MinX + MaxX) / 2, (MinY + MaxY) / 2);
}
  InitGeomGraph;
  DrawRange(LightGray);
  Scale.Init;
  Scale.Calculate(S);
  Scale.Correct(A);
  GoToXY(2, 2);
  write('Глубина = ', GetDeep(A, S, True));
  Pause;
  CloseGeomGraph;
end.
