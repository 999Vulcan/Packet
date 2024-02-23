(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль StrStack                                        *)
(* Объект StrStack - строковой стек                       *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 06.11.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit StrStack;

interface

uses Objects, LineColl, StrServ, StreamID;

type

  PStrStack =^TStrStack;
  TStrStack = object(TLineCollection)
    MaxSize: Integer;

    constructor Init(ALimit, ADelta, AMaxSize: Integer);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure Push(s: String);
    function Pop: String;
  end;

const

  RStrStack: TStreamRec = (
     ObjType: idStrStack;
     VmtLink: Ofs(TypeOf(TStrStack)^);
     Load:    @TStrStack.Load;
     Store:   @TStrStack.Store
  );

implementation

constructor TStrStack.Init(ALimit, ADelta, AMaxSize: Integer);
begin
  inherited Init(ALimit, ADelta);
  MaxSize := AMaxSize;
end;

constructor TStrStack.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(MaxSize, SizeOf(MaxSize));
end;

procedure TStrStack.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(MaxSize, SizeOf(MaxSize));
end;

procedure TStrStack.Push(s: String);
begin
  if (Count > 0) and (s = GetStr(At(Count - 1)))
    then Exit;
  if Count = MaxSize then AtFree(0);
  Insert(NewStr(s));
end;

function TStrStack.Pop: String;
begin
  if Count = 0
    then Pop := ''
  else Pop := GetStr(At(Count - 1));
  AtFree(Count - 1);
end;

end.
