{$define Graph}

{***************************************************************************}
{                                                                           }
{  Модуль "Геометрия".                                                      }
{                                                                           }
{  Автор: Константин Вулах                                                  }
{  Copyright (C) 1993,94 by VULCAN                                          }
{                                                                           }
{  Начат         : 12.10.93                                                 }
{  Корректирован : 06.04.94                                                 }
{                                                                           }
{***************************************************************************}

{$A+,B-,E+,F-,G-,I-,N+,O-,R+,S+,V-,X-}

Unit Geometry;

interface

uses

  Crt,
  Objects

{$ifdef Graph}

  , Graph

{$endif}

  ;

const

  { Поправка на погрешность }
  Mistake = 1e-10;

  { Начальное количество точек в множестве (см. TPointsSet.Init) }
  StartSize = 50;
  { Приращение количества точек в множестве (см. TPointsSet.Init) }
  Delta     = 50;

  { Код ошибки или 0 }
  GeomStatus: Integer = 0;

{$ifdef Graph}
  PathToDrv = 'D:\BGI';
  Cpr = 'Copyright (C) 1994 by VULCAN';
  Prompt = 'Press a key . . .';
{$endif}

type

  { Вещественный тип }
  TReal = extended;

  { Абстрактный тип геометрического объекта }
  PGeomObject = ^TGeomObject;
  TGeomObject = object(TObject)
    function Exist: boolean; virtual;
    function Area: TReal; virtual;
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    { Color1 - цвет отрезка, Color2 - цвет точки }
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Точка }
  PPoint = ^TPoint;
  TPoint = object(TGeomObject)
    X, Y: TReal;

    constructor Init(ax, ay: TReal);
    function Exist: boolean; virtual;
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Окружность }
  PCircle = ^TCircle;
  TCircle = object(TPoint)
    R: TReal;

    constructor Init(AX, AY, AR: TReal);
    function Exist: boolean; virtual;
    function D: TReal;
    function Length: TReal;
    function Area: TReal; virtual;
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Прямая }
  PLine = ^TLine;
  TLine = object(TGeomObject)
    A, B, C: TReal;     { коэффициенты в уравнении Ax + By + C = 0 }
    KExist: boolean;    { признак существования уравнения вида y = kx + d }
    k, d:TReal;         { коэффициенты в уравнении y = kx + d }

    constructor Init(var aA, aB: TPoint);
    function Exist: boolean; virtual;
    { Вычисление k и d из A, B и C }
    procedure CalcK;
    { Построение перпендикуляра к прямой, проходящего через точку M }
    procedure BuildPerp(M: TPoint; var L: TLine);
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Отрезок }
  PSegment = ^TSegment;
  TSegment = object(TGeomObject)
    A, B: TPoint;

    constructor Init(var aA, aB: TPoint);
    function Exist: boolean; virtual;
    function Length: TReal;
    procedure GetMiddle(var M: TPoint);
    procedure BuildMidPerp(var L: TLine);
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Треугольник }
  PTriangle = ^TTriangle;
  TTriangle = object(TGeomObject)
    A, B, C: TPoint;

    constructor Init(var aA, aB, aC: TPoint);
    function Area: TReal; virtual;
    function Perimeter: TReal;
    { Центр описанной окружности }
    procedure GetCircumscrCircle(var Circle: TCircle);
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Прямоугольник }
  PRectangle = ^TRectangle;
  TRectangle = object(TGeomObject)
    A, B: TPoint;

    constructor Init(var aA, aB: TPoint);
    function Area: TReal; virtual;
    function Perimeter: TReal;
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  PPolygon = ^TPolygon;

  { Множество точек }
  PPointsSet = ^TPointsSet;
  TPointsSet = object(TGeomObject)
    Points: TCollection;  { Индексация с 0 }

    constructor Init;
    destructor Done; virtual;
    function Exist: boolean; virtual;
    function CountPoints: integer;
    procedure AddPoint(x, y: TReal);
    { Индексация с 1 }
    function GetPoint(Index: Integer): PPoint;
    function Diameter: TReal;
    procedure AddPointAt(Index: Integer; x, y: TReal);
    procedure DeletePoint(Index: Integer);
    procedure DelLastPoint;
    procedure GetMinSalientShell(var Shell: PPolygon);
    procedure FindMinMax(var MinX, MinY, MaxX, MaxY: TReal); virtual;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;

  { Ломаная }
  PBroken = ^TBroken;
  TBroken = object(TPointsSet)

    constructor Init;
    function Exist: boolean; virtual;
    function IsSelfCross: boolean;
    function Perimeter: TReal;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;


  { Многоугольник }
  TPolygon = object(TBroken)

    constructor Init;
    function Exist: boolean; virtual;
    function IsSelfCross: boolean;
    function IsSalient: boolean;
    function Area: TReal; virtual;
    function Perimeter: TReal;
{$ifdef Graph}
    procedure Draw(Color1, Color2, Radius: Integer); virtual;
{$endif}
  end;


{$ifdef Graph}

  { Шкала }
  PScale = ^TScale;
  TScale = object(TObject)
    factorX, factorY: TReal;
    MinX, MinY, MaxX, MaxY: TReal;

    constructor Init;
    procedure Calculate(var Obj: TGeomObject);
    procedure Correct(var Obj: TGeomObject);
    procedure Even;
  end;

