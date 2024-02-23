(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль CrossRef                                        *)
(* Объекты поддержки перекрестных ссылок                  *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1996 by VULCAN                           *)
(*                                                        *)
(* Начат         : 08.03.1996                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit CrossRef;

interface

uses Objects, Items, Dirs, StrServ, EditRes, Disp_Obj, PackText;

type

  TNameType = (Item, Drawing);

  PNamesColl = ^TNamesColl;
  TNamesColl = object(TSortedCollection)
    procedure Add(Name, NumStr: String; NameType: TNameType);
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function GetNumber(Name: String): String;
  end;

  PRefsColl = ^TRefsColl;
  TRefsColl = object(TSortedCollection)
    procedure Add(Pos: LongInt; Name: String; Len: byte; ItemName: String);
    function Compare(Key1, Key2: Pointer): Integer; virtual;
    function GetPos(Index: Integer): LongInt;
    function GetName(Index: Integer): String;
    function GetLength(Index: Integer): byte;
    function GetItemTitle(Index: Integer): String;
  end;

  PName = ^TName;
  TName = object(TObject)
    Name, NumStr: PString;
    NameType: TNameType;
    constructor Init(AName, ANumStr: String; ANameType: TNameType);
    destructor Done; virtual;
  end;

  function GetItemName(P: PItem; DirHandler: PDirHandler): String;

implementation

type

  PRef = ^TRef;
  TRef = object(TObject)
    Pos: LongInt;
    Name: PString;
    Length: byte;
    IName: PString;
    constructor Init(APos: LongInt; AName: String; ALength: byte;
                     ItemName: String);
    destructor Done; virtual;
  end;

constructor TName.Init(AName, ANumStr: String; ANameType: TNameType);
begin
  inherited Init;
  if (FullTrim(AName) = '') or (ANumStr = '') then Fail;
  Name := NewStr(AName);
  NumStr := NewStr(ANumStr);
  NameType := ANameType;
end;

destructor TName.Done;
begin
  DispStr(Name);
  DispStr(NumStr);
  inherited Done;
end;

{ vvv Методы объекта TNamesColl vvv }

procedure TNamesColl.Add(Name, NumStr: String; NameType: TNameType);
var
  p: PObject;
begin
  if GetNumber(Name) = ''
    then begin
      p := New(PName, Init(StrUpCase(Name), FullTrim(NumStr), NameType));
      if Assigned(p) then Insert(p);
    end;
end;

function TNamesColl.Compare(Key1, Key2: Pointer): Integer;
begin
  if GetStr(PName(Key1)^.Name) = GetStr(PName(Key2)^.Name)
    then Compare := 0
  else if GetStr(PName(Key1)^.Name) > GetStr(PName(Key2)^.Name)
    then Compare := 1
  else Compare := -1;
end;

function TNamesColl.GetNumber(Name: String): String;
var
  p: PName;
  Index: Integer;
  s: String;
begin
  GetNumber := '';
  if FullTrim(Name) = '' then Exit;
  New(p, Init(StrUpCase(Name), '-', Item));
  if Search(p, Index)
    then begin
      s := FullTrim(GetStr(PName(At(Index))^.NumStr));
      if s[Length(s)] = '.' then Dec(s[0]);
      GetNumber := s;
    end;
  DisposeObj(p);
end;

{ ^^^ Методы объекта TNamesColl ^^^ }

constructor TRef.Init(APos: LongInt; AName: String; ALength: byte;
                      ItemName: String);
begin
  inherited Init;
  if Fulltrim(AName) = '' then Fail;
  Pos := APos;
  Name := NewStr(AName);
  Length := ALength;
  IName := NewStr(ItemName);
end;

destructor TRef.Done;
begin
  DispStr(Name);
  DispStr(IName);
  inherited Done;
end;

{ vvv Методы объекта TRefsColl vvv }

procedure TRefsColl.Add(Pos: LongInt; Name: String; Len: byte;
                        ItemName: String);
var
  p: PObject;
begin
  if FullTrim(Name) = '' then Exit;
  p := New(PRef, Init(Pos, StrUpCase(Name), Len, ItemName));
  if Assigned(p) then Insert(p);
end;

function TRefsColl.Compare(Key1, Key2: Pointer): Integer;
begin
  if PRef(Key1)^.Pos = PRef(Key2)^.Pos
    then Compare := 0
  else if PRef(Key1)^.Pos > PRef(Key2)^.Pos
    then Compare := 1
  else Compare := -1;
end;

function TRefsColl.GetPos(Index: Integer): LongInt;
begin
  GetPos := PRef(At(Index))^.Pos;
end;

function TRefsColl.GetName(Index: Integer): String;
begin
  GetName := GetStr(PRef(At(Index))^.Name);
end;

function TRefsColl.GetLength(Index: Integer): byte;
begin
  GetLength := PRef(At(Index))^.Length;
end;

function TRefsColl.GetItemTitle(Index: Integer): String;
begin
  GetItemTitle := GetStr(PRef(At(Index))^.IName);
end;
{ ^^^ Методы объекта TRefsColl ^^^ }

function GetItemName(P: PItem; DirHandler: PDirHandler): String;
var
  AnnIndex: TResIndex;
  Line: String;
  Reader: PResReader;
begin
  GetItemName := '';
  Line := '';
  if not Assigned(P) then Exit;
  DirHandler^.GetAnnIndex(P, AnnIndex);
  if GetStr(AnnIndex.Name) <> ''
  then begin
    New(Reader, Init(DirHandler^.Directory, GetStr(AnnIndex.Name)));
    if Assigned(Reader)
      then Line := Reader^.ReadString;
    DisposeObj(Reader);
  end;
  DoneResIndex(AnnIndex);
  if StrUpCase(GetWord(Line, 1)) = ItemNameStr
    then GetItemName := GetWord(Line, 2);
end;

end.
