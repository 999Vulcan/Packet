(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PMApp                                           *)
(* Объект TPMApp (программа PackMain)                     *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 21.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

Unit PMApp;

{$L smouse.obj}

interface

uses
  Objects, Drivers, Memory, HeapFunc, Views, Menus, Dialogs, App, AppMac,
{$ifdef DPMI}
  WinAPI,
{$endif}
  BaseApp, MyMsgBox, StdDlg, HistList, Language, PackLng, ProcMess, {WinClip,}
  PackText, PackLink, PackConf, Conf_Var, Pack_Hlp, Dos, Crt, RunDlg,
  FileOps, Editors, Hist_Ind, StreamID, Conf_Dlg, PackStLn, Dir_Wind,
  PackMenu, Win_List, Line_Num, Edit_Dlg, Gadgets, MyColSel, Pack_CS,
  MyMouDlg, MyCalend, MyAscii, MyCalc, User_Scr, HelpFile, Err_Exit,
  Pack_Cmd, Pack_Dlg, Enc_Stm, Blink, Disp_Obj, StrServ, Dirs, SubDirs,
  Items, DirConf, Ann_Wind, SysError, PathStk, ShtState, HotKeys, HKDlg,
  LocMenus, TempFlag, CheckPW, RepMChrs, AlarmDlg, Alarm, EditServ, MakeDoc,
  Registr, Ext_Serv, WinCheck, Outp_Win, StrStack, DskStack, Crypt, DrvTypes;

const

  DskSignStrOld = 'Packet''s 3.0 (beta-1) Desktop File'#26;
  DskSignStr    = '--= Packet''s 3.31 Desktop File =--'#26;
  DskSignatureLen = Length(DskSignStr);
  DskSignature: String[DskSignatureLen] = DskSignStr;
  DskSignatureOld: String[DskSignatureLen] = DskSignStrOld;

  PalSignStr = 'Packet''s 3.0 (alpha-1) Palette File'#26;
  PalSignatureLen = Length(PalSignStr);
  PalSignature: String[PalSignatureLen] = PalSignStr;

  { Маски для InitStatus }
  isReadLngFile   = 1;
  isReadLngExe    = 2;
  isInitOvr       = 4;
  isRunFromPacket = 8;

  { Константы режимов работы метода RetrieveConfig }
  roReadConfig   = 1;
  roRetrieveOpt  = 2;

  { Константы типов окон }
  wtEditWindow   = 1;
  wtDirWindow    = 2;

type

  PPMApp = ^TPMApp;
  TPMApp = object(TMacApplication)

    private

    CryptedNum: real;
    IsRegCopy: boolean;
    SmoothMouse: boolean;
    PackDir: DirStr;
    LinkBlock: PLinkBlock;
    BellRequest: byte;
    Title: PTitleView;
    Clock: PClockView;
    MacroInd: PNameView;
    HeapViewer: PHeapView;
    ProtWord: Word;
    ClosedFiles: PClosedFilesColl; { Позиции курсора в закрытых файлах }
    ReloadFlag: boolean;    { Признак необходимости перезагрузки }
    UnlockDesktop: boolean; { Признак необходимости разблокировать Desktop }
    CloseWin: boolean;      { Признак необходимости закрыть окно }
    InitWorks: boolean;     { Признак того, что работает метод TPMApp.Init }
    DskStack: PStrStack;    { Стек состояний }
    AltPressed: boolean;    { Признак "нажат Alt" }
    CancelAlt: boolean;     { Признак "Alt отменить" }
    { Имя файла состояния, который необходимо прочитать или '' }
    LoadDskName: FNameStr;
    NeedUpdateCFMenu: boolean; { Необходимо обновить список закрытых файлов }

    public

    constructor Init;
    destructor Done; virtual;

    private

    procedure CheckBellRequest;
    procedure Bell;
    procedure GetEvent(var Event: TEvent); virtual;
    procedure RegisterTypes;
    procedure RegisterDirectories;
    function CheckRunFromPacket: boolean;
    procedure DeleteGadgets;
    procedure SetGadgets;
    procedure UpdateGadgets;
    procedure SetMouse;
    procedure InitMenuBar; virtual;
    procedure InitStatusLine; virtual;
    procedure OutOfMemory; virtual;
    function ReadLngFile: boolean;
    function ReadLngExe: boolean;
    function CalcLngFileName: PathStr;
    procedure HandleEvent(var Event: TEvent); virtual;
    function CalcHelpName: PathStr;
    function GetPalette: PPalette; virtual;
    procedure Idle; virtual;
    procedure RegularActions;
    procedure ReloadPackMain;
    procedure CheckTime;
    procedure CheckAlarm;
    procedure SetCommandsState;
    procedure DisableDirCommands;
    procedure ChangeDir;
    procedure About;
    procedure RetrieveDesktop(DskName: PathStr; AskNec, Temp: boolean);
    procedure LoadDesktop(var S: TStream);
    procedure SaveDesktop(DskName: PathStr; AskNec, Temp: boolean);
    procedure StoreDesktop(var S: TStream);
    procedure SaveConfig(ConfName: PathStr; AskNec: boolean);
    procedure RetrieveConfig(ConfName: PathStr; AskNec: boolean; Mode: byte);
    procedure SetNewPalette(const Palette: TPalette);
    function IsNotColorPalette(const Palette: TPalette): boolean;
    procedure SavePalette;
    procedure RetrievePalette;
    procedure LoadPalette(FileName: FNameStr);
    procedure SetOptions;
    function ClearDesktop: boolean;
    procedure SetScreen;
    function ScreenDelay: LongInt; virtual;
    procedure DosShell;
    procedure DosCommandDialog;
    procedure Preferences;
    procedure ChangeInterface;
    procedure Colors;
    procedure Calendar;
    procedure AsciiTab;
    procedure Calculator;
    procedure UserScreen;
    procedure RenumberWindows;
    procedure WinList;
    procedure Mouse;
    procedure FileOpen(FileName: PathStr);
    procedure OpenEditOrDir(FileName: FNameStr);
    procedure OpenDirWin(FileName: FNameStr);
    procedure OpenDesktop;
    function IsDesktopFile(FileName: FNameStr): boolean;
    function IsPaletteFile(FileName: FNameStr): boolean;
    procedure OpenNewDirWin;
    procedure OpenAnnWindow;
    procedure OpenIntEditor(FileName: FNameStr);
    procedure InitEditor;
    function  OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
    procedure ShowClip;
    function  IsClipBoard(P: PView): Boolean;
    procedure SaveAll;
    procedure SetAutoIndentMode;
    procedure SetBakFiles;
    procedure GetWinSize(var R: TRect; WindowType: Word);
    procedure GoToLine;
    function ShowShadow: boolean; virtual;
    function TimeBeep: boolean;
    function AskQuit: boolean;
    procedure DoExecuteCmd(ExecInfoPtr: PExecInfo);
    procedure ExecuteCmd(Cmd: String; StartDir: DirStr;
               ClearKbd, DelayScr, RestCD: boolean; EnvSize: String);
    procedure RestCurrDir(Conditional: boolean);
    procedure StoreCurrDir;
    procedure DelTmpFiles;
    procedure SetWorkDir(Conditional: boolean);
    function CalcWorkDir: DirStr;
    function BuildRandFName(FName: FNameStr): FNameStr;
    function BuildTmpConfName: FNameStr;
    function BuildTmpDskName: FNameStr;
    procedure CloseAll;
    function FirstStart: boolean;
    procedure StartBeep;
    procedure ProcessParams;
    procedure ChangeLanguage;
    procedure ChangeWorkDir;
    function LoadLanguage(LngName: FNameStr): boolean;
    procedure UpdateAnnotation;
    procedure CheckHotKey(var Event: TEvent);
    procedure HotKeysList;
    procedure SetProtections;
    procedure ClearKeyboard;
    procedure VerticalTile;
    procedure HorisontalTile;
    function GetDirForOpen: DirStr;
    procedure AddClosedFile(P: PEditWindow);
    procedure GlobalExtensions;
    procedure OutputWindow;
    procedure LastDesktop;
    procedure DesktopStack;
    function IsRegisteredCopy: boolean;
    function CheckRegisteredCopy: boolean;
    procedure CheckAlt;
    procedure UpdateCFMenu;
    procedure OpenClosedFile(Num: Integer);
    function CallExtEditor(FileName: FNameStr): boolean;
    procedure CallMenu4Editor;
    procedure LastDocument;
    function PhMacro(ANo: Byte): String; virtual;
    function RunMsgBox(No: Word; Params: Pointer; AOptions: Word): Word; virtual;
    function ExtGetHelpCtx(AHelpCtx: Word): Word; virtual;
    procedure CheckDocSize(FileName: FNameStr);
    function CalcRegFileName: FNameStr;
    procedure FillDiskTypes;
  end;

var

  LBSelector: Word;

  OldAlarmClock: pointer;
  CriticalArea: boolean;
  SMInstalled: boolean;
  OvrInitError: boolean;
  US: TUserScreen;
  ClipWindow: PEditWindow;
  OldLngFileName: FNameStr;  { Имя последнего файла языка }
                             { до чтения конфигурации }

implementation

const

  EditorAndDirCommands = [cmCut, cmCopy, cmReplace];

procedure InstallSmoothMouse; external;
procedure UninstallSmoothMouse; external;
procedure EnableSmoothMouse; external;
procedure DisableSmoothMouse; external;
procedure RefreshSmoothMouse; external;
procedure ChangeFont8to9; external;
procedure CursorToClock; external;

procedure MyAlarmClock; interrupt;
begin
  Message(Application, evCommand, cmSetAlarmFlag, nil);
end;

{ ---------------------- Методы объекта TPMApp --------------------------- }
constructor TPMApp.Init;
var
  R: TRect;
  InitStatus: Word;
  Name: NameStr;
  Ext: ExtStr;
  c: Integer;
  N: LongInt;
begin
  LBSelector := 0;
  InitStatus := 0;
  CriticalArea := True;
  BellRequest := 0;

  if not CheckRunFromPacket
    then InitStatus := InitStatus or isRunFromPacket;

  if OvrInitError
    then InitStatus := InitStatus or isInitOvr;

  Clock := nil;
  HeapViewer := nil;
  Title := nil;
  MacroInd := nil;

  SmoothMouse := True;
  Config.Init;
  PackDir := GetExeDir;

  if InitStatus = 0 then
    RetrieveConfig(LinkBlock^.GetTmpConfFile, False, roReadConfig);

  if not ReadLngFile
    then begin
      InitStatus := InitStatus or isReadLngFile;
      if not ReadLngExe
        then InitStatus := InitStatus or isReadLngExe;
    end;
  OldLngFileName := CalcLngFileName;

  MaxHeapSize := HeapSize;
  HistorySize := HistSize;

  SmoothMouse :=
     SmoothMouse and ((InitStatus = 0) or (InitStatus = isReadLngFile))
     and not LinkBlock^.GetSMProh and not (WindowsActive or OS2Active);

  if SmoothMouse then InstallSmoothMouse;

  SMInstalled := SmoothMouse;

  inherited Init;  {<------------------}

  Randomize;
  BellRequest := 4;
  LoadDskName := '';
  ReloadFlag := False;
  UnlockDesktop := False;
  CloseWin := False;
  SysErrorFunc := PackSystemError;
  InitWorks := True;
  AltPressed := False;
  CancelAlt := False;
  NeedUpdateCFMenu := True;
  CryptedNum := 0;

  if not SMInstalled
    then MouseCharsSet := [];
  if not (HiResScreen and
          MouseEvents and
          not (Lo(ScreenMode) in [smBW80, smMono]))
    then begin
      if SMInstalled
        then begin
          UninstallSmoothMouse;
          ChangeFont8to9;
          SMInstalled := False;
        end;
      MouseCharsSet := [];
    end;

  Clock := nil;
  HeapViewer := nil;
  Title := nil;
  MacroInd := nil;

  SmoothMouse := (InitStatus = 0) or (InitStatus = isReadLngFile);
  SetMouse;
  Config.Init;
  PackDir := GetExeDir;
  New(DskStack, Init(DskStackSize, 0, DskStackSize));

  if (InitStatus and isInitOvr) <> 0
    then begin
      MessageBox(tsOvrInitError, nil, mfError + mfOkButton, hcNoContext);
      Done;
      Fail;
    end;

  if (InitStatus and isReadLngExe) <> 0
    then begin
      MessageBox(tsLngReadError, nil, mfError + mfOkButton, hcNoContext);
      FatalErrorFlag := True;
      Done;
      Fail;
    end;

  if (InitStatus and isRunFromPacket) <> 0
    then begin
      MessageBox(^M^C + Ph(phRunPacket), nil,
                 mfError + mfOkButton, hcNoContext);
      FatalErrorFlag := True;
      Done;
      Fail;
    end
  else CheckRunFromPacket;

  CriticalArea := False;
{-------------------- Конец критической секции --------------------------}

  New(ClosedFiles, Init);
  InitEditor;
  RegisterTypes;
  SetIndexHelpInfo(cmHelpIndex, hcPacket);
  RestCurrDir(True);
  StoreCurrDir;
  FillDiskTypes;
  GetUserInfo(CalcRegFileName, UserName, UserCompany, UserNum);
  RetrieveConfig(LinkBlock^.GetTmpConfFile, False, roRetrieveOpt);
  RetrieveDesktop(LinkBlock^.GetTmpDskFile, False, not FirstStart);

  if FirstStart
    then begin
      SetProtections;
      Message(Desktop, evBroadcast, cmUpdateCalendar, nil);
    end;

  DelTmpFiles;

  ProcessParams;

  if ((InitStatus and isReadLngFile) <> 0) and (CalcLngFileName <> '')
    and FirstStart
    then MessageBox(^C + Ph(phLngFileReadError) + ^M^M^C + CalcLngFileName,
                    nil, mfError + mfOkButton, hcLngReadError);

  if CryptedNum = 0
    then CryptedNum :=
           Ln(CalculateRegNum(CryptStr(UserName), CryptStr(UserCompany)));

  Val(CryptStr(UserNum), N, c);
  if N <> 0
    then IsRegCopy := Ln(N) = CryptedNum
  else IsRegCopy := Ln(0.1) = CryptedNum;

  LinkBlock^.SetDelProgFlag(False);
  LinkBlock^.SetDelTmpDskFlag(False);
  LinkBlock^.SetDelTmpConfFlag(False);
  MinWinSize.X := 23;
  LowMemSize := PackLowMemSize;
  HelpCtx := hcBackgrCtx;

  if FirstStart and (LoadDskName = '')
    and not (Assigned(Desktop^.Current) and IsRegisteredCopy)
  then About;
  InitWorks := False;
end; { of Init }

destructor TPMApp.Done;
begin
  if Assigned(LinkBlock) and not FatalErrorFlag
    then begin
      {  Autosave если выход  }
      if (Config.ASDesktop) and (LinkBlock^.GetExitFlag)
        then SaveDesktop(LinkBlock^.GetDskFile, False, False);
      if (Config.ASConfig) and (LinkBlock^.GetExitFlag)
        then SaveConfig(LinkBlock^.GetConfFile, False);
    end;

  if not FatalErrorFlag and (LBSelector <> 0)
    then LinkBlock^.SetFirstStartFlag(False);
  DisposeObj(ClosedFiles);
  DisposeObj(DskStack);

  FreePhraseList;
  DisposeObj(Clock);
  DisposeObj(HeapViewer);
  if SMInstalled then UninstallSmoothMouse;
  HideMouse;
  ClearScreen;

{$ifdef DPMI}
  if LBSelector <> 0 then FreeSelector(LBSelector);
{$endif}

  inherited Done;

  if SMInstalled then ChangeFont8to9;
end;

procedure TPMApp.ProcessParams;
var
  i: Integer;
  FileName: FNameStr;
begin
  for i := ServParamCount + 1 to ParamCount do
  begin
    FileName := ParamStr(i);
    if FileName[Length(FileName)] = '\' then
      FileName := FileName + AllFilesMask;
    if (Pos('?', FileName) = 0) and (Pos('*', FileName) = 0) then
      OpenEditOrDir(FExpand(FileName))
    else FileOpen(FileName);
  end;
end;

function TPMApp.CalcHelpName: PathStr;
begin
  CalcHelpName := GetExeDir + Ph(phHelpFileName);
end;

function TPMApp.CalcLngFileName: PathStr;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  if FullTrim(Config.GetLngFile) = ''
    then begin
      CalcLngFileName := '';
      Exit;
    end;
  FSplit(Config.GetLngFile, Dir, Name, Ext);
  if FullTrim(Dir) = ''
    then CalcLngFileName := GetExeDir + Name + Ext
    else CalcLngFileName := Dir + Name + Ext
end;

function TPMApp.ReadLngExe: boolean;
begin
{$ifndef DPMI}
  ReadLanguage('', LngSign, rtExe);
{$else}
  ReadLanguage(GetExeDir + DefaultLngFile, LngSign, rtFile);
{$endif}
  ReadLngExe := LngReadError = 0;
end;

function TPMApp.ReadLngFile: boolean;
begin
  ReadLanguage(CalcLngFileName, LngSign, rtFile);
  ReadLngFile := LngReadError = 0;
end;

function TPMApp.CheckRunFromPacket: boolean;
var
  flag: boolean;
begin
  flag := False;
  if (ParamCount >= ServParamCount) and (ParamStr(1) = PackVerID) then
  begin
{$ifdef DPMI}
    if LBSelector <> 0 then FreeSelector(LBSelector);
{$endif}
    LBSelector := GetLinkPtr(LinkBlock);
    flag := True;
  end;
  if (not flag) and (not Assigned(LinkBlock)) then New(LinkBlock, Init);
{$ifdef Debug}
  flag := True;
{$endif}
  CheckRunFromPacket := flag and LinkBlock^.CompVer(PackVerID);
end;

procedure TPMApp.RegisterDirectories;
begin
  RegisterType(RFileItem);
  RegisterType(RArchItem);
  RegisterType(RSubDirItem);
  RegisterType(RUpDirItem);
  RegisterType(RTextResource);
  RegisterType(RSubDir);
  RegisterType(RItemsCollection);
  RegisterType(RDirHandler);
  RegisterType(RPathStack);
  RegisterType(RPathItem);
  RegisterType(RDirConfig);
  RegisterType(RDirWindow);
  RegisterType(RDirectoryBox);
  RegisterType(RAnnViewer);
  RegisterType(RAnnWindow);
  RegisterType(RDirWinIndicator);
end;

procedure TPMApp.RegisterTypes;
begin
  RegisterObjects;
  RegisterViews;
  RegisterEditors;
  RegisterDialogs;

  RegisterAppMac;

  RegisterType(RHelpTopic);
  RegisterType(RHelpIndex);
  RegisterDirectories;
  RegisterType(RCalendarView);
  RegisterType(RCalendarWindow);
  RegisterType(RTable);
  RegisterType(RReport);
  RegisterType(RCalcDisplay);
  RegisterType(RCalculator);
  RegisterType(RASCIIChart);
  RegisterType(RHotKeyRef);
  RegisterType(RClosedFile);
  RegisterType(RClosedFilesColl);
  RegisterType(ROutputWindow);
  RegisterType(ROutputInterior);
  RegisterType(RStrStack);
end;

procedure TPMApp.OutOfMemory;
begin
  CriticalArea := True;
  MessageBox(^C + Ph(phNotEnoughMem), nil,
             mfError + mfOkButton + mfInsertInApp, hcNoContext);
  CriticalArea := False;
end;

procedure TPMApp.InitEditor;
begin
  DisableCommands([cmSave, cmSaveAs, cmCut, cmCopy, cmPaste, cmClear,
    cmUndo, cmFind, cmReplace, cmSearchAgain]);
  EditorDialog := DoEditDialog;

  ClipWindow := OpenEditor('', False);
  if Assigned(ClipWindow) then
  begin
    ClipWindow^.HelpCtx := hcClipboard;
    Clipboard := ClipWindow^.Editor;
    Clipboard^.CanUndo := False;
  end;
end;

procedure TPMApp.DeleteGadgets;
begin
  DisposeObj(Title);
  DisposeObj(Clock);
  DisposeObj(HeapViewer);
  DisposeObj(MacroInd);
end;

procedure TPMApp.UpdateGadgets;
begin
  if Assigned(Clock) then Clock^.Update;
  if Assigned(HeapViewer) then HeapViewer^.Update;
  if SMInstalled then RefreshSmoothMouse;
end;

procedure TPMApp.SetGadgets;
var
  R:TRect;
begin
  Case Config.ShowClock of
    True:if not Assigned(Clock) then
           begin
             GetExtent(R);
             R.A.X := R.B.X - 11; R.B.Y := R.A.Y + 1;
             Clock := New(PClockView, Init(R));
             Insert(Clock);
           end;
   False: DisposeObj(Clock);
  end;
  Case Config.ShowHeap of
    True:if not Assigned(HeapViewer) then
           begin
             GetExtent(R);
             Dec(R.B.X);
             R.A.X := R.B.X - 10; R.A.Y := R.B.Y - 1;
             HeapViewer := New(PHeapView, Init(R));
             Insert(HeapViewer);
           end;
   False: DisposeObj(HeapViewer);
  end;

  if not Assigned(Title) then
  begin
    GetExtent(R);
    R.B.Y := R.A.Y + 1;
    R.A.X := R.B.X - 22;
    R.B.X := R.A.X + 10;
    Title := New(PTitleView, Init(R, '', tsTitle, cmAbout));
    Insert(Title);
  end;

  if not Assigned(MacroInd) and IsModMacro then
  begin
    GetExtent(R);
    R.B.Y := R.A.Y + 1;
    R.A.X := R.B.X - 30;
    R.B.X := R.A.X + 7;
    MacroInd := New(PNameView, Init(R, '', Ph(phRecMacro)));
    Insert(MacroInd);
  end;
  if not IsModMacro
    then DisposeObj(MacroInd);
end;

procedure TPMApp.SetMouse;
begin
  if SmoothMouse
    then begin
      EnableSmoothMouse;
      CursorToClock;
    end
  else DisableSmoothMouse;
end;

procedure TPMApp.InitMenuBar;
var
  R: TRect;
begin
  GetExtent(R);
  R.B.Y := R.A.Y+1;
  MenuBar := New(PMenuBar, Init(R, NewPackMenu));
end;

procedure TPMApp.InitStatusLine;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  StatusLine := New(PPackStatusLine, Init(R));
end;

procedure TPMApp.AddClosedFile(P: PEditWindow);
begin
  ClosedFiles^.AddFile(P^.Editor^.FileName, P^.Editor^.CurPtr);
  NeedUpdateCFMenu := True;
end;

procedure TPMApp.HandleEvent(var Event: TEvent);
begin
  if Event.What = evCommand then
    Case Event.Command of
 cmVerticalTile: begin
                   VerticalTile;
                   ClearEvent(Event);
                 end;
 cmHorisontalTile: begin
                     HorisontalTile;
                     ClearEvent(Event);
                   end;
       cmQuit: if not AskQuit
                 then ClearEvent(Event)
               else begin
                 DelTmpFiles;
                 LinkBlock^.SetExitFlag(True);
                 Event.Command := cmQuit;
               end;
    end;

  inherited HandleEvent(Event);

  if Event.What = evCommand then
  begin
    Case Event.Command of
      cmBellRequest: BellRequest := Event.InfoByte;
      cmAbout: About;
      cmCascade: Cascade;
      cmCloseAll: CloseAll;
      cmChangeDir: ChangeDir;
      cmRefreshDisplay: begin
                          Redraw;
                          SetIntensity;
                        end;
      cmCalendar: Calendar;
      cmAsciiTab: AsciiTab;
      cmCalculator: Calculator;
      cmUserScreen: UserScreen;
      cmOpen: FileOpen(GetDirForOpen + AllFilesMask);
      cmSaveAll: SaveAll;
      cmShowClip: ShowClip;
      cmGoToLine: GoToLine;
      cmSaveDesktop: SaveDesktop('', True, False);
      cmRetrieveDesktop: begin
                           RetrieveDesktop('', True, False);
                           Message(Desktop, evBroadcast, cmUpdateCalendar, nil);
                           SetProtections;
                         end;
      cmSaveConfig: SaveConfig('', True);
      cmRetrieveConfig: RetrieveConfig('', True, roRetrieveOpt);
      cmSavePalette: SavePalette;
      cmRetrievePalette: RetrievePalette;
      cmColors: Colors;
      cmOpenAnnWindow: OpenAnnWindow;
      cmOutputWindow: OutputWindow;
      cmWinList: WinList;
      cmDosShell: DosShell;
      cmMouse: Mouse;
      cmDosCommand: DosCommandDialog;
      cmPreferences: Preferences;
      cmInterface: ChangeInterface;
      cmNewFile: OpenEditor('', True);
      cmNewDir: OpenNewDirWin;
      cmLanguage: ChangeLanguage;
      cmWorkDir: ChangeWorkDir;
      cmStoreCurrDir: StoreCurrDir;
      cmScreenRest: ScreenOff;
      cmExecuteCmd: DoExecuteCmd(Event.InfoPtr);
      cmRestCurrDir: RestCurrDir(False); { безусловно }
      cmOpenIntEditor: OpenIntEditor(GetStr(PString(Event.InfoPtr)));
      cmOpenDirWindow: OpenEditOrDir(GetStr(PString(Event.InfoPtr)));
      cmUpdateGadgets: UpdateGadgets;
      cmHotKeysList: HotKeysList;
      cmLocalMenu: LocalMenu;
      cmRenumber: RenumberWindows;
      cmRegLastEvTime: RegisterLastEventTime;
      cmAlarmClock: if not IsRegisteredCopy
                      then Remind
                    else begin
                      AlarmClock;
                      LinkBlock^.SetAlarmText(AlarmData.Info);
                      LinkBlock^.SetAlarmTime(AlarmData.Time);
                    end;
      cmResetAlarmFlag: LinkBlock^.SetAlarmFlag(False);
      cmSetAlarmFlag: LinkBlock^.SetAlarmFlag(True);
      cmGlobalExt: GlobalExtensions;
      cmEditorClosed: AddClosedFile(Event.InfoPtr);
      cmRemind: if not IsRegisteredCopy then Remind;
      cmUnlockDesktop: UnlockDesktop := True;
      cmCloseWin: CloseWin := True;
      cmLastDesktop: LastDesktop;
      cmDesktopStack: DesktopStack;
      cmCallExtEditor: CallExtEditor('');
      cmCallMenu4Editor: CallMenu4Editor;
      cmLastDocument: LastDocument;
      cmCheckDocSize: CheckDocSize(GetStr(PString(Event.InfoPtr)));
      cmSetDelProgFlag: LinkBlock^.SetDelProgFlag(True);
      cmInsRef: FirstDirWindow^.DirectoryBox^.InsertReference;
      cmClosedFile1..cmClosedFile5: OpenClosedFile(
                                       Event.Command - cmClosedFile1 + 1);
      cmExitPM: begin
                  Event.Command := cmQuit;
                  inherited HandleEvent(Event);
                end;
      else
        Exit;
    end;
    ClearEvent(Event);
  end;
end;

procedure TPMApp.GlobalExtensions;
begin
  OpenEditor(GlobalExtName, True);
end;

procedure TPMApp.CheckHotKey(var Event: TEvent);
var
  Key: Char;
begin
  if (Event.What <> evKeyBoard)
    or CriticalArea
    or not (AltDown and (CtrlDown or ShiftDown))
    or (Application^.Current <> PView(Desktop))
    or not Assigned(Desktop^.Current)
    or (Desktop^.Current^.State and (sfModal + sfDragging) <> 0)
  then Exit;
  Key := GetAltChar(Event.KeyCode);
  if Key = #0 then Exit;
  ClearEvent(Event);
  Message(Desktop, evBroadcast, cmHotKey, Pointer(Key));
end;

procedure TPMApp.HotKeysList;
var
  Key: Char;
begin
  Key := #0;
  if (Application^.ExecuteDialog(New(PHotKeysListDlg, Init), @Key)
      <> cmCancel) and (Key <> #0)
  then Message(Desktop, evBroadcast, cmHotKey, Pointer(Key));
end;

procedure TPMApp.DoExecuteCmd(ExecInfoPtr: PExecInfo);
begin
  with ExecInfoPtr^ do
    ExecuteCmd(ProgName + ' ' + Params, StartDir,
               ClearKbd, DelayScreen, RestCurrDir, EnvSize);
end;

procedure TPMApp.SetCommandsState;

function IsTileable(P: PView): boolean; far;
begin
  IsTileable := (P^.Options and ofTileable <> 0) and
                (P^.State and sfVisible <> 0);
end;

function IsEditWindow(P: PView): boolean; far;
begin
  IsEditWindow := (TypeOf(TEditWindow) = TypeOf(P^)) and
                  (P^.State and sfVisible <> 0) and not IsClipboard(P)
end;

begin
  if CriticalArea
    then Exit;

  if (Assigned(Desktop^.Current))
    and (TypeOf(Desktop^.Current^) = TypeOf(TEditWindow)) then
    EnableCommands([cmFind, cmSearchAgain, cmSaveAs, cmGoToLine])
  else
    DisableCommands([cmFind, cmSearchAgain, cmSaveAs, cmGoToLine]);

  if (Assigned(Desktop^.Current))
    and (TypeOf(Desktop^.Current^) = TypeOf(TEditWindow))
    and (FirstDirWindow <> nil)
  then EnableCommands([cmInsRef])
  else DisableCommands([cmInsRef]);

  if (Assigned(Desktop^.Current))
    and (TypeOf(Desktop^.Current^) = TypeOf(TEditWindow))
    and not IsClipBoard(Desktop^.Current)
  then EnableCommands([cmSave])
  else begin
    DisableCommands([cmSave]);
    if not (Assigned(Desktop^.Current) and
      (Desktop^.Current = PView(FirstDirWindow)))
    then DisableCommands(EditorAndDirCommands);
  end;

  if (Assigned(Desktop^.Current)) and
    (Desktop^.FirstThat(@IsTileable) <> nil) then
    EnableCommands([cmVerticalTile, cmHorisontalTile, cmCascade])
  else
    DisableCommands([cmVerticalTile, cmHorisontalTile, cmCascade]);

  if (Assigned(Desktop^.Current)) and
    (Desktop^.FirstThat(@IsEditWindow) <> nil) then
    EnableCommands([cmSaveAll])
  else DisableCommands([cmSaveAll]);

  if (Assigned(Desktop^.Current)) then
    EnableCommands([cmCloseAll, cmRenumber])
  else DisableCommands([cmCloseAll, cmRenumber]);

  if Assigned(Desktop^.Current) and
    (Desktop^.Current = PView(FirstDirWindow))
  then PDirWindow(Desktop^.Current)^.EnableDirCommands
  else DisableDirCommands;

  if Assigned(Desktop^.Current) and
    ((Desktop^.Current = PView(FirstDirWindow))
      and (FirstDirWindow^.DirectoryBox^.CountItems <> 0)
      and not FirstDirWindow^.GetDirHandler^.Protected)
    or ((Desktop^.Current = PView(SearchAnnWindow))
         and (FirstDirWindow <> nil)
         and (FirstDirWindow^.DirectoryBox^.CountItems <> 0)
         and not FirstDirWindow^.GetDirHandler^.Protected)
  then EnableCommands([cmAnnotate])
  else DisableCommands([cmAnnotate]);

  if FirstDirWindow <> nil
    then EnableCommands([cmHotKeysList])
  else DisableCommands([cmHotKeysList]);

  if DskStack^.Count > 1
    then EnableCommands([cmLastDesktop, cmDesktopStack])
  else DisableCommands([cmLastDesktop, cmDesktopStack]);

  if not OS2Active
    then EnableCommands([cmAlarmClock])
  else DisableCommands([cmAlarmClock]);

  if FullTrim(LastDocName) <> ''
    then EnableCommands([cmLastDocument])
  else DisableCommands([cmLastDocument]);
end;

procedure TPMApp.DisableDirCommands;
begin
  DisableCommands(DirCommands);
end;

procedure TPMApp.CheckAlt; { Alt - menu }
var
  E: TEvent;
begin
  if not Alt4Menu then Exit;
  if CtrlDown or ShiftDown then CancelAlt := True;
  if not CancelAlt and AltPressed and not AltDown and
    (Application^.Current = PView(Desktop)) and
     (not Assigned(Desktop^.Current) or
     (Assigned(Desktop^.Current) and
      (Desktop^.Current^.State and sfModal = 0)))
  then Message(Application, evCommand, cmMenu, nil)
  else
  if not CancelAlt and AltPressed and not AltDown and
     (Application^.Current = PView(MenuBar))
  then begin
    E.What := evKeyDown;
    E.KeyCode := kbEsc;
    E.InfoPtr := nil;
    PutEvent(E);
  end;

  if not AltDown then CancelAlt := False;
  AltPressed := AltDown;
end;

procedure TPMApp.Idle;
begin
  RegularActions;

  inherited Idle;

  SetGadgets;
  UpdateGadgets;
  CheckMouseInCorner;
{$ifndef Debug}
  if CheckRegisteredCopy <> IsRegisteredCopy
    then HackersHere := True;
{$endif}
  CheckBellRequest;
  CheckAlarm;
  CheckTime;

  CheckAlt;
end;

procedure TPMApp.CheckTime;
var
  H, M, S, S100: Word;
  R: TRect;
begin
  GetTime(H, M, S, S100);
  if (M = 0) and (S = 0) and (S100 < 10)
    then begin
      Message(Desktop, evBroadcast, cmUpdateCalendar, nil);
      if not TimeBeep then Exit;
      if Assigned(Clock) then Clock^.Update;
      DoTimeBeep;
    end;
  if (M mod 10 = 1) and (S = 0) and (S100 < 20) and not IsRegisteredCopy
    then begin
      Delay(250 + Random(10));
      Randomize;
      if Random(2) = 0 then Exit;
      Remind;
    end;

  HackersHere := HackersHere or
     (Pos(CryptStr('БлУZк┌з╞|1ЕПK¤╣'), tsAbout) = 0) or
     (Pos(CryptStr('ГЮ`ЧгRуB╬Cчх╪b╞%╨I'), tsAbout) = 0);
end;

procedure TPMApp.CheckAlarm;
var
  D: PDialog;
  R: TRect;
begin
  if CriticalArea or (not LinkBlock^.GetAlarmFlag)
    or (MouseButtons <> 0) then Exit;
  LinkBlock^.SetAlarmFlag(False);
  Message(Application, evCommand, cmBellRequest, Pointer(5));
  R.Assign(0, 0, 39, 10);
  D := New(PDialog, Init(R, Ph(phDoNotForget)));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Grow(-2, -2);
    Dec(R.B.Y, 1);
    Insert(New(PStaticText,
               Init(R, ^C + LinkBlock^.GetAlarmTime + '. ' +
                       LinkBlock^.GetAlarmText)));
    R.Assign(14, 7, 24, 9);
    Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
    HelpCtx := hcAlarmInfo;
  end;
  BaseApplication^.AppExecuteDialog(D, nil);
end;

procedure TPMApp.UpdateAnnotation;
var
  DirWin: PDirWindow;
begin
  if CriticalArea then Exit;
  DirWin := FirstDirWindow;
  if not Assigned(DirWin)
    then begin
      Message(Desktop, evBroadcast, cmNewAnn, nil);
      Exit;
    end;
  if GetIdleTime < AnnDelay then Exit;
  DirWin^.DirectoryBox^.ChangeAnn;
end;

{*************** Desktop & options  store & retrieve ****************}
procedure TPMApp.LoadDesktop(var S: TStream);
var
  P, PP: PView;
  DirWind: PDirWindow;
  OutW: POutputWindow;

begin
  ProtWord := 0;
  if ClearDesktop then
  begin
    repeat
      PP := PView(S.Get);
      if Assigned(PP)
        then Inc(ProtWord, PP^.HelpCtx xor PP^.Size.X xor PP^.Origin.Y
                           xor PP^.Options xor PP^.Cursor.X);
      P := ValidView(PP);
      if Assigned(P) and (TypeOf(TEditWindow) = TypeOf(P^))
        then PEditWindow(P)^.Editor^.Overwrite  :=
             PEditWindow(P)^.Editor^.State and sfCursorIns <> 0;
      Desktop^.InsertBefore(P, Desktop^.Last);
    until not Assigned(PP);
    SetAutoIndentMode;
  end;

  DirWind := FirstDirWindow;
  if Assigned(DirWind)
    then DirWind^.DirectoryBox^.ChangeAnn;
  OutW := Message(Desktop, evBroadcast, cmSearchOutputWin, nil);
  if Assigned(OutW)
    then OutW^.Adjust(@US);
end;  { of LoadDesktop }

procedure TPMApp.StoreDesktop(var S: TStream);

procedure WriteView(P: PView); far;
begin
  if (P <> Desktop^.Last)
   and not IsClipboard(P)
    then begin
      S.Put(P);
      Inc(ProtWord, P^.HelpCtx xor P^.Size.X xor P^.Origin.Y
                    xor P^.Options xor P^.Cursor.X);
    end;
end;

begin
  ProtWord := 0;
  Desktop^.ForEach(@WriteView);
  S.Put(nil);
end;

procedure TPMApp.SaveDesktop(DskName: PathStr; AskNec, Temp: boolean);
var
  S: PBufStream;
  F: File;
  RandWord: Word;
  P: PString;
begin
  if AskNec then
  begin
    DskName := DskFileName;
    if ExecuteDialog(New(PFileDialog, Init(DskExt, Ph(phSaveDsk),
                                           Ph(phCName),
                                           fdOkButton + fdHelpButton,
                                           hiDsk, hcSaveDesktop)),
                      @DskName) = cmCancel
      then Exit;
  end;

  CurrentDskName := DskName;
  S := New(PBufStream, Init(DskName, stCreate, StreamBuffSize));
  if {not LowMemory and} (S^.Status = stOk) then
  begin
    S^.Write(DskSignature[1], DskSignatureLen);
    S^.Write(Temp, SizeOf(Temp));
    StoreDesktop(S^);
    if Temp
      then begin
        LinkBlock^.SetProtWord(ProtWord);
        Randomize;
        RandWord := Random(MaxInt);
        P := NewStr(GetRandString(30));
        S^.Write(RandWord, SizeOf(RandWord));
        Inc(RandWord, Length(GetStr(P)));
        LinkBlock^.SetRandWord(RandWord);
        S^.WriteStr(P);
        DispStr(P);
      end;
    StoreHistory(S^);
    StoreIndexes(S^);
    S^.Write(AddSubDirCoord, SizeOf(TPoint));
    S^.Write(AddFileItemCoord, SizeOf(TPoint));
    S^.Write(EditResCoord, SizeOf(TRect));
    S^.Write(ParamsCoord, SizeOf(TPoint));
    S^.Write(ParamListCoord, SizeOf(TPoint));
    S^.Write(DocDataInitialized, SizeOf(DocDataInitialized));
    S^.Write(DocData, SizeOf(DocData));
    S^.Put(ClosedFiles);
    S^.Put(DskStack);
    S^.Write(LastDocName, SizeOf(LastDocName));
    SaveStream(PStream(S));
    if S^.Status <> stOk then
    begin
      MessageBox(^C + Ph(phCouldNotCreate) + ^M^M^C + DskName, nil,
        mfOkButton + mfError, hcErrorCreateFile);
      DisposeObj(S);
      Assign(F, DskName);
      Erase(F);
      ClearError;
      Exit;
    end
    else if AskNec
      then LinkBlock^.SetDskFile(FExpand(DskName));
  end else MessageBox(^C + Ph(phCouldNotCreate) + ^M^M^C + DskName, nil,
                      mfOkButton + mfError, hcErrorCreateFile);
  DisposeObj(S);
  ReadingTmpDsk := False;
end;  { of SaveDesktop }

function TPMApp.ClearDesktop: boolean;

procedure CloseView(P: PView); far;
begin
  Message(P, evCommand, cmClose, nil);
end;

begin
  ClearDesktop := False;
  if not Desktop^.Valid(cmClose)
    then Exit;
  ClearDesktop := True;
  Desktop^.ForEach(@CloseView);
  DoneHistory;
  InitHistory;
end;

procedure TPMApp.RetrieveDesktop(DskName: PathStr; AskNec, Temp: boolean);
var
  S: PBufStream;
  Signature: string[DskSignatureLen];
  Mess: PProcMess;
  RandWord: Word;
  P: PString;
  flag: boolean;
  DS: PStrStack;
  NewLastDocName: FNameStr;
begin
  if AskNec then
  begin
    DskName := DskFileName;
    if ExecuteDialog(New(PFileDialog, Init(DskExt, Ph(phRetrDsk),
                                           Ph(phCName),
                                           fdOkButton + fdHelpButton,
                                           hiDsk, hcRetrieveDesktop)),
                      @DskName) = cmCancel
      then Exit;
  end;

  if not ClearDesktop then Exit;

  Mess := nil;
  CurrentDskName := DskName;
  S := New(PBufStream, Init(DskName, stOpenRead, StreamBuffSize));
  if S^.Status <> stOk then
    begin
      DisposeObj(S);
      if AskNec then
        MessageBox(^C + Ph(phCouldNotOpen) + ^M^M^C + DskName, nil,
          mfOkButton + mfError, hcErrorOpenFile)
      else begin
        if PackDir <> GetFDir(DskName) then
          RetrieveDesktop(PackDir + DskFileName, False, Temp);
        Exit;
      end
    end
  else
  begin
    Signature[0] := Char(DskSignatureLen);
    S^.Read(Signature[1], DskSignatureLen);
    if (Signature = DSKSignature) or (Signature = DSKSignatureOld) then
    begin
      New(Mess, Init(Ph(phLoadingDesktop) + '...'));
      S^.Read(ReadingTmpDsk, SizeOf(ReadingTmpDsk));
      flag := ReadingTmpDsk;
      ReadingTmpDsk := ReadingTmpDsk and Temp;
      LoadDesktop(S^);
      if flag
        then begin
          S^.Read(RandWord, SizeOf(RandWord));
          P := S^.ReadStr;
          Inc(RandWord, Length(GetStr(P)));
          DispStr(P);
        end;
      LoadHistory(S^);
      LoadIndexes(S^);
      S^.Read(AddSubDirCoord, SizeOf(TPoint));
      S^.Read(AddFileItemCoord, SizeOf(TPoint));
      S^.Read(EditResCoord, SizeOf(TRect));
      S^.Read(ParamsCoord, SizeOf(TPoint));
      S^.Read(ParamListCoord, SizeOf(TPoint));
      S^.Read(DocDataInitialized, SizeOf(DocDataInitialized));
      S^.Read(DocData, SizeOf(DocData));
      DisposeObj(ClosedFiles);
      ClosedFiles := Pointer(S^.Get);
      if not ReadingTmpDsk
        then SetProtections
      else if (LinkBlock^.GetProtWord <> ProtWord) or
              (LinkBlock^.GetRandWord <> RandWord)
           then ClearDesktop;
      if S^.Status <> stOk then
        begin
          ClearDesktop;
          DisposeObj(Mess);
          MessageBox(^C + Ph(phErrReadDsk), nil,
                     mfOkButton + mfError, hcErrorReadFile);
          InitPackDlgCoord;
          DisposeObj(ClosedFiles);
          New(ClosedFiles, Init);
          DocDataInitialized := False;
        end
      else begin
        { -- Чтение новых данных из Dsk -- }
        DS := PStrStack(S^.Get);
        if (S^.Status = stOk) and InitWorks
          then begin
            DisposeObj(DskStack);
            DskStack := DS;
          end
        else DisposeObj(DS);
        S^.Read(NewLastDocName, SizeOf(LastDocName));
        if S^.Status = stOk
          then LastDocName := NewLastDocName
        else LastDocName := '';
        LoadStream(PStream(S));
        { --- }
        if (InitWorks and FirstStart) or AskNec
             then LinkBlock^.SetDskFile(FExpand(DskName));
        if not Temp then DskStack^.Push(FExpand(StrUpCase(DskName)));
      end;
    end
    else
      MessageBox(^M^C + Ph(phInvDsk), nil, mfOkButton + mfError, hcInvFile);
    DisposeObj(S);
  end;
  ReadingTmpDsk := False;
  DisposeObj(Mess);
  UpdateCFMenu;
end; { of RetrieveDesktop }

procedure TPMApp.SaveConfig(ConfName: PathStr; AskNec: boolean);
var
  S: PBufStream;
begin
  if AskNec then
  begin
    ConfName := ConfFileName;
    if ExecuteDialog(New(PFileDialog, Init(ConfExt, Ph(phSaveConf),
                                           Ph(phCName),
                                           fdOkButton + fdHelpButton,
                                           hiConf, hcSaveConfig)),
                     @ConfName) = cmCancel
      then Exit;
  end;
  S := New(PBufStream, Init(ConfName, stCreate, StreamBuffSize));
  if {not LowMemory and} (S^.Status = stOk) then
    begin
      Config.Write(S^);
      S^.Write(InterfaceFlags, SizeOf(InterfaceFlags));
      S^.Write(BaseApplication^.GetPalette^, SizeOf(TPalette));
      S^.Write(DoubleDelay, SizeOf(DoubleDelay));
      S^.Write(MouseReverse, SizeOf(MouseReverse));
      S^.Write(SmoothMouse, SizeOf(SmoothMouse));
      if AskNec
        then LinkBlock^.SetConfFile(FExpand(ConfName));
    end;
  if S^.Status <> stOk then
    MessageBox(^C + Ph(phCouldNotCreate) + ^M^M^C + ConfName, nil,
         mfError + mfOkButton, hcErrorCreateFile);
  DisposeObj(S);
end;

procedure TPMApp.RetrieveConfig
   (ConfName: PathStr; AskNec: boolean; Mode: byte);

   {  Mode = roRetrieveOpt - восстановить все опции из файла конфигурации  }
   {  Mode = roReadConfig  - прочитать конфигурацию                        }

var
  S: PBufStream;
  TmpPalette: TPalette;
  TmpConf: TConfig;
  TmpDoubleDelay, TmpInterfaceFlags: Word;
  TmpMouseReverse: boolean;
  TmpSmoothMouse: boolean;
  ErrMsg: String;
  HelpContext: Word;
  OldSM: boolean;
begin
  if AskNec then
  begin
    ConfName := ConfFileName;
    if ExecuteDialog(New(PFileDialog, Init(ConfExt, Ph(phRetrConf),
                                           Ph(phCName),
                                           fdOkButton + fdHelpButton,
                                           hiConf, hcRetrieveConfig)),
                     @ConfName) = cmCancel
      then Exit;
  end;

  OldSM := SmoothMouse;
  S := New(PBufStream, Init(ConfName, stOpenRead, StreamBuffSize));
  if {not LowMemory and} (S^.Status = stOk) then
    begin
      TmpConf.Read(S^);
      S^.Read(TmpInterfaceFlags, SizeOf(InterfaceFlags));
      S^.Read(TmpPalette, SizeOf(TPalette));
      S^.Read(TmpDoubleDelay, SizeOf(TmpDoubleDelay));
      S^.Read(TmpMouseReverse, SizeOf(TmpMouseReverse));
      S^.Read(TmpSmoothMouse, SizeOf(TmpSmoothMouse));
    end
  else
    begin
      if Mode = roRetrieveOpt
        then begin
          SetOptions;
          SetWorkDir(False);
        end;
      DisposeObj(S);
      if AskNec
        then begin
          if Mode = roRetrieveOpt
            then MessageBox(^C + Ph(phCouldNotOpen) + ^M^M^C + ConfName, nil,
              mfOkButton + mfError, hcErrorOpenFile)
        end
      else begin
        if PackDir <> GetFDir(ConfName) then
          RetrieveConfig(PackDir + ConfFileName, False, Mode);
        Exit;
      end;
      Exit;
    end;
  if S^.Status = stOk
    then begin
      Config := TmpConf;
      if Mode = roRetrieveOpt
        then begin
          SetNewPalette(TmpPalette);
          DoubleDelay := TmpDoubleDelay;
          MouseReverse := TmpMouseReverse;
          SmoothMouse := TmpSmoothMouse;
          InterfaceFlags := TmpInterfaceFlags;
          DoneMemory;
          Redraw;
        end
      else SmoothMouse := TmpSmoothMouse;
      if (InitWorks and FirstStart) or AskNec
        then LinkBlock^.SetConfFile(FExpand(ConfName));
    end
  else begin
    if S^.Status = stChkSumError
      then begin
        ErrMsg := Ph(phInvConf);
        HelpContext := hcInvFile
      end
    else begin
      ErrMsg := Ph(phCouldNotRead);
      HelpContext := hcErrorReadFile;
    end;
    if Mode = roRetrieveOpt
      then MessageBox(^C + ErrMsg + ^M^M^C + ConfName, nil,
                      mfOkButton + mfError, HelpContext);
  end;

  if Mode = roRetrieveOpt
    then begin
      SetOptions;
      SetWorkDir(False);
    end;

  DisposeObj(S);
  if (not OldSM) and (not SMInstalled) and SmoothMouse
    and (not LinkBlock^.GetSMProh)
    and not (Lo(ScreenMode) in [smBW80, smMono])
    and (Mode = roRetrieveOpt)
      then ReloadFlag := MessageBox(^C + Ph(phAskReload4Mouse), nil,
                                    mfInformation + mfYesButton + mfNoButton,
                                    hcAskReload4Mouse) = cmYes;
end; { of RetrieveConfig }
{**************** Desktop & options  store & retrieve *******************}

function TPMApp.IsNotColorPalette(const Palette: TPalette): boolean;
var
  i: byte;
begin
  IsNotColorPalette := False;
  for i := 1 to Length(Palette) do
    if not ((ord(Palette[i]) and $F) in [0,1,7,8,15])
      then Exit;
  IsNotColorPalette := True;
end;

procedure TPMApp.SetNewPalette(const Palette: TPalette);
begin
  if (not (Lo(ScreenMode) in [smBW80, smMono]))
      or IsNotColorPalette(Palette)
    then BaseApplication^.GetPalette^ := Palette
  else MessageBox(Ph(phWrongPalette), nil,
                  mfInformation + mfOkButton, hcWrongPalette);
end;

procedure TPMApp.SavePalette;
var
  PalName: FNameStr;
  S: PBufStream;
  Signature: string[PalSignatureLen];
  F: file;
begin
  PalName := PackDir + PalDir + PalExt;
  if ExecuteDialog(New(PFileDialog, Init(PackDir + PalDir + PalExt,
                                         Ph(phSavePal),
                                         Ph(phCName),
                                         fdOkButton + fdHelpButton,
                                         hiPal, hcSavePalette)),
                   @PalName) = cmCancel
    then Exit;
  S := New(PBufStream, Init(PalName, stCreate, StreamBuffSize));
  if not LowMemory and (S^.Status = stOk) then
  begin
    S^.Write(PalSignature[1], PalSignatureLen);
    S^.Write(BaseApplication^.GetPalette^, SizeOf(TPalette));
    if S^.Status <> stOk then
    begin
      MessageBox(^C + Ph(phCouldNotCreate) + ^M^M^C + PalName, nil,
        mfOkButton + mfError, hcErrorCreateFile);
      DisposeObj(S);
      Assign(F, PalName);
      Erase(F);
      ClearError;
      Exit;
    end;
  end;
  DisposeObj(S);
end;

procedure TPMApp.LoadPalette(FileName: FNameStr);
var
  TmpPalette: TPalette;
  S: PBufStream;
  Signature: string[PalSignatureLen];
begin
  S := New(PBufStream, Init(FileName, stOpenRead, StreamBuffSize));
  if S^.Status <> stOk then
    begin
      MessageBox(^C + Ph(phCouldNotOpen) + ^M^M^C + FileName, nil,
          mfOkButton + mfError, hcErrorOpenFile)
    end
  else begin
    Signature[0] := Char(PalSignatureLen);
    S^.Read(Signature[1], PalSignatureLen);
    if (S^.Status = stOk) and (Signature = PalSignature)
      then begin
        S^.Read(TmpPalette, SizeOf(TPalette));
        if S^.Status = stOk
          then SetNewPalette(TmpPalette)
          else MessageBox(^C + Ph(phErrReadPal), nil,
                          mfOkButton + mfError, hcErrorReadFile);
      end
    else MessageBox(^C + Ph(phErrReadPal), nil,
                    mfOkButton + mfError, hcErrorReadFile);
  end;
  DisposeObj(S);
  DoneMemory;
  Redraw;
end;

procedure TPMApp.RetrievePalette;
var
  PalName: FNameStr;
begin
  PalName := PackDir + PalDir + PalExt;
  if ExecuteDialog(New(PFileDialog, Init(PalExt, Ph(phRetrPal),
                                         Ph(phCName),
                                         fdOkButton + fdHelpButton,
                                         hiPal, hcRetrievePalette)),
                   @PalName) = cmCancel
    then Exit;
  LoadPalette(PalName);
end;

procedure TPMApp.SetScreen;
var
  Mode: Word;
  R:TRect;
begin
  SetIntensity;

  Mode := Config.GetVMode;
  if ScreenMode = Mode then Exit;

  DeleteGadgets;

  DisableSmoothMouse;
  ClearScreen;
  SetScreenMode(Mode);
  SetIntensity;
  ScreenMode := Mode;
  SetMouse;
  InitScreen;

  SetGadgets;
  MenuBar^.Show;
  Redraw;
  InitPackDlgCoord;
end;

function TPMApp.ScreenDelay: LongInt;
begin
  ScreenDelay := Config.GetScreenDelay;
end;

function TPMApp.ShowShadow: boolean;
begin
  ShowShadow := Config.ShowShadow
end;

function TPMApp.TimeBeep: boolean;
begin
  TimeBeep := Config.TimeBeep;
end;

procedure TPMApp.AsciiTab;
var
  P: PAsciiChart;
begin
  P := New(PAsciiChart, Init);
  P^.HelpCtx := hcAsciiTable;
  P^.Number := FirstFreeWin;
  InsertWindow(P);
end;

procedure TPMApp.Calculator;
var
  P: PCalculator;
begin
  P := New(PCalculator, Init);
  P^.HelpCtx := hcCalculator;
  P^.Number := FirstFreeWin;
  InsertWindow(P);
end;

procedure TPMApp.Calendar;
var
  P: PCalendarWindow;
begin
  P := New(PCalendarWindow, Init);
  P^.HelpCtx := hcCalendar;
  P^.Number := FirstFreeWin;
  InsertWindow(P);
end;

function TPMApp.AskQuit: boolean;
begin
  AskQuit := (not NeedAskExit) or
   (MessageBox(Ph(phAskQuit), nil, mfConfirmation + mfYesNoCancel, hcAskQuit)
      = cmYes);
end;

procedure TPMApp.UserScreen;
begin
  DisableSmoothMouse;
  HideMouse;
  US.Show;
  SetMouse;
  Redraw;
  RegisterLastEventTime;
  ShowMouse;
end;

procedure TPMApp.RenumberWindows;
var
  N: Word;
  W: PWindow;

  function IsWindowWithoutN(P: PWindow): boolean; far;
  begin
    IsWindowWithoutN := (P <> PWindow(Desktop^.Last)) and
                        (P^.State and sfVisible <> 0) and
                        ((P^.Number = 0) or (P^.Number > N))
  end;

begin
  if not Assigned(Desktop^.Current)
    then Exit;
  repeat
    N := FirstFreeWin;
    if N = 0 then Break;
    W := PWindow(Desktop^.FirstThat(@IsWindowWithoutN));
    if not Assigned(W) then Exit;
    W^.Number := N;
    W^.Redraw;
  until False;
end;

procedure TPMApp.WinList;
begin
  WindowList(hcWindowList);
end;

procedure TPMApp.ChangeDir;
begin
  ExecuteDialog(New(PChDirDialog, Init(Ph(phChangeCurrDir),
                                       cdNormal + cdHelpButton,
                                       hiChDir, hcFCChDirDBox)),
                nil);
  StoreCurrDir;
end;

procedure TPMApp.CloseAll;

procedure CloseView(P: PView); far;
begin
  Message(P, evCommand, cmClose, nil);
end;

begin
  Desktop^.ForEach(@CloseView)
end;

procedure TPMApp.About;
var
  R: TRect;
  D: PDialog;
begin
  Case IsRegisteredCopy of
     True: R.Assign(0, 0, 46, 21);
    False: R.Assign(0, 0, 46, 20);
  end;
  D := New(PDialog, Init(R, Ph(phAbout)));
  with D^ do
  begin
    Options := Options or ofCentered;
    R.Grow(-1, -1);
    Dec(R.B.Y, 3);
    Insert(New(PStaticText, Init(R, tsAbout)));
    Case IsRegisteredCopy of
       True: R.Assign(18, 18, 28, 20);
      False: R.Assign(18, 17, 28, 19);
    end;
    Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
    HelpCtx := hcAbout;
    Case IsRegisteredCopy of
       True: begin
               R.Assign(3, 14, 43, 15);
               Insert(New(PStaticText, Init(R,
                          Ph(phUserName) + ' ' + CryptStr(UserName))));
               R.Move(0, 1);
               Insert(New(PStaticText, Init(R,
                          Ph(phUserCompany) + ' ' + CryptStr(UserCompany))));
               R.Move(0, 1);
               Insert(New(PStaticText, Init(R,
                          Ph(phUserNum) + ' ' + CryptStr(UserNum))));
             end;
      False: begin
               R.Assign(3, 14, 43, 16);
               Insert(New(PStaticText, Init(R,
                          ^C + Ph(phUnregisteredShareware))));
             end;
    end;
  end;
  if ValidView(D) <> nil then
  begin
    Desktop^.ExecView(D);
    DisposeObj(D);
  end;
end;

procedure TPMApp.DosShell;
begin
  ExecuteCmd('', '', False, False, True, '512');
end;

procedure TPMApp.Colors;
var
  D: PColorDialog;
begin
  D := New(PColorDialog, Init('',
    ColorGroup(Ph(phDesktop),
      ColorItem(Ph(phColor),         1,
      nil),
    ColorGroup(Ph(phMenus),          PackMenusColorItems,
    ColorGroup(Ph(phDirectories),    PackDirColorItems,
    ColorGroup(Ph(phDialogs),        PackDialogsColorItems,
    ColorGroup(Ph(phEditor),         PackEditorColorItems,
    ColorGroup(Ph(phAnnWindow),      PackAnnColorItems,
    ColorGroup(Ph(phAsciiTabForCS),  PackAsciiColorItems,
    ColorGroup(Ph(phCalendar),       PackCalendarColorItems,
    ColorGroup(Ph(phHelp),           PackHelpColorItems,
    ColorGroup(Ph(phScreenRest),
      ColorItem(Ph(phStar),          136,
      ColorItem(Ph(phNewStar),       137,
      nil)),
    nil))))))))))));
  D^.HelpCtx := hcOCColorsDBox;
  if ExecuteDialog(D, BaseApplication^.GetPalette) <> cmCancel then
  begin
    DoneMemory;    { Dispose all group buffers }
    Redraw;        { Redraw application with new palette }
  end;
end;

procedure TPMApp.DosCommandDialog;
var
  Cmd: String;
  DelayScreen: boolean;
  RestCD: boolean;
  ClearKbd: boolean;
begin
  Cmd := InputDosCmd(ClearKbd, DelayScreen, RestCD);
  if FullTrim(Cmd) <> ''
    then ExecuteCmd(Cmd, '', ClearKbd, DelayScreen, RestCD, '512');
end;

procedure TPMApp.Mouse;
var
  D: PDialog;
  Data: word;
begin
  D := New(PMouseDialog, Init);
  D^.HelpCtx := hcOMMouseDBox;
  Data := 0;
  if MouseReverse
    then Data := Data or 1;
  if SmoothMouse
    then Data := Data or 2;
  if ExecuteDialog(D, @Data) = cmCancel
    then Exit;
  MouseReverse := Data and 1 = 1;
  if (not SmoothMouse) and (not SMInstalled) and (Data and 2 = 2)
    and (not LinkBlock^.GetSMProh)
    and not (Lo(ScreenMode) in [smBW80, smMono])
      then if MessageBox(^C + Ph(phAskReload4Mouse), nil,
                mfInformation + mfYesButton + mfNoButton, hcAskReload4Mouse)
               = cmYes
             then begin
               SmoothMouse := Data and 2 = 2;
               ReloadFlag := True;
             end;
  SmoothMouse := Data and 2 = 2;
  SetMouse;
end;

procedure TPMApp.Preferences;

procedure ChangeConfig(NewConfData: TConfigData);
var
  OldConfig: TConfig;
begin
  OldConfig.Init;
  OldConfig := Config;
  Config.SetData(NewConfData);
  if OldConfig.ShowShadow <> Config.ShowShadow
    then SetShadows;
  if (OldConfig.ShowHeap <> Config.ShowHeap)
   or (OldConfig.ShowClock <> Config.ShowClock)
    then SetGadgets;
  if OldConfig.AutoIndent <> Config.AutoIndent
    then SetAutoIndentMode;
  if OldConfig.CreateBak <> Config.CreateBak
    then SetBakFiles;
  if OldConfig.GetVMode <> Config.GetVMode
    then SetScreen;
end;

var
  NewConfData: TConfigData;
begin
  Config.GetData(NewConfData);
  if ExecuteDialog(New(PPrefDialog, Init), @NewConfData) <> cmCancel
    then ChangeConfig(NewConfData);
end;

procedure TPMApp.ChangeInterface;
begin
  ExecuteDialog(New(PInterfaceDialog, Init), @InterfaceFlags);
  DoneMemory;
  Redraw;
end;

procedure TPMApp.FileOpen(FileName: PathStr);
begin
  if ExecuteDialog(New(PFileDialog, Init(AllFilesMask, Ph(phOpenAFile),
    Ph(phCName), fdOpenButton + fdHelpButton, hiOpen, hcFOFileOpenDBox)),
    @FileName) <> cmCancel
  then OpenEditOrDir(FileName);
end;

procedure TPMApp.OpenEditOrDir(FileName: FNameStr);
begin
  if FileName = '' then Exit;
  if (Pos('?', FileName) <> 0) or (Pos('*', FileName) <> 0)
    then begin
      FileOpen(FileName);
      Exit;
    end;
  FileName := FExpand(FileName);
  if IsDirectoryFile(FileName)
    then OpenDirWin(FileName)
  else if IsDesktopFile(FileName)
    then LoadDskName := FileName
  else if IsPaletteFile(FileName)
    then LoadPalette(FileName)
  else begin
    if GetFileSize(FileName) > $FFF0
      then begin
        if not CallExtEditor(FileName)
          then MessageBox(^C + Ph(phNotEnoughMem), nil,
                          mfError + mfOkButton + mfInsertInApp, hcNoMemory);
      end
    else OpenEditor(FileName, True);
  end;
end;

function TPMApp.IsDesktopFile(FileName: FNameStr): boolean;
var
  S: PBufStream;
  Signature: String;
begin
  IsDesktopFile := False;
  if StrUpCase(GetFExt(FileName)) <> DskExtUp
    then Exit;

  S := New(PBufStream, Init(FileName, stOpenRead, 1024));
  Signature[0] := Char(DskSignatureLen);
  S^.Read(Signature[1], DskSignatureLen);
  if (S^.Status = stOk) and
    ((Signature = DskSignature) or (Signature = DSKSignatureOld))
  then IsDesktopFile := True;
  DisposeObj(S);
end;

function TPMApp.IsPaletteFile(FileName: FNameStr): boolean;
var
  S: PBufStream;
  Signature: String;
begin
  IsPaletteFile := False;
  if StrUpCase(GetFExt(FileName)) <> PalExtUp
    then Exit;

  S := New(PBufStream, Init(FileName, stOpenRead, 1024));
  Signature[0] := Char(PalSignatureLen);
  S^.Read(Signature[1], PalSignatureLen);
  if (S^.Status = stOk) and (Signature = PalSignature)
    then IsPaletteFile := True;
  DisposeObj(S);
end;

procedure TPMApp.OpenDesktop;
var
  FileName: FNameStr;
  ConfFileName: FNameStr;
begin
  if InitWorks or (FullTrim(LoadDskName) = '') then Exit;
  FileName := LoadDskName;
  LoadDskName := '';
  ConfFileName := GetFDir(FileName) + GetFName(FileName) + ConfExtUp;

  if (Config.ASDesktop) and not FNamesEqual(FileName, LinkBlock^.GetDskFile)
    then SaveDesktop(LinkBlock^.GetDskFile, False, False);
  if (Config.ASConfig) and not FNamesEqual(ConfFileName, LinkBlock^.GetConfFile)
    then SaveConfig(LinkBlock^.GetConfFile, False);

  if not ClearDesktop
    then Exit;

  if FileExist(ConfFileName)
    then RetrieveConfig(ConfFileName, False, roRetrieveOpt);
  RetrieveDesktop(FileName, False, False);

  LinkBlock^.SetDskFile(FileName);
  LinkBlock^.SetConfFile(ConfFileName);

  Message(Desktop, evBroadcast, cmUpdateCalendar, nil);
end;

procedure TPMApp.OpenNewDirWin;
var
  FileName: FNameStr;
  p: Pointer;
  Cmd: Word;
begin
  FileName := DirExt;
  Cmd := cmYes;
  if ExecuteDialog(New(PFileDialog, Init(DirExt, Ph(phCreateDir),
    Ph(phCName), fdOkButton + fdHelpButton, hiNewDir, hcCreateDirDlg)),
    @FileName) <> cmCancel
      then begin
        p := @FileName;
        if FileExist(FileName)
          then begin
            Cmd := MessageBox(Ph(phFileExist_Overvrite), @p,
                   mfConfirmation + mfYesNoCancel, hcFileExist);
            if Cmd = cmCancel then Exit;
          end;
        if Cmd = cmYes then
          if not CreateNewDirectory(FileName)
            then begin
              MessageBox(^C + Ph(phCouldNotCreate) + ^M^M^C' ' + FileName,
              nil, mfError + mfOkButton, hcErrorCreateFile);
              Exit;
            end;
        if IsDirectoryFile(FileName)
          then OpenDirWin(FileName)
          else MessageBox(^C + Ph(phErrorOpenDirFile) + ^M^M^C + FileName,
                          nil, mfError + mfOkButton, hcErrorOpenDirFile);

      end;
end;

procedure TPMApp.OpenDirWin(FileName: FNameStr);
var
  R: TRect;
begin
  GetWinSize(R, wtDirWindow);
  InsertWindow(New(PDirWindow, Init(R, FileName, FirstFreeWin)));
end;

procedure TPMApp.OpenIntEditor(FileName: FNameStr);
var
  P: PDirWindow;
begin
  FileName := FullTrim(FileName);
  if FileName = ''
    then Exit;
  FileName := FExpand(FileName);
  P := Message(Desktop, evBroadcast, cmSearchDirWindow, @FileName);
  if Assigned(P)
    then P^.Select
  else OpenEditOrDir(FileName);
end;

procedure TPMApp.OpenAnnWindow;
var
  P: PAnnWindow;
  R: TRect;
  DirWind: PDirWindow;
begin
  Desktop^.GetExtent(R);
  R.A.X := R.B.X div 2;
  P := SearchAnnWindow;

  Desktop^.Lock;

  if Assigned(P)
    then P^.Select
  else InsertWindow(New(PAnnWindow, Init(R)));

  DirWind := FirstDirWindow;
  if Assigned(DirWind)
    then DirWind^.DirectoryBox^.ChangeAnn;

  Desktop^.Unlock;
end;

procedure TPMApp.OutputWindow;
var
  OutW: POutputWindow;
  R: TRect;
begin
  OutW := Message(Desktop, evBroadcast, cmSearchOutputWin, nil);
  if Assigned(OutW)
    then OutW^.Select
  else begin
    Desktop^.GetExtent(R);
    InsertWindow(New(POutputWindow, Init(R, Ph(phOutputWinTitle),
                                    FirstFreeWin, @US, hcOutputWindow)));
  end;
end;

procedure TPMApp.ExecuteCmd(Cmd: String; StartDir: DirStr;
                 ClearKbd, DelayScr, RestCD: boolean; EnvSize: String);
begin
  if not Desktop^.Valid(cmClose)
    then begin
      Exit;
      LinkBlock^.SetDelProgFlag(False);
    end;

  LinkBlock^.SetFirstStartFlag(False);

  Randomize;

  if Config.ASDesktop
    then LinkBlock^.SetTmpDskFile(LinkBlock^.GetDskFile)
  else begin
    LinkBlock^.SetTmpDskFile(BuildTmpDskName);
    LinkBlock^.SetDelTmpDskFlag(True);
  end;

  if Config.ASConfig
    then LinkBlock^.SetTmpConfFile(LinkBlock^.GetConfFile)
  else begin
    LinkBlock^.SetTmpConfFile(BuildTmpConfName);
    LinkBlock^.SetDelTmpConfFlag(True);
  end;

  SaveConfig(LinkBlock^.GetTmpConfFile, False);
  SaveDesktop(LinkBlock^.GetTmpDskFile, False, True);

  LinkBlock^.SetDosCmd(FullTrim(Cmd));
  LinkBlock^.SetEnvSize(EnvSize);
  LinkBlock^.SetRestCurrDirFlag(RestCD);
  LinkBlock^.SetDelayScreen(DelayScr);
  LinkBlock^.SetClearKbd(ClearKbd);

  LinkBlock^.SetExitFlag(False);
  ChangeDirectory(StartDir);

  Message(@Self, evCommand, cmExitPM, nil);
end;

procedure TPMApp.RestCurrDir(Conditional: boolean);
var
  D: DirStr;
begin
  if (not Conditional) or (LinkBlock^.GetRestCurrDirFlag)
    then begin
      D := LinkBlock^.GetCurrDir;
      ChangeDirectory(D);
    end;
end;

procedure TPMApp.StoreCurrDir;
begin
  LinkBlock^.SetCurrDir(GetCurrDir);
end;

procedure TPMApp.DelTmpFiles;
begin
  if FirstStart then Exit;

  if LinkBlock^.GetDelTmpDskFlag
    then EraseFile(LinkBlock^.GetTmpDskFile);
  if LinkBlock^.GetDelTmpConfFlag
    then EraseFile(LinkBlock^.GetTmpConfFile);

  if LinkBlock^.GetDelProgFlag
    then EraseFile(LinkBlock^.GetDosCmd);
end;

function TPMApp.CalcWorkDir: DirStr;
var
  s: string[1];
  WD: DirStr;
begin
  WD := LinkBlock^.GetWorkDir;
  FullTrim(WD);
  if WD[Length(WD)] = '\'
    then s := ''
    else s := '\';
  CalcWorkDir := WD + s;
end;

function TPMApp.BuildRandFName(FName: FNameStr): FNameStr;
var
  i: Integer;
begin
  for i := 5 to 8 do
    FName[i] := chr(ord('0') + Random(10));
  BuildRandFName := FName;
end;

function TPMApp.BuildTmpConfName: FNameStr;
begin
  BuildTmpConfName := CalcWorkDir + BuildRandFName(TmpConf);
end;

function TPMApp.BuildTmpDskName: FNameStr;
begin
  BuildTmpDskName := CalcWorkDir + BuildRandFName(TmpDsk);
end;

procedure TPMApp.SetWorkDir(Conditional: boolean);
begin
  if not Conditional or FirstStart then
    if FullTrim(Config.GetWorkDir) = ''
      then LinkBlock^.SetWorkDir(GetCurrDir)
    else LinkBlock^.SetWorkDir(Config.GetWorkDir);
end;

procedure TPMApp.StartBeep;
begin
  if FirstStart
    then begin
      Sound(1500);
      Delay(5);
      NoSound;
    end;
end;

function TPMApp.FirstStart: boolean;
begin
  FirstStart := LinkBlock^.GetFirstStartFlag;
end;

procedure TPMApp.SetOptions;
begin
  SetScreen;
  SetMouse;
  SetShadows;
  SetWorkDir(True);
  SetBakFiles;
  SetGadgets;
  if not FNamesEqual(CalcLngFileName, OldLngFileName)
    then LoadLanguage(CalcLngFileName);
end;

function TPMApp.OpenEditor(FileName: FNameStr; Visible: Boolean): PEditWindow;
var
  P, P1: PView;
  R: TRect;
  WinNum: Integer;
  CurPtr: Word;

function FindWin(P: PView): boolean;
begin
  FindWin := (TypeOf(TEditWindow) = TypeOf(P^)) and
    FNamesEqual(PEditWindow(P)^.Editor^.FileName, FileName) and
    (FullTrim(PEditWindow(P)^.Editor^.FileName) <> '')
end;

begin
  P1 := Desktop^.FirstThat(@FindWin);
  P := P1;
  if Assigned(P1) then P1^.Select
  else begin
    GetWinSize(R, wtEditWindow);
    if Visible
      then WinNum := FirstFreeWin
    else WinNum := wnNoNumber;
    P := BaseApplication^.ValidView(New(PEditWindow,
      Init(R, FileName, WinNum)));
    if not Assigned(P) then
    begin
      OpenEditor := nil;
      Exit;
    end;
    if not Visible then P^.Hide;
    PEditWindow(P)^.Editor^.AutoIndent := Config.AutoIndent;
    if FNamesEqual(FileName, GlobalExtName)
      then P^.HelpCtx := hcEditGlobalExt
    else P^.HelpCtx := hcEditor;
    if Visible and ClosedFiles^.GetFileInfo(FExpand(FileName), CurPtr)
      and (PEditWindow(P)^.Editor^.BufLen >= CurPtr) and RestoreCurPos
      then begin
        PEditWindow(P)^.Editor^.SetCurPtr(CurPtr, 0);
        PEditWindow(P)^.Editor^.TrackCursor(True);
      end;
    DeskTop^.Insert(P);
  end;
  OpenEditor := PEditWindow(P);
  UpdateCFMenu;
end;

procedure TPMApp.ShowClip;
var
  R: TRect;
begin
(*
{$ifndef DPMI}
  if ClipFnsAvail
    then begin
      MessageBox(Ph(phUseWinClip), nil, mfInformation + mfOkButton,
                 hcUseWinClip);
      Exit;
    end;
{$endif}
*)
  if not Assigned(ClipWindow)
    then begin
      OutOfMemory;
      Exit;
    end;
  if ClipWindow^.State and sfVisible = 0
  then begin
    ClipWindow^.Number := FirstFreeWin;
    GetWinSize(R, wtEditWindow);
    ClipWindow^.Origin := R.A;
    ClipWindow^.ChangeBounds(R);
  end;
  ClipWindow^.Select;
  ClipWindow^.Show;
end;

function TPMApp.IsClipboard(P: PView): Boolean;
begin
  IsClipboard := (TypeOf(TEditWindow) = TypeOf(P^)) and
    (Pointer(PEditWindow(P)^.Editor) = Pointer(Clipboard));
end;

procedure TPMApp.SetAutoIndentMode;

procedure SetAI(P: PView); far;
begin
  if TypeOf(TEditWindow) = TypeOf(P^)
    then PEditWindow(P)^.Editor^.AutoIndent := Config.AutoIndent;
end;

begin
  Desktop^.ForEach(@SetAI);
end;

procedure TPMApp.SetBakFiles;
begin
  Case Config.CreateBak of
     True: EditorFlags := EditorFlags or efBackupFiles;
    False: EditorFlags := EditorFlags and not efBackupFiles;
  end;
end;

procedure TPMApp.SaveAll;

procedure SaveFile(P: PView); far;
begin
  if (TypeOf(TEditWindow) = TypeOf(P^)) and (P^.State and sfVisible <> 0)
    and (not IsClipboard(P)) and PEditWindow(P)^.Editor^.Modified
  then Message(P, evCommand, cmSave, nil);
end;

begin
  Desktop^.ForEach(@SaveFile);
end;

procedure TPMApp.GoToLine;
var
  R: TRect;
  LineData: String[LineNumLen];
  LineNum: Word;
  c: Integer;

begin
  LineData := HistoryStr(hiLine, 0);
  if FullTrim(LineData) = ''
    then LineData := '1';
  if ExecuteDialog(New(PLineNumDialog, Init), @LineData) <> cmCancel then
  begin
    Val(LineData, LineNum, c);
    PEditor(PEditWindow(Desktop^.Current)^.Editor)^.SetCurPtr(
     PEditor(PEditWindow(Desktop^.Current)^.Editor)^.LineMove(0,LineNum-1),0);
     PEditor(PEditWindow(Desktop^.Current)^.Editor)^.TrackCursor(True);
  end;
end;

procedure TPMApp.GetWinSize(var R: TRect; WindowType: Word);

function IsEditWindow(P: PView): Boolean; far;
begin
  IsEditWindow := (TypeOf(TEditWindow) = TypeOf(P^)) and
                       (P^.State and sfVisible <> 0);
end;

function IsDirWindow(P: PView): Boolean; far;
begin
  IsDirWindow := (TypeOf(TDirWindow) = TypeOf(P^)) and
                       (P^.State and sfVisible <>0);
end;

var
  P: PView;

begin
  Case WindowType of
    wtEditWindow: P := Desktop^.FirstThat(@IsEditWindow);
    wtDirWindow:  P := Desktop^.FirstThat(@IsDirWindow);
  else P := nil;
  end;
  if Assigned(P) then
  begin
    P^.GetBounds(R);
    if (P^.Size.X > MinWinSize.X) then Inc(R.A.X);
    if (P^.Size.Y > MinWinSize.Y) then Inc(R.A.Y);
  end
  else Desktop^.GetExtent(R);
end;

function TPMApp.GetPalette: PPalette;
const
  CNewColor = CAppColor + CHelpColor + CScreenRestColor + CDirColor +
              CAsciiColor;
  CNewBlackWhite = CAppBlackWhite + CHelpBlackWhite + CScreenRestBlackWhite +
                   CDirBlackWhite + CAsciiBlackWhite;
  CNewMonochrome = CAppMonochrome + CHelpMonochrome + CScreenRestMonochrome +
                   CDirMonochrome + CAsciiMonochrome;
  P: array[apColor..apMonochrome] of string[Length(CNewColor)] =
    (CNewColor, CNewBlackWhite, CNewMonochrome);
begin
  GetPalette := @P[AppPalette];
end;

procedure TPMApp.Bell;
var
  i: byte;
begin
  for i := 1 to 10 do
    begin
      Sound(500);
      Delay(30);
      KeyPressed;
      NoSound;
      Delay(20);
    end;
end;

procedure TPMApp.CheckBellRequest;
begin
  if BellRequest = 5
    then DoAlarmSound;
  if Config.GetBellFlag then
    Case BellRequest of
      1: Bell;
      2: OpenSound;
      3: LockSound;
      4: StartBeep;
    end;
  BellRequest := 0;
end;

procedure TPMApp.ReloadPackMain;
begin
  if not ReloadFlag then Exit;
  ReloadFlag := False;
  ExecuteCmd(#0, '', False, False, True, '512');
end;

procedure TPMApp.RegularActions;
begin
  if NeedUpdateCFMenu then UpdateCFMenu;
  UpdateAnnotation;
  if UnlockDesktop
    then begin
      Desktop^.Unlock;
      UnlockDesktop := False;
    end;
  if CloseWin
    then begin
      Message(Application, evCommand, cmClose, nil);
      CloseWin := False;
    end;
  ReloadPackMain;
  OpenDesktop;
  ClearKeyboard;
  SetCommandsState;
  if HackersHere then LockUp;
end;

procedure TPMApp.GetEvent(var Event: TEvent);
var
  W: PWindow;
  HFile: PHelpFile;
  HelpStrm: PDosStream;
  ErrorCode: LongInt;
  StLn: PStatusLine;
  R: TRect;
const
  HelpInUse: Boolean = False;

begin
  RegularActions;
  StLn := StatusLine;
  if AltDown and (ShiftDown or CtrlDown)
    then StatusLine := nil;

  inherited GetEvent(Event);  { <--- }

  if Event.What <> evNothing
    then CancelAlt := True;

  UpdateGadgets;
  StatusLine := StLn;
  CheckHotKey(Event);

  case Event.What of
    evCommand:
      if ((Event.Command = cmHelp) or (Event.Command = cmLastHelp)
       or (Event.Command = cmHelpIndex))
       and not (HelpInUse or CriticalArea)
       and not ((MouseButtons <> 0) and (GetHelpCtx = hcDragging))
        then begin
          if LowMemory
            then begin
              OutOfMemory;
              Exit;
            end;
          HelpInUse := True;
          HelpStrm := New(PEncStream, Init(CalcHelpName, stOpenRead, 2048));
          HFile := New(PHelpFile, Init(HelpStrm));
          if HelpStrm^.Status <> stOk
            then begin
              ErrorCode := HelpStrm^.Status;
              MessageBox(^C + Ph(phCouldNotOpen) + ' ' + CalcHelpName, nil,
                mfError + mfOkButton + mfInsertInApp, hcErrorOpenFile);
              DisposeObj(HFile);
            end
          else begin
            R.Assign(0, 0, 65, 21);
            if Event.Command = cmHelpIndex
              then W := New(PHelpWindow, Init(R, HFile, Ph(phHelp),
                                            hcAbout, cmHelp))
            else W := New(PHelpWindow, Init(R, HFile, Ph(phHelp),
                                            GetHelpCtx, Event.Command));
            if ValidView(W) <> nil
              then begin
                W^.HelpCtx := hcHelpWindow;
                ExecView(W);
                DisposeObj(W);
              end;
            ClearEvent(Event);
          end;
          HelpInUse := False;
        end;
  end;
end;

procedure TPMApp.ChangeWorkDir;
var
  Dir: DirStr;
begin
  Dir := Config.GetWorkDir;
  ChangeDirectory(Dir);
  if ExecuteDialog(New(PChDirDialog, Init(Ph(phChangeWorkDir),
                                          cdNormal + cdHelpButton,
                                          hiChWorkDir, hcChangeWorkDir)),
                   @Dir) = cmOk
    then Config.SetWorkDir(Dir);
  RestCurrDir(False);
  SetWorkDir(False);
end;

procedure TPMApp.ChangeLanguage;
var
  OldLngName, LngFileName: FNameStr;
  Command: Word;
begin
  OldLngName := CalcLngFileName;
  LngFileName := PackDir + LngExt;
  Command := ExecuteDialog(New(PFileDialog, Init(LngExt,
                                     Ph(phChangeLngFile),
                                     Ph(phCName),
                                     fdOkButton + fdClearButton + fdHelpButton,
                                     hiReadLng, hcChangeLanguage)),
                   @LngFileName);

  if Command = cmCancel
    then Exit;
  if Command = cmFileClear
    then LngFileName := '';
  if FNamesEqual(Config.GetLngFile, LngFileName)
    then Exit;
  Config.SetLngFile(LngFileName);
  LngFileName := CalcLngFileName;
  if not LoadLanguage(LngFileName)
    then begin
      Config.SetLngFile(OldLngName);
      MessageBox(^C + Ph(phLngFileReadError) + ^M^M^C + LngFileName,
        nil, mfError + mfOkButton, hcErrorReadFile);
    end;
end;

function TPMApp.LoadLanguage(LngName: FNameStr): boolean;
begin
  LoadLanguage := False;
  if FullTrim(LngName) = ''
    then ReadLngExe
  else ReadLanguage(LngName, LngSign, rtFile);
  if LngReadError <> stOk
    then begin
      LngReadError := stOk;
      Exit;
    end;
  LoadLanguage := True;
  DeleteGadgets;
  DisposeObj(MenuBar);
  DisposeObj(StatusLine);
  DoneLocalMenus;
  InitMenuBar;
  InitStatusLine;
  Insert(MenuBar);
  Insert(StatusLine);
  SetGadgets;
  DoneMemory;
  Redraw;
  UpdateCFMenu;
  OldLngFileName := LngName;
end;

procedure TPMApp.SetProtections;
begin
  Message(Desktop, evBroadcast, cmSetProtections, nil);
end;

procedure TPMApp.ClearKeyboard;
begin
  if not Assigned(LinkBlock) then Exit;
  if LinkBlock^.GetClearKbd
    then while KeyPressed do ReadKey;
  LinkBlock^.SetClearKbd(False);
end;

procedure TPMApp.VerticalTile;
begin
  Desktop^.TileColumnsFirst := True;
  inherited Tile;
end;

procedure TPMApp.HorisontalTile;
begin
  Desktop^.TileColumnsFirst := False;
  inherited Tile;
end;

procedure TPMApp.LastDesktop;
var
  DskName, CurName: FNameStr;
begin
  if DskStack^.Count < 2 then Exit;
  CurName := DskStack^.Pop;
  DskName := DskStack^.Pop;
  if IsDesktopFile(DskName)
    then begin
      DskStack^.Push(DskName);
      LoadDskName := DskName;
    end
  else DskStack^.Push(CurName);
end;

procedure TPMApp.DesktopStack;
var
  NewDskName: FNameStr;
begin
  if DskStack^.Count < 2 then Exit;
  if ExecuteDialog(New(PDskStackDlg, Init(DskStack)), @NewDskName) <> cmOk
  then Exit;
  if IsDesktopFile(NewDskName)
    then LoadDskName := NewDskName;
end;

{ Возвращает каталог файла из активного окна редактора }
function TPMApp.GetDirForOpen: DirStr;
var
  DirForOpen: DirStr;
  FileName: PathStr;
begin
  DirForOpen := '';
  if (Assigned(Desktop^.Current))
    and (TypeOf(Desktop^.Current^) = TypeOf(TEditWindow))
    and not IsClipBoard(Desktop^.Current)
  then begin
    FileName := PFileEditor(PEditWindow(Desktop^.Current)^.Editor)^.FileName;
    if FullTrim(FileName) <> ''
      then DirForOpen := GetFDir(FileName);
  end;
  GetDirForOpen := DirForOpen;
end;

function TPMApp.IsRegisteredCopy: boolean;
var
  c: Integer;
  N: LongInt;
begin
  { Хакеру работа }
  IsRegisteredCopy := False;

  RegularActions;
{$ifndef Debug}
  if (FullTrim(UserName) = '') or (FullTrim(UserNum) = '')
    then Exit;
{$endif}
  UpdateGadgets;
  CheckMouseInCorner;

  IsRegisteredCopy := IsRegCopy;

  CheckBellRequest;
  CheckAlarm;
{$ifdef Debug}
  IsRegisteredCopy := True;
{$endif}
end;

procedure TPMApp.CallMenu4Editor;
var
  Action: TAction;
  FileName: FNameStr;
begin
  if (FirstDirWindow = nil) or
     (TypeOf(Desktop^.Current^) = TypeOf(TAnnEdWindow))
  then Exit;
  FileName := PEditWindow(Desktop^.Current)^.Editor^.FileName;
  Action.Init(afDoMenuByExt,
              NewExecInfo('', FileName, '', '', '512', '', nil,
                          False, False, True));
  FirstDirWindow^.DirectoryBox^.DoAction(Action);
end;

function TPMApp.CheckRegisteredCopy: boolean;
var
  c: Integer;
  N: LongInt;
begin
  { Хакеру работа }

  CheckRegisteredCopy := False;

  RegularActions;
  if (FullTrim(UserName) = '') or (FullTrim(UserNum) = '')
    then Exit;
  UpdateGadgets;
  CheckMouseInCorner;

  Val(CryptStr(UserNum), N, c);
  CheckRegisteredCopy := (N <> 0) and (Ln(N) = CryptedNum);

  CheckBellRequest;
  CheckAlarm;
end;

procedure TPMApp.UpdateCFMenu;
begin
  UpdateClosedFilesMenu(ClosedFiles);
  NeedUpdateCFMenu := False;
end;

procedure TPMApp.OpenClosedFile(Num: Integer);
begin
  if not IsRegisteredCopy
    then begin
      Remind;
      Exit;
    end;
  OpenEditOrDir(GetClosedFileName(ClosedFiles, Num));
  if GetClosedFileName(ClosedFiles, 1) <> ''
    then FilesMenu^.SubMenu^.Default := ClosedFilesItemPtr^.Next^.Next
  else FilesMenu^.SubMenu^.Default := FilesMenu^.SubMenu^.Items;
end;

function TPMApp.CallExtEditor(FileName: FNameStr): boolean;
var
  DirWin: PDirWindow;
  EditorName: FNameStr;
begin
  CallExtEditor := False;
  DirWin := FirstDirWindow;
  if not Assigned(DirWin) or
     ((FileName = '') and not Assigned(Desktop^.Current))
  then Exit;
  EditorName := DirWin^.GetDirPtr^.GetExtEditor;
  if FileName = ''
    then begin
      if TypeOf(Desktop^.Current^) <> TypeOf(TEditWindow)
        then Exit;
      FileName := PEditWindow(Desktop^.Current)^.Editor^.FileName;
    end;
  if (FileName = '') or not FileExist(EditorName) then Exit;

  ExecuteCmd(EditorName + ' ' + FileName, '', False, False, True, '512');
  CallExtEditor := True;
end;

procedure TPMApp.LastDocument;
begin
  OpenEditOrDir(LastDocName);
end;

function TPMApp.CalcRegFileName: FNameStr;
var
  FileName: FNameStr;
begin
  FileName := AddPath(KeyFileName, LinkBlock^.GetStartDir);
  if not FileExist(FileName)
    then FileName := AddPath(KeyFileName, GetExeDir);
  CalcRegFileName := FileName;
end;

function TPMApp.PhMacro(ANo: Byte): String;
begin
  Case ANo of
    phmNothingDelete: PhMacro := Ph(phm_NothingDelete);
    phmExistanceMacro: PhMacro := Ph(phm_ExistanceMacro);
    phmNotSavedMacros: PhMacro := Ph(phm_NotSavedMacros);
    phmWarningForDeleteMacros: PhMacro := Ph(phm_WarningForDeleteMacros);
    phmWinCreateMacro: PhMacro := Ph(phm_WinCreateMacro);
    phmNameWinRemoveMacro: PhMacro := Ph(phm_NameWinRemoveMacro);
    phmNameWinPlayMacro: PhMacro := Ph(phm_NameWinPlayMacro);
    phmCancel: PhMacro := Ph(phCancel);
    phmMacro: PhMacro := Ph(phm_Macro);
    phmOK: PhMacro := Ph(phCOk);
    phmCreateMacro: PhMacro := Ph(phm_CreateMacro);
    phmStopMacro: PhMacro := Ph(phm_StopMacro);
    phmPlayMacro: PhMacro := Ph(phm_PlayMacro);
    phmRemoveMacro: PhMacro := Ph(phm_RemoveMacro);
    phmDeleteMacros: PhMacro := Ph(phm_DeleteMacros);
    phmCreateMacroHotKey: PhMacro := Ph(phKAltEqual);
    phmStopMacroHotKey: PhMacro := Ph(phKAltMinus);
    phmPlayMacroHotKey: PhMacro := Ph(phKCtrlP);
  else
    PhMacro := '';
  end;
end;

function TPMApp.RunMsgBox(No: Word; Params: Pointer; AOptions: Word): Word;
var
  HCtx: Word;
begin
  Case No of
    phmNothingDelete: HCtx := hcMacro_Nothing2Del;
    phmExistanceMacro: HCtx := hcMacro_ExistanceMacro;
    phmNotSavedMacros: HCtx := hcMacro_Nothing2Del;
    phmWarningForDeleteMacros: HCtx := hcMacro_WarnDelMac;
  else
    HCtx := hcNoContext;
  end;

  RunMsgBox := MessageBox(PhMacro(No), Params, AOptions + mfInsertInApp, HCtx);
end;

function TPMApp.ExtGetHelpCtx(AHelpCtx: Word): Word;
begin
  Case AHelpCtx of
    hcmWinCreateMacro: ExtGetHelpCtx := hcm_WinCreateMacro;
    hcmWinPlayMacro: ExtGetHelpCtx := hcm_WinPlayMacro;
    hcmWinRemoveMacro: ExtGetHelpCtx := hcm_WinRemoveMacro;
    hcmCreateMacro: ExtGetHelpCtx := hcm_CreateMacro;
    hcmStopMacro: ExtGetHelpCtx := hcm_StopMacro;
    hcmPlayMacro: ExtGetHelpCtx := hcm_PlayMacro;
    hcmRemoveMacro: ExtGetHelpCtx := hcm_RemoveMacro;
    hcmDeleteMacros: ExtGetHelpCtx := hcm_DeleteMacros;
  else
    ExtGetHelpCtx := hcNoContext;
  end;
end;

procedure TPMApp.CheckDocSize(FileName: FNameStr);
begin
  if IsRegisteredCopy then Exit;
  if GetFileSize(FileName) > 13 * 1024
    then begin
      EraseFile(FileName);
      MessageBox(^C + Ph(phMaxUnregDocSize), nil,
                 mfInformation + mfOkButton, hcMaxUnregDocSize);
    end;
end;

procedure TPMApp.FillDiskTypes;
var
  i: char;
begin
  for i := 'A' to 'Z' do
    DiskTypes[i] := getDriveType(ord(i) - ord('A') + 1);
end;

end.
