(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль XListBox                                        *)
(* Объект TXListBox (список с горизонтальным скроллингом) *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат   : 10.12.1994                                   *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit XListBox;

interface

uses

  Objects, Views, Drivers;

type

  PXListBox = ^TXListBox;
  TXListBox = object(TListViewer)
    constructor Init(var Bounds: TRect;
		     AHScrollBar, AVScrollBar: PScrollBar);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure AdjustHorScr;
    function MaxXValue: byte; virtual;
  end;

implementation

constructor TXListBox.Init(var Bounds: TRect;
                           AHScrollBar, AVScrollBar: PScrollBar);
begin
  inherited Init(Bounds, 1, AHScrollBar, AVScrollBar);
end;

procedure TXListBox.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evMouseDown) and Event.Double
    then begin
      Message(Owner, evCommand, cmOk, nil);
      ClearEvent(Event);
    end;

  inherited HandleEvent(Event);
end;

procedure TXListBox.AdjustHorScr;
begin
  if Assigned(HScrollBar)
    then HScrollBar^.SetParams(HScrollBar^.Value, 1, MaxXValue,
                               Size.X, HScrollBar^.ArStep);
end;

function TXListBox.MaxXValue: byte;
var
  i, MaxValue: Integer;
  s: String;
begin
  MaxValue := 0;
  for i := 0 to Range - 1 do
    begin
      s := GetText(i, 255);
      if Length(s) > MaxValue
        then MaxValue := Length(s);
    end;
  MaxValue := MaxValue - Size.X + 3;
  if MaxValue > 0
    then MaxXValue := Lo(MaxValue)
  else MaxXValue := 0;
end;

end.
