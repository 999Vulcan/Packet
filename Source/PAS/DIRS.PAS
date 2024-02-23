(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Dirs                                            *)
(* Объекты, представляющие оглавления                     *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 07.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit Dirs;

interface

uses
  Objects, Memory, App, Items, SubDirs, LineColl, StreamID, Language,
  PackLng, Dos, PackText, Enc_Stm, DirConf, PathStk, StrServ, Disp_Obj,
  FileOps, ProcMess, Crypt, Ext_Serv, Menus, PackConf, TempFlag;

type

  PDirectory = ^TDirectory;
  TDirectory = object(TObject)
  private
    DirFileName: FNameStr;  { Имя файла оглавления }
    Config: PDirConfig;     { Указатель на объект - конфигурацию оглавления }
    StartDir: DirStr;       { Стартовый каталог для оглавления }
    RndNameTpl: PathStr;    { Шаблон для случайного имени файла }
    WindCount: Word;        { Количество окон, открытых с этим оглавлением }
    DirFile: TResourceFile; { Файл оглавления }
    Changed: boolean;       { Признак модификации }
  public
    constructor Init(FileName: FNameStr);
    destructor Done; virtual;
    procedure Connect;      { Вызывается из конструктора TDirHandler }
    procedure Disconnect;   { Вызывается из деструктора TDirHandler }
    procedure SetConfig(var ConfigData: TDirConfData);
    procedure GetConfig(var ConfigData: TDirConfData);
    function GetStartDir(ForEdit: boolean): DirStr;
    procedure SetStartDir(Dir: DirStr);
    function ReadStartDir: DirStr;
    function GetRndNameTpl: pathStr;
    procedure SetRndNameTpl(Tpl: PathStr);
    function ReadRndNameTpl: PathStr;
    function ProtectionType: Word;
    function Compress: Integer;
    function GetTitle: String;
    function GetPassword: String;
    function GetExtEditor: String;
    function PrefixColorSame: boolean;
    function GetItemColor(P: PItem): byte;
    function GetPrefixColor(P: PItem): byte;
    function GetPrefix(P: PItem): String;
    function ReadOnlySubDir(SubDirName: String): PSubDir;
    function ReadSubDir(SubDirName: String): PSubDir;
    procedure WriteOnlySubDir(SubDirName: String; P: PSubDir);
    procedure WriteSubDir(SubDirName: String; P: PSubDir);
    procedure Flush;
    function ReadObj(Ind: String): PObject;
    procedure WriteObj(P: PObject; Ind: String);
    procedure DelObj(Ind: String);
    function GetNewIndex(FirstPart: String; Len: byte): String;
    function CreateNewSubDir(var AStartDir, Parameters: TInhString;
                             Attributes, Inheritance: Word;
                             var AnnIndex, PIFIndex: TResIndex): String;
    function RemoveSubDir(SubDirName: String; DelAnn: boolean): boolean;
    procedure RemoveItemResources(P: PItem);
    procedure RemoveResource(var Index: TResIndex);
    procedure UpdateGadgets;
    function GetFileName: FNameStr;
    procedure UpdateHotKey(Item: PItem);
    procedure DoMenuByExt(var Action: TAction);
    procedure CheckExt(var Action: TAction);
    function FindCommand(FileName: FNameStr; Main: boolean): String;
    function SearchExt(FileName: FNameStr; Mode: byte; Main: boolean): String;
    procedure FillMenuByExt(var Menu: PMenuByExt; FileName: PathStr);
    function FillExtMenu(var Menu: PMenuByExt; FileName: PathStr;
                         Mode: byte): boolean;
  end;

  PDirHandler = ^TDirHandler;
  TDirHandler = object(TObject)
    DirFileName: PString;
    Directory: PDirectory;
    SubDir: PSubDir;
    SubDirName: PString;
    Stack: PPathStack;
    ComParams: PString;
    EnteredPW: PString;
    SelNumbers: PByteArray;  { Номера отмеченных пунктов         }
                             { - для чтения/записи в/из поток(а) }
  private
    CountSelected: Integer;

  public
    constructor Init(FileName: FNameStr);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure SetEnteredPW(PW: String);
    function GetEnteredPW: String;
    function GetItemPtr(I: Integer): PItem;
    function GetItemColor(I: Integer): byte;
    function GetPrefixColor(I: Integer): byte;
    function GetPrefix(I: Integer): String;
    function IsSelected(I: Integer): boolean;
    function CalcCountSelected: Integer;
    function GetFirstSelected: Integer;
    function GetFirstSelItem(ItemType: byte): Integer;
    procedure GetAnnIndex(P: PItem; var Index: TResIndex);
    procedure SetAnnIndex(P: PItem; var Index: TResIndex);
    procedure InitSelNumbers;
    procedure DoneSelNumbers;
    procedure SetSelItems;
    procedure AddFileItem(Item: Integer; P: PItem);
    procedure DeleteItems(DelFiles: boolean);
    procedure DeleteItem(Item: Integer; DelFiles: boolean);
    function Protected: boolean;
    procedure ChangeSelections;
    function CreateBatch4Group(FileName: FNameStr; Cmd: ComStr): boolean;
    procedure Add2Batch(Item: PItem; var BatFile: Text; Cmd: ComStr);
  end;

  procedure RegisterDirs;
  function FindDirectory(FileName: FNameStr; OpenFlag: boolean): PDirectory;
  function IsDirectoryFile(FileName: FNameStr): boolean;
  function CreateNewDirectory(FileName: FNameStr): boolean;

const

  RDirHandler: TStreamRec = (
     ObjType: idDirHandler;
     VmtLink: Ofs(TypeOf(TDirHandler)^);
     Load:    @TDirHandler.Load;
     Store:   @TDirHandler.Store
  );

implementation

uses
  Views, Drivers, Dir_Wind, Pack_Cmd, HotKeys, CheckPW, Pack_Dlg, EditRes,
  TextProc;

const
  { Режимы чтения списка обработчиков (лок./глоб.) }
  fmLocal  = 0;
  fmGlobal = 1;

{ Методы объекта TDirectory }
constructor TDirectory.Init(FileName: FNameStr);
var
  Ok: boolean;
begin
  inherited Init;
  Ok := False;
  Changed := False;
  DirFileName := FileName;
  StartDir := '*';
  RndNameTpl := '.TXT';
  if IsDirectoryFile(DirFileName)
    then begin
      DirFile.Init(New(PEncStream, Init(DirFileName, stOpen, StreamBuffSize)));
      if DirFile.Stream^.Status = stOk
        then Config := PDirConfig(ReadObj(tsDirConfIndex))
      else Config := nil;
      if DirFile.Stream^.Status = stOk
        then StartDir := ReadStartDir;
      if DirFile.Stream^.Status = stOk
        then RndNameTpl := ReadRndNameTpl;
      Ok := DirFile.Stream^.Status = stOk;
    end;
  if not Ok
    then Fail;
  WindCount := 0;
end;

destructor TDirectory.Done;
begin
  if Changed
{$ifdef ForPacket}
    and Autocompress
{$endif}
    then Compress;
  DirFile.Done;
  DisposeObj(Config);
  inherited Done;
end;

procedure TDirectory.Connect;
begin
  Inc(WindCount);
end;

procedure TDirectory.SetConfig(var ConfigData: TDirConfData);
begin
  Config^.SetData(ConfigData);
  WriteObj(Config, tsDirConfIndex);
  Flush;
end;

procedure TDirectory.GetConfig(var ConfigData: TDirConfData);
begin
  Config^.GetData(ConfigData);
end;

function TDirectory.GetStartDir(ForEdit: boolean): DirStr;
begin
  if (StartDir = '*') and not ForEdit
    then GetStartDir := GetFDir(DirFileName)
  else GetStartDir := StartDir;
end;

procedure TDirectory.SetStartDir(Dir: DirStr);
var
  SD: PStartDir;
begin
  New(SD, Init(Dir));
  WriteObj(SD, tsStartDirIndex);
  StartDir := Dir;
  DisposeObj(SD);
end;

function TDirectory.ReadStartDir: DirStr;
var
  SD: PStartDir;
begin
  ReadStartDir := '*';
  SD := PStartDir(ReadObj(tsStartDirIndex));
  if Assigned(SD) then ReadStartDir := SD^.StartDir;
  DisposeObj(SD);
end;

function TDirectory.GetRndNameTpl: PathStr;
begin
  GetRndNameTpl := RndNameTpl;
end;

procedure TDirectory.SetRndNameTpl(Tpl: PathStr);
var
  RNTpl: PRndNameTpl;
begin
  New(RNTpl, Init(Tpl));
  WriteObj(RNTpl, tsRndNameTplIndex);
  RndNameTpl := Tpl;
  DisposeObj(RNTpl);
end;

function TDirectory.ReadRndNameTpl: PathStr;
var
  RNTpl: PRndNameTpl;
begin
  ReadRndNameTpl := RndNameTpl;
  RNTpl := PRndNameTpl(ReadObj(tsRndNameTplIndex));
  if Assigned(RNTpl) then ReadRndNameTpl := RNTpl^.RndNameTpl;
  DisposeObj(RNTpl);
end;

procedure TDirectory.Disconnect;
begin
  Dec(WindCount);
  if WindCount = 0
    then Dispose(PObject(@Self), Done);
end;

function TDirectory.ProtectionType: Word;
begin
  ProtectionType := Config^.GetProtection;
end;

function TDirectory.Compress: Integer;
var
  P: PEncStream;
  Ok: boolean;
  ErrCode: Integer;
  TmpName: FNameStr;
begin
  Compress := 0;
  TmpName := GetFDir(DirFileName) + GetFName(DirFileName) + TmpExt;
  EraseFile(TmpName);
  New(P, Init(TmpName, stCreate, StreamBuffSize));
  if not Assigned(P)
    then begin
      Compress := -11;
      Exit;
    end;
  if P^.Status = stOk
    then begin
      UpdateGadgets;
      P := PEncStream(DirFile.SwitchTo(P, True));
      ErrCode := DirFile.Stream^.Status;
      UpdateGadgets;
      if ErrCode = 0 then ErrCode := P^.Status;
      DirFile.Done;
      if ErrCode = 0 then ErrCode := EraseFile(DirFileName);
      UpdateGadgets;
      if ErrCode = 0 then ErrCode := RenameFile(TmpName, DirFileName);
      UpdateGadgets;
      {if ErrCode = 0
        then} DirFile.Init(New(PEncStream,
                              Init(DirFileName, stOpen, StreamBuffSize)));
      UpdateGadgets;
    end
  else ErrCode := P^.Status;
  DisposeObj(P);
  Compress := ErrCode;
  if ErrCode = 0 then Changed := False;
end;

function TDirectory.GetTitle: String;
begin
  GetTitle := Config^.GetTitle;
end;

function TDirectory.GetExtEditor: String;
begin
  GetExtEditor := Config^.GetExtEditor;
end;

function TDirectory.GetPassword: String;
begin
  GetPassword := Config^.GetPassword;
end;

function TDirectory.PrefixColorSame: boolean;
begin
  PrefixColorSame := False;
end;

function TDirectory.GetItemColor(P: PItem): byte;
begin
  if P^.GetItemType in [itSubDirItem, itUpDirItem]
    then GetItemColor := 5
  else GetItemColor := 1;
end;

function TDirectory.GetPrefixColor(P: PItem): byte;
begin
  if PrefixColorSame
    then GetPrefixColor := GetItemColor(P)
  else GetPrefixColor := 7;
end;

function TDirectory.GetPrefix(P: PItem): String;
begin
  if P^.GetItemType in [itSubDirItem, itUpDirItem]
    then GetPrefix := tsSubDirPrefix
  else GetPrefix := Copy(Ph(phItemPrefix), 1, PrefixLen);
  if (P^.GetItemType = itFileItem) and (PFileItem(P)^.GetFileName = '')
    then GetPrefix := Copy(Ph(phEmptyItemPrefix), 1, PrefixLen);
end;

procedure TDirectory.UpdateHotKey(Item: PItem);
begin
  WriteHotKey(Self, Item^.GetHotKey, Item);
end;

{ Поиск обработчика в глобальном или локальном списке }
function TDirectory.SearchExt(FileName: FNameStr;
                              Mode: byte; Main: boolean): String;

var
  F: TTextFile;
  Reader: PResReader;
  s: String;
  OkFlag: boolean;

function ReadString: String;
begin
  Case Mode of
    fmGlobal: ReadString := F.ReadString;
     fmLocal: ReadString := Reader^.ReadString;
  end;
end;

function Eof: boolean;
begin
  Case Mode of
    fmGlobal: Eof := F.Status <> stOk;
     fmLocal: Eof := Reader^.EndOfRes;
  end;
end;

begin
  SearchExt := #0;  { Cписок не существует }
  if (Mode = fmGlobal) and not FileExist(GlobalExtName)
    then Exit;
  Case Mode of
    fmGlobal: F.Init(GlobalExtName, 0, stOpenRead, 1024);
     fmLocal: New(Reader, Init(@Self, tsLocalExtIndex));
  end;
  if (Mode = fmLocal) and not Assigned(Reader)
    then Exit;
  SearchExt := '';

  OkFlag := False;
  while True do
  begin
    s := ReadString;
    if Eof and (s = '') then Break;
    OkFlag := (s <> '') and (s[1] = ExtBeginner) and
              MaskMatch(FileName, Copy(s, 2, Pos(' ', s + ' ') - 2));
    if OkFlag then Break;
  end;
  if not Main
  then begin
    s := FullTrim(ReadString);
    OkFlag := (s <> '') and (s[1] = SecondTreatmentChar);
    if OkFlag then s := ' ' + Copy(s, 2, 255);
  end;
  s := s + '  ';
  if OkFlag
    then SearchExt := Copy(s, Pos(' ', s) + 1, 255);
  Case Mode of
    fmGlobal: F.Done;
     fmLocal: DisposeObj(Reader);
  end;
end;

function TDirectory.FindCommand(FileName: FNameStr; Main: boolean): String;
var
  s: String;
begin
  FindCommand := '';
  if FileName = ''
    then Exit;
  s := FullTrim(SearchExt(FileName, fmLocal, Main));
  if s = #0
    then FindCommand := FullTrim(SearchExt(FileName, fmGlobal, Main))
  else FindCommand := s;
end;

procedure TDirectory.CheckExt(var Action: TAction);
var
  Command: ComStr;
  FileName: PathStr;
  StDir: DirStr;
  Main: boolean;
begin
  { Обработчик по умолчанию - по Enter }
  if Action.What and (afIntEditor + afExtEditor) <> 0
    then begin
      Main := Action.What and afExtEditor = 0;
      Case Main of
        True: FileName := FullTrim(GetStr(PString(Action.InfoPtr)));
       False: FileName := GetWord(PExecInfo(Action.InfoPtr)^.Params, 1);
      end;

      FileName := AddPath(FileName, GetStartDir(False)); { не для редакт-я }
      Command := FindCommand(FileName, Main);
      if (Command = '') or (Command = #0) then Exit;
      Command := TreatMacro(Command, FileName, True);
{
      Case Main of
         True: StDir := GetFDir(FileName);
        False: StDir := PExecInfo(Action.InfoPtr)^.StartDir;
      end;
}
      StDir := ''; { ??? }

      Action.Done;
      Action.Init(afRunDosCmd, NewExecInfo('', Command, '',
                                           StDir, '512', '',
                                           nil, False, False, True));
      Exit;
    end;

  { Список обработчиков - по Shift+Enter }
  DoMenuByExt(Action);
end;

procedure TDirectory.DoMenuByExt(var Action: TAction);
var
  Menu: PMenuByExt;
  FileName: PathStr;
  Popup: PMenuPopup;
  R: TRect;
  Cmd: Word;
  Command: ComStr;
begin
  { Список обработчиков - по Shift+Enter }
  if Action.What and afDoMenuByExt = 0
    then Exit;
  FileName := FullTrim(PExecInfo(Action.InfoPtr)^.ProgName);
  New(Menu, Init(FileName));
  FillMenuByExt(Menu, FileName);
  Command := '';
  if not Menu^.IsEmpty
    then begin
      Menu^.CreateMenu;
      R.Assign(15, 7, 75, 22);
      New(Popup, Init(R, Menu^.Menu));
      with Popup^ do Options := Options or ofCentered;
      Cmd := Application^.ExecView(Popup);
      DisposeObj(Popup);
      if Cmd <> 0
        then Command := Menu^.GetCommand(Cmd)
      else Command := '';
      if (Cmd <> 0) and (FileName = #0'.'#0)
        then Command := GetStr(Menu^.Commands^.At(Cmd - CommandsOffset))
      else if FileName = #0'.'#0
        then begin
          Command := '';
          PExecInfo(Action.InfoPtr)^.ProgName := '';
        end;
    end;
  DisposeObj(Menu);
  if Command = ''
    then Exit;
  Action.What := (Action.What and not afDoMenuByExt) + afRunDosCmd;
  Action.What := Action.What and not afSearchFile;
  PExecInfo(Action.InfoPtr)^.ProgName := Command;
end;

procedure TDirectory.FillMenuByExt(var Menu: PMenuByExt; FileName: PathStr);
begin
  if not FillExtMenu(Menu, FileName, fmLocal)
    then FillExtMenu(Menu, FileName, fmGlobal);
end;

function TDirectory.FillExtMenu(var Menu: PMenuByExt; FileName: PathStr;
                                Mode: byte): boolean;

var
  F: TTextFile;
  Reader: PResReader;
  s: String;
  OkFlag: boolean;

function ReadString: String;
begin
  Case Mode of
    fmGlobal: ReadString := F.ReadString;
     fmLocal: ReadString := Reader^.ReadString;
  end;
end;

function Eof: boolean;
begin
  Case Mode of
    fmGlobal: Eof := F.Status <> stOk;
     fmLocal: Eof := Reader^.EndOfRes;
  end;
end;

begin
  FillExtMenu := False;
  if (Mode = fmGlobal) and not FileExist(GlobalExtName)
    then Exit;
  OkFlag := False;
  Case Mode of
    fmGlobal: F.Init(GlobalExtName, 0, stOpenRead, 1024);
     fmLocal: New(Reader, Init(@Self, tsLocalExtIndex));
  end;
  if (Mode = fmLocal) and not Assigned(Reader)
    then Exit;
  FillExtMenu := True;
  { Чтение общего списка }
  repeat
    s := ReadString;
    if (Eof and (s = '')) or (s[1] = ExtBeginner)
      then Break;
    s := FullTrim(s);
    if (s = '') or (s[1] = CommentChar) or (s[1] = SecondTreatmentChar)
      then Continue;
    if s = MenuDivider
      then Menu^.AddLine
    else Menu^.AddItem(s);
  until False;
  { Поиск списка по маске }
  while True do
  begin
    if Eof and (s = '')
      then Break;
    OkFlag := (FullTrim(s) <> '') and (Length(s) > 1) and
              (s[1] = ExtBeginner) and
              MaskMatch(FileName, Copy(s, 2, Pos(' ', s + ' ') - 2));
    if OkFlag then Break;
    s := ReadString;
  end;
  { Чтение списка по маске }
  if OkFlag then
  repeat
    s := ReadString;
    if (Eof and (s = '')) or (s[1] = ExtBeginner)
      then Break;
    s := FullTrim(s);
    if (s = '') or (s[1] = CommentChar) or (s[1] = SecondTreatmentChar)
      then Continue;
    if s = MenuDivider
      then Menu^.AddLine
    else Menu^.AddItem(s);
  until False;
  Case Mode of
    fmGlobal: F.Done;
     fmLocal: DisposeObj(Reader);
  end;
end;

function TDirectory.ReadOnlySubDir(SubDirName: String): PSubDir;
begin
  ReadOnlySubDir := PSubDir(DirFile.Get(SubDirName));
end;

function TDirectory.ReadSubDir(SubDirName: String): PSubDir;
var
  SD: PSubDir;
begin
  SD := PSubDir(ReadObj(SubDirName));
  if Assigned(SD) then SD^.ReadItems(DirFile);
  ReadSubDir := SD;
end;

procedure TDirectory.WriteSubDir(SubDirName: String; P: PSubDir);
begin
  WriteObj(P, SubDirName);
  P^.WriteItems(DirFile);
end;

procedure TDirectory.WriteOnlySubDir(SubDirName: String; P: PSubDir);
begin
  DirFile.Put(P, SubDirName);
end;

procedure TDirectory.Flush;
var
  FileHandle: Word;
begin
  DirFile.Flush;
  DirFile.Stream^.Flush;
  FileHandle := PDosStream(DirFile.Stream)^.Handle;
  asm
    mov    ah, 68h
    mov    bx, FileHandle
    int    21h
  end;
  Changed := True;
  Message(Application, evBroadcast, cmDirChanged, @Self);
end;

function TDirectory.ReadObj(Ind: String): PObject;
begin
  DirFile.Stream^.Reset;
  ReadObj := DirFile.Get(Ind);
end;

procedure TDirectory.WriteObj(P: PObject; Ind: String);
begin
  DirFile.Put(P, Ind);
end;

procedure TDirectory.DelObj(Ind: String);
begin
  if Ind <> ''
    then DirFile.Delete(Ind);
end;

function TDirectory.GetNewIndex(FirstPart: String; Len: byte): String;
var
  ok: boolean;
  NewIndex: String;
  i: Integer;
begin
  RandSeed := Random(MaxInt);
  repeat
    ok := true;
    NewIndex := FirstPart;
    for i := 1 to Len do
      NewIndex := NewIndex + chr(Random(200) + 32);
    for i := 0 to DirFile.Count - 1 do
      if DirFile.KeyAt(i) = NewIndex
        then begin
          ok := False;
          Break;
        end;
  until ok;
  GetNewIndex := NewIndex;
end;

function TDirectory.CreateNewSubDir(var AStartDir, Parameters: TInhString;
                                  Attributes, Inheritance: Word;
                                  var AnnIndex, PIFIndex: TResIndex): String;
var
  ItemsIndex, SubDirIndex: String;
  SD: PSubDir;
begin
  ItemsIndex := GetNewIndex(tsItemsIndex, IndLen);
  SubDirIndex := GetNewIndex(tsSubDirIndex, IndLen);
  SD := CreateEmptySubDir(ItemsIndex,
                          AStartDir, Parameters,
                          Attributes, Inheritance,
                          AnnIndex, PIFIndex);
  WriteSubDir(SubDirIndex, SD);
  DisposeObj(SD);
  CreateNewSubDir := SubDirIndex;
end;

function TDirectory.RemoveSubDir(SubDirName: String; DelAnn: boolean): boolean;
var
  i: Integer;
  SD: PSubDir;
  Name: String;
  P: PItem;
  AnnIndex: TResIndex;
begin
  RemoveSubDir := False;
  UpdateGadgets;
  SD := PSubDir(DirFile.Get(SubDirName));
  if not Assigned(SD) then Exit;
  if SD^.GetCountLinks > 1
    then begin
      SD^.Unlink;
      WriteOnlySubDir(SubDirName, SD);
      DisposeObj(SD);
      Exit;
    end;
  if DelAnn
    then begin
      SD^.GetAnnIndex(AnnIndex);
      RemoveResource(AnnIndex);
      DoneResIndex(AnnIndex);
    end;
  SD^.ReadItems(DirFile);
  for i := 0 to SD^.CountItems - 1 do
  begin
    P := SD^.GetItem(i);
    if SD^.IsSubDir(i) and
      not RemoveSubDir(PSubDirItem(P)^.SubDirName^, True) { Del annotation }
    then Continue;
    if not SD^.IsSubDir(i) then RemoveItemResources(P);
    ResetHotKey(Self, P^.GetHotKey);
  end;
  DirFile.Delete(SubDirName);
  DirFile.Delete(SD^.ItemsIndex^);
  DisposeObj(SD);
  RemoveSubDir := True;
end;

procedure TDirectory.RemoveItemResources(P: PItem);
var
  AnnIndex, PIFIndex: TResIndex;
  SD: PSubDir;
begin
  if not Assigned(P) then Exit;
  if P^.GetItemType = itUpDirItem then Exit;
  AnnIndex.Name := nil;
  PIFIndex.Name := nil;
  Case P^.GetItemType of
       itFileItem: begin
                     P^.GetAnnIndex(AnnIndex);
                     P^.GetPIFIndex(PIFIndex);
                   end;
     itSubDirItem: begin
                     SD := PSubDir(ReadObj(PSubDirItem(P)^.GetSubDirName));
                     SD^.GetAnnIndex(AnnIndex);
                     DisposeObj(SD);
                   end;
  end;
  RemoveResource(AnnIndex);
  DoneResIndex(AnnIndex);
  RemoveResource(PIFIndex);
  DoneResIndex(PIFIndex);
end;

procedure TDirectory.RemoveResource(var Index: TResIndex);
begin
  with Index do
    if (Place = pfDirFile) and Assigned(Name) and (not InhFlag)
      then DirFile.Delete(Name^);
end;

procedure TDirectory.UpdateGadgets;
begin
  Message(Application, evCommand, cmUpdateGadgets, nil);
end;

function TDirectory.GetFileName: FNameStr;
begin
  GetFileName := DirFileName;
end;

{ Методы объекта TDirHandler }
constructor TDirHandler.Init(FileName: FNameStr);
var
  P: PProcMess;
begin
  inherited Init;

  SubDir := nil;
  Stack := nil;
  SelNumbers := nil;
  ComParams := nil;
  EnteredPW := nil;

  DirFileName := nil;
  New(P, Init(Ph(phLoadingFile) + ' "' + FileName + '"...'));
  Directory := FindDirectory(FileName, True);
  if not Assigned(Directory) or LowMemory
    then begin
      if LowMemory then Application^.OutOfMemory;
      DisposeObj(Directory);
      DisposeObj(P);
      Done;
      Fail;
    end;
  Directory^.Connect;
  DirFileName := NewStr(FileName);
  SubDirName := NewStr(tsRootDirIndex);
  New(Stack, Init(10, 10));
  SubDir := Directory^.ReadSubDir(SubDirName^);
  DisposeObj(P);
end;

destructor TDirHandler.Done;
begin
  if Assigned(Directory) then Directory^.Disconnect;
  DisposeObj(SubDir);
  DisposeObj(Stack);
  DispStr(SubDirName);
  DispStr(DirFileName);
  DispStr(ComParams);
  DispStr(EnteredPW);
  inherited Done;
end;

constructor TDirHandler.Load(var S: TStream);
var
  P: PString;
begin
  DirFileName := ReadString(S);
  SetNewStr(DirFileName, AddPath(GetStr(DirFileName),
                                 GetFDir(FExpand(CurrentDskName))));

  SubDirName := ReadString(S);
  ComParams := ReadString(S);
  EnteredPW := ReadString(S);
  P := ReadString(S);
  DispStr(P);
  PObject(Stack) := S.Get;
  SubDir := nil;
  S.Read(CountSelected, SizeOf(CountSelected));
  if CountSelected > 0
    then begin
      GetMem(SelNumbers, CountSelected);
      S.Read(SelNumbers^, CountSelected);
    end;
end;

procedure TDirHandler.Store(var S: TStream);
var
  P: PString;
  fn: FNameStr;
begin
  fn := GetStr(DirFileName);
  MakeFNRelative(fn, GetFDir(CurrentDskName));
  P := NewStr(fn);
  WriteString(S, P);
  DispStr(P);
  WriteString(S, SubDirName);
  WriteString(S, ComParams);
  WriteString(S, EnteredPW);
  P := NewStr(GetRandString(30));
  WriteString(S, P);
  DispStr(P);

  S.Put(Stack);
  InitSelNumbers;
  S.Write(CountSelected, SizeOf(CountSelected));
  if CountSelected > 0
    then S.Write(SelNumbers^, CountSelected);
  DoneSelNumbers;
end;

procedure TDirHandler.SetEnteredPW(PW: String);
begin
  SetNewStr(EnteredPW, CryptStr(PW));
end;

function TDirHandler.GetEnteredPW: String;
begin
  GetEnteredPW := GetStr(EnteredPW);
end;

function TDirHandler.GetItemPtr(I: Integer): PItem;
begin
  GetItemPtr := SubDir^.GetItem(I);
end;

function TDirHandler.GetItemColor(I: Integer): byte;
begin
  GetItemColor := Directory^.GetItemColor(GetItemPtr(I));
end;

function TDirHandler.GetPrefixColor(I: Integer): byte;
begin
  GetPrefixColor := Directory^.GetPrefixColor(GetItemPtr(I));
end;

function TDirHandler.GetPrefix(I: Integer): String;
begin
  GetPrefix := Directory^.GetPrefix(GetItemPtr(I));
end;

function TDirHandler.IsSelected(I: Integer): boolean;
begin
  IsSelected := GetItemPtr(I)^.Selected;
end;

function TDirHandler.CalcCountSelected: Integer;
var
  i, Count: Integer;
begin
  Count := 0;
  for i := 0 to SubDir^.CountItems - 1 do
    if IsSelected(i) then Inc(Count);
  CalcCountSelected := Count;
end;

function TDirHandler.GetFirstSelected: Integer;
var
  i: Integer;
begin
  for i := 0 to SubDir^.CountItems - 1 do
    if IsSelected(i)
      then begin
        GetFirstSelected := i;
        Exit;
      end;
  GetFirstSelected := -1;
end;

function TDirHandler.GetFirstSelItem(ItemType: byte): Integer;
var
  i: Integer;
begin
  for i := 0 to SubDir^.CountItems - 1 do
    if (IsSelected(i)) and (GetItemPtr(i)^.GetItemType = ItemType)
      then begin
        GetFirstSelItem := i;
        Exit;
      end;
  GetFirstSelItem := -1;
end;

procedure TDirHandler.InitSelNumbers;
var
  i, n: Integer;
begin
  CountSelected := CalcCountSelected;
  if CountSelected = 0
    then begin
      SelNumbers := nil;
      Exit;
    end;
  GetMem(SelNumbers, CountSelected);
  n := 0;
  for i := 0 to SubDir^.CountItems - 1 do
    if IsSelected(i)
      then if i < 256
        then begin
          SelNumbers^[n] := i;
          Inc(n);
        end;
end;

procedure TDirHandler.DoneSelNumbers;
begin
  if Assigned(SelNumbers) then FreeMem(SelNumbers, CountSelected);
  CountSelected := 0;
end;

procedure TDirHandler.SetSelItems;
var
  i: Integer;
begin
  for i := 0 to CountSelected - 1 do
    SubDir^.SelectItem(SelNumbers^[i]);
end;

procedure TDirHandler.AddFileItem(Item: Integer; P: PItem);
begin
  SubDir^.InsertItem(Item, P);
  Directory^.WriteSubDir(SubDirName^, SubDir);
end;

procedure TDirHandler.GetAnnIndex(P: PItem; var Index: TResIndex);
var
  SD: PSubDir;
begin
  Index.Name := nil;
  DoneResIndex(Index);
  Case P^.GetItemType of
       itFileItem: P^.GetAnnIndex(Index);
     itSubDirItem: begin
                     SD := PSubDir(Directory^.ReadObj(
                                       PSubDirItem(P)^.GetSubDirName));
                     if not Assigned(SD) then Exit;
                     SD^.GetAnnIndex(Index);
                     DisposeObj(SD);
                   end;
      itUpDirItem: SubDir^.GetAnnIndex(Index);
  end;
end;

procedure TDirHandler.SetAnnIndex(P: PItem; var Index: TResIndex);
var
  SD: PSubDir;
begin
  Case P^.GetItemType of
       itFileItem: begin
                     P^.SetAnnIndex(Index);
                     Directory^.WriteSubDir(SubDirName^, SubDir);
                   end;
     itSubDirItem: begin
                     SD := PSubDir(Directory^.ReadObj(
                                       PSubDirItem(P)^.GetSubDirName));
                     if Assigned(SD)
                       then begin
                         SD^.SetAnnIndex(Index);
                         Directory^.WriteObj(SD,
                                  PSubDirItem(P)^.GetSubDirName);
                         DisposeObj(SD);
                       end;
                   end;
      itUpDirItem: begin
                     SubDir^.SetAnnIndex(Index);
                     Directory^.WriteObj(SubDir, SubDirName^);
                   end;
  end;
end;


procedure TDirHandler.DeleteItems(DelFiles: boolean);
var
  i: Integer;
begin
  repeat
    i := GetFirstSelected;
    if i >= 0 then DeleteItem(i, DelFiles);
  until i = -1;
  Directory^.WriteSubDir(SubDirName^, SubDir);
  Directory^.Flush;
end;

procedure TDirHandler.DeleteItem(Item: Integer; DelFiles: boolean);
var
  P: PItem;
begin
  P := GetItemPtr(Item);
  if SubDir^.IsSubDir(Item)
    then Directory^.RemoveSubDir(PSubDirItem(P)^.SubDirName^, True) {Del ann}
  else begin
    Directory^.RemoveItemResources(P);
    ResetHotKey(Directory^, P^.GetHotKey);
    if DelFiles and (GetItemPtr(Item)^.GetItemType = itFileItem)
      then EraseFile(PFileItem(GetItemPtr(Item))^.GetFileName);
  end;
  SubDir^.DeleteItem(Item);
end;

function TDirHandler.Protected: boolean;
begin
  Protected := not PasswordsMatch(GetEnteredPW, Directory^.GetPassword)
               and (Directory^.Config^.GetProtection <> prNothing);
end;

procedure TDirHandler.ChangeSelections;
var
  i: Integer;
begin
  for i := 0 to SubDir^.CountItems - 1 do
    GetItemPtr(i)^.ChangeSel;
end;

procedure TDirHandler.Add2Batch(Item: PItem; var BatFile: Text; Cmd: ComStr);
var
  i: Integer;
  SD: PSubDir;
begin
  Case Item^.GetItemType of
    itFileItem: if FullTrim(PFileItem(Item)^.GetFileName) <> ''
                  then writeln(BatFile,
                     TreatMacro(Cmd, PFileItem(Item)^.GetFileName, True));
  itSubDirItem: if not LowMemory then begin
                  SD := Directory^.ReadSubDir(
                                     PSubDirItem(Item)^.GetSubDirName);
                  if Assigned(SD)
                    then for i := 0 to SD^.CountItems - 1 do
                      Add2Batch(SD^.GetItem(i), BatFile, Cmd);
                  DisposeObj(SD);
                end;
  end;
end;

function TDirHandler.CreateBatch4Group(FileName: FNameStr;
                                       Cmd: ComStr): boolean;
var
  i: Integer;
  BatFile: Text;
begin
  CreateBatch4Group := False;
  Assign(BatFile, FileName);
  Rewrite(BatFile);
  if IOResult <> 0 then Exit;
  writeln(BatFile, '@Echo off');
  repeat
    i := GetFirstSelected;
    if i >= 0
      then begin
        Add2Batch(GetItemPtr(i), BatFile, Cmd);
        GetItemPtr(i)^.ChangeSel;
      end;
  until i = -1;
  Close(BatFile);
  if IOResult <> 0 then Exit;
  CreateBatch4Group := True;
end;
{---------------------- TDirHandler ---------------------------------}

function FindDirectory(FileName: FNameStr; OpenFlag: boolean): PDirectory;
var
  P: PDirWindow;
begin
  P := Message(Desktop, evBroadcast, cmSearchDirWindow, @FileName);
  if Assigned(P)
    then FindDirectory := P^.GetDirPtr
  else if OpenFlag
         then FindDirectory := New(PDirectory, Init(FileName))
         else FindDirectory := nil;
end;

function IsDirectoryFile(FileName: FNameStr): boolean;
var
  R: PResourceFile;
  Ok: boolean;
  SD: PSubDir;
begin
  if LowMemory
    then begin
      Application^.OutOfMemory;
      IsDirectoryFile := False;
      Exit;
    end;
  if FindDirectory(FileName, False) <> nil
    then begin
      IsDirectoryFile := True;
      Exit;
    end;
  New(R, Init(New(PEncStream, Init(FileName, stOpenRead, StreamBuffSize))));
  Ok := Assigned(R) and (R^.Stream^.Status = stOk);
  if Ok then
  begin
    SD := PSubDir(R^.Get(tsRootDirIndex));
    Ok := Assigned(SD);
    DisposeObj(SD);
  end;
  DisposeObj(R);
  IsDirectoryFile := Ok;
end;

function CreateNewDirectory(FileName: FNameStr): boolean;
var
  Dir: PDirectory;
  P: PResourceFile;
  SD: PSubDir;
  DirConfig: PDirConfig;
begin
  CreateNewDirectory := False;
  Dir := FindDirectory(FileName, False);
  if Assigned(Dir)
    then Dir^.DirFile.Done;
  New(P, Init(New(PEncStream, Init(FileName, stCreate, StreamBuffSize))));
  if not (Assigned(P) and (P^.Stream^.Status = stOk))
    then begin
      DisposeObj(P);
      if Assigned(Dir) then
        Dir^.DirFile.Init(New(PEncStream,
                              Init(FileName, stOpen, StreamBuffSize)));
      Exit;
    end;

  SD := CreateEmptyRootDir;
  New(DirConfig, Init('', '', '', prNothing, 0));
  P^.Put(SD, tsRootDirIndex);
  P^.Put(DirConfig, tsDirConfIndex);
  SD^.WriteItems(P^);
  if P^.Stream^.Status = stOk then CreateNewDirectory := True;
  DisposeObj(P);
  DisposeObj(DirConfig);
  DisposeObj(SD);

  if Assigned(Dir)
    then begin
      Dir^.DirFile.Init(New(PEncStream,
                            Init(FileName, stOpen, StreamBuffSize)));
      Dir^.Flush;
    end;
end;

procedure RegisterDirs;
begin
  RegisterType(RDirHandler);
  RegisterType(RPathStack);
  RegisterType(RPathItem);
  RegisterType(RDirConfig);
end;

end.