const

  { Начало координат }

  Origin: TPoint = (X: 0; Y: 0);

var

  Scale: TScale;

{$endif}

  function max(x, y: TReal): TReal;
  function min(x, y: TReal): TReal;
  function sign(x: TReal): Integer;

  function Distance(var A,B: TGeomObject): TReal;
  { Расстояние между двумя точками }
  function DistancePP(var A,B: TPoint): TReal;
  { Расстояние от точки до прямой }
  function DistancePL(var M: TPoint; var L:TLine): TReal;

  function Belong(var A, B: TGeomObject): boolean;

  { Точка на прямой ? }
  function BelongPL(var M: TPoint; var L: TLine): boolean;
  { Точка на отрезке ? }
  function BelongPS(var M: TPoint; var S: TSegment): boolean;
  { Точка принадлежит треугольнику ? }
  function BelongPT(var M: TPoint; var T: TTriangle): boolean;
  { Точка принадлежит прямоугольнику ? }
  function BelongPR(var M: TPoint; var R: TRectangle): boolean;
  { Точка на ломаной ? }
  function BelongPB(var M: TPoint; var B: TBroken): boolean;
  { Точка на окружности ? }
  function BelongPC(var M: TPoint; var C: TCircle): boolean;
  { Точка принадлежит многоугольнику ? }
  function BelongPPol(var M: TPoint; var P: TPolygon): boolean;
  { Многоугольник принадлежит многоугольнику ? - только для выпуклых ! }
  function BelongPolPol(var A, B: TPolygon): boolean;


  function Inside(var A, B: TGeomObject): boolean;
  { Точка в треугольнике ? }
  function InsidePT(var M: TPoint; var T: TTriangle): boolean;
  { Точка в прямоугольнике ? }
  function InsidePR(var M: TPoint; var R: TRectangle): boolean;
  { Точка внутри окружности ? }
  function InsidePC(var M: TPoint; var C: TCircle): boolean;
  { Точка в многоугольнике ? }
  function InsidePPol(var M: TPoint; var P: TPolygon): boolean;
  { Многоугольник внутри многоугольника ? - только для выпуклых ! }
  function InsidePolPol(var A, B: TPolygon): boolean;

  function Equal(var A, B: TGeomObject): boolean;

  function EqualPP(var A, B: TPoint): boolean;

  function IsZero(x: TReal): boolean;

  function ArcTan2(x, y: TReal): TReal;
  function ArcSin(x: TReal): TReal;
  function ArcCos(x: TReal): TReal;
  function ArcCtg(x: TReal): TReal;

  function Gradus(x: TReal): TReal;
  function IGradus(x: TReal): Integer;
  function Radian(x: TReal): TReal;
  { Возвращает угол, под которым виден отрезок BC из точки A  [-Pi..Pi] }
  { За положительное принято направление против часовой стрелки }
  function GetAngle(var A, B, C: TPoint): TReal;

  function FindLIntersectPoint(var l, m: TLine; var A: TPoint): boolean;
  function FindSIntersectPoint(var s1, s2: TSegment; var A: TPoint): boolean;

{$ifdef Graph}
  procedure InitGeomGraph;
  procedure CloseGeomGraph;
  function fx(x: TReal):integer;
  function fy(y: TReal):integer;
  procedure DrawRange(Color: Integer);
  { Процедура рисования координатных осей }
  procedure DrawAxis(Color: Integer);
  { Пересчитывает масштаб и вызывает DrawAxis }
  { V  Должна вызываться после подсчета масштаба перед вызовом методов Draw }
  procedure InsertOrigin(Color: Integer);
  procedure MLine(var A, B: TPoint);
{$endif}
  procedure Pause;
  { Возвращает True, если нажат ESC }
  function CPause: boolean;

implementation

function ArcSin(x: TReal): TReal;
begin
  ArcSin := ArcTan(x / sqrt(1 - x*x));
end;

function ArcCos(x: TReal): TReal;
begin
  ArcCos := Pi / 2 - ArcTan(x / sqrt(1 - x*x));
end;

function ArcCtg(x: TReal): TReal;
begin
  ArcCtg := Pi / 2 - ArcTan(x);
end;

function ArcTan2(x, y: TReal): TReal;
var
  at2: TReal;
begin
  if IsZero(y)
    then at2 := Pi / 2 * sign(x)
    else if not IsZero(x)
           then at2 := ArcTan(x / y)
           else if y > 0 then at2 := 0
                         else at2 := Pi;

  if y < 0
    then at2 := Pi * sign(x) + at2;

  ArcTan2 := at2;
end;

function TGeomObject.Exist: boolean;
begin
  Exist := Area <> 0;
end;

function TGeomObject.Area: TReal;
begin
  Area := 0;
end;

procedure TGeomObject.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  Abstract;
end;
{************ V V V *** Методы объекта TPoint *** V V V ************}
constructor TPoint.Init(ax, ay: TReal);
begin
  inherited Init;
  X := ax;
  Y := ay;
end;

function TPoint.Exist: boolean;
begin
  Exist := True;
end;

procedure TPoint.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  MinX := X;
  MaxX := X;
  MinY := Y;
  MaxY := Y;
