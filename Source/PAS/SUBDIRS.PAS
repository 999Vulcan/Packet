(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль SubDirs                                         *)
(* Объекты, представляющие подоглавления                  *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 07.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit SubDirs;

interface

uses
  Objects, Items, StrServ, StreamID, LineColl, Disp_Obj, PackText, Crypt;

type

  TSelSDData = record
                 SubDirName: String;
                 Item: Integer;
               end;

  { !!!!!!!!!!!!! Перекрыть Error !!!!!!!!!!!!! }
  PItemsCollection = ^TItemsCollection;
  TItemsCollection = object(TCollection)
    procedure Error(Code, Info: Integer); virtual;
    function At(Index: Integer): PItem;
  end;

  PTitles = ^TTitles;
  TTitles = object(TLineCollection)
  end;

  PSubDirData = ^TSubDirData;
  TSubDirData = object(TObject)
    CountLinks: Word;
    StartDir: TInhString;
    RndNameTpl: TInhString;
    Attributes: Word;
    Inheritance: Word;
    AnnIndex: TResIndex;
    PIFIndex: TResIndex;
    ItemsIndex: PString;

    constructor Init;
    destructor Done; virtual;
  end;

  PSubDir = ^TSubDir;
  TSubDir = object(TObject)
  private
    CountLinks: Word;
  public
    ItemsColl: PItemsCollection;
    StartDir: TInhString;
    RndNameTpl: TInhString;
    Attributes: Word;
    Inheritance: Word;
    AnnIndex: TResIndex;
    PIFIndex: TResIndex;

    ItemsIndex: PString;

    constructor Init(AItemsIndex: String;
                     var AStartDir, ARndNameTpl: TInhString;
                     AAttributes, AInheritance: Word;
                     var AAnnIndex, APIFIndex: TResIndex);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function CountItems: Integer;
    function GetItem(Item: Integer): PItem;
    function IndexOf(P: PItem): Integer;
    function IsSubDir(Item: Integer): boolean;
    procedure GetData(var Data: TSubDirData);
    procedure SetData(var Data: TSubDirData);
    function GetTitle(Item: Integer): String;
    procedure GetAnnIndex(var Index: TResIndex);
    procedure SetAnnIndex(var Index: TResIndex);
    procedure ChangeSelItem(Item: Integer);
    procedure SelectItem(Item: Integer);
    procedure UnselectItem(Item: Integer);
    procedure DeleteItem(Item: Integer);
    procedure DeleteItemWithoutDispose(Item: Integer);
    procedure InsertItem(Item: Integer; P: PItem);
    procedure AddItem(P: PItem);
    procedure ReplaceItem(Item: Integer; P: PItem);
    procedure ReadItems(var F: TResourceFile);
    procedure WriteItems(var F: TResourceFile);
    function GetTitles: PTitles;
    procedure SetTitles(P: PTitles);
    function GetCountLinks: Word;
    procedure Link;
    procedure Unlink;
    function GetRndNameTpl: FNameStr;
  end;

const

  RSubDir: TStreamRec = (
     ObjType: idSubDir;
     VmtLink: Ofs(TypeOf(TSubDir)^);
     Load:    @TSubDir.Load;
     Store:   @TSubDir.Store
  );

  RItemsCollection: TStreamRec = (
     ObjType: idItemsCollection;
     VmtLink: Ofs(TypeOf(TItemsCollection)^);
     Load:    @TItemsCollection.Load;
     Store:   @TItemsCollection.Store
  );

  procedure RegisterSubDirs;
  function CreateEmptyRootDir: PSubDir;
  function CreateEmptySubDir(ItemsIndex: String;
                             var StartDir, RndNameTpl: TInhString;
                             Attributes, Inheritance: Word;
                             var AnnIndex, PIFIndex: TResIndex): PSubDir;

implementation

{ Методы объекта TSubDir }
constructor TSubDir.Init(AItemsIndex: String;
                         var AStartDir, ARndNameTpl: TInhString;
                         AAttributes, AInheritance: Word;
                         var AAnnIndex, APIFIndex: TResIndex);
begin
  inherited Init;

  CountLinks := 1;
  SetNewInhStr(StartDir, AStartDir);
  SetNewInhStr(RndNameTpl, ARndNameTpl);
  Attributes := AAttributes;
  Inheritance := AInheritance;
  AnnIndex.Name := nil;
  PIFIndex.Name := nil;
  SetNewResIndex(AnnIndex, AAnnIndex);
  SetNewResIndex(PIFIndex, APIFIndex);
  ItemsIndex := NewStr(AItemsIndex);

  New(ItemsColl, Init(10, 10));
end;

destructor TSubDir.Done;
begin
  DisposeObj(ItemsColl);
  DispStr(StartDir.Str);
  DispStr(RndNameTpl.Str);
  DispStr(AnnIndex.Name);
  DispStr(PIFIndex.Name);
  DispStr(ItemsIndex);

  inherited Done;
end;

constructor TSubDir.Load(var S: TStream);
begin
  S.Read(CountLinks, sizeof(CountLinks));
  ReadInhStr(S, StartDir);
  ReadInhStr(S, RndNameTpl);
  S.Read(Attributes, sizeof(Attributes));
  S.Read(Inheritance, sizeof(Inheritance));
  ReadResIndex(S, AnnIndex);
  ReadResIndex(S, PIFIndex);
  ItemsIndex := ReadString(S);
  ItemsColl := nil;
end;

procedure TSubDir.Store(var S: TStream);
begin
  S.Write(CountLinks, sizeof(CountLinks));
  WriteInhStr(S, StartDir);
  WriteInhStr(S, RndNameTpl);
  S.Write(Attributes, sizeof(Attributes));
  S.Write(Inheritance, sizeof(Inheritance));
  WriteResIndex(S, AnnIndex);
  WriteResIndex(S, PIFIndex);
  WriteString(S, ItemsIndex);
end;

function TSubDir.CountItems: Integer;
begin
  CountItems := ItemsColl^.Count;
end;

function TSubDir.GetItem(Item: Integer): PItem;
begin
  GetItem := ItemsColl^.At(Item)
end;

function TSubDir.IndexOf(P: PItem): Integer;
begin
  IndexOf := ItemsColl^.IndexOf(P);
end;

function TSubDir.IsSubDir(Item: Integer): boolean;
var
  P: PItem;
begin
  P := GetItem(Item);
  IsSubDir := Assigned(P) and
             (P^.GetItemType = itSubDirItem);
end;

procedure TSubDir.GetData(var Data: TSubDirData);
begin
  Data.Init;

  Data.CountLinks := CountLinks;
  SetNewInhStr(Data.StartDir, StartDir);
  SetNewInhStr(Data.RndNameTpl, RndNameTpl);
  Data.Attributes := Attributes;
  Data.Inheritance := Inheritance;
  SetNewResIndex(Data.AnnIndex, AnnIndex);
  SetNewResIndex(Data.PIFIndex, PIFIndex);

end;

procedure TSubDir.SetData(var Data: TSubDirData);
begin
  CountLinks := Data.CountLinks;
  SetNewInhStr(StartDir, Data.StartDir);
  SetNewInhStr(RndNameTpl, Data.RndNameTpl);
  Attributes := Data.Attributes;
  Inheritance := Data.Inheritance;
  SetNewResIndex(AnnIndex, Data.AnnIndex);
  SetNewResIndex(PIFIndex, Data.PIFIndex);
end;

function TSubDir.GetTitle(Item: Integer): String;
begin
  GetTitle := GetItem(Item)^.GetTitle;
end;

procedure TSubDir.GetAnnIndex(var Index: TResIndex);
begin
  Index.Name := nil;
  SetNewResIndex(Index, AnnIndex);
end;

procedure TSubDir.SetAnnIndex(var Index: TResIndex);
begin
  SetNewResIndex(AnnIndex, Index);
  Case Index.InhFlag of
    True: Inheritance := Inheritance or ifAnnotation;
   False: Inheritance := Inheritance and not ifAnnotation;
  end;
end;

procedure TSubDir.ChangeSelItem(Item: Integer);
begin
  if GetItem(Item) <> nil then GetItem(Item)^.ChangeSel;
end;

procedure TSubDir.SelectItem(Item: Integer);
begin
  if GetItem(Item) <> nil then GetItem(Item)^.Select;
end;

procedure TSubDir.UnselectItem(Item: Integer);
begin
  if GetItem(Item) <> nil then GetItem(Item)^.Unselect;
end;

procedure TSubDir.DeleteItem(Item: Integer);
begin
  ItemsColl^.AtFree(Item);
end;

procedure TSubDir.DeleteItemWithoutDispose(Item: Integer);
begin
  ItemsColl^.AtDelete(Item);
end;

procedure TSubDir.InsertItem(Item: Integer; P: PItem);
begin
  ItemsColl^.AtInsert(Item, P);
end;

procedure TSubDir.AddItem(P: PItem);
begin
  ItemsColl^.Insert(P);
end;

procedure TSubDir.ReplaceItem(Item: Integer; P: PItem);
begin
  if Item >= CountItems then Exit;
  DeleteItem(Item);
  InsertItem(Item, P);
end;

procedure TSubDir.ReadItems(var F: TResourceFile);
begin
  DisposeObj(ItemsColl);
  ItemsColl := PItemsCollection(F.Get(ItemsIndex^));
end;

procedure TSubDir.WriteItems(var F: TResourceFile);
begin
  F.Put(ItemsColl, ItemsIndex^);
end;

function TSubDir.GetTitles: PTitles;
begin
  GetTitles := nil;
end;

procedure TSubDir.SetTitles(P: PTitles);
begin

end;

function TSubDir.GetCountLinks: Word;
begin
  GetCountLinks := CountLinks;
end;

procedure TSubDir.Link;
begin
  Inc(CountLinks);
end;

procedure TSubDir.Unlink;
begin
  if CountLinks > 0 then Dec(CountLinks);
end;

function TSubDir.GetRndNameTpl: FNameStr;
begin
  GetRndNameTpl := GetStr(RndNameTpl.Str);
end;

{ Методы объекта TSubDirData }
constructor TSubDirData.Init;
begin
  inherited Init;

  CountLinks := 0;
  StartDir.Str := nil;
  RndNameTpl.Str := nil;
  Attributes := 0;
  Inheritance := 0;
  AnnIndex.Name := nil;
  PIFIndex.Name := nil;
  ItemsIndex := nil;
end;

destructor TSubDirData.Done;
begin
  DispStr(StartDir.Str);
  DispStr(RndNameTpl.Str);
  DispStr(AnnIndex.Name);
  DispStr(PIFIndex.Name);
  DispStr(ItemsIndex);

  inherited Done;
end;

procedure TItemsCollection.Error(Code, Info: Integer);
begin
  inherited Error(Code, Info);
end;

function TItemsCollection.At(Index: Integer): PItem;
begin
  if Index < Count
    then At := inherited At(Index)
  else At := nil;
end;

function CreateEmptyRootDir: PSubDir;
var
  SubDir: PSubDir;
  StartDir, RndNameTpl: TInhString;
  Attributes, Inheritance: Word;
  AnnIndex, PIFIndex: TResIndex;
begin
  RndNameTpl.Str := nil;
  RndNameTpl.InhFlag:= False;
  StartDir.Str := nil;
  StartDir.InhFlag := False;
  Attributes := 0;
  Inheritance := 0;

  AnnIndex.Place := pfNowhere;
  AnnIndex.Name := nil;
  AnnIndex.InhFlag := False;

  PIFIndex.Place := pfNowhere;
  PIFIndex.Name := nil;
  PIFIndex.InhFlag := False;

  SubDir := New(PSubDir, Init(tsRootDirItemsIndex,
                         StartDir, RndNameTpl,
                         Attributes, Inheritance,
                         AnnIndex, PIFIndex));

  CreateEmptyRootDir := SubDir;
end;

function CreateEmptySubDir(ItemsIndex: String;
                           var StartDir, RndNameTpl: TInhString;
                           Attributes, Inheritance: Word;
                           var AnnIndex, PIFIndex: TResIndex): PSubDir;
var
  SubDir: PSubDir;
begin
  SubDir := New(PSubDir, Init(ItemsIndex,
                         StartDir, RndNameTpl,
                         Attributes, Inheritance,
                         AnnIndex, PIFIndex));

  SubDir^.AddItem(New(PUpDirItem, Init(tsUpDirTitle)));
  CreateEmptySubDir := SubDir;
end;

procedure RegisterSubDirs;
begin
  RegisterType(RSubDir);
  RegisterType(RItemsCollection);
end;

end.

