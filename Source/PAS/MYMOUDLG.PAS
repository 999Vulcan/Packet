{************************************************}
{                                                }
{   Turbo Vision Demo                            }
{   Copyright (c) 1990 by Borland International  }
{   Changed by VULCAN                            }
{   28.09.93 - 18.10.94                          }
{                                                }
{************************************************}

{ Mouse option dialog used by TVDEMO.PAS and TVRDEMO.PAS }

unit MyMouDlg;

{$F+,O+,X+,S-,D-}

interface

uses Drivers, Objects, Views, Dialogs;

const
  CClickTester = #7#8;

type

  { TClickTester }

  {Palette layout}
  { 0 = Unclicked }
  { 1 = Clicked }

  PClickTester = ^TClickTester;
  TClickTester = object(TStaticText)
    Clicked: Boolean;
    constructor Init(var Bounds: TRect; AText: String);
    function GetPalette: PPalette; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
  end;

  { TMouseDialog }

  PMouseDialog = ^TMouseDialog;
  TMouseDialog = object(TDialog)
    MouseScrollBar: PScrollBar;
    OldDelay: Word;
    constructor Init;
    constructor Load(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Store(var S: TStream);
  end;

implementation

{***}
uses Language, PackLng;
{***}

{ TClickTester }

constructor TClickTester.Init(var Bounds: TRect; AText: String);
begin
  inherited Init(Bounds, AText);
  Clicked := False;
end;

function TClickTester.GetPalette: PPalette;
const
  P: String[Length(CClickTester)] = CClickTester;
begin
  GetPalette := @P;
end;

procedure TClickTester.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evMouseDown) then
  begin
    if Event.Double then
    begin
      Clicked := not Clicked;
      DrawView;
    end;
    ClearEvent(Event);
  end;
end;

procedure TClickTester.Draw;
var
  B: TDrawBuffer;
  C: Byte;
begin
  if Clicked then C := GetColor(2)
  else C := GetColor(1);
  MoveChar(B, ' ', C, Size.X);
  MoveStr(B, Text^, C);
  WriteLine(0, 0, Size.X, 1, B);
end;

{ TMouseDialog }

constructor TMouseDialog.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 34, 12);
  inherited Init(R, Ph(phMouseOptions));
  Options := Options or ofCentered;

  R.Assign(3, 4, 30, 5);
  MouseScrollBar := New(PScrollBar, Init(R));
  MouseScrollBar^.SetParams(1, 1, 20, 20, 1);
  MouseScrollBar^.Options := MouseScrollBar^.Options or ofSelectable;
  MouseScrollBar^.SetValue(DoubleDelay);
  Insert(MouseScrollBar);
{***}
  R.Assign(2, 2, 30, 3);
{***}
  Insert(New(PLabel, Init(R, Ph(phCMouseDoubleClick), MouseScrollBar)));

  R.Assign(3, 3, 30, 4);
  Insert(New(PClickTester, Init(R, Ph(phMouseDlgI))));

  R.Assign(3, 6, 30, 8);
  Insert(New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCReverseMouseButtons),
    NewSItem(Ph(phCSmoothMouse),
    nil)))));

  OldDelay := DoubleDelay;

  R.Assign(9, 9, 19, 11);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  Inc(R.A.X, 12); Inc(R.B.X, 12);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));

  SelectNext(False);
end;

constructor TMouseDialog.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, MouseScrollBar);
  MouseScrollBar^.SetValue(DoubleDelay);
end;

procedure TMouseDialog.HandleEvent(var Event: TEvent);
begin
{***}
{***}
  case Event.What of
    evCommand:
      if Event.Command = cmCancel then DoubleDelay := OldDelay;
    evBroadcast:
      if Event.Command = cmScrollBarChanged then
      begin
        DoubleDelay := MouseScrollBar^.Value;
        ClearEvent(Event);
      end;
  end;
{***}
  inherited HandleEvent(Event);
{***}
end;

procedure TMouseDialog.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, MouseScrollBar);
end;

end.