end;
{************ ^ ^ ^ *** Методы объекта TPoint *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TCircle *** V V V ************}
constructor TCircle.Init(AX, AY, AR: TReal);
begin
  inherited Init(AX, AY);
  R := AR;
end;

function TCircle.D: TReal;
begin
  D := 2 * R
end;

function TCircle.Length: TReal;
begin
  Length := 2 * Pi * R
end;

function TCircle.Area: TReal;
begin
  Area := Pi * R * R
end;

function TCircle.Exist: boolean;
begin
  Exist := not IsZero(R);
end;

procedure TCircle.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  MinX := X - R;
  MaxX := X + R;
  MinY := Y - R;
  MaxY := Y + R;
end;
{************ ^ ^ ^ *** Методы объекта TCircle *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TSegment *** V V V ************}
constructor TSegment.Init(var aA, aB: TPoint);
begin
  inherited Init;
  A.Init(aA.X, aA.Y);
  B.Init(aB.X, aB.Y);
end;

function TSegment.Exist: boolean;
begin
  Exist := not IsZero(DistancePP(A, B));
end;

function TSegment.Length: TReal;
begin
  Length := DistancePP(A, B);
end;

procedure TSegment.GetMiddle(var M: TPoint);
begin
  M.Init((A.X + B.X)/2, (A.Y + B.Y)/2);
end;

procedure TSegment.BuildMidPerp(var L: TLine);
var
  Line: TLine;
  M: TPoint;
begin
  GetMiddle(M);
  Line.Init(A,B);
  Line.BuildPerp(M, L);
end;

procedure TSegment.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  MinX := min(A.X, B.X);
  MaxX := max(A.X, B.X);
  MinY := min(A.Y, B.Y);
  MaxY := max(A.Y, B.Y);
end;
{************ ^ ^ ^ *** Методы объекта TSegment *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TLine *** V V V ************}
constructor TLine.Init(var aA, aB: TPoint);
begin
  inherited Init;
  { Коэффициенты для уравнения Ax + By + C = 0 }
  A := aB.Y - aA.Y;
  B := aA.X - aB.X;
  C := aA.Y*(aB.X-aA.X) - aA.X*(aB.Y-aA.Y);
  CalcK;
end;

function TLine.Exist: boolean;
begin
  Exist := not (IsZero(A) and IsZero(B))
end;

procedure TLine.CalcK;
begin
  { Коэффициенты для уравнения y = kx + d }
  if B <> 0 then
    begin
      k := -A/B;
      d := -C/B;
      KExist := True;
    end
  else KExist := False;
end;

procedure TLine.BuildPerp(M: TPoint; var L: TLine);
var
  N: TPoint;
begin
  if not Exist then Exit;
  N.Init(M.X, M.Y + 1);
  L.Init(M, N);
  L.A := -B;
  L.B := A;
  L.C := B * M.X - A * M.Y;
end;

procedure TLine.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  MinX := 0;
  MaxX := 0;
  MinY := 0;
  MaxY := 0;
end;
{************ ^ ^ ^ *** Методы объекта TLine *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TTriangle *** V V V ************}
constructor TTriangle.Init(var aA, aB, aC: TPoint);
begin
  inherited Init;

  A.Init(aA.X, aA.Y);
  B.Init(aB.X, aB.Y);
  C.Init(aC.X, aC.Y);
end;

function TTriangle.Area: TReal;
var
  p: TReal;
begin
  p := Perimeter / 2;
  Area := sqrt(p *
    (p - DistancePP(A,B)) * (p - DistancePP(A,C)) * (p - DistancePP(B,C)));
end;

function TTriangle.Perimeter: TReal;
begin
  Perimeter := DistancePP(A,B) + DistancePP(A,C) + DistancePP(B,C);
end;

procedure TTRiangle.GetCircumscrCircle(var Circle: TCircle);
var
  s1, s2: TSegment;
  p1, p2: TLine;
  f: boolean;
  Centre: TPoint;
  Radius: TReal;
begin
  s1.Init(A, B);
  s2.Init(A, C);
  s1.BuildMidPerp(p1);
  s2.BuildMidPerp(p2);
  f := FindLIntersectPoint(p1, p2, Centre);
  Radius := DistancePP(Centre, A);
  Circle.Init(Centre.X, Centre.Y, Radius);
end;

procedure TTriangle.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  MinX := min(A.X, min(B.X, C.X));
  MaxX := max(A.X, max(B.X, C.X));
  MinY := min(A.Y, min(B.Y, C.Y));
  MaxY := max(A.Y, max(B.Y, C.Y));
end;
{************ ^ ^ ^ *** Методы объекта TTriangle *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TRectangle *** V V V ************}
constructor TRectangle.Init(var aA, aB: TPoint);
begin
  inherited Init;
  A.Init(min(aA.X, aB.X), min(aA.Y, aB.Y));
  B.Init(max(aA.X, aB.X), max(aA.Y, aB.Y));
end;

function TRectangle.Area: TReal;
begin
  Area := (B.X - A.X) * (B.Y - A.Y);
end;

function TRectangle.Perimeter: TReal;
begin
  Perimeter := 2 * ((B.Y - A.Y) + (B.X - A.X));
end;

