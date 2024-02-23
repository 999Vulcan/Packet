{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1992 by Borland International  }
{   Changed by VULCAN   20.09.94                 }
{                                                }
{************************************************}

unit Gadgets;

{$F+,O-,S-,D-,Q-,R-}

{ Useful gadgets: clock and heap available viewer }

interface

uses Dos, Objects, Views, App;

type
  PHeapView = ^THeapView;
  THeapView = object(TView)
    OldMem : LongInt;
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update;
  end;

  PClockView = ^TClockView;
  TClockView = object(TView)
    Refresh: Byte;
    LastTime: DateTime;
    TimeStr: string[10];
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    procedure Update; virtual;
    function FormatTimeStr(H, M, S: Word): String; virtual;
    function DateStr: String; virtual;
    function DayStr: String; virtual;
  end;

implementation

uses Drivers, ShtState, Language, PackLng, PackConf;

{------ Heap Window object ----------}

constructor THeapView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  OldMem := 0;
end;

procedure THeapView.Draw;
var
  S: String;
  B: TDrawBuffer;
  C: Byte;
begin
  OldMem := MemAvail;
  Str(OldMem:Size.X, S);
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, S, C);
  WriteLine(0, 0, Size.X, 1, B);
end;


procedure THeapView.Update;
begin
  if (OldMem <> MemAvail) then DrawView;
end;

{-------- ClockView Object --------}

function LeadingZero(w: Word): String;
var s: String;
begin
  Str(w:0, s);
  LeadingZero := Copy('00', 1, 2 - Length(s)) + s;
end;

constructor TClockView.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  FillChar(LastTime, SizeOf(LastTime), #$FF);
  TimeStr := '';
  Refresh := 1;
end;


procedure TClockView.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  C := GetColor(2);
  MoveChar(B, ' ', C, Size.X);
  if not AltDown and CtrlDown and CalendarInClock
    then MoveStr(B, DayStr, C)
  else if not AltDown and ShiftDown and CalendarInClock
    then MoveStr(B, DateStr, C)
  else MoveStr(B, TimeStr, C);
  WriteLine(0, 0, Size.X, 1, B);
end;


procedure TClockView.Update;
var
  h,m,s,hund: word;
begin
  GetTime(h,m,s,hund);
  if Abs(s - LastTime.sec) >= Refresh then
  begin
    with LastTime do
    begin
      Hour := h;
      Min := m;
      Sec := s;
    end;
    TimeStr := FormatTimeStr(h, m, s);
    DrawView;
  end;
end;

function TClockView.FormatTimeStr(H, M, S: Word): String;
begin
  FormatTimeStr := '  ' + LeadingZero(h)+ ':'+ LeadingZero(m) +
    ':' + LeadingZero(s);
end;

function TClockView.DateStr: String;
var
  Year, Month, Day, DayOfWeek: Word;
begin
  GetDate(Year, Month, Day, DayOfWeek);
  DateStr := '  ' + LeadingZero(Day) + '/' + LeadingZero(Month) + '/' +
             LeadingZero(Year mod 100);
end;

function TClockView.DayStr: String;
var
  Year, Month, Day, DayOfWeek: Word;
begin
  GetDate(Year, Month, Day, DayOfWeek);
  DayStr := Ph(phSunday + DayOfWeek);
end;

end.
