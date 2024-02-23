
{*********************************************************************}
{                                                                     }
{       Turbo Pascal Version 7.0                                      }
{       Packet's Configuration Unit                                   }
{                                                                     }
{       Copyright (c) 1993,94 by VULCAN ( Constantine Vulakh )        }
{                                                                     }
{       10.09.93                                                      }
{                                                                     }
{*********************************************************************}

{*********************************************************************}
{                                                                     }
{       Объект TConfig - конфигурация программы                       }
{                                                                     }
{*********************************************************************}

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit PackConf;

interface

uses Objects, Drivers, StreamID, Dos, Crt, StrServ;

const

  stChkSumError = 1;

  ConfSignStr = 'Packet''s 3.0 (alpha-5) Config File'#26;
  ConfSignatureLen = Length(ConfSignStr);
  ConfSignature : string[ConfSignatureLen] = ConfSignStr;

type
  TCheckSum = Word;

  PConfigData = ^PConfigData;
  TConfigData = record
    Look: Word;
    ScreenSize: Word;
    Mode1: String[2];
    Mode2: String[2];
    Editor: Word;
    ScreenDelay: Word;
    AutoSave: Word;
    WorkDir: DirStr;
    ExtEditor: PathStr;
    LngFile: PathStr;
  end;

  PConfig = ^TConfig;
  TConfig = object(TObject)
    constructor Init;
    procedure SetData(AConfigData: TConfigData);
    procedure GetData(var AConfigData: TConfigData);
    procedure SetCheckSum(ChS: TCheckSum);
    function CalcCheckSum: TCheckSum;
    procedure Read(var S: TStream);
    procedure Write(var S: TStream);
    procedure Store(var S: TStream);
    constructor Load(var S: TStream);
    function ShowHeap: boolean;
    function ShowClock: boolean;
    function ShowShadow: boolean;
    function TimeBeep: boolean;
    function ASConfig: boolean;
    function ASDesktop: boolean;
    function CreateBak: boolean;
    function AutoIndent: boolean;
    function EGALines: boolean;
    function GetVMode: Word;
    function GetLngFile: PathStr;
    procedure SetLngFile(const LngFileName: FNameStr);
    function GetExtEditor: PathStr;
    procedure SetExtEditor(const EditorFileName: FNameStr);
    function GetWorkDir: DirStr;
    procedure SetWorkDir(const Dir: DirStr);
    function GetBellFlag: boolean;
    function GetScreenDelay: integer;
    function ConvertToByte(S: string): byte;

  private
    ConfigData: TConfigData;
    CheckSum: TCheckSum;
  end;

  PStartDir = ^TStartDir;
  TStartDir = object(TObject)
    StartDir: DirStr;
    constructor Init(Dir: DirStr);
    procedure Store(var S: TStream);
    constructor Load(var S: TStream);
  end;

  PRndNameTpl = ^TRndNameTpl;
  TRndNameTpl = object(TObject)
    RndNameTpl: PathStr;
    constructor Init(Tpl: PathStr);
    procedure Store(var S: TStream);
    constructor Load(var S: TStream);
  end;

var

  InterfaceFlags: Word;

  function NeedAskExit: boolean;
  function Esc4Editor: boolean;
  function Esc4DirWin: boolean;
  function AddConfirm: boolean;
  function AddNonExistConfirm: boolean;
  function RestoreCurPos: boolean;
  function Autocompress: boolean;
  function Alt4Menu: boolean;
  function CalendarInClock: boolean;
  function ChangeDirOnSelDir: boolean;
  function ItemTitleOnEditor: boolean;
  function CreateFileNames: boolean;

implementation

const

  cfBakUp       = 1;
  cfAIndent     = 2;
  cfClock       = 1;
  cfHeap        = 2;
  cfShadow      = 4;
  cfErrBell     = 8;
  cfTimeBeep    = 16;
  cf25          = 0;
  cf43_50       = 1;
  cfMode1       = 2;
  cfMode2       = 3;
  cfASConf      = 1;
  cfASDsk       = 2;
  cfNoRest      = 0;
  cfRestAfter1  = 1;
  cfRestAfter3  = 2;
  cfRestAfter5  = 3;
  cfRestAfter10 = 4;

{ Битовые флаги для слова InterfaceFlags }
  ifAskExit            =   $1;
  ifEsc4Editor         =   $2;
  ifEsc4DirWin         =   $4;
  ifAddConfirm         =   $8;
  ifAddNonExistConfirm =  $10;
  ifRestoreCurPos      =  $20;
  ifDontAutocompress   =  $40;
  ifAlt4Menu           =  $80;
  ifCalendarInClock    = $100;
  ifChangeDirOnSelDir  = $200;
  ifItemTitleOnEditor  = $400;
  ifCreateFileNames    = $800;

{  Запись регистрации типа TConfig  }
  RConfig: TStreamRec = (
    ObjType: idConfig;
    VmtLink: Ofs(TypeOf(TConfig)^);
    Load: @TConfig.Load;
    Store: @TConfig.Store
  );

  RStartDir: TStreamRec = (
    ObjType: idStartDir;
    VmtLink: Ofs(TypeOf(TStartDir)^);
    Load: @TStartDir.Load;
    Store: @TStartDir.Store
  );

  RRndNameTpl: TStreamRec = (
    ObjType: idRndNameTpl;
    VmtLink: Ofs(TypeOf(TRndNameTpl)^);
    Load: @TRndNameTpl.Load;
    Store: @TRndNameTpl.Store
  );

{  V V V     Методы объекта TConfig   V V V  }

constructor TConfig.Init;
begin
  ConfigData.Look := cfClock + cfShadow + cfErrBell + cfTimeBeep;
  ConfigData.ScreenSize := cf25;
  ConfigData.Mode1 := '';
  ConfigData.Mode2 := '';
  ConfigData.AutoSave := 0;
  ConfigData.Editor := cfAIndent;
  ConfigData.ScreenDelay := cfRestAfter1;

  ConfigData.ExtEditor := '';
  ConfigData.WorkDir := '';
{$ifndef Debug}
  ConfigData.LngFile := '';
{$else}
  ConfigData.LngFile := 'english.lng';
{$endif}
end;

procedure TConfig.Store(var S: TStream);
begin
  CheckSum := CalcCheckSum;
  S.Write(ConfigData, SizeOf(TConfigData));
  S.Write(CheckSum, SizeOf(TCheckSum));
end;

constructor TConfig.Load(var S: TStream);
var
  ChkSum: TCheckSum;
begin
  S.Read(ConfigData, SizeOf(TConfigData));
  S.Read(CheckSum, SizeOf(TCheckSum));
end;

procedure TConfig.Read(var S: TStream);
var
  C: PConfig;
  CD: TConfigData;
  SignStr: string[ConfSignatureLen];
begin
  SignStr[0] := chr(ConfSignatureLen);
  S.Read(SignStr[1], ConfSignatureLen);
  C := PConfig(S.Get);
  if S.Status <> stOk
    then Exit;
  if (C^.CalcCheckSum <> C^.CheckSum) or (SignStr <> ConfSignature)
    then begin
      S.Status := stChkSumError;
      Dispose(C, Done);
      Exit;
    end;
  C^.GetData(CD);
  Dispose(C, Done);
  SetData(CD);
  SetCheckSum(CalcCheckSum);
end;

procedure TConfig.Write(var S: TStream);
begin
  S.Write(ConfSignature[1], ConfSignatureLen);
  S.Put(@Self);
end;

procedure TConfig.SetData(AConfigData: TConfigData);
begin
  ConfigData := AConfigData
end;

procedure TConfig.GetData(var AConfigData: TConfigData);
begin
  AConfigData := ConfigData
end;

function TConfig.ShowHeap: boolean;
begin
  ShowHeap := ConfigData.Look and cfHeap <> 0;
end;

function TConfig.ShowClock: boolean;
begin
  ShowClock := ConfigData.Look and cfClock <> 0;
end;

function TConfig.ShowShadow: boolean;
begin
  ShowShadow := ConfigData.Look and cfShadow <> 0;
end;

function TConfig.TimeBeep: boolean;
begin
  TimeBeep := ConfigData.Look and cfTimeBeep <> 0;
end;

function TConfig.GetBellFlag: boolean;
begin
  GetBellFlag := ConfigData.Look and cfErrBell <> 0
end;

function TConfig.ASConfig: boolean;
begin
  ASConfig := ConfigData.AutoSave and cfASConf <> 0;
end;

function TConfig.ASDesktop: boolean;
begin
  ASDesktop := ConfigData.AutoSave and cfASDsk <> 0;
end;

function TConfig.CreateBak: boolean;
begin
  CreateBak := ConfigData.Editor and cfBakUp <> 0;
end;

function TConfig.AutoIndent: boolean;
begin
  AutoIndent := ConfigData.Editor and cfAIndent <> 0;
end;

function TConfig.GetVMode: Word;
begin
  Case ConfigData.ScreenSize of
       cf25: GetVMode := Lo(LastMode);
    cf43_50: GetVMode := Lo(LastMode) + smFont8x8;
    cfMode1: GetVMode := ConvertToByte(ConfigData.Mode1);
    cfMode2: GetVMode := ConvertToByte(ConfigData.Mode2);
  end;
end;

function TConfig.EGALines: boolean;
begin
  EGALines := ConfigData.ScreenSize = cf43_50;
end;

procedure TConfig.SetLngFile(const LngFileName: FNameStr);
begin
  ConfigData.LngFile := LngFileName;
end;

function TConfig.GetLngFile;
begin
  GetLngFile := ConfigData.LngFile;
end;

function TConfig.GetExtEditor: PathStr;
begin
  GetExtEditor := ConfigData.ExtEditor;
end;

procedure TConfig.SetExtEditor(const EditorFileName: FNameStr);
begin
  ConfigData.ExtEditor := EditorFileName;
end;

function TConfig.GetWorkDir: DirStr;
begin
  GetWorkDir := ConfigData.WorkDir;
end;

procedure TConfig.SetWorkDir(const Dir: DirStr);
begin
  ConfigData.WorkDir := Dir;
end;

function TConfig.GetScreenDelay: integer;
begin
  Case ConfigData.ScreenDelay of
    cfRestAfter1: GetScreenDelay := 60;
    cfRestAfter3: GetScreenDelay := 3 * 60;
    cfRestAfter5: GetScreenDelay := 5 * 60;
   cfRestAfter10: GetScreenDelay := 10 * 60;
  else
    GetScreenDelay := 0;
  end;
end;

procedure TConfig.SetCheckSum(ChS: TCheckSum);
begin
  CheckSum := ChS;
end;

function TConfig.CalcCheckSum: TCheckSum;
var
  Arr: TByteArray absolute ConfigData;
  ChS: TCheckSum;
  i: Integer;
begin
  ChS := 0;
  for i := 0 to SizeOf(TConfigData) - 1 do
    Inc(ChS, ord(Arr[i]) xor (3 * i + 1));
  CalcCheckSum := ChS;
end;

function TConfig.ConvertToByte(S: string): byte;
const
  HexDigits = '0123456789ABCDEF';
begin
  S := StrUpCase(Copy(S, 1, 2));
  if (S = '') or (S = '0') then
    begin
      ConvertToByte := Lo(LastMode);
      Exit;
    end;
  if Length(S) = 1 then S := '0' + S;
  ConvertToByte := Lo(Pos(S[2], HexDigits) - 1 +
                      16 * (Pos(S[1], HexDigits) - 1));
end;
{  ^ ^ ^     Методы объекта TConfig   ^ ^ ^  }

constructor TStartDir.Init(Dir: DirStr);
begin
  inherited Init;
  StartDir := Dir;
end;

procedure TStartDir.Store(var S: TStream);
begin
  S.Write(StartDir, SizeOf(StartDir));
end;

constructor TStartDir.Load(var S: TStream);
begin
  S.Read(StartDir, SizeOf(StartDir));
end;
{  ^ ^ ^     Методы объекта TStartDir   ^ ^ ^  }

constructor TRndNameTpl.Init(Tpl: PathStr);
begin
  inherited Init;
  RndNameTpl := Tpl;
end;

procedure TRndNameTpl.Store(var S: TStream);
begin
  S.Write(RndNameTpl, SizeOf(RndNameTpl));
end;

constructor TRndNameTpl.Load(var S: TStream);
begin
  S.Read(RndNameTpl, SizeOf(RndNameTpl));
end;

function NeedAskExit: boolean;
begin
  NeedAskExit := InterfaceFlags and ifAskExit <> 0;
end;

function Esc4Editor: boolean;
begin
  Esc4Editor := InterfaceFlags and ifEsc4Editor <> 0;
end;

function Esc4DirWin: boolean;
begin
  Esc4DirWin := InterfaceFlags and ifEsc4DirWin <> 0;
end;

function AddConfirm: boolean;
begin
  AddConfirm := InterfaceFlags and ifAddConfirm <> 0;
end;

function AddNonExistConfirm: boolean;
begin
  AddNonExistConfirm := InterfaceFlags and ifAddNonExistConfirm <> 0;
end;

function RestoreCurPos: boolean;
begin
  RestoreCurPos := InterfaceFlags and ifRestoreCurPos <> 0;
end;

function Autocompress: boolean;
begin
  Autocompress := InterfaceFlags and ifDontAutocompress = 0;
end;

function Alt4Menu: boolean;
begin
  Alt4Menu := InterfaceFlags and ifAlt4Menu <> 0;
end;

function CalendarInClock: boolean;
begin
  CalendarInClock := InterfaceFlags and ifCalendarInClock <> 0;
end;

function ChangeDirOnSelDir: boolean;
begin
  ChangeDirOnSelDir := InterfaceFlags and ifChangeDirOnSelDir <> 0;
end;

function ItemTitleOnEditor: boolean;
begin
  ItemTitleOnEditor := InterfaceFlags and ifItemTitleOnEditor <> 0;
end;

function CreateFileNames: boolean;
begin
  CreateFileNames := InterfaceFlags and ifCreateFileNames <> 0;
end;

begin
  RegisterType(RConfig);
  RegisterType(RStartDir);
  RegisterType(RRndNameTpl);
  InterfaceFlags :=
    ifAskExit + ifAddConfirm + ifEsc4Editor + ifAddNonExistConfirm
    + ifRestoreCurPos + ifAlt4Menu + ifCalendarInClock
    + ifChangeDirOnSelDir + ifItemTitleOnEditor;
end.