procedure TRectangle.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
begin
  MinX := A.X;
  MaxX := B.X;
  MinY := A.Y;
  MaxY := B.Y;
end;
{************ ^ ^ ^ *** Методы объекта TRectangle *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TPointsSet *** V V V ************}
constructor TPointsSet.Init;
begin
  inherited Init;
  Points.Init(StartSize, Delta);
end;

destructor TPointsSet.Done;
begin
  Points.Done;

  inherited Done;
end;

function TPointsSet.CountPoints: Integer;
begin
  CountPoints := Points.Count;
end;

function TPointsSet.GetPoint(Index: Integer): PPoint;
begin
  GetPoint := Points.At(Index - 1)
end;

function TPointsSet.Diameter: TReal;
var
  D: TReal;
  i, j: Integer;
begin
  D := 0;
  for i := 1 to CountPoints - 1 do
    for j := i + 1 to CountPoints do
      D := max(D, DistancePP(GetPoint(i)^, GetPoint(j)^));
  Diameter := D;
end;

procedure TPointsSet.AddPoint(x, y: TReal);
var
  Point: PPoint;
begin
  New(Point, Init(x, y));
  Points.Insert(Point);
end;

procedure TPointsSet.AddPointAt(Index: Integer; x, y: TReal);
var
  Point: PPoint;
begin
  New(Point, Init(x, y));
  Points.AtInsert(Index - 1, Point);
end;

procedure TPointsSet.DeletePoint(Index: Integer);
begin
  Points.AtFree(Index - 1);
end;

procedure TPointsSet.DelLastPoint;
begin
  DeletePoint(CountPoints);
end;

function TPointsSet.Exist: boolean;
begin
  Exist := CountPoints <> 0;
end;

procedure TPointsSet.FindMinMax(var MinX, MinY, MaxX, MaxY: TReal);
var
  i: Integer;
begin
  MinX := GetPoint(1)^.X;
  MinY := GetPoint(1)^.Y;
  MaxX := MinX;
  MaxY := MinY;
  for i := 2 to CountPoints do
  begin
    MaxX := max(MaxX, GetPoint(i)^.X);
    MinX := min(MinX, GetPoint(i)^.X);
    MaxY := max(MaxY, GetPoint(i)^.Y);
    MinY := min(MinY, GetPoint(i)^.Y);
  end;
end;

procedure TPointsSet.GetMinSalientShell(var Shell: PPolygon);
var
  LeftX, Angle, MaxAngle: TReal;
  LeftPoint, NextPoint: Integer;
  PrevPoint: TPoint;
  i: Integer;
begin
  New(Shell, Init);
  if not Exist then Exit;
  LeftX := GetPoint(1)^.X;
  LeftPoint := 1;
  for i := 2 to CountPoints do
    if LeftX > GetPoint(i)^.X then
    begin
      LeftPoint := i;
      LeftX := GetPoint(i)^.X;
    end;

  PrevPoint.Init(LeftX + 1, GetPoint(LeftPoint)^.Y);
  NextPoint := LeftPoint;
  repeat
    Shell^.AddPoint(GetPoint(NextPoint)^.X, GetPoint(NextPoint)^.Y);
    MaxAngle := -500;
    for i := 1 to CountPoints do
      begin
        Angle := GetAngle(Shell^.GetPoint(Shell^.CountPoints)^,
                   PrevPoint, GetPoint(i)^);
        if Angle < 0 then Angle := 2 * Pi - Angle;
        if (Angle > MaxAngle) and not IsZero(
          (DistancePP(Shell^.GetPoint(Shell^.CountPoints)^, GetPoint(i)^)))
            then begin
              NextPoint := i;
              MaxAngle := Angle;
            end;
      end;
    PrevPoint := Shell^.GetPoint(Shell^.CountPoints)^;
  until NextPoint = LeftPoint;
end;
{************ ^ ^ ^ *** Методы объекта TPointsSet *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TBroken *** V V V ************}
constructor TBroken.Init;
begin
  inherited Init;
end;

function TBroken.IsSelfCross: boolean;
var
  i, j: Integer;
  p: TPoint;
  S1, S2: TSegment;
begin
  IsSelfCross := True;
  for i := 1 to CountPoints - 2 do
    for j := i + 2 to CountPoints - 1 do
    begin
      S1.Init(GetPoint(i)^, GetPoint(i + 1)^);
      S2.Init(GetPoint(j)^, GetPoint(j mod CountPoints + 1)^);
      if FindSIntersectPoint(S1, S2, p) and not
        ((i = 1) and (j = CountPoints - 1)
        and IsZero(DistancePP(p, GetPoint(1)^))
        and IsZero(DistancePP(p, GetPoint(CountPoints)^)))
      then Exit;
    end;
  IsSelfCross := False;
end;

function TBroken.Perimeter: TReal;
var
  Perim: TReal;
  i: Integer;
begin
  Perim := 0;
  for i := 1 to CountPoints - 1 do
    Perim := Perim + DistancePP(GetPoint(i)^, GetPoint(i+1)^);
  Perimeter := Perim;
end;

function TBroken.Exist: boolean;
begin
  Exist := inherited Exist;
end;
{************ ^ ^ ^ *** Методы объекта TBroken *** ^ ^ ^ ************}

