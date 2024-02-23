(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PathStk                                         *)
(* Объект TPathStack                                      *)
(* ( стек для запоминания пути по подоглавлениям )        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 19.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit PathStk;

interface

uses Objects, StreamID, StrServ;

type

  PPathItem = ^TPathItem;
  TPathItem = object(TObject)
    SubDirName: PString;
    Item: Integer;

    constructor Init(SD: String; I: Integer);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

  PPathStack = ^TPathStack;
  TPathStack = object(TCollection)
    function Pop: PPathItem;
    function GetUpItem: PPathItem;
    function GetSDPos(SD: String): Integer;
    procedure DelTail(Index: Integer);
    procedure DelTop;
  end;

function CopyStack(P: PPathStack): PPathStack;

const

  RPathStack: TStreamRec = (
    ObjType: idPathStack;
    VmtLink: Ofs(TypeOf(TPathStack)^);
    Load: @TPathStack.Load;
    Store: @TPathStack.Store
  );

  RPathItem: TStreamRec = (
    ObjType: idPathItem;
    VmtLink: Ofs(TypeOf(TPathItem)^);
    Load: @TPathItem.Load;
    Store: @TPathItem.Store
  );

implementation

constructor TPathItem.Init(SD: String; I: Integer);
begin
  inherited Init;

  SubDirName := NewStr(SD);
  Item := I;
end;

destructor TPathItem.Done;
begin
  DispStr(SubDirName);

  inherited Done;
end;

constructor TPathItem.Load(var S: TStream);
begin
  SubDirName := S.ReadStr;
  S.Read(Item, SizeOf(Item));
end;

procedure TPathItem.Store(var S: TStream);
begin
  S.WriteStr(SubDirName);
  S.Write(Item, SizeOf(Item));
end;

function TPathStack.Pop: PPathItem;
begin
  Pop := GetUpItem;
  AtDelete(Count - 1);
end;

function TPathStack.GetUpItem: PPathItem;
begin
  GetUpItem := PPathItem(At(Count - 1));
end;

function TPathStack.GetSDPos(SD: String): Integer;
var
  i: Integer;
begin
  GetSDPos := -1;
  for i := 0 to Count - 1 do
    if GetStr(PPathItem(At(i))^.SubDirName) = SD
      then begin
        GetSDPos := i;
        Exit;
      end;
end;

procedure TPathStack.DelTop;
begin
  if Count > 0 then AtFree(Count - 1);
end;

{ Удаляет вершину стека начиная с элемента с индексом Index }
procedure TPathStack.DelTail(Index: Integer);
begin
  if Index < 0 then Exit;
  while Count > Index do
    AtFree(Count - 1);
end;

function CopyStack(P: PPathStack): PPathStack;
var
  NewStack: PPathStack;

procedure AddPathItem(PI: PPathItem); far;
begin
  NewStack^.Insert(New(PPathItem, Init(GetStr(PI^.SubDirName), PI^.Item)));
end;

begin
  New(NewStack, Init(P^.Count, 10));
  P^.ForEach(@AddPathItem);
  CopyStack := NewStack;
end;

end.





