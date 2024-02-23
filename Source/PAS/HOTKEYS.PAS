(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль HotKeys                                         *)
(* Управление горячими клавишами для оглавлений           *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат   : 08.12.1994                                   *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit HotKeys;

interface

uses
  Objects, App, Views, Drivers, StreamID, Disp_Obj, Language, PackLng,
  Pack_Hlp, MyMsgBox, Items, PackText, Dirs, StrServ, Pack_Cmd;

type

  PHotKeyRef = ^THotKeyRef;
  THotKeyRef = object(TObject)

    private

    Item: PItem;

    public

    constructor Init(AItem: PItem);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetItem: PItem;
  end;

  function SearchGlobalHKTitle(Key: Char): String;
  function StoreHotKey(var Dir: TDirectory; Key: Char; Item: PItem): boolean;
  procedure ResetHotKey(var Dir: TDirectory; Key: Char);
  function SearchHotKey(var Dir: TDirectory; Key: Char): PItem;
  function GetHotKeyIndex(Key: Char): String;
  procedure WriteHotKey(var Dir: TDirectory; Key: Char; Item: PItem);
  procedure ConvertToFigure(var Key: Char);

const

  HotKeysSet = ['A'..'Z', '0'..'9'];

  RHotKeyRef: TStreamRec = (
     ObjType: idHotKeyRef;
     VmtLink: Ofs(TypeOf(THotKeyRef)^);
     Load:    @THotKeyRef.Load;
     Store:   @THotKeyRef.Store
  );

implementation

uses Dir_Wind;

constructor THotKeyRef.Init(AItem: PItem);
begin
  inherited Init;
  Item := AItem;
end;

constructor THotKeyRef.Load(var S: TStream);
begin
  Item := PItem(S.Get);
end;

procedure THotKeyRef.Store(var S: TStream);
begin
  S.Put(Item);
end;

function THotKeyRef.GetItem: PItem;
begin
  GetItem := Item;
end;

function StoreHotKey(var Dir: TDirectory; Key: Char; Item: PItem): boolean;
var
  P: PItem;
  Info: record
          Key: LongInt;
          Title: PString;
        end;
  Cmd: Word;
begin
  StoreHotKey := False;
  if not (Key in HotKeysSet) then Exit;
  P := SearchHotKey(Dir, Key);
  if Assigned(P)
    then begin
      Info.Title := NewStr(Copy(P^.GetTitle, 1, 100));
      Info.Key := Word(Key);
      DisposeObj(P);
      Cmd := MessageBox(^C + Ph(phAsk4OverwriteHK), @Info,
                    mfOkButton + mfInformation, hcAsk4OverwriteHK);
      DispStr(Info.Title);
      {if Cmd <> cmYes then}
      Exit;
    end;
  WriteHotKey(Dir, Key, Item);
  StoreHotKey := True;
end;

procedure WriteHotKey(var Dir: TDirectory; Key: Char; Item: PItem);
var
  P: PHotKeyRef;
begin
  if not (Key in HotKeysSet) then Exit;
  P := New(PHotKeyRef, Init(Item));
  Dir.WriteObj(P, GetHotKeyIndex(Key));
  DisposeObj(P);
end;

procedure ResetHotKey(var Dir: TDirectory; Key: Char);
begin
  if Key in HotKeysSet
    then Dir.DelObj(GetHotKeyIndex(Key));
end;

function SearchHotKey(var Dir: TDirectory; Key: Char): PItem;
var
  P: PHotKeyRef;
begin
  SearchHotKey := nil;
  if not (Key in HotKeysSet)
    then Exit;
  P := PHotKeyRef(Dir.ReadObj(GetHotKeyIndex(Key)));
  if Assigned(P)
    then SearchHotKey := P^.GetItem;
  DisposeObj(P);
end;

function GetHotKeyIndex(Key: Char): String;
begin
  GetHotKeyIndex := tsHotKeyIndex + Key;
end;

function SearchGlobalHKTitle(Key: Char): String;
var
  DirWindow: PDirWindow;
  P: PItem;
begin
  SearchGlobalHKTitle := '';
  P := Pointer(Key);
  DirWindow := Message(Desktop, evBroadcast, cmSearchHotKey, @P);
  if (not Assigned(DirWindow)) or (not Assigned(P))
    then Exit;
  SearchGlobalHKTitle := P^.GetTitle;
  DisposeObj(P);
end;

procedure ConvertToFigure(var Key: Char);
var
  p: byte;
begin
  p := Pos(Key, tsCharsAboveFigures);
  if p > 0
    then Key := chr(p - 1 + ord('0'));
end;

end.