{************ V V V *** Методы объекта TPolygon *** V V V ************}
constructor TPolygon.Init;
begin
  inherited Init;
end;

function TPolygon.Exist: boolean;
begin
  Exist := inherited Exist;
end;

function TPolygon.IsSelfCross: boolean;
var
  i: Integer;
  S1, S2: TSegment;
  p: TPoint;
begin
  IsSelfCross := True;
  AddPoint(GetPoint(1)^.X, GetPoint(1)^.Y);
  IsSelfCross := inherited IsSelfCross;
  DelLastPoint;
end;

function TPolygon.IsSalient: boolean;
var
  i, j: Integer;
  l: TLine;
  s: integer;
begin
  IsSalient := False;
  for i := 1 to CountPoints do
  begin
    l.Init(GetPoint(i)^, GetPoint(i mod CountPoints + 1)^);
    j := 0;
    repeat
      Inc(j);
      s := sign(l.A * GetPoint(j)^.X + l.B * GetPoint(j)^.Y + l.C);
    until (s <> 0) or (j = CountPoints);
    if s = 0 then
    begin
      IsSalient := True;
      Exit;
    end;
    for j := 1 to CountPoints do
      if s = - sign(l.A * GetPoint(j)^.X + l.B * GetPoint(j)^.Y + l.C)
        then Exit;
  end;
  IsSalient := True;
end;

function TPolygon.Area: TReal;
var
  i: Integer;
  s: TReal;
begin
  s := 0;

  AddPoint(GetPoint(1)^.X, GetPoint(1)^.Y);

  for i := 1 to CountPoints - 1 do
    s := s + (GetPoint(i)^.X - GetPoint(i+1)^.X) *
       (GetPoint(i)^.Y + GetPoint(i+1)^.Y) / 2;

  DelLastPoint;

  Area := abs(s);
end;

function TPolygon.Perimeter: TReal;
begin
  Perimeter := inherited Perimeter +
               DistancePP(GetPoint(1)^, GetPoint(CountPoints)^)
end;
{************ ^ ^ ^ *** Методы объекта TPolygon *** ^ ^ ^ ************}

{ Расстояние между двумя точками }
function DistancePP(var A,B: TPoint): TReal;
begin
  DistancePP := sqrt(sqr(A.X - B.X) + sqr(A.Y - B.Y));
end;

{ Расстояние от точки до прямой }
function DistancePL(var M: TPoint; var L:TLine): TReal;
begin
  DistancePL :=
    abs(L.A * M.X + L.B * M.Y + L.C) / sqrt(sqr(L.A) + sqr(L.B));
end;

function Distance(var A,B: TGeomObject): TReal;
begin
  Distance := 0;

  { Расстояние между двумя точками }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TPoint))
    then Distance := DistancePP(PPoint(@A)^, PPoint(@B)^) else

  { Расстояние от точки до прямой }
  if (TypeOf(A) = TypeOf(TLine)) and (TypeOf(B) = TypeOf(TPoint))
    then Distance := DistancePL(PPoint(@B)^, PLine(@A)^) else
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TLine))
    then Distance := DistancePL(PPoint(@A)^, PLine(@B)^);
end;

function BelongPL(var M: TPoint; var L: TLine): boolean;
begin
  BelongPL := IsZero(L.A * M.X + L.B * M.Y + L.C)
end;

function BelongPS(var M: TPoint; var S: TSegment): boolean;
begin
  BelongPS := IsZero(S.Length - DistancePP(S.A, M) - DistancePP(S.B, M));
end;

function BelongPC(var M: TPoint; var C: TCircle): boolean;
begin
  BelongPC := IsZero(DistancePP(M, C) - C.R);
end;

function BelongPT(var M: TPoint; var T: TTriangle): boolean;
var
  T1, T2, T3: TTriangle;
begin
  T1.Init(T.A, T.B, M);
  T2.Init(T.A, T.C, M);
  T3.Init(T.B, T.C, M);
  BelongPT := IsZero(T.Area - T1.Area - T2.Area - T3.Area);
end;

function BelongPR(var M: TPoint; var R: TRectangle): boolean;
begin
  BelongPR := (R.A.X <= M.X) and (R.B.X >= M.X)
              and (R.A.Y <= M.Y) and (R.B.Y >= M.Y);
end;

function BelongPB(var M: TPoint; var B: TBroken): boolean;
var
  i: Integer;
  S: TSegment;
  Belong: boolean;
begin
  Belong := False;
  for i := 1 to B.CountPoints - 1 do
  begin
    S.Init(B.GetPoint(i)^, B.GetPoint(i+1)^);
    Belong := Belong or BelongPS(M, S);
    if Belong then Break;
  end;
  BelongPB := Belong;
end;

function BelongPPol(var M: TPoint; var P: TPolygon): boolean;
var
  Belong: boolean;
begin
  if not P.Exist then
  begin
    BelongPPol := False;
    Exit
  end;
  P.AddPoint(P.GetPoint(1)^.X, P.GetPoint(1)^.Y);
  Belong := BelongPB(M, P);
  P.DelLastPoint;
  BelongPPol := Belong or InsidePPol(M, P);
end;

function BelongPolPol(var A, B: TPolygon): boolean;
var
  i: Integer;
