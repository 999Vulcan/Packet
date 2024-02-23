(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Dir_Wind                                        *)
(* Объект TDirWindow ( окно оглавления )                  *)
(* Объект TDirectoryBox ( интерьер окна оглавления )      *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Dir_Wind;

interface

uses
  Objects, Memory, App, BaseApp, Drivers, Views, Dialogs, StreamID,
  Dirs, ProcMess, SubDirs, Disp_Obj, Pack_Dlg, StrServ, Language, PackLng,
  PathStk, Pack_Cmd, Pack_Hlp, MyMsgBox, Items, PackText, FileOps, Editors,
  EditRes, ParamDlg, Ann_Wind, ShtState, Dos, HotKeys, HKDlg, DirConf,
  Conf_Dlg, CheckPW, TempFlag, Crypt,
{$ifdef ForPacket}
  PackConf, DrvTypes, RunDlg,
{$endif}
  MUpCase, WinCheck, ContRepl, Ext_Serv;

const

  CDirColor      = #$30#$3F#$3A#$13#$13#$30#$20#$3E +
                   #$3F#$2E#$31#$3E#$30#$30#$30#$30;
  CDirBlackWhite = #$07#$0F#$07#$70#$70#$07#$70#$0F +
                   #$07#$7F#$07#$0F#$07#$07#$07#$07;
  CDirMonochrome = #$07#$0F#$07#$70#$70#$07#$70#$01 +
                   #$0F#$70#$07#$0F#$07#$07#$07#$07;
  CDirectoryBox  = #6#6#7#8#9#10#11#12#13#14#15;
  CDirWindow     = #138#139#140#141#142#143#144#145 +
                   #146#147#148#149#150#151#152#153;
  CDirWinIndicator = #1#2#3;

  DirCommands = [cmAddFileItems, cmAddSubDirs, cmDelItems, cmSelectItem,
                 cmModifyItems, cmCompressDir, cmEditFile, cmLocalExt,
                 cmEditParameters, cmMoveItems, cmComParameters, cmSetHotKey,
                 cmDirConfig, cmSetProtect, cmMarkTarget, cmCollectDocument,
                 cmTranspose, cmOpenCopy, cmCrossRef, cmRemoveItems,
                 cmCreateBatch];

type

  PDirWinIndicator = ^TDirWinIndicator;
  TDirWinIndicator = object(TView)
    constructor Init(var Bounds: TRect);
    procedure Draw; virtual;
    function GetPalette: PPalette; virtual;
  end;

  PDirectoryBox = ^TDirectoryBox;
  TDirectoryBox = object(TListViewer)

    DirHandler: PDirHandler;

    private

    MouseSelecting: byte;

    public

    constructor Init(var Bounds: TRect; FileName: FNameStr;
                     AHScrollBar, AVScrollBar: PScrollBar);
    destructor Done; virtual;
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function Valid(Command: Word): boolean; virtual;
    procedure EnableCommands;
    procedure FocusItem(Item: Integer); virtual;
    function GetDirPtr: PDirectory;
    function GetSubDir: PSubDir;
    function GetItem(Item: Integer): PItem;
    function GetSubDirName: String;
    function GetFocusedItem: PItem;
    function CountItems: Integer;
    procedure ChangeSelItem(Item: Integer);
    function GetText(Item: Integer; MaxLen:Integer): String; virtual;
    function GetPrefix(Item: Integer): String; virtual;
    function GetPalette: PPalette; virtual;
    function IsSelected(Item: Integer): boolean; virtual;
    procedure Draw; virtual;
    procedure ChangeBounds(var Bounds: TRect); virtual;
    procedure AdjustHorScr;
    function MaxTitleLen: byte;
    function MaxXValue: byte;
    procedure ChangeRange;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure WriteCurrSubDir;
    function ReadCurrSubDir: boolean;
    function RootDirIsCurrent: boolean;
    function InsBefore: Word;
    procedure AddFileItems;
    procedure AddSubDirs;
    procedure DeleteItems(DelFiles: boolean);
    procedure MoveItems;
    procedure DoMove(var Data: TSelSDData);
    procedure DoReplace(Item: Integer);
    procedure FillProhSD(var ProhSubDirNames: PStringCollection);
    function CheckProhSD: boolean;
    function CheckCopy2Itself: boolean;
    function DoCopy: boolean;
    procedure Move2AnotherDir;
    procedure ModifyItems;
    procedure CompressDirectory;
    function EditResource(Mode: byte): boolean;
    procedure Annotate;
    procedure EditParameters;
    procedure ComParameters;
    procedure ProcKey(Key: Word);
    function DoSearch(var Action: TAction): boolean;
    procedure DoAction(var Action: TAction);
    procedure EnterSubDir(SDName: String);
    procedure ReturnFromSubDir;
    procedure RunExtEditor(var Action: TAction);
    procedure GoToRoot;
    procedure RunWithParams(var Action: TAction);
    procedure GetAnnIndex(P: PItem; var Index: TResIndex);
    procedure SetAnnIndex(P: PItem; var Index: TResIndex);
    procedure GetPIFIndex(P: PItem; var Index: TResIndex);
    procedure SetPIFIndex(P: PItem; var Index: TResIndex);
    procedure ChangeAnn;
    procedure EditFile;
    function MayEditFocused: boolean;
    function GetComParams: String;
    procedure SetHotKey;
    function HotKey(Key: Char): boolean;
    procedure ChangeConfig;
    procedure SetProtect;
    procedure UnselectAll;
    procedure Copy2Target;
    procedure Cut2Target;
    procedure CollectDocument;
    procedure EditLocalExt;
    procedure Transpose;
    procedure TurnFile;
    procedure TurnSD;
    function GetStartDir: PathStr;
    procedure AddStartDir(var Action: TAction);
    procedure InsertReference;
    procedure OpenIntEditor(var Action: TAction);
    procedure CrossRef;
    procedure CheckFilesExist;
    function GetRndNameTpl: FNameStr;
    procedure CreateBatch;
    function CreateBatch4Group(FileName: FNameStr; Cmd: ComStr): boolean;
  end;

  PDirWindow = ^TDirWindow;
  TDirWindow = object(TWindow)
    DirectoryBox: PDirectoryBox;
    IsTarget: boolean;
    Indicator: PDirWinIndicator;

    constructor Init(R: TRect; FileName: FNameStr; ANumber: Integer);
    constructor Load(var S: TStream);
    procedure Store(var S: TStream);
    function GetSubDir: PSubDir;
    procedure CheckWriteProtect;
    function GetTitle(MaxSize: Integer): TTitleStr; virtual;
    function GetPalette: PPalette; virtual;
    function GetFileName: FNameStr;
    function GetDirTitle: String;
    function GetDirPtr: PDirectory;
    function GetDirHandler: PDirHandler;
    procedure ReadCurrSubDir;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure EnableDirCommands;
    function DirOnFloppy: boolean;
    procedure ProtectDir;
    procedure MakeTarget;
    procedure MakeNonTarget;
    procedure SetState(AState: Word; Enable: Boolean); virtual;
    procedure OpenCopy;
  end;

  function FirstDirWindow: PDirWindow;
  function SearchTarget: PDirWindow;
  function TargetPresent: boolean;
  function AskInsertBefore: Word;

const

  RDirWindow: TStreamRec = (
     ObjType: idDirWindow;
     VmtLink: Ofs(TypeOf(TDirWindow)^);
     Load:    @TDirWindow.Load;
     Store:   @TDirWindow.Store
  );

  RDirectoryBox: TStreamRec = (
     ObjType: idDirectoryBox;
     VmtLink: Ofs(TypeOf(TDirectoryBox)^);
     Load:    @TDirectoryBox.Load;
     Store:   @TDirectoryBox.Store
  );

  RDirWinIndicator: TStreamRec = (
     ObjType: idDirWinIndicator;
     VmtLink: Ofs(TypeOf(TDirWinIndicator)^);
     Load:    @TDirWinIndicator.Load;
     Store:   @TDirWinIndicator.Store
  );

implementation

uses

  AddItDlg, AddSDDlg, SelSDDlg, MakeDoc, CrossRef;

const

  { Текущий режим отметки мышкой }
  msNone = 0;
  msSelect = 1;
  msUnselect = 2;

  { Режимы работы процедуры EditResource }
  emLocalExt   = 1;
  emParameters = 2;

var
  Stack: PPathStack;

(***** V V V ******* Методы объекта TDirWindow ****** V V V ******)
constructor TDirWindow.Init(R: TRect; FileName: FNameStr; ANumber: Integer);
var
  HScrollBar, VScrollBar: PScrollBar;
begin
  inherited Init(R, '', ANumber);
  Options := Options or (ofTileable + ofFirstClick);
  HelpCtx := hcDirWindow;

  VScrollBar := StandardScrollBar(sbVertical + sbHandleKeyboard);
  HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  Inc(HScrollBar^.Origin.X, 2);
  Dec(HScrollBar^.Size.X, 2);

  R.Assign(2, Size.Y - 1, 3, Size.Y);
  New(Indicator, Init(R));
  Insert(Indicator);
  Indicator^.Hide;
  IsTarget := False;

  GetExtent(R);
  R.Grow(-1, -1);
  DirectoryBox := nil;
  DirectoryBox := New(PDirectoryBox,
                      Init(R, FileName, HScrollBar, VScrollBar));
  if not Assigned(DirectoryBox)
    then begin
      Done;
      Fail;
    end;
  Insert(DirectoryBox);

  if (GetDirPtr^.ProtectionType = prReadWrite)
     and (FindDirectory(FileName, False) = nil)
     and (CheckPassword(GetDirPtr^.GetPassword) = #0)
  then begin
    Done;
    Fail;
  end;
  if GetDirPtr^.ProtectionType = prReadWrite
    then GetDirHandler^.SetEnteredPW(GetDirPtr^.GetPassword);
  CheckWriteProtect;
end;

constructor TDirWindow.Load(var S: TStream);
var
  P: PProcMess;
  FileName: FNameStr;
begin
  inherited Load(S);
  GetSubViewPtr(S, DirectoryBox);
  GetSubViewPtr(S, Indicator);
  S.Read(IsTarget, SizeOf(IsTarget));
  FileName := GetFileName;
  New(P, Init(Ph(phLoadingFile) + ' "' + FileName + '"...'));
  GetDirHandler^.Directory := FindDirectory(GetFileName, True);
  if GetDirPtr = nil
    then begin
      if LowMemory then Application^.OutOfMemory;
      DisposeObj(P);
      MessageBox(^C + Ph(phErrorOpenDirFile) + ^M^M^C + GetFileName,
                 nil, mfError + mfOkButton, hcErrorOpenDirFile);
      Exit;
    end;
  GetDirPtr^.Connect;
  GetDirHandler^.SubDir := GetDirPtr^.ReadSubDir(GetDirHandler^.SubDirName^);
  GetDirHandler^.SetSelItems;
  GetDirHandler^.DoneSelNumbers;

  if (GetDirPtr^.ProtectionType = prReadWrite) and
     ((not ReadingTmpDsk
       and (FindDirectory(FileName, False) = nil)
       and (CheckPassword(GetDirPtr^.GetPassword) = #0))
      or (ReadingTmpDsk and
         not PasswordsMatch(GetDirHandler^.GetEnteredPW,
                            GetDirPtr^.GetPassword)))
  then begin
    GetDirPtr^.Disconnect;
    GetDirHandler^.Directory := nil;
    DisposeObj(P);
    Exit;
  end;

  if (GetDirPtr^.ProtectionType = prReadWrite) and Valid(cmCancel)
    then GetDirHandler^.SetEnteredPW(GetDirPtr^.GetPassword);

  if not Assigned(GetDirHandler^.SubDir)
    then DirectoryBox^.ReturnFromSubDir
  else DirectoryBox^.ChangeRange;
  DisposeObj(P);
  if GetDirHandler^.Protected
    then MakeNonTarget;
  DirectoryBox^.CheckFilesExist;
end;

procedure TDirWindow.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, DirectoryBox);
  PutSubViewPtr(S, Indicator);
  S.Write(IsTarget, SizeOf(IsTarget));
end;

procedure TDirWindow.CheckWriteProtect;
var
  P: PDirWindow;
  FileName: FNameStr;
begin
  FileName := GetFileName;
  P := Message(Desktop, evBroadcast, cmSearchDirWindow, @FileName);
  if Assigned(P)
    then GetDirHandler^.SetEnteredPW(
            CryptStr(P^.GetDirHandler^.GetEnteredPW));
end;

function TDirWindow.GetSubDir: PSubDir;
begin
  GetSubDir := GetDirHandler^.SubDir;
end;

function TDirWindow.GetTitle(MaxSize: Integer): TTitleStr;
var
  Titl, Prefix, s: TTitleStr;
begin
  Titl := FullTrim(GetDirPtr^.GetTitle);
  if Titl = ''
    then begin
      Prefix := Ph(phDirectory_O) + ' - ';
      s := Prefix + GetShortFName(GetFileName, MaxSize - Length(Prefix));
      if Length(s) <= MaxSize
        then GetTitle := s
      else GetTitle := GetShortFName(GetFileName, MaxSize);
    end
  else GetTitle := Copy(Titl, 1, MaxSize + 5);
end;

function TDirWindow.GetPalette: PPalette;
const
  P: String[Length(CDirWindow)] = CDirWindow;
begin
  GetPalette := @P;
end;

function TDirWindow.GetFileName: FNameStr;
begin
  GetFileName := GetStr(GetDirHandler^.DirFileName);
end;

function TDirWindow.GetDirTitle: String;
begin
  GetDirTitle := GetDirPtr^.GetTitle;
end;

function TDirWindow.GetDirPtr: PDirectory;
begin
  GetDirPtr := GetDirHandler^.Directory;
end;

function TDirWindow.GetDirHandler: PDirHandler;
begin
  GetDirHandler := DirectoryBox^.DirHandler;
end;

procedure TDirWindow.OpenCopy;
var
  FileName: FNameStr;
begin
  FileName := GetFileName;
  Message(Application, evCommand, cmOpenDirWindow, @FileName);
end;

procedure TDirWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evBroadcast
    then begin
      Case Event.Command of
        cmSearchDirWindow: if PString(Event.InfoPtr)^ = GetFileName
                             then ClearEvent(Event);
        cmDirChanged: if Event.InfoPtr = GetDirPtr
                        then ReadCurrSubDir;
        cmSearchFirstDirW: ClearEvent(Event);
        cmSetPasswords: if PPWInfo(Event.InfoPtr)^.Dir = GetDirPtr
                             then begin
                                GetDirHandler^.SetEnteredPW(
                                            PPWInfo(Event.InfoPtr)^.PW);
                                if GetDirHandler^.Protected
                                  then MakeNonTarget;
                             end;
        cmSetProtections: ProtectDir;
        cmResetTarget: MakeNonTarget;
        cmSearchTarget: if IsTarget then ClearEvent(Event);
        cmRedrawCnt: begin
                       DirectoryBox^.CheckFilesExist;
                       Redraw;
                     end;
      end;
      Exit;
    end;

  if Event.What = evCommand
    then begin
      Case Event.Command of
        cmMarkTarget: MakeTarget;
        cmOpenCopy: OpenCopy;
      else
        Exit;
      end;
      ClearEvent(Event);
      Exit;
    end;
end;

procedure TDirWindow.ReadCurrSubDir;
begin
  Lock;
  GetDirHandler^.InitSelNumbers;
  DirectoryBox^.ReadCurrSubDir;
  GetDirHandler^.SetSelItems;
  GetDirHandler^.DoneSelNumbers;
  Redraw;
  Unlock;
end;

procedure TDirWindow.EnableDirCommands;
begin
  DirectoryBox^.EnableCommands;
end;

function TDirWindow.DirOnFloppy: boolean;
var
  S: string[1];
begin
  S := GetDirPtr^.GetFileName;
  DirOnFloppy := UpCase(S[1]) in ['A','B'];
end;

procedure TDirWindow.ProtectDir;
begin
  Case GetDirPtr^.ProtectionType of
        prWrite: GetDirHandler^.SetEnteredPW(#0);
    prReadWrite: if not PasswordsMatch(GetDirHandler^.GetEnteredPW,
                                       GetDirPtr^.GetPassWord)
                   then Message(@Self, evCommand, cmClose, nil);
  else
    Exit
  end;
  MakeNonTarget;
end;

procedure TDirWindow.SetState(AState: Word; Enable: Boolean);
begin
  inherited SetState(AState, Enable);
  if (AState = sfActive) and Enable
{$ifdef ForPacket}
    and ChangeDirOnSelDir
{$endif}
    then begin
      ChangeDirectory(DirectoryBox^.GetStartDir);
      Message(Application, evCommand, cmStoreCurrDir, nil);
    end;
end;

procedure TDirWindow.MakeTarget;
var
  IsT: boolean;
begin
  if GetDirHandler^.Protected then Exit;
  IsT := not IsTarget;
  Message(Desktop, evBroadcast, cmResetTarget, nil);
  IsTarget := IsT;
  if IsTarget
    then Indicator^.Show
  else Indicator^.Hide;
end;

procedure TDirWindow.MakeNonTarget;
begin
  IsTarget := False;
  Indicator^.Hide;
end;
(***** ^ ^ ^ ******* Методы объекта TDirWindow ****** ^ ^ ^ ******)

(***** V V V ******* Методы объекта TDirectoryBox ****** V V V ******)
constructor TDirectoryBox.Init(var Bounds: TRect; FileName: FNameStr;
                          AHScrollBar, AVScrollBar: PScrollBar);
begin
  inherited Init(Bounds, 1, AHScrollBar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  DirHandler := New(PDirHandler, Init(FileName));
  if not Assigned(DirHandler) or LowMemory
    then begin
      if LowMemory then Application^.OutOfMemory;
      DisposeObj(DirHandler);
      MessageBox(^M^C + Ph(phErrorOpenDirFile), nil,
                 mfError + mfOkButton, hcErrorOpenDirFile);
      Done;
      Fail;
    end;
  ChangeRange;
end;

destructor TDirectoryBox.Done;
begin
  DisposeObj(DirHandler);
  Range := 0;
  inherited Done;
end;

constructor TDirectoryBox.Load(var S: TStream);
begin
  inherited Load(S);
  DirHandler := PDirHandler(S.Get);
end;

procedure TDirectoryBox.Store(var S: TStream);
begin
  inherited Store(S);
  S.Put(DirHandler);
end;

procedure TDirectoryBox.EnableCommands;

{ Команда разрешена,                   }
{   если есть пункты                   }
{   и текущий пункт - не ссылка наверх }
{   или есть отмеченные пункты         }
procedure CheckCommand1(Cmd: byte);
begin
  if (Range = 0) or
      ((DirHandler^.CalcCountSelected = 0) and
      (GetFocusedItem^.GetItemType = itUpDirItem))
    then Application^.DisableCommands([Cmd])
  else Application^.EnableCommands([Cmd]);
end;

{ Команда разрешена,                   }
{   если есть пункты                   }
procedure CheckCommand2(Cmd: byte);
begin
  if Range = 0
    then Application^.DisableCommands([Cmd])
  else Application^.EnableCommands([Cmd]);
end;

{ Команда разрешена,                   }
{   если есть пункты                   }
{   и текущий пункт - файл             }
procedure CheckCommand3(Cmd: byte);
begin
  if (Range = 0) or (GetFocusedItem^.GetItemType <> itFileItem)
    then Application^.DisableCommands([Cmd])
  else Application^.EnableCommands([Cmd]);
end;

{ Команда разрешена,                             }
{   если текущий пункт - ссылка на подоглавление }
{   или есть отмеченные пункты и среди них есть  }
{   ссылки на подоглавления                      }
procedure CheckCommand4(Cmd: byte);

  function IsSelSD(P: PItem): boolean;
  begin
     IsSelSD := (P^.Selected) and (P^.GetItemType = itSubDirItem);
  end;

begin
  if (Range = 0) or
    (((DirHandler^.CalcCountSelected = 0) and
     (GetFocusedItem^.GetItemType <> itSubDirItem))
    or ((DirHandler^.CalcCountSelected <> 0) and
         (DirHandler^.SubDir^.ItemsColl^.FirstThat(@IsSelSD) = nil)))
  then Application^.DisableCommands([Cmd])
  else Application^.EnableCommands([Cmd]);
end;

begin
  if MayEditFocused
    then Application^.EnableCommands([cmEditFile])
    else Application^.DisableCommands([cmEditFile]);

  if DirHandler^.Protected
    then begin
      Application^.DisableCommands(DirCommands + [cmCut, cmReplace] -
        [cmHotKeysList, cmSetProtect, cmEditFile, cmComParameters,
         cmSelectItem, cmCollectDocument, cmOpenCopy]);
      CheckCommand1(cmCopy);
      CheckCommand1(cmCollectDocument);
      CheckCommand2(cmSelectItem);
      Application^.EnableCommands(
         [cmHotKeysList, cmSetProtect, cmComParameters]);
      Exit;
    end;

  Application^.EnableCommands(DirCommands -
      [cmDelItems, cmModifyItems, cmAnnotate, cmEditFile,
       cmEditParameters, cmSelectItem, cmMoveItems, cmSetHotKey,
       cmSetProtect, cmCollectDocument, cmCrossRef]);

  if GetDirPtr^.ProtectionType <> prWrite
    then Application^.DisableCommands([cmSetProtect])
  else Application^.EnableCommands([cmSetProtect]);

  CheckCommand1(cmDelItems);
  CheckCommand1(cmRemoveItems);
  CheckCommand1(cmModifyItems);
  CheckCommand1(cmMoveItems);
  CheckCommand1(cmCut);
  CheckCommand1(cmCopy);
  CheckCommand1(cmReplace);
  CheckCommand1(cmCollectDocument);
  CheckCommand1(cmCreateBatch);
  CheckCommand2(cmAnnotate);
  CheckCommand2(cmSelectItem);
  CheckCommand3(cmSetHotKey);
  CheckCommand3(cmEditParameters);
  CheckCommand4(cmCrossRef);
  if (Range = 0) or (GetFocusedItem^.GetItemType = itUpDirItem)
    then Application^.DisableCommands([cmTranspose])
  else Application^.EnableCommands([cmTranspose]);
end;

function TDirectoryBox.Valid(Command: Word): boolean;
begin
  Valid := inherited Valid(Command) and (GetDirPtr <> nil);
end;

procedure TDirectoryBox.FocusItem(Item: Integer);
var
  I: Integer;

  function RightButtonPressed: boolean;
  begin
    RightButtonPressed := (MouseReverse and (MouseButtons = mbLeftButton))
                   or (not MouseReverse and (MouseButtons = mbRightButton))
  end;

begin
  if Item < Range
    then I := Item
    else I := Range - 1;
  if Range > 0
    then begin
      if RightButtonPressed then
        Case MouseSelecting of
            msSelect: GetSubDir^.SelectItem(Item);
          msUnselect: GetSubDir^.UnselectItem(Item);
              msNone: begin
                        ChangeSelItem(Item);
                        Case IsSelected(Item) of
                           True: MouseSelecting := msSelect;
                          False: MouseSelecting := msUnselect;
                        end;
                      end;
        end;
      inherited FocusItem(I);
    end;
end;

function TDirectoryBox.GetDirPtr: PDirectory;
begin
  GetDirPtr := DirHandler^.Directory;
end;

procedure TDirectoryBox.CompressDirectory;
var
  ErrCode: Integer;
  Mess: PProcMess;
begin
  if OS2Active then Exit;
  New(Mess, Init(Ph(phCompressing)));
  ErrCode := GetDirPtr^.Compress;
  DisposeObj(Mess);
  if ErrCode <> 0
    then MessageBox(^C + Ph(phCompressError) + ^M^M^C + GetErrMsg(ErrCode),
           nil, mfError + mfOkButton, hcCompressError);
end;

function TDirectoryBox.GetSubDir: PSubDir;
begin
  GetSubDir := DirHandler^.SubDir;
end;

function TDirectoryBox.GetItem(Item: Integer): PItem;
begin
  GetItem := GetSubDir^.GetItem(Item);
end;

function TDirectoryBox.GetFocusedItem: PItem;
begin
  GetFocusedItem := GetItem(Focused);
end;

function TDirectoryBox.CountItems: Integer;
begin
  CountItems := GetSubDir^.CountItems;
end;

function TDirectoryBox.GetText(Item: Integer; MaxLen:Integer): String;
begin
  GetText := Copy(GetSubDir^.GetTitle(Item), 1, MaxLen);
end;

function TDirectoryBox.GetPrefix(Item: Integer): String;
begin
  GetPrefix := DirHandler^.GetPrefix(Item);
  if GetItem(Item)^.GetItemType <> itFileItem
    then Exit;
  if not PFileItem(GetItem(Item))^.FileExist
    then GetPrefix := Ph(phEmptyItemPrefix);
end;

procedure TDirectoryBox.CheckFilesExist;
var
  Item: Integer;
  Name: FNameStr;
  ch: char;
begin
{$ifdef ForPacket}
  for Item := 0 to CountItems - 1 do
  begin
    if GetItem(Item)^.GetItemType <> itFileItem
      then Continue;
    PFileItem(GetItem(Item))^.FileExist := True;
    Name := PFileItem(GetItem(Item))^.GetFileName;
    if PFileItem(GetItem(Item))^.GetStartDir = ''
      then Name := AddPath(Name, GetStartDir);
    if Name[2] = ':'
      then begin
        ch := UpCase(Name[1]);
        if DiskTypes[ch] in
          [dtError, dtRemovable, dtBernoully, dtCDROM, dtRemote]
        then Continue;
      end;
    if (GetItem(Item)^.GetItemType = itFileItem) and
       (FSearch(Name, GetEnv('path')) = '')
    then PFileItem(GetItem(Item))^.FileExist := False;
  end;
{$endif}
end;

procedure TDirectoryBox.Draw;
var
  i, Item: Integer;
  NormalColor, SelectedColor, FocusedColor, HotKeyColor,
  SelFocColor, PrefColor, Color: Word;
  ColWidth, Indent: Integer;
  B: TDrawBuffer;
  Text, Prefix: String;
  SCOff: byte;
  HK: byte;
begin
  NormalColor := GetColor(1);
  FocusedColor := GetColor(3);
  SelectedColor := GetColor(4);
  SelFocColor := GetColor(6);
  Indent := HScrollBar^.Value;
  ColWidth := Size.X + 1;
  for i := 0 to Size.Y - 1 do
  begin
    Item := i + TopItem;
    if (Range > 0) and (Focused = Item)
      then begin
        if IsSelected(Item)
          then begin
            Color := SelFocColor;
            PrefColor := SelFocColor;
            HotKeyColor := SelFocColor;
          end
        else begin
          Color := FocusedColor;
          PrefColor := FocusedColor;
          HotKeyColor := FocusedColor;
        end;
        SetCursor(1, i);
        SCOff := 0;
      end
    else if (Item < Range) and IsSelected(Item)
      then begin
        Color := SelectedColor;
        PrefColor := SelectedColor;
        SCOff := 2;
        HotKeyColor := SelectedColor;
      end
    else if Item < Range
      then begin
        Color := GetColor(
                 GetDirPtr^.GetItemColor(GetItem(Item)));
        PrefColor := GetColor(DirHandler^.GetPrefixColor(Item));
        HotKeyColor := GetColor(8);
        SCOff := 4;
      end
    else Color := NormalColor;
    MoveChar(B, ' ', Color, ColWidth);
    if Item < Range then
    begin
      Text := GetText(Item, ColWidth + Indent);
      Prefix := GetPrefix(Item);
      Text := Copy(Text, Indent, ColWidth - PrefixLen - 2);
      MoveStr(B[2], Prefix, PrefColor);
      MoveStr(B[PrefixLen + 2], Text, Color);
      if Indent > 1
        then MoveStr(B[PrefixLen + 1], tsLeftPartSkiped, Color);
      HK := byte(GetItem(Item)^.GetHotKey);
      if HK <> 0
        then begin
          WordRec(B[1]).Lo := HK;
          WordRec(B[1]).Hi := HotKeyColor;
        end;
{  Рисование маркеров
      if ShowMarkers then
      begin
        WordRec(B[0]).Lo := byte(SpecialChars[SCOff]);
        WordRec(B[ColWidth - 2]).Lo := byte(SpecialChars[SCOff + 1]);
      end;
}
    end;
    WriteLine(0, i, Size.X, 1, B);
  end;
end;

function TDirectoryBox.MaxTitleLen: byte;
var
  MaxLen, Len: byte;
  i: Integer;
begin
  MaxLen := 0;
  for i := 0 to CountItems - 1 do
  begin
    Len := Length(GetSubDir^.GetTitle(i));
    if Len > MaxLen then MaxLen := Len;
  end;
  MaxTitleLen := MaxLen;
end;

function TDirectoryBox.MaxXValue: byte;
var
  MaxValue: integer;
begin
  MaxValue := MaxTitleLen - Size.X + PrefixLen + 4;
  if MaxValue > 0
    then MaxXValue := Lo(MaxValue)
  else MaxXValue := 0;
end;

procedure TDirectoryBox.ChangeBounds(var Bounds: TRect);
begin
  inherited ChangeBounds(Bounds);
  ChangeRange;
end;

procedure TDirectoryBox.AdjustHorScr;
begin
  HScrollBar^.SetParams(HScrollBar^.Value, 1, MaxXValue,
                        Size.X, HScrollBar^.ArStep);
end;

procedure TDirectoryBox.ChangeRange;
var
  flag: boolean;
begin
  flag := Focused <> 0;
  SetRange(CountItems);
  AdjustHorScr;
  if Assigned(Owner) then Owner^.Lock;
  if flag and (Focused = 0) and (Range > 0)
    then FocusItem(Range - 1);

  if ((Focused < TopItem) or ((Focused - TopItem) >= Size.Y)) and (Range > 0)
     then TopItem := Focused - Size.Y + 1;

  if (CountItems - TopItem) < Size.Y
    then TopItem := CountItems - Size.Y;

  if TopItem < 0
    then TopItem := 0;

  if Assigned(Owner) and (Owner^.State and sfVisible <> 0)
    then Owner^.Redraw;
  if Assigned(Owner) then Owner^.Unlock;
end;

function TDirectoryBox.IsSelected(Item: Integer): boolean;
begin
  IsSelected := DirHandler^.IsSelected(Item);
end;

function TDirectoryBox.GetPalette: PPalette;
const
  P: String[Length(CDirectoryBox)] = CDirectoryBox;
begin
  GetPalette := @P;
end;

procedure TDirectoryBox.HandleEvent(var Event: TEvent);
label 1;
var
  KeyCode: Word;
  Key: Char;
  P: PItem;
begin
  if (Event.What = evMouseDown) and Event.Double
    then begin
      if CtrlDown
        then KeyCode := kbCtrlEnter
      else KeyCode := kbEnter;
      Message(@Self, evKeyDown, KeyCode, nil);
      ClearEvent(Event);
    end;

  if (Event.What = evMouseDown) and (Event.Buttons = mbRightButton)
    then begin
      if Range = 0 then Exit;
      Event.Buttons := mbLeftButton;
      MouseSelecting := msNone;
      Focused := -1;
      inherited HandleEvent(Event);
      ClearEvent(Event);
    end;

  if (Event.What = evKeyDown) and (Event.KeyCode = $3920)
    then begin
      Message(Application, evKeyDown, kbGrayPlus, nil);
      ClearEvent(Event);
    end;

  if (Event.What = evKeyDown) and ShiftDown and
     ((Event.KeyCode = kbUp) or (Event.KeyCode = kbDown) or
      (Event.KeyCode = kbLeft) or (Event.KeyCode = kbRight) or
      (Event.KeyCode = kbPgUp) or (Event.KeyCode = kbPgDn) or
      (Event.KeyCode = kbHome) or (Event.KeyCode = kbEnd) or
      (Event.KeyCode = kbCtrlPgUp) or (Event.KeyCode = kbCtrlPgDn))
    then begin
      if SearchAnnWindow <> nil
        then SearchAnnWindow^.Scroll(Event.KeyCode);
      ClearEvent(Event);
    end;

  inherited HandleEvent(Event);

  if Event.What = evCommand
    then begin
      Case Event.Command of
        cmAddFileItems: AddFileItems;
          cmAddSubDirs: AddSubDirs;
         cmModifyItems: ModifyItems;
            cmDelItems: DeleteItems(False);
         cmremoveItems: DeleteItems(True);
           cmMoveItems: MoveItems;
         cmCompressDir: CompressDirectory;
            cmAnnotate: Annotate;
            cmEditFile: EditFile;
      cmEditParameters: EditParameters;
       cmComParameters: ComParameters;
              cmHotKey: HotKey(Char(Event.InfoPtr));
           cmSetHotKey: SetHotKey;
           cmDirConfig: ChangeConfig;
          cmSetProtect: SetProtect;
                cmCopy: Copy2Target;
                 cmCut: Cut2Target;
     cmCollectDocument: CollectDocument;
         cmCreateBatch: CreateBatch;
            cmLocalExt: EditLocalExt;
           cmTranspose: Transpose;
             cmReplace: if ContReplaceDlg(DirHandler, Focused)
                          then UnselectAll;
          cmSelectItem: begin
                          ChangeSelItem(Focused);
                          FocusItem(Focused + 1);
                          Owner^.Redraw;
                        end;
            cmCrossRef: CrossRef;
      else
        Exit;
      end;
      ClearEvent(Event);
    end;

  if Event.What = evBroadcast
    then begin
      Case Event.Command of
        cmHotKey: if HotKey(Char(Event.InfoPtr))
                    then ClearEvent(Event);
        cmSearchHotKey: begin
                          P := SearchHotKey(GetDirPtr^,
                                            PChar(Event.InfoPtr)^);
                          if Assigned(P)
                            then begin
                              PItem(Event.InfoPtr^) := P;
                              ClearEvent(Event);
                            end;
                        end;
      else
        Exit;
      end;
    end;

  if Event.What = evKeyDown
    then begin
      Case Event.KeyCode of
        kbEnter, kbCtrlEnter: ProcKey(Event.KeyCode);
        kbEsc: begin
                 ClearEvent(Event);
                 ReturnFromSubDir;
                 Exit;
               end;
        kbCtrlHome, $2B1C: GoToRoot;
        $372A: begin
                 DirHandler^.ChangeSelections;
                 Owner^.Redraw;
               end;
        $352F: if ShiftDown
                 then Message(@Self, evCommand, cmTranspose, nil);
      else
        goto 1;
      end;
      ClearEvent(Event);
    end;

  1:

  if (Event.What = evKeyDown)
    and (Owner^.State and (sfModal + sfDragging) = 0)
    then begin
      Key := MyUpCase(Event.CharCode);
      ConvertToFigure(Key);
      if Key in HotKeysSet
        then begin
          ClearEvent(Event);
          Message(@Self, evCommand, cmHotKey, Pointer(Key));
        end;
    end;
end;

procedure TDirectoryBox.CrossRef;
var
  Data: TSelSDData;
  i, InsPos: Integer;
  P: PSubDirItem;
  SD, SD1: PSubDir;
  ProhSD: PStringCollection;
begin
  if CountItems = 0 then Exit;
  New(ProhSD, Init(10, 10));
  for i := 0 to CountItems - 1 do
  if (IsSelected(i) and (GetItem(i)^.GetItemType = itSubDirItem)
       and (DirHandler^.CalcCountSelected <> 0))
     or ((DirHandler^.CalcCountSelected = 0) and (i = Focused)
       and (GetItem(i)^.GetItemType = itSubDirItem))
  then ProhSD^.Insert(NewStr(PSubDirItem(GetItem(i))^.GetSubDirName));

  if Application^.ExecuteDialog(New(PSelectSubDirDlg,
                                    Init(Ph(phSelSD4CrossRef),
                                         hcSelSD4CrossRef,
                                         GetDirPtr, DirHandler^.Stack,
                                         GetSubDirName, Focused,
                                         ProhSD, True)),
                                @Data) = cmCancel
    then Exit;

  InsPos := Data.Item + 1;
  if Data.SubDirName = GetSubDirName then Exit;
  SD := GetDirPtr^.ReadSubDir(Data.SubDirName);

  for i := 0 to CountItems - 1 do
  if (IsSelected(i) and (GetItem(i)^.GetItemType = itSubDirItem)
       and (DirHandler^.CalcCountSelected <> 0))
     or ((DirHandler^.CalcCountSelected = 0) and (i = Focused)
       and (GetItem(i)^.GetItemType = itSubDirItem))
  then begin
    SD1 := GetDirPtr^.ReadSubDir(PSubDirItem(GetItem(i))^.GetSubDirName);
    SD1^.Link;
    GetDirPtr^.WriteSubDir(PSubDirItem(GetItem(i))^.GetSubDirName, SD1);
    New(P, Init(GetItem(i)^.GetTitle,
                PSubDirItem(GetItem(i))^.GetSubDirName));
    SD^.InsertItem(InsPos, P);
    Inc(InsPos);
    DisposeObj(SD1);
  end;
  GetDirPtr^.WriteSubDir(Data.SubDirName, SD);
  DisposeObj(SD);
  GetDirPtr^.Flush;
  UnselectAll;
end;

procedure TDirectoryBox.ChangeSelItem(Item: Integer);
begin
  if Range > Item then GetSubDir^.ChangeSelItem(Item);
end;

procedure TDirectoryBox.ProcKey(Key: Word);
var
  Action: TAction;
begin
  if CountItems = 0 then Exit;
  GetFocusedItem^.GetAction(Key, Action);
  DoAction(Action);
end;

function TDirectoryBox.DoSearch(var Action: TAction): boolean;
var
  SearchFlag: boolean;
begin
  DoSearch := True;
  SearchFlag := Action.What and afSearchFile <> 0;
  Action.What := Action.What and not afSearchFile;
  if (Action.What and afExtEditor <> 0)
     and (FullTrim(PExecInfo(Action.InfoPtr)^.Params) = '')
    then begin
      MessageBox(^C + Ph(phActionIsntSpecified),
                 nil, mfError + mfOkButton, hcFileItemNotFound);
      DoSearch := False;
      Exit;
    end;
  if Action.What and afRunDosCmd <> 0
    then begin
      if SearchFlag
        then begin
          if not FileExist(PExecInfo(Action.InfoPtr)^.ProgName)
            then begin
              DoSearch := False;
              MessageBox(^C + Ph(phFileNotFound) + ^M^M^C +
                         PExecInfo(Action.InfoPtr)^.ProgName,
                         nil, mfError + mfOkButton, hcFileItemNotFound);
            end;
        end;
      Exit;
    end;
  if (Action.What and afIntEditor <> 0)
     and (FullTrim(PExecInfo(Action.InfoPtr)^.ProgName) = '')
    then begin
      DoSearch := False;
      MessageBox(^C + Ph(phActionIsntSpecified),
                 nil, mfError + mfOkButton, hcFileItemNotFound);
      Exit;
    end;
end;

procedure TDirectoryBox.AddStartDir(var Action: TAction);
var
  s: String;
begin
  if (Action.What and afRunDosCmd <> 0) and
     (PExecInfo(Action.InfoPtr)^.StartDir = '')
  then begin
    PExecInfo(Action.InfoPtr)^.StartDir := GetStartDir;
    PExecInfo(Action.InfoPtr)^.ProgName :=
       AddPath(PExecInfo(Action.InfoPtr)^.ProgName, GetStartDir);
  end;

  if Action.What = afIntEditor
    then begin
      s := PExecInfo(Action.InfoPtr)^.ProgName;
      PExecInfo(Action.InfoPtr)^.ProgName := AddPath(s, GetStartDir);
    end;
end;

procedure TDirectoryBox.DoAction(var Action: TAction);
var
  s: FNameStr;
begin
  if Action.What and afRunDosCmd <> 0
    then PExecInfo(Action.InfoPtr)^.Directory := GetDirPtr;

  if (Action.What = afIntEditor) and
     (Pos('!', PExecInfo(Action.InfoPtr)^.ProgName) > 0)
    then begin
      s := TreatMacro(PExecInfo(Action.InfoPtr)^.ProgName, GetComParams, False);
      PExecInfo(Action.InfoPtr)^.ProgName := s;
    end;

  AddStartDir(Action);
  GetDirPtr^.CheckExt(Action);

  if DoSearch(Action) then
    Case Action.What of
      afRunDosCmd: begin
                     if FullTrim(PExecInfo(Action.InfoPtr)^.Params) = ''
                       then PExecInfo(Action.InfoPtr)^.Params := GetComParams;
                     Message(Application, evCommand, cmExecuteCmd,
                             Action.InfoPtr);
                   end;
    afEnterSubDir: EnterSubDir(PString(Action.InfoPtr)^);
         afReturn: ReturnFromSubDir;
      afIntEditor: OpenIntEditor(Action);
    afRunDosCmd +
      afExtEditor: RunExtEditor(Action);
    afRunDosCmd +
       afAskParam: RunWithParams(Action);
    end;
  Action.Done;
end;

procedure TDirectoryBox.OpenIntEditor(var Action: TAction);
var
  P: PWindow;
begin
  Message(Application, evCommand, cmOpenIntEditor,
          @PExecInfo(Action.InfoPtr)^.ProgName);
  P := PWindow(Desktop^.Current);
  if (TypeOf(P^) = TypeOf(TEditWindow)) and
     (FNamesEqual(PEditWindow(P)^.Editor^.FileName,
                  PExecInfo(Action.InfoPtr)^.ProgName))
    then PEditWindow(P)^.ItemTitle := PExecInfo(Action.InfoPtr)^.ItemTitle;
  DoneMemory;
  Desktop^.Redraw;
end;

procedure TDirectoryBox.RunExtEditor(var Action: TAction);
var
  EditorName: FNameStr;
begin
  EditorName := FullTrim(GetDirPtr^.GetExtEditor);
  if (not IsExeFile(EditorName)) or (not FileExist(EditorName))
    then begin
      if MessageBox(^C + Ph(phExtEditorNotFound), nil,
                    mfError + mfYesNoCancel, hcExtEditorNotFound)
         = cmYes
      then Message(Application, evCommand, cmOpenIntEditor,
                   @PExecInfo(Action.InfoPtr)^.Params);
    end
  else begin
    PExecInfo(Action.InfoPtr)^.ProgName := EditorName;
    Message(Application, evCommand, cmExecuteCmd, Action.InfoPtr);
  end;
end;

procedure TDirectoryBox.RunWithParams(var Action: TAction);
var
  Params: String;
  ParamIndex: TResIndex;
begin
{
  GetPIFIndex(GetFocusedItem, ParamIndex);
}
  ParamIndex.Place := pfDirFile;
  ParamIndex.Name := NewStr(PExecInfo(Action.InfoPtr)^.ParIndex);
  if not Assigned(ParamIndex.Name) then ParamIndex.Place := pfNowhere;
  Params := PExecInfo(Action.InfoPtr)^.Params;
  if FullTrim(Params) = ''
    then Params := GetComParams;
  if Application^.ExecuteDialog(New(PParamsDlg,
                                    Init(wtRunWithParams,
                                         PExecInfo(Action.InfoPtr)^.ItemTitle,
                                         PExecInfo(Action.InfoPtr)^.Directory,
                                         ParamIndex,
                                         PExecInfo(Action.InfoPtr)^.StartDir)),
                                @Params) = cmOk
    then begin
      PExecInfo(Action.InfoPtr)^.Params := Params;
      Message(Application, evCommand, cmExecuteCmd, Action.InfoPtr);
    end;
  DoneResIndex(ParamIndex);
end;

procedure TDirectoryBox.EnterSubDir(SDName: String);
var
  Index: Integer;
begin
  DirHandler^.Stack^.Insert(New(PPathItem, Init(GetSubDirName, Focused)));
  Index := DirHandler^.Stack^.GetSDPos(SDName);
  DirHandler^.Stack^.DelTail(Index);

  SetNewStr(DirHandler^.SubDirName, SDName);

  Owner^.Lock;
  if ReadCurrSubDir
    then FocusItem(0);
  Owner^.Unlock;
end;

procedure TDirectoryBox.GoToRoot;
begin
  DirHandler^.Stack^.FreeAll;
  SetNewStr(DirHandler^.SubDirName, tsRootDirIndex);
  Focused := 0;
  ReadCurrSubDir;
end;

procedure TDirectoryBox.ReturnFromSubDir;
var
  P: PPathItem;
  Dir: PDirectory;
begin
{$ifdef ForPacket}
  if (DirHandler^.Stack^.Count = 0) and Esc4DirWin
    then begin
      Message(Application, evCommand, cmCloseWin, nil);
      Exit;
    end;
{$endif}
  if DirHandler^.Stack^.Count = 0
    then Exit;
  P := DirHandler^.Stack^.Pop;
  SetNewStrByP(DirHandler^.SubDirName, P^.SubDirName);
  Owner^.Lock;
  if ReadCurrSubDir
    then FocusItem(P^.Item);
  Owner^.Unlock;
  DisposeObj(P);
end;

function TDirectoryBox.GetSubDirName: String;
begin
  GetSubDirName := DirHandler^.SubDirName^;
end;

procedure TDirectoryBox.WriteCurrSubDir;
begin
  GetDirPtr^.WriteSubDir(GetSubDirName, GetSubDir);
end;

function TDirectoryBox.ReadCurrSubDir: boolean;
begin
  ReadCurrSubDir := True;
  DisposeObj(DirHandler^.SubDir);
  DirHandler^.SubDir := GetDirPtr^.ReadSubDir(GetSubDirName);
  if not Assigned(DirHandler^.SubDir)
    then begin
      ReturnFromSubDir;
      ReadCurrSubDir := False;
    end;
  CheckFilesExist;
  ChangeRange;
end;

function TDirectoryBox.EditResource(Mode: byte): boolean;
var
  MemoData: TShortMemoData;
  ResName: TResIndex;
  Resource: PTextResource;
  Cmd: Word;
begin
  EditResource := False;
  if (CountItems = 0) and (Mode <> emLocalExt)
    then Exit;

  {!!! Временно }
  if (Mode = emParameters) and (GetFocusedItem^.GetItemType <> itFileItem)
    then Exit;

  MemoData.Length := 0;
  Resource := nil;

  Case Mode of
      emLocalExt: begin
                    ResName.Name := NewStr(tsLocalExtIndex);
                    ResName.Place := pfDirFile;
                    ResName.InhFlag := False;
                  end;
    emParameters: GetPIFIndex(GetFocusedItem, ResName);
  end;

  if GetStr(ResName.Name) <> ''
    then begin
      Resource := Pointer(GetDirPtr^.ReadObj(ResName.Name^));
      if Assigned(Resource)
        then MemoData.Length := Resource^.Length
      else MemoData.Length := 0;
      if MemoData.Length > 0
        then Move(Resource^.Text^, MemoData.Buffer, MemoData.Length);
      DisposeObj(Resource);
    end;

  Case Mode of
       emLocalExt: Cmd := Application^.ExecuteDialog(PDialog(New(PEditResDlg,
                                                    Init(Ph(phEditLocalExt),
                                                    hcEditLocalExtWin))),
                                               @MemoData);
     emParameters: Cmd := Application^.ExecuteDialog(PDialog(New(PEditResDlg,
                                                    Init(Ph(phEditParams),
                                                    hcEditParamListDlg))),
                                               @MemoData);
  end;
  if Cmd = cmCancel
    then begin
      DoneResIndex(ResName);
      Exit;
    end;

  EditResource := True;

  if Cmd = cmDelRes
    then begin
      if (not ResName.InhFlag) and (Assigned(ResName.Name))
        then GetDirPtr^.DelObj(ResName.Name^);
      DoneResIndex(ResName);
      ResName.Place := pfNowhere;
      ResName.InhFlag := False;
      Case Mode of
        emParameters: begin
                        SetPIFIndex(GetFocusedItem, ResName);
                        GetDirPtr^.UpdateHotKey(GetFocusedItem);
                      end;
      end;
    end;

  if Cmd = cmOk
    then begin
      New(Resource, Init(MemoData.Length, MemoData.Buffer));
      if not Assigned(ResName.Name)
        then begin
          ResName.Place := pfDirFile;
          ResName.InhFlag := False;
          Case Mode of
            emParameters: begin
                            ResName.Name := NewStr(GetDirPtr^.GetNewIndex(
                                                   tsParIndex, IndLen));
                            SetPIFIndex(GetFocusedItem, ResName);
                            GetDirPtr^.UpdateHotKey(GetFocusedItem);
                          end;
          end;
        end;
      GetDirPtr^.WriteObj(Resource, ResName.Name^);
      DoneResIndex(ResName);
      DisposeObj(Resource);
    end;
  GetDirPtr^.Flush;
end;

procedure TDirectoryBox.Annotate;
var
  R, ZoomRect: TRect;
  Num: Word;
  AnnW: PAnnWindow;
  EdWin: PAnnEdWindow;
  DirWind: PDirWindow;
  Cur: PView;
  MemoData: TShortMemoData;
  ResName: TResIndex;
  Resource: PTextResource;
  Cmd: Word;
begin
  if CountItems = 0 then Exit;

  Desktop^.Lock;  {!}
  Message(Application, evCommand, cmUnlockDesktop, nil);

  Cur := Desktop^.Current;
  AnnW := SearchAnnWindow;
  if not Assigned(AnnW)
    then begin
      Desktop^.GetExtent(R);
      R.A.X := R.B.X div 2;
      Application^.InsertWindow(New(PAnnWindow, Init(R)));
      AnnW := SearchAnnWindow;
    end;
  if not Assigned(AnnW) then Exit;

  MemoData.Length := 0;
  Resource := nil;
  GetAnnIndex(GetFocusedItem, ResName);
  if GetStr(ResName.Name) <> ''
    then begin
      Resource := Pointer(GetDirPtr^.ReadObj(ResName.Name^));
      if Assigned(Resource)
        then MemoData.Length := Resource^.Length
      else MemoData.Length := 0;
      if MemoData.Length > MaxTextResSize
        then begin
          DisposeObj(Resource);
          DoneResIndex(ResName);
          MessageBox(^C + Ph(phCantEditAnn), nil, mfError + mfOkButton,
                        hcCantEditAnn);
          Exit;
        end;
      if MemoData.Length > 0
        then Move(Resource^.Text^, MemoData.Buffer, MemoData.Length);
      DisposeObj(Resource);
    end;

  AnnW^.GetBounds(R);
  Num := AnnW^.Number;
  ZoomRect := AnnW^.ZoomRect;
  if Cur = PView(AnnW)
    then Cur := nil;

  Message(AnnW, evCommand, cmClose, nil);

  EdWin := New(PAnnEdWindow, Init(R, Num));
  EdWin^.ZoomRect := ZoomRect;
  EdWin^.SetData(MemoData);
  Cmd := Desktop^.ExecView(EdWin); { <------| }
  EdWin^.GetData(MemoData);
  EdWin^.GetBounds(R);
  ZoomRect := EdWin^.ZoomRect;
  DisposeObj(EdWin);

  Case Cmd of
    cmCancel: DoneResIndex(ResName);
    cmDelRes: begin
                if (not ResName.InhFlag) and (Assigned(ResName.Name))
                  then GetDirPtr^.DelObj(ResName.Name^);
                DoneResIndex(ResName);
                ResName.Place := pfNowhere;
                ResName.InhFlag := False;
                SetAnnIndex(GetFocusedItem, ResName);
                GetDirPtr^.UpdateHotKey(GetFocusedItem);
              end;
        cmOk: begin
                New(Resource, Init(MemoData.Length, MemoData.Buffer));
                if not Assigned(ResName.Name)
                  then begin
                    ResName.Place := pfDirFile;
                    ResName.InhFlag := False;
                    ResName.Name := NewStr(GetDirPtr^.GetNewIndex(
                                           tsAnnIndex, IndLen));
                    SetAnnIndex(GetFocusedItem, ResName);
                    GetDirPtr^.UpdateHotKey(GetFocusedItem);
                  end;
                GetDirPtr^.WriteObj(Resource, ResName.Name^);
                DoneResIndex(ResName);
                DisposeObj(Resource);
              end;
  end;

  Application^.InsertWindow(New(PAnnWindow, Init(R)));

  AnnW := SearchAnnWindow;
  AnnW^.Number := Num;
  AnnW^.ChangeBounds(R);
  AnnW^.ZoomRect := ZoomRect;

  if Assigned(Cur)
    then Cur^.Select;
  Desktop^.Redraw;
  Message(Application, evCommand, cmUnlockDesktop, nil);
  GetDirPtr^.Flush;
  ChangeAnn;
end;

procedure TDirectoryBox.EditParameters;
begin
  EditResource(emParameters);
end;

procedure TDirectoryBox.ComParameters;
var
  Params: String;
  ParInd: TResIndex;
begin
  ParInd.Place := pfNowhere;
  ParInd.Name := nil;
  ParInd.InhFlag := False;

  Params:= GetComParams;
  if Application^.ExecuteDialog(New(PParamsDlg,
                                    Init(wtComParams, '',
                                    GetDirPtr, ParInd, '')),
                                @Params) = cmOk
    then SetNewStr(DirHandler^.ComParams, Params);
end;

function TDirectoryBox.RootDirIsCurrent: boolean;
begin
  RootDirIsCurrent := GetSubDirName = tsRootDirIndex;
end;

function TDirectoryBox.InsBefore: Word;
begin
  InsBefore := cmNo;
  if (CountItems = 0) or not RootDirIsCurrent or (Focused > 0)
    then Exit;
  InsBefore := AskInsertBefore;
end;

procedure TDirectoryBox.AddFileItems;
var
  InsPos: Integer;
  OldCount: Integer;
begin
  if CountItems = 0
    then InsPos := 0
  else InsPos := Focused + 1;

  Case InsBefore of
       cmYes: Dec(InsPos);
    cmCancel: Exit;
  end;

  OldCount := CountItems;

  BaseApplication^.AppExecuteDialog(New(PAddFileItemsDlg,
                                    Init(wtAdd, InsPos)), nil);

  if OldCount <> CountItems
    then begin
      FocusItem(InsPos + CountItems - OldCount - 1);
      WriteCurrSubDir;
      GetDirPtr^.Flush;
    end;
end;

procedure TDirectoryBox.AddSubDirs;
var
  InsPos: Integer;
  OldCount: Integer;
begin
  if CountItems = 0
    then InsPos := 0
  else InsPos := Focused + 1;

  Case InsBefore of
       cmYes: Dec(InsPos);
    cmCancel: Exit;
  end;

  OldCount := CountItems;

  BaseApplication^.AppExecuteDialog(New(PAddSubDirsDlg,
                                        Init(wtAdd, InsPos)), nil);
  if OldCount <> CountItems
    then begin
      FocusItem(InsPos + CountItems - OldCount - 1);
      WriteCurrSubDir;
      GetDirPtr^.Flush;
    end;
end;

procedure TDirectoryBox.DeleteItems(DelFiles: boolean);
var
  CountDel: LongInt;
  PartII: String;
  Del_1: boolean;
  Mess: PProcMess;
begin
  CountDel := DirHandler^.CalcCountSelected;
  if CountDel = 0
    then begin
      GetSubDir^.SelectItem(Focused);
      Del_1 := True;
    end
  else Del_1 := False;
  CountDel := DirHandler^.CalcCountSelected;
  if CountDel = 0 then Exit;
  Case CountDel - (CountDel div 100) * 100 of
     1: PartII := Ph(phItems_1);
     21, 31, 41, 51,
         61, 71, 81, 91: PartII := Ph(phItems_2);
     2..4, 22..24, 32..34, 42..44, 52..54, 62..64, 72..74,
         82..84, 92..94: PartII := Ph(phItems_3);
    else PartII := Ph(phItems_4);
  end;
  if DelFiles
    then PartII := Copy(PartII, 1, Length(PartII) - 1) +
                   Ph(phWithFiles) + ' ?';
  if MessageBox(Ph(phAskDeleteItems) + ' ' + PartII, @CountDel,
                mfConfirmation + mfYesNoCancel, hcAskDeleteItems) <> cmYes
    then begin
      if Del_1 then GetSubDir^.UnselectItem(Focused);
      Exit;
    end;
  New(Mess, Init(Ph(phDeleting)));
  DirHandler^.DeleteItems(DelFiles);
  DisposeObj(Mess);
end;

procedure TDirectoryBox.DoMove(var Data: TSelSDData);
var
  i: Integer;
  P: PItem;
  SD: PSubDir;
begin
  SD := GetDirPtr^.ReadSubDir(Data.SubDirName);
  if not Assigned(SD)
    then begin
      MessageBox(^C + Ph(phErrorProcessDirFile), nil, mfError + mfOkButton,
                 hcErrorProcessDirFile);
      Exit;
    end;
  i := 0;
  while i < GetSubDir^.CountItems do
    if IsSelected(i)
      then begin
        Inc(Data.Item);
        P := GetItem(i);
        P^.Unselect;
        GetSubDir^.DeleteItemWithoutDispose(i);
        SD^.InsertItem(Data.Item, P);
      end
    else Inc(i);
  GetDirPtr^.WriteSubDir(GetSubDirName, GetSubDir);
  GetDirPtr^.WriteSubDir(Data.SubDirName, SD);
  GetDirPtr^.Flush;
  DisposeObj(SD);
end;

procedure TDirectoryBox.DoReplace(Item: Integer);
var
  i, InsAfterNum, CountReplaced: Integer;
  InsAfterItem, P: PItem;
  InsertInBeg: boolean;
begin
  InsAfterItem := nil;
  InsertInBeg := Item = -1;
  if not InsertInBeg
    then begin
      InsAfterItem := GetItem(Item);
      InsAfterNum := GetSubDir^.IndexOf(InsAfterItem);
      while IsSelected(InsAfterNum) and (InsAfterNum > 0)
        do Dec(InsAfterNum);
      InsertInBeg := (InsAfterNum = 0) and IsSelected(0);
    end
  else InsAfterNum := 0;
  CountReplaced := 0;
  i := 0;
  while i < GetSubDir^.CountItems do
    if IsSelected(i)
      then begin
        P := GetItem(i);
        P^.Unselect;
        Inc(CountReplaced);
        if (i = InsAfterNum + 1) and not InsertInBeg
          then begin
            InsAfterItem := P;
            Continue;
          end;
        GetSubDir^.DeleteItemWithoutDispose(i);
        InsAfterNum := GetSubDir^.IndexOf(InsAfterItem);
        if InsertInBeg
          then GetSubDir^.InsertItem(CountReplaced - 1, P)
        else GetSubDir^.InsertItem(InsAfterNum + 1, P);
        InsAfterItem := P;
        i := 0;
      end
    else Inc(i);
  GetDirPtr^.WriteSubDir(GetSubDirName, GetSubDir);
  GetDirPtr^.Flush;
end;

procedure TDirectoryBox.FillProhSD(var ProhSubDirNames: PStringCollection);
var
  i: Integer;
  P: PItem;
begin
  New(ProhSubDirNames, Init(10, 10));
  for i := 0 to Range - 1 do
  begin
    P := GetItem(i);
    if IsSelected(i) and (P^.GetItemType = itSubDirItem)
      then ProhSubDirNames^.Insert(NewStr(PSubDirItem(P)^.GetSubDirName));
  end;
end;

procedure TDirectoryBox.MoveItems;
var
  CountMove: LongInt;
  Mess: PProcMess;
  ProhSubDirNames: PStringCollection;
  Move_1: boolean;
  Data: TSelSDData;

begin
  CountMove := DirHandler^.CalcCountSelected;
  Move_1 := False;
  if CountMove = 0
    then begin
      GetSubDir^.SelectItem(Focused);
      Move_1 := True;
    end
  else Move_1 := False;
  CountMove := DirHandler^.CalcCountSelected;
  if CountMove = 0 then Exit;

  FillProhSD(ProhSubDirNames);

  if Application^.ExecuteDialog(New(PSelectSubDirDlg,
                                    Init(Ph(phMoveItems),
                                         hcMoveItemsDlg,
                                         GetDirPtr, DirHandler^.Stack,
                                         GetSubDirName, Focused,
                                         ProhSubDirNames, False)),
                                @Data) = cmCancel
    then begin
      if Move_1 then GetSubDir^.UnselectItem(Focused);
      Exit;
    end;

  if (Data.SubDirName = tsRootDirIndex) and (Data.Item = 0)
    then begin
      Case AskInsertBefore of
         cmCancel: begin
                     if Move_1 then GetSubDir^.UnselectItem(Focused);
                     Exit;
                   end;
            cmYes: Dec(Data.Item);
      end;
    end;

  if Data.SubDirName = GetSubDirName
    then begin
      DoReplace(Data.Item);
      if Move_1 then GetSubDir^.UnselectItem(Focused);
      Exit;
    end;

  New(Mess, Init(Ph(phMoving)));
  DoMove(Data);
  if Move_1 then GetSubDir^.UnselectItem(Focused);
  DisposeObj(Mess);
  ReadCurrSubDir;
end;

function TDirectoryBox.CheckProhSD: boolean;
var
  ProhSD: PStringCollection;
  TargetDirWin: PDirWindow;
  NoSelected: boolean;

function IsProhSD(P: PString): boolean; far;

function IsInStack(PI: PPathItem): boolean; far;
begin
  IsInStack := GetStr(PI^.SubDirName) = GetStr(P);
end;

begin
  IsProhSD :=
    (TargetDirWin^.GetDirHandler^.Stack^.LastThat(@IsInStack) <> nil)
    or (GetStr(TargetDirWin^.GetDirHandler^.SubDirName) = GetStr(P));
end; { of IsProhSD }

begin
  CheckProhSD := True;
  NoSelected := DirHandler^.CalcCountSelected = 0;
  if NoSelected then GetSubDir^.SelectItem(Focused);
  FillProhSD(ProhSD);
  if NoSelected then GetSubDir^.UnselectItem(Focused);
  TargetDirWin := SearchTarget;
  if not Assigned(TargetDirWin) then Exit;
  CheckProhSD := ProhSD^.FirstThat(@IsProhSD) <> nil;
  DisposeObj(ProhSD);
end; { of CheckProhSD }

function TDirectoryBox.CheckCopy2Itself: boolean;
var
  P: PDirectory;
begin
  CheckCopy2Itself := False;
  P := SearchTarget^.GetDirPtr;
  if P <> GetDirPtr then Exit;
  if not CheckProhSD then Exit;
  CheckCopy2Itself := True;
  MessageBox(Ph(phCantCopy2Itself), nil, mfError + mfOkButton,
             hcCantCopy2Itself);
end;

function TDirectoryBox.DoCopy: boolean;
var
  TargetDirWindow: PDirWindow;
  TargetDir: PDirectory;
  TargetSubDir: PSubDir;
  i, Item: Integer;
  P: PProcMess;

procedure NewResource(var Index: TResIndex; FirstPart: String);
var
  Resource: PTextResource;
begin
  if not Assigned(Index.Name) then Exit;
  Resource := PTextResource(GetDirPtr^.ReadObj(GetStr(Index.Name)));
  DispStr(Index.Name);
  if not Assigned(Resource) then Exit;
  SetNewStr(Index.Name, TargetDir^.GetNewIndex(FirstPart, IndLen));
  TargetDir^.WriteObj(Resource, GetStr(Index.Name));
  DisposeObj(Resource);
end;

function CopyItem(P: PItem; SD: PSubDir; Item: Integer): boolean; forward;

function CopySubDir(P: PItem; TargetSD: PSubDir; Item: Integer): boolean;
var
  SourceSD, NewSD: PSubDir;
  NewSDItem: PSubDirItem;
  SDName, ItemsIndex, SDIndex: String;
  i, CurrItem: Integer;
  Data: TSubDirData;
  OldItem: PItem;
begin
  CopySubDir := False;
  Message(Application, evCommand, cmUpdateGadgets, nil);

  SDName := PSubDirItem(P)^.GetSubDirName;
  if Stack^.GetSDPos(SDName) > -1
    then Exit;

  SourceSD := GetDirPtr^.ReadSubDir(SDName);
  SourceSD^.GetData(Data);

  NewResource(Data.AnnIndex, tsAnnIndex);
  NewResource(Data.PIFIndex, tsParIndex);

  Stack^.Insert(New(PPathItem, Init(SDName, 0)));

  ItemsIndex := TargetDir^.GetNewIndex(tsItemsIndex, IndLen);
  NewSD := CreateEmptySubDir(ItemsIndex,
                             Data.StartDir, Data.RndNameTpl,
                             Data.Attributes, Data.Inheritance,
                             Data.AnnIndex, Data.PIFIndex);
  TargetDir^.WriteObj(nil, ItemsIndex);
  SDIndex := TargetDir^.GetNewIndex(tsSubDirIndex, IndLen);
  TargetDir^.WriteObj(nil, SDIndex);

  New(NewSDItem, Init(P^.GetTitle, SDIndex));
  TargetSD^.InsertItem(Item, NewSDItem);

  CurrItem := 1;
  for i := 0 to SourceSD^.CountItems - 1 do
  begin
    OldItem := SourceSD^.GetItem(i);
    if CopyItem(OldItem, NewSD, CurrItem)
      then Inc(CurrItem);
  end;
  TargetDir^.WriteSubDir(SDIndex, NewSD);
  DisposeObj(SourceSD);
  DisposeObj(NewSD);
  Stack^.DelTop;
  Data.Done;
  CopySubDir := True;
end;

function CopyItem(P: PItem; SD: PSubDir; Item: Integer): boolean;
var
  NewItem: PItem;
  FIData: TFileItemData;

procedure NewHotKey(P: PItem; Key: Char);
var
  HK: PItem;
begin
  HK := SearchHotKey(TargetDir^, Key);
  if (Key <> #0) and (HK = nil)
    then begin
      StoreHotKey(TargetDir^, Key, P);
      P^.SetHotKey(Key);
    end;
  DisposeObj(HK);
end;

begin  { of CopyItem }
  CopyItem := False;
  if P^.GetItemType = itSubDirItem
    then begin
      CopyItem := CopySubDir(P, SD, Item);
      Exit;
    end;
  if P^.GetItemType <> itFileItem then Exit;

  PFileItem(P)^.GetData(FIData);
  NewResource(FIData.AnnIndex, tsAnnIndex);
  NewResource(FIData.PIFIndex, tsParIndex);
  with FIData do
    NewItem := New(PFileItem, Init(
      GetStr(Title), GetStr(FileName), GetStr(DiskLabel), StartDir,
      Parameters, Attributes, Inheritance, AnnIndex, PIFIndex));
  FIData.Done;
  NewHotKey(NewItem, P^.GetHotKey);
  SD^.InsertItem(Item, NewItem);
  CopyItem := True;
end;

begin  { of DoCopy }
  DoCopy := False;
  if LowMemory
    then begin
      Application^.OutOfMemory;
      Exit;
    end;
  TargetDirWindow := SearchTarget;
  if not Assigned(TargetDirWindow) then Exit;

  TargetDir := TargetDirWindow^.GetDirPtr;
  TargetSubDir := TargetDirWindow^.GetSubDir;
  Item := TargetDirWindow^.DirectoryBox^.Focused + 1;

  Case TargetDirWindow^.DirectoryBox^.InsBefore of
    cmCancel: Exit;
       cmYes: Dec(Item);
  end;

  if TargetDirWindow^.DirectoryBox^.CountItems = 0
    then Item := 0;

  New(P, Init(Ph(phCopying)));
  New(Stack, Init(10, 10));

  i := 0;
  while i < CountItems do
  begin
    if IsSelected(i)
      then begin
        CopyItem(GetItem(i), TargetSubDir, Item);
        if (PGroup(TargetDirWindow) = Owner) and (i >= Item)
          then Inc(i);
        Inc(Item);
      end;
    Inc(i);
  end;

  TargetDir^.WriteSubDir(GetStr(TargetDirWindow^.GetDirHandler^.SubDirName),
                         TargetSubDir);
  TargetDirWindow^.Lock;
  TargetDir^.Flush;
  TargetDirWindow^.DirectoryBox^.FocusItem(Item - 1);
  TargetDirWindow^.Unlock;
  DisposeObj(Stack);
  DisposeObj(P);
  DoCopy := True;
end;

procedure TDirectoryBox.Move2AnotherDir;
var
  P: PProcMess;
begin
  if DoCopy
    then begin
      New(P, Init(Ph(phDeleting)));
      DirHandler^.DeleteItems(False);
      DisposeObj(P);
    end;
end;

procedure TDirectoryBox.Cut2Target;
var
  TargetDirWin: PDirWindow;
  D: PDirectory;
  NoSelected: boolean;

procedure MoveInOneDir;
var
  Data: TSelSDData;
  CountMoved: Integer;
begin
  Data.SubDirName := TargetDirWin^.DirectoryBox^.GetSubDirName;
  Data.Item := TargetDirWin^.DirectoryBox^.Focused;
  CountMoved := DirHandler^.CalcCountSelected;
  if CountMoved = 0 then Inc(CountMoved);
  Case TargetDirWin^.DirectoryBox^.InsBefore of
    cmCancel: Exit;
       cmYes: Dec(Data.Item);
  end;
  TargetDirWin^.Lock;
  if TargetDirWin^.DirectoryBox^.GetSubDirName = GetSubDirName
    then DoReplace(Data.Item)
  else DoMove(Data);
  if TargetDirWin^.DirectoryBox^.GetSubDirName <> GetSubDirName
    then TargetDirWin^.DirectoryBox^.FocusItem(Data.Item)  {Data.Item уже изменен}
  else TargetDirWin^.DirectoryBox^.FocusItem(Data.Item + CountMoved);
  TargetDirWin^.Unlock;
end;

begin
  if not TargetPresent then Exit;
  if CheckCopy2Itself then Exit;
  TargetDirWin := SearchTarget;
  D := TargetDirWin^.GetDirPtr;
  NoSelected := DirHandler^.CalcCountSelected = 0;
  if NoSelected then GetSubDir^.SelectItem(Focused);
  if D = GetDirPtr
    then MoveInOneDir
  else Move2AnotherDir;
  if NoSelected then GetSubDir^.UnselectItem(Focused);
  GetDirPtr^.Flush;
end;

procedure TDirectoryBox.Copy2Target;
var
  NoSelected: boolean;
begin
  if not TargetPresent then Exit;
  if CheckCopy2Itself then Exit;
  NoSelected := DirHandler^.CalcCountSelected = 0;
  if NoSelected then GetSubDir^.SelectItem(Focused);
  Owner^.Lock;
  if DoCopy
    then UnselectAll;
  Owner^.Unlock;
  if NoSelected then GetSubDir^.UnselectItem(Focused);
end;

procedure TDirectoryBox.ModifyItems;
var
  Repl_1: boolean;
begin
  if DirHandler^.CalcCountSelected = 0
    then begin
      GetSubDir^.SelectItem(Focused);
      Repl_1 := True;
    end
  else Repl_1 := False;
  if DirHandler^.CalcCountSelected = 0
    then Exit;

  if (DirHandler^.GetFirstSelItem(itSubDirItem) = -1)
    or (BaseApplication^.AppExecuteDialog(New(PAddSubDirsDlg,
                                             Init(wtReplace, 0)), nil)
        <> cmCancel)
  then BaseApplication^.AppExecuteDialog(New(PAddFileItemsDlg,
                                             Init(wtReplace, 0)), nil);

  if Repl_1 then GetSubDir^.UnselectItem(Focused);
  WriteCurrSubDir;
  GetDirPtr^.Flush;
end;

procedure TDirectoryBox.GetAnnIndex(P: PItem; var Index: TResIndex);
var
  SubDir: PSubDir;
begin
  Index.Name := nil;
  DoneResIndex(Index);
  if not Assigned(P) then Exit;
  Case P^.GetItemType of
       itFileItem: P^.GetAnnIndex(Index);
     itSubDirItem: begin
                     SubDir := PSubDir(GetDirPtr^.ReadObj(
                                       PSubDirItem(P)^.GetSubDirName));
                     SubDir^.GetAnnIndex(Index);
                     DisposeObj(SubDir);
                   end;
      itUpDirItem: GetSubDir^.GetAnnIndex(Index);
  end;
end;

procedure TDirectoryBox.SetAnnIndex(P: PItem; var Index: TResIndex);
var
  SubDir: PSubDir;
begin
  Case P^.GetItemType of
       itFileItem: begin
                     P^.SetAnnIndex(Index);
                     WriteCurrSubDir;
                   end;
     itSubDirItem: begin
                     SubDir := PSubDir(GetDirPtr^.ReadObj(
                                       PSubDirItem(P)^.GetSubDirName));
                     if Assigned(SubDir)
                       then begin
                         SubDir^.SetAnnIndex(Index);
                         GetDirPtr^.WriteObj(SubDir,
                                  PSubDirItem(P)^.GetSubDirName);
                         DisposeObj(SubDir);
                       end;
                   end;
      itUpDirItem: begin
                     GetSubDir^.SetAnnIndex(Index);
                     GetDirPtr^.WriteObj(GetSubDir, GetSubDirName);
                   end;
  end;
end;

procedure TDirectoryBox.GetPIFIndex(P: PItem; var Index: TResIndex);
var
  SubDir: PSubDir;
begin
  Index.Name := nil;
  DoneResIndex(Index);
  if not Assigned(P) then Exit;
  Case P^.GetItemType of
       itFileItem: P^.GetPIFIndex(Index);
{
     itSubDirItem: begin
                     SubDir := PSubDir(GetDirPtr^.ReadObj(
                                       PSubDirItem(P)^.GetSubDirName));
                     SubDir^.GetPIFIndex(Index);
                     DisposeObj(SubDir);
                   end;
      itUpDirItem: GetSubDir^.GetPIFIndex(Index);
}
  end;
end;

procedure TDirectoryBox.SetPIFIndex(P: PItem; var Index: TResIndex);
var
  SubDir: PSubDir;
begin
  Case P^.GetItemType of
       itFileItem: begin
                     P^.SetPIFIndex(Index);
                     WriteCurrSubDir;
                   end;
{
     itSubDirItem: begin
                     SubDir := PSubDir(GetDirPtr^.ReadObj(
                                       PSubDirItem(P)^.GetSubDirName));
                     if Assigned(SubDir)
                       then begin
                         SubDir^.SetPIFIndex(Index);
                         GetDirPtr^.WriteObj(SubDir,
                                  PSubDirItem(P)^.GetSubDirName);
                         DisposeObj(SubDir);
                       end;
                   end;
      itUpDirItem: begin
                     GetSubDir^.SetPIFIndex(Index);
                     GetDirPtr^.WriteObj(GetSubDir, GetSubDirName);
                   end;
}
  end;
end;

function TDirectoryBox.GetComParams: String;
begin
  GetComParams := GetStr(DirHandler^.ComParams);
end;

procedure TDirectoryBox.SetProtect;
var
  PW: String;
  PWInfo: TPWInfo;
begin
  if not DirHandler^.Protected
    then begin
      if MessageBox(^M^C + Ph(phAskSetProtect), nil,
                    mfYesNoCancel + mfConfirmation, hcAskSetProtect)
         <> cmYes then Exit;
      PW := #0;
      Message(Application, evCommand, cmBellRequest, Pointer(3));
      PDirWindow(Owner)^.MakeNonTarget;
    end
  else PW := CheckPassword(GetDirPtr^.GetPassword);
  PWInfo.Dir := GetDirPtr;
  PWInfo.PW := CryptStr(PW);
  Message(Desktop, evBroadcast, cmSetPasswords, @PWInfo);
end;

procedure TDirectoryBox.UnselectAll;
var
  i: Integer;
begin
  for i := 0 to CountItems - 1 do
    GetSubDir^.UnselectItem(i);
  Owner^.Redraw;
end;

procedure TDirectoryBox.ChangeConfig;
var
  PW: String;
  PWInfo: TPWInfo;
  CD: record
        ConfData: TDirConfData;
        RndFNTpl: FNameStr;
        StartDir: DirStr;
      end;
begin
  GetDirPtr^.GetConfig(CD.ConfData);
  CD.StartDir := GetDirPtr^.GetStartDir(True); { для редактирования }
  CD.RndFNTpl := GetDirPtr^.GetRndNameTpl;
  if Application^.ExecuteDialog(New(PDirConfDialog,
                                    Init(GetStr(DirHandler^.DirFileName))),
                                @CD)
     = cmCancel
  then Exit;
  GetDirPtr^.SetStartDir(CD.StartDir);
  GetDirPtr^.SetRndNameTpl(CD.RndFNTpl);
  GetDirPtr^.SetConfig(CD.ConfData);   { выполняет Flush }
  PWInfo.Dir := GetDirPtr;
  PWInfo.PW := GetDirPtr^.GetPassword;
  Message(Desktop, evBroadcast, cmSetPasswords, @PWInfo);
end;

procedure TDirectoryBox.SetHotKey;
var
  Key: Char;
  OldKey: Char;
begin
  if (Range = 0) or (GetFocusedItem^.GetItemType = itUpDirItem)
    then Exit;
  Key := GetFocusedItem^.GetHotKey;
  OldKey := Key;
  Case Application^.ExecuteDialog(New(PSetHotKeyDlg, Init), @Key) of
        cmOk: if OldKey <> Key
                then begin
                  if (Key <> #0)
                     and not StoreHotKey(GetDirPtr^, Key, GetFocusedItem)
                    then Exit;
                  ResetHotKey(GetDirPtr^, OldKey);
                  GetFocusedItem^.SetHotKey(Key);
                end;
     cmDelHK: begin
                ResetHotKey(GetDirPtr^, GetFocusedItem^.GetHotKey);
                GetFocusedItem^.SetHotKey(#0);
              end;
  else
    Exit;
  end;
  WriteCurrSubDir;
  GetDirPtr^.Flush;
end;

function TDirectoryBox.HotKey(Key: Char): boolean;
var
  P: PItem;
  Action: TAction;
  ShiftWasDown: boolean;
  Dir: PDirectory;
begin
  HotKey := False;
  ShiftWasDown := ShiftDown;
  if not (Key in HotKeysSet) then Exit;
  P := SearchHotKey(GetDirPtr^, Key);
  if not Assigned(P) then Exit;
  if ShiftWasDown
    then P^.GetAction(kbCtrlEnter, Action)
  else P^.GetAction(kbEnter, Action);
  DoAction(Action);
  DisposeObj(P);
  HotKey := True;
end;

function TDirectoryBox.MayEditFocused: boolean;
var
  P: PFileItem;
  FileName: FNameStr;
begin
  MayEditFocused := False;
  P := PFileItem(GetFocusedItem);
  if not Assigned(P) or (P^.GetItemType <> itFileItem)
    then Exit;
  FileName := FullTrim(P^.GetFileName);
  if (FileName = '') or (IsExeFile(FileName) and not IsBatFile(FileName))
    then Exit;
  MayEditFocused := True;
end;

procedure TDirectoryBox.EditFile;
var
  FileName: FNameStr;
begin
  if not MayEditFocused then Exit;
  FileName := PFileItem(GetFocusedItem)^.GetFileName;
  FileName := AddPath(FileName, GetStartDir);

  if (FileName = '') or (IsExeFile(FileName) and not IsBatFile(FileName))
    then Exit;
  Message(Application, evCommand, cmOpenIntEditor, @FileName);
end;

procedure TDirectoryBox.ChangeAnn;
var
  AnnIndex: TResIndex;
  AnnName: String;
begin
  AnnIndex.Name := nil;
  if Range = 0
    then begin
      Message(Desktop, evBroadcast, cmNewAnn, nil);
      Exit;
    end;

  GetAnnIndex(GetFocusedItem, AnnIndex);
  AnnName := GetStr(AnnIndex.Name);

  Message(Desktop, evBroadcast, cmNewAnn, @AnnName);
  DoneResIndex(AnnIndex);
end;

procedure TDirectoryBox.CollectDocument;
begin
  MakeDocument(Self);
end;

procedure TDirectoryBox.EditLocalExt;
begin
  EditResource(emLocalExt);
end;

procedure TDirectoryBox.Transpose;
begin
  if (Range = 0) or (GetFocusedItem^.GetItemType = itUpDirItem)
    or (DirHandler^.Protected)
  then Exit;

  if GetFocusedItem^.GetItemType = itSubDirItem
    then TurnSD
  else if GetFocusedItem^.GetItemType = itFileItem
    then TurnFile;
end;

procedure TDirectoryBox.TurnFile;
var
  Data: TFileItemData;
  Answer: Word;
  AnnIndex, PIFIndex: TResIndex;
  StartDir, Parameters: TInhString;
  SD: PSubDirItem;
  SubDirIndex: String;
begin
  PFileItem(GetFocusedItem)^.GetData(Data);
  if FullTrim(GetStr(Data.FileName)) <> ''
    then Answer := MessageBox(^C + Ph(phAskTransposeFile),
                  nil, mfConfirmation + mfYesNoCancel, hcAskTransposeFile)
  else Answer := cmYes;

  if Answer = cmYes
    then begin
      ResetHotKey(GetDirPtr^, GetFocusedItem^.GetHotKey);
      AnnIndex.Place := pfDirFile;
      AnnIndex.Name := nil;
      SetNewStrByP(AnnIndex.Name, Data.AnnIndex.Name);
      AnnIndex.InhFlag := False;
      PIFIndex.Place := pfNowhere;
      PIFIndex.Name := nil;
      PIFIndex.InhFlag := False;
      Parameters.Str := nil;
      Parameters.InhFlag:= False;
      StartDir.Str := nil;
      SetNewStrByP(StartDir.Str, Data.StartDir.Str);
      StartDir.InhFlag := False;

      SubDirIndex := GetDirPtr^.CreateNewSubDir(StartDir, Parameters,
                           {Attributes}0, {Inheritance}0,
                           AnnIndex, PIFIndex);

      DispStr(AnnIndex.Name);
      DispStr(StartDir.Str);

      New(SD, Init(GetStr(Data.Title), SubDirIndex));

      GetSubDir^.DeleteItem(Focused);
      GetDirPtr^.DelObj(GetStr(Data.PIFIndex.Name));
      GetSubDir^.InsertItem(Focused, SD);
      PDirWindow(Desktop^.Current)^.DirectoryBox^.ChangeRange;
      WriteCurrSubDir;
      GetDirPtr^.Flush;
    end;

  Data.Done;
end;

procedure TDirectoryBox.TurnSD;
var
  Data: TSubDirItemData;
  Answer: Word;
  AnnIndex, PIFIndex: TResIndex;
  StartDir, Parameters: TInhString;
  SD: PSubDir;
  P: PFileItem;
  SubDirIndex: String;
  Title: String;
  FileName: FNameStr;
  DiskLabel: String[11];
  Attributes, Inheritance: Word;
begin
  PSubDirItem(GetFocusedItem)^.GetData(Data);
  SD := GetDirPtr^.ReadSubDir(Data.SubDirName^);
  if SD^.CountItems > 1
    then begin
      MessageBox(^C + Ph(phCantTranspFullDir),
                 nil, mfWarning + mfOkButton, hcCantTranspFullDir);
      DisposeObj(SD);
      Data.Done;
      Exit;
    end;
  DisposeObj(SD);

  Title := GetStr(Data.Title);

  FileName := '';
  Parameters.Str := nil;
  Parameters.InhFlag := False;
  StartDir.Str := nil;
  StartDir.InhFlag := False;
  DiskLabel := '';
  Attributes := iaRestCD + iaSearchBeforeProcess;
  Inheritance := 0;
  DirHandler^.GetAnnIndex(GetFocusedItem, AnnIndex);
  PIFIndex.Place := pfNowhere;
  PIFIndex.Name := nil;
  PIFIndex.InhFlag := False;

  New(P, Init(Title, FileName, DiskLabel, StartDir, Parameters,
      Attributes, Inheritance, AnnIndex, PIFIndex));

  GetSubDir^.DeleteItem(Focused);
  GetSubDir^.InsertItem(Focused, P);
  PDirWindow(Desktop^.Current)^.DirectoryBox^.ChangeRange;
  GetDirPtr^.RemoveSubDir(Data.SubDirName^, False); { Don't del annotation }
  WriteCurrSubDir;
  GetDirPtr^.Flush;

  Data.Done;
  DispStr(Parameters.Str);
  DoneResIndex(AnnIndex);
  DoneResIndex(PIFIndex);
  DispStr(StartDir.Str);
end;

procedure TDirectoryBox.InsertReference;
var
  Data: TSelSDData;
  s: String;
  P: PItem;
  SD: PSubDir;
begin
  if Application^.ExecuteDialog(New(PSelectSubDirDlg,
                                    Init(Ph(phInsRef),
                                         hcInsRefDlg,
                                         GetDirPtr, DirHandler^.Stack,
                                         GetSubDirName, Focused,
                                         nil, False)),
                                @Data) = cmCancel
  then Exit;

  SD := GetDirPtr^.ReadSubDir(Data.SubDirName);
  if not Assigned(SD)
    then begin
      MessageBox(^C + Ph(phErrorProcessDirFile), nil, mfError + mfOkButton,
                 hcErrorProcessDirFile);
      Exit;
    end;
  s := GetItemName(SD^.GetItem(Data.Item), DirHandler);
  DisposeObj(SD);
  if FullTrim(s) = ''
    then begin
      MessageBox(^C + Ph(phItemHasntName), nil, mfInformation + mfOkButton,
                 hcItemHasntName);
      Exit;
    end;
  s := '[  ]:' + s + ' ';
  PEditWindow(Desktop^.Current)^.Editor^.InsertText(@s[1], Length(s), False);
end;

function TDirectoryBox.GetStartDir: PathStr;
begin
  GetStartDir := GetDirPtr^.GetStartDir(False);  { не для редактирования }
end;

function TDirectoryBox.GetRndNameTpl: FNameStr;
var
  SD: PSubDir;
  i: Integer;
  s: FNameStr;
begin
  for i := DirHandler^.Stack^.Count downto 0 do
  begin
    if i = DirHandler^.Stack^.Count
      then s := GetSubDir^.GetRndNameTpl
    else begin
      SD := GetDirPtr^.ReadSubDir(GetStr(
                        PPathItem(DirHandler^.Stack^.At(i))^.SubDirName));
      if not Assigned(SD) then Continue;
      s := SD^.GetRndNameTpl;
      DisposeObj(SD);
    end;
    GetRndNameTpl := s;
    if s <> '' then Exit;
  end;
  GetRndNameTpl := GetDirPtr^.GetRndNameTpl;
end;

function TDirectoryBox.CreateBatch4Group(FileName: FNameStr;
                                         Cmd: ComStr): boolean;
var
  Count: Integer;
begin
  Count := DirHandler^.CalcCountSelected;
  if Count = 0
    then GetSubDir^.SelectItem(Focused);
  Count := DirHandler^.CalcCountSelected;
  if Count = 0 then Exit;
  CreateBatch4Group := DirHandler^.CreateBatch4Group(FileName, Cmd);
  UnselectAll;
end;

procedure TDirectoryBox.CreateBatch;
var
  Cmd: String;
  DelayScreen: boolean;
  RestCD: boolean;
  ClearKbd: boolean;
  Action: TAction;
  ExecInfo: PExecInfo;
begin
  Cmd := '';
  Action.Init(afDoMenuByExt, NewExecInfo(
                   '', #0'.'#0, '', '', '512', '', nil, false, False, True));
  GetDirPtr^.DoMenuByExt(Action);
  Cmd := PExecInfo(Action.InfoPtr)^.ProgName;
  Action.Done;
  if (FullTrim(Cmd) = '') or (Cmd = #0'.'#0) then Exit;
  if not CreateBatch4Group('$$$.BAT', Cmd)
    then Exit;
  ExecInfo := NewExecInfo('', '$$$.BAT', '', '',
                          '512', '', GetDirPtr,
                          False, False, True);
  Message(Application, evCommand, cmSetDelProgFlag, nil);
  Message(Application, evCommand, cmExecuteCmd, ExecInfo);
  Dispose(ExecInfo);
end;

(***** ^ ^ ^ ******* Методы объекта TDirectoryBox ****** ^ ^ ^ ******)

constructor TDirWinIndicator.Init(var Bounds: TRect);
begin
  inherited Init(Bounds);
  GrowMode := gfGrowLoY + gfGrowHiY;
end;

procedure TDirWinIndicator.Draw;
var
  Color: Byte;
  Ch: Char;
begin
  Ch := tsTargetDirChar;
  WriteChar(0, 0, Ch, 2, 1);
end;

function TDirWinIndicator.GetPalette: PPalette;
const
  P: string[Length(CDirWinIndicator)] = CDirWinIndicator;
begin
  GetPalette := @P;
end;

function FirstDirWindow: PDirWindow;
begin
  FirstDirWindow := Message(Desktop, evBroadcast, cmSearchFirstDirW, nil);
end;

function SearchTarget: PDirWindow;
begin
  SearchTarget := Message(Desktop, evBroadcast, cmSearchTarget, nil);
end;

function TargetPresent: boolean;
begin
  TargetPresent := True;
  if SearchTarget <> nil
    then Exit;
  TargetPresent := False;
  MessageBox(Ph(phTargetIsntSpecified), nil, mfInformation + mfOkButton,
             hcTargetIsntSpecified);
end;

function AskInsertBefore: Word;
begin
  AskInsertBefore := MessageBox(^C + Ph(phAskInsertBefore), nil,
                     mfYesNoCancel + mfConfirmation, hcAskInsertBefore);
end;

end.

