(**********************************************************)
(*                                                        *)
(* Модуль LineColl                                        *)
(* Несортированная коллекция строк                        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 07.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

Unit LineColl;

interface

uses Objects;

type

  { TLineCollection }

  PLineCollection = ^TLineCollection;
  TLineCollection = object(TStringCollection)
    procedure Insert(Item: Pointer); virtual;
    function AtStr(Index: Integer): String;
  end;

implementation

{ TLineCollection }

procedure TLineCollection.Insert(Item: Pointer);
begin
  AtInsert(Count, Item);
end;

function TLineCollection.AtStr(Index: Integer): String;
var
  p: PString;
begin
  p := PString(At(Index));
  if Assigned(p)
    then AtStr := p^
  else AtStr:= '';
end;

end.