begin
  for i := 1 to A.CountPoints do
    if not BelongPPol(A.GetPoint(i)^, B)
    then begin
      BelongPolPol := False;
      Exit;
    end;
  for i := 1 to B.CountPoints do
    if InsidePPol(B.GetPoint(i)^, A)
    then begin
      BelongPolPol := False;
      Exit;
    end;
  BelongPolPol := True;
end;

function Belong(var A, B: TGeomObject): boolean;
begin
  Belong := False;

  { Точка на прямой ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TLine))
    then Belong := BelongPL(PPoint(@A)^, PLine(@B)^) else

  { Точка на отрезке ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TSegment))
    then Belong := BelongPS(PPoint(@A)^, PSegment(@B)^) else

  { Точка принадлежит треугольнику ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TTriangle))
    then Belong := BelongPT(PPoint(@A)^, PTriangle(@B)^) else

  { Точка принадлежит прямоугольнику ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TRectangle))
    then Belong := BelongPR(PPoint(@A)^, PRectangle(@B)^) else

  { Точка принадлежит многоугольнику ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TPolygon))
    then Belong := BelongPPol(PPoint(@A)^, PPolygon(@B)^) else

  { Точка на ломаной ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TBroken))
    then Belong := BelongPB(PPoint(@A)^, PBroken(@B)^) else

  { Точка на окружности ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TCircle))
    then Belong := BelongPC(PPoint(@A)^, PCircle(@B)^) else

  { Многоугольник принадлежит многоугольнику ? - только для выпуклых ! }
  if (TypeOf(A) = TypeOf(TPolygon)) and (TypeOf(B) = TypeOf(TPolygon))
    then Belong := BelongPolPol(PPolygon(@A)^, PPolygon(@B)^)
end;

function InsidePC(var M: TPoint; var C: TCircle): boolean;
begin
  InsidePC := DistancePP(M, C) < C.R
end;

function InsidePT(var M: TPoint; var T: TTriangle): boolean;
var
  S1, S2, S3: TSegment;
begin
  S1.Init(T.A, T.B);
  S2.Init(T.B, T.C);
  S3.Init(T.A, T.C);
  InsidePT := BelongPT(M, T) and
                not (BelongPS(M, S1) or BelongPS(M, S2) or BelongPS(M, S3));
end;

function InsidePR(var M: TPoint; var R: TRectangle): boolean;
begin
  InsidePR := (R.A.X < M.X) and (R.B.X > M.X)
              and (R.A.Y < M.Y) and (R.B.Y > M.Y);
end;

function InsidePPol(var M: TPoint; var P: TPolygon): boolean;
var
  alpha, R: TReal;
  i, l: Integer;
begin
  if not P.Exist then
  begin
    InsidePPol := False;
    Exit
  end;
  alpha := 0;
  for i := 1 to P.CountPoints do
  begin
    l := i mod P.CountPoints + 1;

    R := GetAngle(M, P.GetPoint(i)^, P.GetPoint(l)^);

    if not (IsZero(abs(R) - Pi) or
      IsZero(DistancePP(M, P.GetPoint(i)^) * DistancePP(M, P.GetPoint(l)^)))
    then alpha := alpha + R
    else begin
      alpha := 0;
      Break;
    end;
  end;
  InsidePPol := not IsZero(alpha);
end;

function InsidePolPol(var A, B: TPolygon): boolean;
var
  i: Integer;
begin
  for i := 1 to A.CountPoints do
    if not InsidePPol(A.GetPoint(i)^, B)
    then begin
      InsidePolPol := False;
      Exit;
    end;
  for i := 1 to B.CountPoints do
    if BelongPPol(B.GetPoint(i)^, A)
    then begin
      InsidePolPol := False;
      Exit;
    end;
  InsidePolPol := True;
end;

function Inside(var A, B: TGeomObject): boolean;
begin
  Inside := False;

  { Точка в треугольнике ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TTriangle))
    then Inside := InsidePT(PPoint(@A)^, PTriangle(@B)^) else

  { Точка в прямоугольнике ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TRectangle))
    then Inside := InsidePR(PPoint(@A)^, PRectangle(@B)^) else

  { Точка в многоугольнике ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TPolygon))
    then Inside := InsidePPol(PPoint(@A)^, PPolygon(@B)^) else

  { Точка внутри окружности ? }
  if (TypeOf(A) = TypeOf(TPoint)) and (TypeOf(B) = TypeOf(TCircle))
    then Inside := InsidePC(PPoint(@A)^, PCircle(@B)^) else

  { Многоугольник внутри многоугольника ? - только для выпуклых ! }
  if (TypeOf(A) = TypeOf(TPolygon)) and (TypeOf(B) = TypeOf(TPolygon))
    then Inside := InsidePolPol(PPolygon(@A)^, PPolygon(@B)^)
end;

function Equal(var A, B: TGeomObject): boolean;
begin
  Equal := False;
  if TypeOf(A) <> TypeOf(B) then Exit;
  if TypeOf(A) = TypeOf(TPoint)
    then Equal := EqualPP(PPoint(@A)^, PPoint(@B)^);
end;

function EqualPP(var A, B: TPoint): boolean;
begin
  EqualPP := IsZero(A.X - B.X) and IsZero(A.Y - B.Y);
end;

