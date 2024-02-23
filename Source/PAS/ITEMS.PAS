(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Items                                           *)
(* Объекты, представляющие пункты оглавлений              *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1993-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 14.12.1993                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit Items;

interface

uses
  Objects, LineColl, StrServ, StreamId, Crypt, Editors, Dos, Pack_Cmd,
  ShtState;

const

  { Константы, задающие типы пунктов }
  itFileItem    = 1;
  itSubDirItem  = 2;
  itUpDirItem   = 3;
  itArchItem    = 4;

  { Константы, задающие значения поля What типа TAction }

  {  ?????????????????????????????????????????????????????????  }
  afNothing     = 0;   { Ничего не делать                                  }
  afRunDosCmd   = 1;   { Выполнить команду DOS InfoPtr^                    }
  afEnterSubDir = 2;   { Перейти в подоглавление с именем ресурса InfoPtr^ }
  afReturn      = 4;   { Вернуться на шаг назад по цепочке подоглавлений   }
  afSearchFile  = 8;   { Искать файл перед обработкой                      }
  afFocusNext   = $10; { Сфокусировать следующий пункт                     }
  afIntEditor   = $20; { Вызвать встроенный редактор для файла             }
  afAddComParam = $40; { Добавить к InfoStr^ общие параметры по умолчанию  }
                       { Запросить параметры и добавить к InfoPtr^         }
                       { При этом ExtInfoStr^ содержит индекс описания     }
  afAskParam    = $80; { параметров ( если <> '' )                         }
  afExtEditor   = $100;{ Запустить внешний текстовый редактор для файла    }
  afDoMenuByExt = $200;{ Выбрать команду из меню по расширению             }

  { Константы атрибутов пунктов }
  iaSearchBeforeProcess = 1;
  iaNotRunWithoutParams = 2;
  iaRestCD              = 4;
  iaDelayScreen         = 8;
  iaClearKbd            = $10;
  iaAutoSaveEdFiles     = $20;
  iaDontNumberItem      = $40;
  iaDontPutInContents   = $80;

  { Константы признаков наследования }
  ifAnnotation  = 1;
  ifParameters  = 2;

  { Константы, задающие, где находится ресурс  }
  {  (см. описание типа TResIndex )            }
  pfNowhere     = 0;  { Ресурса нет        }
  pfDirFile     = 1;  { В файле оглавления }
  pfDisk        = 2;  { В отдельном файле  }

type

  { Используется для передачи пунктом подоглавления     }
  { информации о действии, которое необходимо выполнить }
  { при выборе этого пункта                             }
  PAction = ^TAction;
  TAction = object(TObject)
    What: Word;
    InfoPtr: Pointer;

    constructor Init(AWhat: Word; AInfoPtr: Pointer);
    { !!!!!!!! Done должен освобождать память по InfoPtr !!!!!!!! }
    destructor Done; virtual;
  end;

  PExecInfo = ^TExecInfo;
  TExecInfo = record
    ItemTitle: String;
    ProgName: PathStr;
    Directory: Pointer;
    Params: String[127];
    ParIndex: String;
    StartDir: DirStr;
    RestCurrDir: boolean;
    DelayScreen: boolean;
    ClearKbd: boolean;
    EnvSize: String[5];
  end;

  { Используется для хранения информации о некоторых ресурсах }
  PResIndex = ^TResIndex;
  TResIndex = record
     Name: PString;     { Указатель на строку с именем ресурса        }
     Place: byte;       { Указывает, где хранится ресурс (см. pfXXXX) }
     InhFlag: boolean;  { True  - ресурс унаследован от подоглавления }
                        { False - ресурс - собственность объекта      }
  end;

  { Используется для хранения строковой информации }
  PInhString = ^TInhString;
  TInhString = record
    Str: PString;
    InhFlag: boolean;  { True  - строка унаследована от подоглавления }
                       { False - строка - собственность объекта       }
  end;

  { Используется для передачи информации о пункте }
  PItemInfo = ^TItemInfo;
  TItemInfo = object(TLineCollection)

  end;

  PTextResource = ^TTextResource;
  TTextResource = object(TObject)
    Length: Word;
    Text: PEditBuffer;

    constructor Init(ALength: Word; var AText);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
  end;

  { Используется для порождения T...ItemData }
  PItemData = ^TItemData;
  TItemData = object(TObject)
    Title: PString;
    HotKey: Char;
    SelFlag: Boolean;

    constructor Init;
    destructor Done; virtual;
  end;

  { Используется для передачи данных объекта TSubDirItem }
  { и связанного с ним подоглавления                     }
  PSubDirItemData = ^TSubDirItemData;
  TSubDirItemData = object(TItemData)
    SubDirName: PString;

     { . . . . . . . . }

    constructor Init;
    destructor Done; virtual;
  end;

  { Используется для передачи данных объекта TUpDirItem }
  PUpDirItemData = ^TUpDirItemData;
  TUpDirItemData = object(TItemData)
  end;

  { Используется для передачи данных объекта TFileItem }
  PFileItemData = ^TFileItemData;
  TFileItemData = object(TItemData)
    FileName: PString;
    DiskLabel: PString;
    StartDir: TInhString;
    Parameters: TInhString;
    Attributes: Word;
    Inheritance: Word;      { Флажки - признаки наследования информации }
    AnnIndex: TResIndex;    { Индекс аннотации }
    PIFIndex: TResIndex;    { Индекс описания параметров }

    constructor Init;
    destructor Done; virtual;
  end;

  { Используется для передачи данных объекта TArchItem }
  PArchItemData = ^TArchItemData;
  TArchItemData = object(TFileItemData)
    ArchName: PString;

    constructor Init;
    destructor Done; virtual;
  end;

  { Пункт подоглавления (абстрактный) }
  PItem = ^TItem;
  TItem = object(TObject)
    constructor Init(ATitle: String);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetTitle: String; virtual;
    function GetItemType: Byte; virtual;
    procedure GetData(var Data: TItemData);
    procedure SetData(var Data: TItemData);
    procedure ChangeSel;
    procedure Unselect;
    procedure Select; virtual;
    function Selected: boolean;
    procedure GetAction(KeyCode: Word; var Action: TAction); virtual;
    procedure GetAnnIndex(var Index: TResIndex); virtual;
    procedure SetAnnIndex(var Index: TResIndex); virtual;
    procedure GetPIFIndex(var Index: TResIndex); virtual;
    procedure SetPIFIndex(var Index: TResIndex); virtual;
    function GetInfo: PItemInfo; virtual;
    function GetHotKey: Char; virtual;
    procedure SetHotKey(Key: Char); virtual;
    function NeedNumber: boolean; virtual;
    function PutInContents: boolean; virtual;
  private
    Title: PString;
    HotKey: Char;
    SelFlag: Boolean;
  end;

  { Ссылка на подоглавление }
  PSubDirItem = ^TSubDirItem;
  TSubDirItem = object(TItem)

    SubDirName: PString;

    constructor Init(ATitle, ASubDirName: String);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetItemType: Byte; virtual;
    function GetSubDirName: String;
    procedure GetData(var Data: TSubDirItemData);
    procedure SetData(var Data: TSubDirItemData);
    procedure GetAction(KeyCode: Word; var Action: TAction); virtual;
    function GetInfo: PItemInfo; virtual;
  end;

  { Ссылка на верхнее подоглавление }
  PUpDirItem = ^TUpDirItem;
  TUpDirItem = object(TItem)
    constructor Init(ATitle: String);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    procedure Select; virtual;
    function GetItemType: Byte; virtual;
    procedure GetData(var Data: TUpDirItemData);
    procedure SetData(var Data: TUpDirItemData);
    procedure GetAction(KeyCode: Word; var Action: TAction); virtual;
    function GetInfo: PItemInfo; virtual;
  end;


  { Ссылка на дисковый файл }
  PFileItem = ^TFileItem;
  TFileItem = object(TItem)

    private

    FileName: PString;
    DiskLabel: PString;
    StartDir: TInhString;
    Parameters: TInhString;
    Attributes: Word;
    Inheritance: Word;      { Флажки - признаки наследования информации }
    AnnIndex: TResIndex;    { Индекс аннотации }
    PIFIndex: TResIndex;    { Индекс описания параметров }

    public

    FileExist: boolean;

    constructor Init(ATitle, AFileName, ADiskLabel: String;
                     var AStartDir, AParameters: TInhString;
                     AAttributes, AInheritance: Word;
                     var AAnnIndex, APIFIndex: TResIndex);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetItemType: Byte; virtual;
    function GetFileName: PathStr;
    procedure GetData(var Data: TFileItemData);
    procedure SetData(var Data: TFileItemData);
    procedure GetAction(KeyCode: Word; var Action: TAction); virtual;
    procedure GetAnnIndex(var Index: TResIndex); virtual;
    procedure SetAnnIndex(var Index: TResIndex); virtual;
    procedure GetPIFIndex(var Index: TResIndex); virtual;
    procedure SetPIFIndex(var Index: TResIndex); virtual;
    function GetInfo: PItemInfo; virtual;
    function GetOwnParams: String;
    function NeedNumber: boolean; virtual;
    function PutInContents: boolean; virtual;
    function GetStartDir: DirStr;
  end;

  { Ссылка на файл в архиве }
  PArchItem = ^TArchItem;
  TArchItem = object(TFileItem)

    private

    ArchName: PString;

    public

    constructor Init(var ATitle, AArchName, AFileName, ADiskLabel: String;
                     var AStartDir, AParameters: TInhString;
                     var AAttributes, AInheritance: Word;
                     var AAnnIndex, APIFIndex: TResIndex);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetItemType: Byte; virtual;
    procedure GetData(var Data: TArchItemData);
    procedure SetData(var Data: TArchItemData);
    procedure GetAction(KeyCode: Word; var Action: TAction); virtual;
    function GetInfo: PItemInfo; virtual;
  end;

  procedure SetNewInhStr(var NewIS, OldIS: TInhString);
  procedure SetNewResIndex(var NewInd, OldInd: TResIndex);
  procedure WriteInhStr(var S: TStream; var InhStr: TInhString);
  procedure WriteResIndex(var S: TStream; var ResInd: TResIndex);
  procedure DoneResIndex(var ResIndex: TResIndex);
  procedure ReadInhStr(var S: TStream; var InhStr: TInhString);
  procedure ReadResIndex(var S: TStream; var ResInd: TResIndex);
  procedure RegisterItems;
  function NewExecInfo(AItemTitle, AProgName, AParams, AStartDir,
                       AEnvSize, AParIndex: String;
                       ADirectory: Pointer;
                       AClearKbd, ADelayScreen,
                       ARestCurrDir: Boolean): PExecInfo;

const

  RFileItem: TStreamRec = (
     ObjType: idFileItem;
     VmtLink: Ofs(TypeOf(TFileItem)^);
     Load:    @TFileItem.Load;
     Store:   @TFileItem.Store
  );

  RArchItem: TStreamRec = (
     ObjType: idArchItem;
     VmtLink: Ofs(TypeOf(TArchItem)^);
     Load:    @TArchItem.Load;
     Store:   @TArchItem.Store
  );

  RSubDirItem: TStreamRec = (
     ObjType: idSubDirItem;
     VmtLink: Ofs(TypeOf(TSubDirItem)^);
     Load:    @TSubDirItem.Load;
     Store:   @TSubDirItem.Store
  );

  RUpDirItem: TStreamRec = (
     ObjType: idUpDirItem;
     VmtLink: Ofs(TypeOf(TUpDirItem)^);
     Load:    @TUpDirItem.Load;
     Store:   @TUpDirItem.Store
  );

  RTextResource: TStreamRec = (
     ObjType: idTextResource;
     VmtLink: Ofs(TypeOf(TTextResource)^);
     Load:    @TTextResource.Load;
     Store:   @TTextResource.Store
  );

implementation

uses Views, Drivers, App, SubDirs;

{ Методы объекта TAction }
constructor TAction.Init(AWhat: Word; AInfoPtr: Pointer);
begin
  inherited Init;
  What := AWhat;
  InfoPtr := AInfoPtr;
end;

destructor TAction.Done;
begin
  Case What of
    afRunDosCmd + afAskParam, afRunDosCmd + afExtEditor, afRunDosCmd,
    afIntEditor: Dispose(PExecInfo(InfoPtr));
  afEnterSubDir: DispStr(PString(InfoPtr));
  afDoMenuByExt: Dispose(PExecInfo(InfoPtr));
  end;
  What := afNothing;
  inherited Done;
end;

{ Методы объекта TItem }
constructor TItem.Init(ATitle: String);
begin
  inherited Init;

  HotKey := #0;
  SelFlag := False;
  Title := NewStr(ATitle);
end;

destructor TItem.Done;
begin
  DispStr(Title);

  inherited Done;
end;

constructor TItem.Load(var S: TStream);
begin
  Title := ReadString(S);
  S.Read(HotKey, sizeof(HotKey));
  SelFlag := False;
end;

procedure TItem.Store(var S: TStream);
begin
  WriteString(S, Title);
  S.Write(HotKey, sizeof(HotKey));
end;

function TItem.GetTitle: String;
begin
  GetTitle := GetStr(Title);
end;

function TItem.GetItemType: Byte;
begin
  Abstract;
end;

procedure TItem.GetData(var Data: TItemData);
begin
  Data.Init;
  SetNewStrByP(Data.Title, Title);
  Data.HotKey := HotKey;
  Data.SelFlag := SelFlag;
end;

procedure TItem.SetData(var Data: TItemData);
begin
  SetNewStrByP(Title, Data.Title);
  HotKey := Data.HotKey;
  SelFlag := Data.SelFlag;
end;

procedure TItem.ChangeSel;
begin
  if GetItemType <> itUpDirItem
    then SelFlag := not SelFlag;
end;

procedure TItem.Unselect;
begin
  SelFlag := False;
end;

procedure TItem.Select;
begin
  SelFlag := True;
end;

function TItem.Selected: boolean;
begin
  Selected := SelFlag;
end;

procedure TItem.GetAction(KeyCode: Word; var Action: TAction);
begin
  Abstract;
end;

procedure TItem.GetAnnIndex(var Index: TResIndex);
begin
  Abstract;
end;

procedure TItem.SetAnnIndex(var Index: TResIndex);
begin
  Abstract;
end;

procedure TItem.GetPIFIndex(var Index: TResIndex);
begin
  Abstract;
end;

procedure TItem.SetPIFIndex(var Index: TResIndex);
begin
  Abstract;
end;

function TItem.GetInfo: PItemInfo;
begin
  Abstract;
end;

function TItem.GetHotKey: Char;
begin
  GetHotKey := HotKey;
end;

procedure TItem.SetHotKey(Key: Char);
begin
  HotKey := Key;
end;

function TItem.NeedNumber: boolean;
begin
  NeedNumber := True;
end;

function TItem.PutInContents: boolean;
begin
  PutInContents := True;
end;

{ Методы объекта TSubDirItem }
constructor TSubDirItem.Init(ATitle, ASubDirName: String);
begin
  inherited Init(ATitle);
  SubDirName := NewStr(ASubDirName);
end;

destructor TSubDirItem.Done;
begin
  DispStr(SubDirName);

  inherited Done;
end;

constructor TSubDirItem.Load(var S: TStream);
begin
  inherited Load(S);
  SubDirName := ReadString(S);
end;

procedure TSubDirItem.Store(var S: TStream);
begin
  inherited Store(S);
  WriteString(S, SubDirName);
end;

function TSubDirItem.GetItemType: Byte;
begin
  GetItemType := itSubDirItem;
end;

function TSubDirItem.GetSubDirName: String;
begin
  GetSubDirName := GetStr(SubDirName);
end;

procedure TSubDirItem.GetData(var Data: TSubDirItemData);
begin
  Data.Init;
  SetNewStrByP(Data.Title, Title);
  Data.HotKey := HotKey;
  Data.SelFlag := SelFlag;
  SetNewStrByP(Data.SubDirName, SubDirName);

  { . . . . . . . . . }

end;

procedure TSubDirItem.SetData(var Data: TSubDirItemData);
begin
  SetNewStrByP(Title, Data.Title);
  HotKey := Data.HotKey;
  SelFlag := Data.SelFlag;
  SetNewStrByP(SubDirName, Data.SubDirName);
end;

procedure TSubDirItem.GetAction(KeyCode: Word; var Action: TAction);
begin
  Case KeyCode of
     kbEnter: Action.Init(afEnterSubDir, NewStr(SubDirName^));
  else Action.Init(afNothing, nil);
  end;
end;

function TSubDirItem.GetInfo: PItemInfo;
begin

end;


{ Методы объекта TUpDirItem }
constructor TUpDirItem.Init(ATitle: String);
begin
  inherited Init(ATitle);
end;

destructor TUpDirItem.Done;
begin
  inherited Done;
end;

constructor TUpDirItem.Load(var S: TStream);
begin
  inherited Load(S);
end;

procedure TUpDirItem.Store(var S: TStream);
begin
  inherited Store(S);
end;

function TUpDirItem.GetItemType: Byte;
begin
  GetItemType := itUpDirItem;
end;

procedure TUpDirItem.GetData(var Data: TUpDirItemData);
begin
  Data.Init;
  SetNewStrByP(Data.Title, Title);
  Data.HotKey := HotKey;
  Data.SelFlag := SelFlag;
end;

procedure TUpDirItem.SetData(var Data: TUpDirItemData);
begin
  SetNewStrByP(Title, Data.Title);
  HotKey := Data.HotKey;
  SelFlag := Data.SelFlag;
end;

procedure TUpDirItem.Select;
begin
  SelFlag := False;
end;

procedure TUpDirItem.GetAction(KeyCode: Word; var Action: TAction);
begin
  Case KeyCode of
     kbEnter: Action.Init(afReturn, nil);
  else Action.Init(afNothing, nil);
  end;
end;

function TUpDirItem.GetInfo: PItemInfo;
begin
end;


{ Методы объекта TFileItem }
constructor TFileItem.Init(ATitle, AFileName, ADiskLabel: String;
                           var AStartDir, AParameters: TInhString;
                           AAttributes, AInheritance: Word;
                           var AAnnIndex, APIFIndex: TResIndex);

begin
  inherited Init(ATitle);

  FileName := NewStr(AFileName);
  DiskLabel := NewStr(ADiskLabel);
  SetNewInhStr(StartDir, AStartDir);
  SetNewInhStr(Parameters, AParameters);
  Attributes := AAttributes;
  Inheritance := AInheritance;
  SetNewResIndex(AnnIndex, AAnnIndex);
  SetNewResIndex(PIFIndex, APIFIndex);
  FileExist := True;
end;

destructor TFileItem.Done;
begin
  DispStr(FileName);
  DispStr(DiskLabel);
  DispStr(StartDir.Str);
  DispStr(Parameters.Str);
  DispStr(AnnIndex.Name);
  DispStr(PIFIndex.Name);

  inherited Done;
end;

procedure TFileItem.GetData(var Data: TFileItemData);
begin
  Data.Init;

  SetNewStrByP(Data.Title, Title);
  Data.HotKey := HotKey;
  Data.SelFlag := SelFlag;
  SetNewStrByP(Data.FileName, FileName);
  SetNewStrByP(Data.DiskLabel, DiskLabel);
  SetNewInhStr(Data.StartDir, StartDir);
  SetNewInhStr(Data.Parameters, Parameters);
  SetNewResIndex(Data.AnnIndex, AnnIndex);
  SetNewResIndex(Data.PIFIndex, PIFIndex);
  Data.Inheritance := Inheritance;
  Data.Attributes := Attributes;
end;

function TFileItem.GetFileName: PathStr;
begin
  GetFileName := AddPath(GetStr(FileName), GetStr(StartDir.Str));
end;

procedure TFileItem.SetData(var Data: TFileItemData);
begin
  SetNewStrByP(Title, Data.Title);
  HotKey := Data.HotKey;
  SelFlag := Data.SelFlag;
  SetNewStrByP(FileName, Data.FileName);
  SetNewStrByP(DiskLabel, Data.DiskLabel);
  SetNewInhStr(StartDir, Data.StartDir);
  SetNewInhStr(Parameters, Data.Parameters);
  SetNewResIndex(AnnIndex, Data.AnnIndex);
  SetNewResIndex(PIFIndex, Data.PIFIndex);
  Inheritance := Data.Inheritance;
  Attributes := Data.Attributes;
end;

constructor TFileItem.Load(var S: TStream);
begin
  inherited Load(S);

  FileName := ReadString(S);
  DiskLabel := ReadString(S);
  ReadInhStr(S, StartDir);
  ReadInhStr(S, Parameters);
  ReadResIndex(S, AnnIndex);
  ReadResIndex(S, PIFIndex);
  S.Read(Attributes, sizeof(Attributes));
  S.Read(Inheritance, sizeof(Inheritance));
  FileExist := True;
end;

procedure TFileItem.Store(var S: TStream);
begin
  inherited Store(S);

  WriteString(S, FileName);
  WriteString(S, DiskLabel);
  WriteInhStr(S, StartDir);
  WriteInhStr(S, Parameters);
  WriteResIndex(S, AnnIndex);
  WriteResIndex(S, PIFIndex);
  S.Write(Attributes, sizeof(Attributes));
  S.Write(Inheritance, sizeof(Inheritance));
end;

function TFileItem.GetItemType: Byte;
begin
  GetItemType := itFileItem;
end;

procedure TFileItem.GetAction(KeyCode: Word; var Action: TAction);
var
  ActionFlag: Word;
begin
  ActionFlag := 0;

  if Attributes and iaSearchBeforeProcess <> 0
    then Inc(ActionFlag, afSearchFile);

  if (Attributes and iaNotRunWithoutParams <> 0)
    and (KeyCode = kbEnter) and not ShiftDown
  then KeyCode := kbCtrlEnter;

  if (Attributes and iaAutoSaveEdFiles <> 0)
    then Message(Application, evCommand, cmSaveAll, nil);

  if (KeyCode = kbEnter) and ShiftDown
    then KeyCode := $FFFF;

  Case KeyCode of
       $FFFF: Action.Init(ActionFlag + afDoMenuByExt,
                                       NewExecInfo(
                                         GetTitle,
                                         GetFileName,
                                         GetStr(Parameters.Str), { !!! }
                                         GetStr(StartDir.Str),   { !!! }
                                         '512',
                                         GetStr(PIFIndex.Name),
                                         nil,
                                         Attributes and iaClearKbd <> 0,
                                         Attributes and iaDelayScreen <> 0,
                                         Attributes and iaRestCD <> 0));
     kbEnter: if IsExeFile(GetFileName)
                then Action.Init(ActionFlag + afRunDosCmd,
                                       NewExecInfo(
                                         GetTitle,
                                         GetFileName,
                                         GetStr(Parameters.Str), { !!! }
                                         GetStr(StartDir.Str),   { !!! }
                                         '512',
                                         GetStr(PIFIndex.Name),
                                         nil,
                                         Attributes and iaClearKbd <> 0,
                                         Attributes and iaDelayScreen <> 0,
                                         Attributes and iaRestCD <> 0))
                else Action.Init(afIntEditor, NewExecInfo(
                                         GetTitle,
                                         GetFileName,
                                         '',
                                         '',
                                         '',
                                         '',
                                         nil,
                                         Attributes and iaClearKbd <> 0,
                                         Attributes and iaDelayScreen <> 0,
                                         Attributes and iaRestCD <> 0));
     kbCtrlEnter: if IsExeFile(GetFileName)
                    then Action.Init(ActionFlag + afRunDosCmd + afAskParam,
                                       NewExecInfo(
                                         GetTitle,
                                         GetFileName,
                                         GetStr(Parameters.Str), { !!! }
                                         GetStr(StartDir.Str),   { !!! }
                                         '512',
                                         GetStr(PIFIndex.Name),
                                         nil,
                                         Attributes and iaClearKbd <> 0,
                                         Attributes and iaDelayScreen <> 0,
                                         Attributes and iaRestCD <> 0))
                    else Action.Init(afExtEditor + afRunDosCmd,
                                       NewExecInfo(
                                         GetTitle,
                                         '',
                                         GetFileName + ' ' +
                                         GetStr(Parameters.Str), { !!! }
                                         GetStr(StartDir.Str),   { !!! }
                                         '512',
                                         GetStr(PIFIndex.Name),
                                         nil,
                                         Attributes and iaClearKbd <> 0,
                                         Attributes and iaDelayScreen <> 0,
                                         Attributes and iaRestCD <> 0));
  else Action.Init(afNothing, nil);
  end;
end;

procedure TFileItem.GetAnnIndex(var Index: TResIndex);
begin
  Index.Name := nil;
  SetNewResIndex(Index, AnnIndex);
end;

procedure TFileItem.SetAnnIndex(var Index: TResIndex);
begin
  SetNewResIndex(AnnIndex, Index);
  Case Index.InhFlag of
    True: Inheritance := Inheritance or ifAnnotation;
   False: Inheritance := Inheritance and not ifAnnotation;
  end;
end;

procedure TFileItem.GetPIFIndex(var Index: TResIndex);
begin
  Index.Name := nil;
  SetNewResIndex(Index, PIFIndex);
end;

procedure TFileItem.SetPIFIndex(var Index: TResIndex);
begin
  SetNewResIndex(PIFIndex, Index);
  Case Index.InhFlag of
    True: Inheritance := Inheritance or ifParameters;
   False: Inheritance := Inheritance and not ifParameters;
  end;
end;

function TFileItem.GetInfo: PItemInfo;
begin
end;

function TFileItem.GetOwnParams: String;
begin
  GetOwnParams := GetStr(Parameters.Str);
end;

function TFileItem.GetStartDir: DirStr;
begin
  GetStartDir := GetStr(StartDir.Str);
end;

function TFileItem.NeedNumber: boolean;
begin
  NeedNumber := Attributes and iaDontNumberItem = 0;
end;

function TFileItem.PutInContents: boolean;
begin
  PutInContents := Attributes and iaDontPutInContents = 0;
end;

{ Методы объекта TArchItem }
constructor TArchItem.Init
                 (var ATitle, AArchName, AFileName, ADiskLabel: String;
                  var AStartDir, AParameters: TInhString;
                  var AAttributes, AInheritance: Word;
                  var AAnnIndex, APIFIndex: TResIndex);
begin
  inherited Init(
                 ATitle, AFileName, ADiskLabel,
                 AStartDir, AParameters,
                 AAttributes, AInheritance,
                 AAnnIndex, APIFIndex);

  ArchName := NewStr(AArchName);
end;

destructor TArchItem.Done;
begin
  inherited Done;

  DispStr(ArchNAme);
end;

procedure TArchItem.SetData(var Data: TArchItemData);
begin
  SetNewStrByP(Title, Data.Title);
  SetNewStrByP(ArchName, Data.ArchName);
  SetNewStrByP(FileName, Data.FileName);
  SetNewStrByP(DiskLabel, Data.DiskLabel);
  SetNewInhStr(StartDir, Data.StartDir);
  SetNewInhStr(Parameters, Data.Parameters);
  SetNewResIndex(AnnIndex, Data.AnnIndex);
  SetNewResIndex(PIFIndex, Data.PIFIndex);
end;

procedure TArchItem.GetData(var Data: TArchItemData);
begin

end;

constructor TArchItem.Load(var S: TStream);
begin
  inherited Load(S);

  FileName := ReadString(S);
  DiskLabel := ReadString(S);
  ReadInhStr(S, StartDir);
  ReadInhStr(S, Parameters);
  ReadResIndex(S, AnnIndex);
  ReadResIndex(S, PIFIndex);
  S.Read(Attributes, sizeof(Attributes));
  S.Read(Inheritance, sizeof(Inheritance));
end;

procedure TArchItem.Store(var S: TStream);
begin
  inherited Store(S);

  WriteString(S, FileName);
  WriteString(S, DiskLabel);
  WriteInhStr(S, StartDir);
  WriteInhStr(S, Parameters);
  WriteResIndex(S, AnnIndex);
  WriteResIndex(S, PIFIndex);
  S.Write(Attributes, sizeof(Attributes));
  S.Write(Inheritance, sizeof(Inheritance));
end;

function TArchItem.GetItemType: Byte;
begin
  GetItemType := itArchItem;
end;

procedure TArchItem.GetAction(KeyCode: Word; var Action: TAction);
begin
  Case KeyCode of
      kbEnter:;
  else Action.Init(afNothing, nil);
  end;
end;

function TArchItem.GetInfo: PItemInfo;
begin
end;


{ Методы объекта TItemData }
constructor TItemData.Init;
begin
  inherited Init;

  Title := nil;
  HotKey := #0;
  SelFlag := False;
end;

destructor TItemData.Done;
begin
  DispStr(Title);
  inherited Done;
end;


{ Методы объекта TFileItemData }
constructor TFileItemData.Init;
begin
  inherited Init;

  Attributes := 0;
  Inheritance := 0;
  FileName := nil;
  DiskLabel := nil;
  StartDir.Str := nil;
  Parameters.Str := nil;
  AnnIndex.Name := nil;
  PIFIndex.Name := nil;
end;

destructor TFileItemData.Done;
begin
  DispStr(FileName);
  DispStr(DiskLabel);
  DispStr(StartDir.Str);
  DispStr(Parameters.Str);
  DispStr(AnnIndex.Name);
  DispStr(PIFIndex.Name);

  inherited Done;
end;


{ Методы объекта TArchItemData }
constructor TArchItemData.Init;
begin
  inherited Init;
  ArchName := nil;
end;

destructor TArchItemData.Done;
begin
  DispStr(ArchName);
  inherited Done;
end;


{ Методы объекта TSubDirItemData }
constructor TSubDirItemData.Init;
begin
  inherited Init;
  SubDirName := nil;
end;

destructor TSubDirItemData.Done;
begin
  inherited Done;
  DispStr(SubDirName);
end;

{ Методы объекта TTextResource }
constructor TTextResource.Init(ALength: Word; var AText);
begin
  Length := ALength;
  if Length = 0
    then Text := nil
  else begin
    GetMem(Text, Length);
    Move(AText, Text^, Length);
  end;
end;

destructor TTextResource.Done;
begin
  if Length > 0
    then FreeMem(Text, Length);
  inherited Done;
end;

constructor TTextResource.Load(var S: TStream);
begin
  S.Read(Length, SizeOf(Length));
  if Length > 0
    then begin
      GetMem(Text, Length);
      S.Read(Text^, Length);
      CryptMem(Text^, Length, True);
    end;
end;

procedure TTextResource.Store(var S: TStream);
begin
  S.Write(Length, SizeOf(Length));
  if (Length > 0) and Assigned(Text)
    then begin
      CryptMem(Text^, Length, True);
      S.Write(Text^, Length);
      CryptMem(Text^, Length, True);
    end;
end;

procedure WriteInhStr(var S: TStream; var InhStr: TInhString);
begin
  S.Write(InhStr.InhFlag, sizeof(InhStr.InhFlag));
  WriteString(S, InhStr.Str);
end;

procedure ReadInhStr(var S: TStream; var InhStr: TInhString);
begin
  S.Read(InhStr.InhFlag, sizeof(InhStr.InhFlag));
  InhStr.Str := ReadString(S);
end;

procedure WriteResIndex(var S: TStream; var ResInd: TResIndex);
begin
  S.Write(ResInd.Place, sizeof(ResInd.Place));
  S.Write(ResInd.InhFlag, sizeof(ResInd.InhFlag));
  WriteString(S, ResInd.Name);
end;

procedure ReadResIndex(var S: TStream; var ResInd: TResIndex);
begin
  S.Read(ResInd.Place, sizeof(ResInd.Place));
  S.Read(ResInd.InhFlag, sizeof(ResInd.InhFlag));
  ResInd.Name := ReadString(S);
end;

procedure SetNewInhStr(var NewIS, OldIS: TInhString);
begin
  NewIS.InhFlag := OldIS.InhFlag;
  SetNewStrByP(NewIS.Str, OldIS.Str);
end;

procedure SetNewResIndex(var NewInd, OldInd: TResIndex);
begin
  NewInd.InhFlag := OldInd.InhFlag;
  NewInd.Place := OldInd.Place;
  SetNewStrByP(NewInd.Name, OldInd.Name);
end;

procedure DoneResIndex(var ResIndex: TResIndex);
begin
  DispStr(ResIndex.Name);
  ResIndex.Place := pfNowhere;
  ResIndex.InhFlag := False;
end;

function NewExecInfo(AItemTitle, AProgName, AParams, AStartDir,
                     AEnvSize, AParIndex: String;
                     ADirectory: Pointer;
                     AClearKbd, ADelayScreen,
                     ARestCurrDir: Boolean): PExecInfo;
var
  P: PExecInfo;
begin
  New(P);
  with P^ do
  begin
    ItemTitle := AItemTitle;
    ProgName := AProgName;
    Params := AParams;
    StartDir := AStartDir;
    RestCurrDir := ARestCurrDir;
    ClearKbd := AClearKbd;
    DelayScreen := ADelayScreen;
    EnvSize := AEnvSize;
    Directory := ADirectory;
    ParIndex := AParIndex;
  end;
  NewExecInfo := P;
end;

procedure RegisterItems;
begin
  RegisterType(RFileItem);
  RegisterType(RArchItem);
  RegisterType(RSubDirItem);
  RegisterType(RUpDirItem);
  RegisterType(RTextResource);
end;

end.