function IsZero(x: TReal): boolean;
begin
  IsZero := abs(x) < Mistake;
end;

function max(x, y: TReal): TReal;
begin
  if x > y
    then max := x
    else max := y
end;

function min(x, y: TReal): TReal;
begin
  if x < y
    then min := x
    else min := y
end;

function FindLIntersectPoint(var l,m: TLine; var A: TPoint): boolean;
var
  d,detx,dety: TReal;
begin
  FindLIntersectPoint := False;
  d := l.A * m.B - l.B * m.A;
  if d=0 then exit;
  detx := -l.C * m.B + l.B * m.C;
  dety := -l.A * m.C + l.C * m.A;
  A.Init(detx/d, dety/d);
  FindLIntersectPoint := True;
end;

function FindSIntersectPoint(var s1, s2: TSegment; var A: TPoint): boolean;
var
  l, m: TLine;
begin
  l.Init(s1.A, s1.B);
  m.Init(s2.A, s2.B);
  FindSIntersectPoint := l.Exist and m.Exist and
                           FindLIntersectPoint(l, m, A) and
                              BelongPS(A, s1) and Belong(A, s2);
end;

function Gradus(x: TReal): TReal;
begin
  Gradus := x * 180 /Pi
end;

function IGradus(x: TReal): Integer;
begin
  IGradus := Round(Gradus(x));
end;

function Radian(x: TReal): TReal;
begin
  Radian := x * Pi / 180
end;

function sign(x: TReal): Integer;
begin
  if IsZero(x) then sign := 0 else
  if x > 0 then sign := 1
  else sign := -1;
end;

function GetAngle(var A, B, C: TPoint): TReal;
var
  R: TReal;
begin
  R := ArcTan2(B.X - A.X, B.Y - A.Y) -
       ArcTan2(C.X - A.X, C.Y - A.Y);

  if R > Pi then R := R - Pi * 2
    else if R < -Pi then R := R + Pi * 2;

  if IsZero(DistancePP(A, B) * DistancePP(A, C))
    then R := 0;

  GetAngle := R;
end;

{$ifdef Graph}

{ Работа с графикой }

{************ V V V *** Методы объекта TScale *** V V V ************}
constructor TScale.Init;
begin
  inherited Init;

  factorX := 1;
  factorY := 1;
  MinX := 0;
  MinY := 0;
  MaxX := GetMaxX;
  MaxY := GetMaxY;
end;

procedure TScale.Calculate(var Obj: TGeomObject);
var
  ResX, ResY:integer;
  ViewPort: ViewPortType;
begin
  GetViewSettings(ViewPort);
  ResX:= ViewPort.x2 - ViewPort.x1 - 10;
  ResY:= ViewPort.y2 - ViewPort.y1 - 10;
  if Obj.Exist
    then Obj.FindMinMax(MinX, MinY, MaxX, MaxY)
  else Init;
  if (MaxX - MinX) <> 0
    then factorX := ResX / (MaxX - MinX);
  if (MaxY - MinY) <> 0
    then factorY := ResY / (MaxY - MinY);
end;

procedure TScale.Correct(var Obj: TGeomObject);
var
  ResX, ResY:integer;
  ViewPort: ViewPortType;
  MinX1, MaxX1, MinY1, MaxY1: TReal;
begin
  Obj.FindMinMax(MinX1, MinY1, MaxX1, MaxY1);
  MaxX := max(MaxX, MaxX1);
  MinX := min(MinX, MinX1);
  MaxY := max(MaxY, MaxY1);
  MinY := min(MinY, MinY1);
  GetViewSettings(ViewPort);
  ResX := ViewPort.x2 - ViewPort.x1 - 10;
  ResY := ViewPort.y2 - ViewPort.y1 - 10;
  if (MaxX - MinX) <> 0
    then factorX := ResX / (MaxX - MinX);
  if (MaxY - MinY) <> 0
    then factorY := ResY / (MaxY - MinY);
end;

procedure TScale.Even;
begin
  if factorX > factorY
    then factorX := factorY
    else factorY := factorX;
end;
{************ ^ ^ ^ *** Методы объекта TScale *** ^ ^ ^ ************}

procedure InitGeomGraph;
var
  Drive, Mode:integer;

begin
  Drive:=Detect;
  InitGraph(Drive, Mode, PathToDrv);
  if GraphResult = grOk then Scale.Init;
end;

procedure CloseGeomGraph;
begin
  CloseGraph;
  Scale.Done;
end;

procedure DrawRange(Color: Integer);
var
  OldColor: Integer;
  LineSettings: LineSettingsType;
begin
  OldColor:=GetColor;
  GetLineSettings(LineSettings);
  SetColor(Color);
  SetLineStyle(SolidLn, 0, ThickWidth);
  SetTextStyle(0, 0, 1);
  rectangle(4,TextHeight(Cpr) + 4, GetMaxX - 4,
              GetMaxY - TextHeight(Prompt) - 7);
  SetTextJustify(CenterText,BottomText);
  OutTextXY(GetMaxX div 2, TextHeight(Cpr), Cpr);
  OutTextXY(GetMaxX div 2, GetMaxY-2, Prompt);
  SetLineStyle
     (LineSettings.LineStyle,LineSettings.Pattern,LineSettings.Thickness);
  SetViewPort(10,TextHeight(Cpr) + 10, GetMaxX - 10,
               GetMaxY - TextHeight(Prompt) - 12, True);
  SetColor(OldColor);
end;

procedure DrawAxis(Color: Integer);
var
  ViewPort: ViewPortType;
begin
  GetViewSettings(ViewPort);
  SetColor(Color);
  with ViewPort do
  begin
    Line(fx(0), 0, fx(0), y2 - y1);
    Line(0, fy(0), x2 - x1, fy(0));
  end;
end;

procedure InsertOrigin(Color: Integer);
begin
  Scale.Correct(Origin);
  DrawAxis(Color);
end;

procedure MLine(var A, B: TPoint);
begin
  Line(fx(A.X), fy(A.Y), fx(B.X), fy(B.Y));
end;

function fx(x: TReal):integer;
var
  ResX:integer;
  ViewPort: ViewPortType;
begin
  GetViewSettings(ViewPort);
  ResX:= ViewPort.x2 - ViewPort.x1 - 10;
  fx := Trunc(ResX / 2 +
       (x - (Scale.MaxX - Scale.MinX) / 2 - Scale.MinX) * Scale.factorX) + 5
end;

function fy(y: TReal):integer;
var
  ResY:integer;
  ViewPort: ViewPortType;
begin
  GetViewSettings(ViewPort);
  ResY:= ViewPort.y2 - ViewPort.y1 - 10;
  fy := Trunc(ResY / 2 +
      (-y + (Scale.MaxY - Scale.MinY) / 2 + Scale.MinY) * Scale.factorY) + 5
end;

{************ V V V *** Методы Draw *** V V V ************}
procedure TGeomObject.Draw(Color1, Color2, Radius: Integer);
begin
  Abstract;
end;

procedure TPoint.Draw(Color1, Color2, Radius: Integer);
begin
  if not Exist then Exit;
  SetColor(Color2);
  if Radius <= 0
    then PutPixel(fx(X), fy(Y), Color2)
    else Ellipse(fx(X), fy(Y), 0, 360, Radius, Radius);
end;

procedure TCircle.Draw(Color1, Color2, Radius: Integer);
begin
  if not Exist then Exit;
  inherited Draw(Color1, Color2, Radius);
  SetColor(Color1);
  Ellipse(fx(X), fy(Y), 0, 360,
    Round(R * Scale.factorX), Round(R * Scale.factorY));
end;

procedure TLine.Draw(Color1, Color2, Radius: Integer);
begin
  if not Exist then Exit;
  SetColor(Color1);

end;

procedure TSegment.Draw(Color1, Color2, Radius: Integer);
begin
  if not Exist then Exit;
  SetColor(Color1);
  MLine(A, B);
  A.Draw(Color1, Color2, Radius);
  B.Draw(Color1, Color2, Radius);
end;

procedure TTriangle.Draw(Color1, Color2, Radius: Integer);
begin
  if not Exist then Exit;
  SetColor(Color1);
  MLine(A, B);
  MLine(A, C);
  MLine(B, C);
  A.Draw(Color1, Color2, Radius);
  B.Draw(Color1, Color2, Radius);
  C.Draw(Color1, Color2, Radius);
end;

procedure TRectangle.Draw(Color1, Color2, Radius: Integer);
var
  C, D: TPoint;
begin
  if not Exist then Exit;
  C.Init(B.X, A.Y);
  D.Init(A.X, B.Y);
  SetColor(Color1);
  MLine(A, C);
  MLine(C, B);
  MLine(B, D);
  MLine(D, A);
  A.Draw(Color1, Color2, Radius);
  B.Draw(Color1, Color2, Radius);
  C.Draw(Color1, Color2, Radius);
  D.Draw(Color1, Color2, Radius);
end;

procedure TPointsSet.Draw(Color1, Color2, Radius: Integer);

{$F+}
  procedure DrawPoint(P: PPoint);
  begin
    P^.Draw(Color1, Color2, Radius);
  end;
{$F-}

begin
  if not Exist then Exit;
  Points.ForEach(@DrawPoint);
end;

procedure TBroken.Draw(Color1, Color2, Radius: Integer);
var
  i: Integer;
  A, B: TPoint;
begin
  if not Exist then Exit;
  SetColor(Color1);
  for i := 1 to CountPoints - 1 do
  begin
    A.Init(GetPoint(i)^.X, GetPoint(i)^.Y);
    B.Init(GetPoint(i+1)^.X, GetPoint(i+1)^.Y);
    MLine(A, B);
  end;

  inherited Draw(Color1, Color2, Radius);
end;

procedure TPolygon.Draw(Color1, Color2, Radius: Integer);
begin
  if not Exist then Exit;
  SetColor(Color1);
  MLine(GetPoint(1)^, GetPoint(CountPoints)^);

  inherited Draw(Color1, Color2, Radius);
end;
{************ ^ ^ ^ *** Методы Draw *** ^ ^ ^ ************}

{$endif}

function CPause: boolean;
var
  ch: char;
begin
  while KeyPressed do ch := ReadKey;
  ch := ReadKey;
  CPause := ch = #27;
  while KeyPressed do ch := ReadKey;
end;

procedure Pause;
begin
  if CPause then;
end;


end.

