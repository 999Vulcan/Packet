(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PackMenu                                        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit PackMenu;

interface

uses Menus, EditServ;

const
  ClosedFilesItemPtr: PMenuItem = nil;
  FilesMenu: PMenuItem = nil;

  function NewPackMenu: PMenu;
  function TreatmentMenu(Next: PMenuItem): PMenuItem;
  procedure UpdateClosedFilesMenu(CFColl: PClosedFilesColl);

implementation

uses

  Objects, App, Views, Drivers, Language, PackLng, Pack_Hlp, Pack_Cmd,
  Editors, PackText, StrServ, AppMac;

function TreatmentMenu(Next: PMenuItem): PMenuItem;
begin
  TreatmentMenu :=
    NewSubMenu(Ph(phMTreatment), hcDTreatment, NewMenu(
      NewItem(Ph(phMEditFile), Ph(phKAltF4), kbAltF4, cmEditFile, hcDEditFile,
      NewItem(Ph(phMCollectDocument) + ts3P, Ph(phKCtrlF7), kbCtrlF7, cmCollectDocument, hcDCollectDocument,
      NewItem(Ph(phMEditParameters) + ts3P, Ph(phKCtrlF6), kbCtrlF6, cmEditParameters, hcDEditParameters,
      NewItem(Ph(phMCommonParameters) + ts3P, Ph(phKAltF2), kbAltF2, cmComParameters, hcDComParameters,
      NewItem(Ph(phMCreateBatch) + ts3P, Ph(phKCtrlF9), kbCtrlF9, cmCreateBatch, hcDCreateBatch,
      NewItem(Ph(phMGlobalExt) + ts3P, '', kbNoKey, cmGlobalExt, hcDGlobalExt,
      NewItem(Ph(phMLocalExt) + ts3P, '', kbNoKey, cmLocalExt, hcDLocalExt,
      nil)))))))), Next);
end;

function NewPackMenu: PMenu;
begin
  ClosedFilesItemPtr := NewItem(Ph(phMExit), Ph(phKAltX),
                          kbAltX, cmQuit, hcExit, nil);

  FilesMenu := NewSubMenu(Ph(phMFiles), hcFiles, NewMenu(
      NewItem(Ph(phMNewFile), Ph(phKShiftF4), kbShiftF4, cmNewFile, hcNewFile,
      NewItem(Ph(phMNewDir) + ts3P, Ph(phKF4), kbF4, cmNewDir, hcNewDir,
      NewItem(Ph(phMOpen) + ts3P, Ph(phKF3), kbF3, cmOpen, hcOpen,
      NewItem(Ph(phMSave), Ph(phKF2), kbF2, cmSave, hcSave,
      NewItem(Ph(phMSaveAs) + ts3P, '', kbNoKey, cmSaveAs, hcSaveAs,
      NewItem(Ph(phMSaveAll), '', kbNoKey, cmSaveAll, hcSaveAll,
      NewLine(
      NewItem(Ph(phMChangeDir) + ts3P, '', kbNoKey, cmChangeDir, hcChangeDir,
      NewItem(Ph(phMDosShell), '', kbNoKey, cmDosShell, hcDosShell,
      NewItem(Ph(phMDosCmd) + ts3P, Ph(phKF9), kbF9, cmDosCommand, hcDosCommand,
      NewItem(Ph(phMUserScreen), Ph(phKAltF5), kbAltF5, cmUserScreen, hcUserScreen,
      NewLine(ClosedFilesItemPtr)
      )))))))))))),
    NewSubMenu(Ph(phMDirectories), hcDirectories, NewMenu(
      NewItem(Ph(phMAddFileItems) + ts3P, Ph(phKIns), kbIns, cmAddFileItems, hcDAddFileItems,
      NewItem(Ph(phMAddSubDirs) + ts3P, Ph(phKF7), kbF7, cmAddSubDirs, hcDAddSubDirs,
      NewItem(Ph(phMModifyItems) + ts3P, Ph(phKCtrlF2), kbCtrlF2, cmModifyItems, hcDModifyItems,
      NewItem(Ph(phMDeleteItems), Ph(phKDel), kbDel, cmDelItems, hcDDeleteItems,
      NewItem(Ph(phMRemoveItems), Ph(phKCtrlDel), kbCtrlDel, cmRemoveItems, hcDRemoveItems,
      NewItem(Ph(phMMoveItems) + ts3P, Ph(phKAltF6), kbAltF6, cmMoveItems, hcDMoveItems,
      NewItem(Ph(phMSelectItem), Ph(phKGrayPlus), kbGrayPlus, cmSelectItem, hcDSelectItem,
      NewItem(Ph(phMTranspose), Ph(phKShiftSlash), kbNoKey, cmTranspose, hcDTranspose,
      NewItem(Ph(phMCrossRef) + ts3P, Ph(phKAltF9), kbAltF9, cmCrossRef, hcDCrossRef,
      NewLine(
      TreatmentMenu(
      NewSubMenu(Ph(phMHotKeys), hcDHotKeys, NewMenu(
        NewItem(Ph(phMSetHotKey) + ts3P, Ph(phKShiftF2), kbShiftF2, cmSetHotKey, hcDSetHotKey,
        NewItem(Ph(phMHotKeysList) + ts3P, Ph(phKShiftF10), kbShiftF10, cmHotKeysList, hcDHotKeysList,
        nil))),
      NewItem(Ph(phMAnnotate) + ts3P, Ph(phKCtrlF3), kbCtrlF3, cmAnnotate, hcDAnnotate,
      NewLine(
      NewItem(Ph(phMDirConfig) + ts3P, '', kbNoKey, cmDirConfig, hcDDirConfig,
      NewItem(Ph(phMSetProtect) + ts3P, Ph(phKShiftF3), kbShiftF3, cmSetProtect, hcDSetProtect,
      NewItem(Ph(phMCompress), Ph(phKF8), kbF8, cmCompressDir, hcDCompressDir,
      NewItem(Ph(phMOpenCopy), Ph(phKAltF8), kbAltF8, cmOpenCopy, hcDOpenCopy,
      nil))))))))))))))))))),
    NewSubMenu(Ph(phMEdit), hcEdit, NewMenu(
      NewItem(Ph(phMUndo), Ph(phKAltBksp), kbAltBack, cmUndo, hcUndo,
      NewSubMenu(Ph(phMSearch), hcSearch, NewMenu(
        NewItem(Ph(phMFind) + ts3P, '', kbNoKey, cmFind, hcFind,
        NewItem(Ph(phMReplace) + ts3P, Ph(phKAltF7), kbAltF7, cmReplace, hcReplace,
        NewItem(Ph(phMSearchAgain), '', kbNoKey, cmSearchAgain, hcSearchAgain,
        NewLine(
        NewItem(Ph(phMGoToLineNum) + ts3P, Ph(phKF7), kbF7, cmGoToLine, hcGoToLine,
        nil)))))),
      NewLine(
      NewItem(Ph(phMCut), Ph(phKShiftDel), kbShiftDel, cmCut, hcCut,
      NewItem(Ph(phMCopy), Ph(phKCtrlIns), kbCtrlIns, cmCopy, hcCopy,
      NewItem(Ph(phMPaste), Ph(phKShiftIns), kbShiftIns, cmPaste, hcPaste,
      NewItem(Ph(phMClear), Ph(phKCtrlDel), kbCtrlDel, cmClear, hcClear,
      NewItem(Ph(phMInsertReference) + ts3P, Ph(phKCtrlF8), kbCtrlF8, cmInsRef, hcInsRef,
      NewLine(
      NewItem(Ph(phMShowClip), '', kbNoKey, cmShowClip, hcShowClip,
      NewItem(Ph(phMMarkTarget), Ph(phKShiftF5), kbShiftF5, cmMarkTarget, hcMarkTarget,
      NewLine(
      NewItem(Ph(phMLastDocument), Ph(phKShiftF9), kbShiftF9, cmLastDocument, hcLastDocument,
      nil)))))))))))))),
    NewSubMenu(Ph(phMWindows), hcWindows, NewMenu(
      NewItem(Ph(phMVerticalTile), '', kbNoKey, cmVerticalTile, hcVerticalTile,
      NewItem(Ph(phMHorisontalTile), '', kbNoKey, cmHorisontalTile, hcHorisontalTile,
      NewItem(Ph(phMCascade), '', kbNoKey, cmCascade, hcCascade,
      NewItem(Ph(phMCloseAll), '', kbNoKey, cmCloseAll, hcCloseAll,
      NewItem(Ph(phMRenumber), '', kbNoKey, cmRenumber, hcRenumber,
      NewLine(
      NewItem(Ph(phMResize), Ph(phKCtrlF5), kbCtrlF5, cmResize, hcResize,
      NewItem(Ph(phMZoom), Ph(phKF5), kbF5, cmZoom, hcZoom,
      NewItem(Ph(phMNext), Ph(phKF6), kbF6, cmNext, hcNext,
      NewItem(Ph(phMPrevious), Ph(phKShiftF6), kbShiftF6, cmPrev, hcPrevious,
      NewItem(Ph(phMClose), Ph(phKAltF3), kbAltF3, cmClose, hcClose,
      NewLine(
      NewItem(Ph(phMAnnWindow), Ph(phKCtrlF4), kbCtrlF4, cmOpenAnnWindow, hcOpenAnnWin,
      NewItem(Ph(phMOutputWindow), Ph(phKCtrlF10), kbCtrlF10, cmOutputWindow, hcOutputWin,
      NewItem(Ph(phMWinList) + ts3P, Ph(phKAlt0), kbAlt0, cmWinList, hcWinList,
      nil)))))))))))))))),
    NewSubMenu(Ph(phMOptions), hcOptions, NewMenu(
      NewSubMenu(Ph(phMMacro_), hcOMacro, NewMenu(
        StdMacroMenuItems(nil)),
      NewLine(
      NewSubMenu(Ph(phMConfig), hcOConfig, NewMenu(
        NewItem(Ph(phMPreferences) + ts3P, '', kbNoKey, cmPreferences, hcOPreferences,
        NewItem(Ph(phMInterface) + ts3P, '', kbNoKey, cmInterface, hcOInterface,
        NewItem(Ph(phMMouse) + ts3P, '', kbNoKey, cmMouse, hcOMouse,
        NewItem(Ph(phMColors) + ts3P, '', kbNoKey, cmColors, hcOColors,
        NewItem(Ph(phMLanguage) + ts3P, '', kbNoKey, cmLanguage, hcOLanguage,
        NewItem(Ph(phMWorkDir) + ts3P, '', kbNoKey, cmWorkDir, hcOWorkDir,
        nil))))))),
      NewItem(Ph(phMSaveConf) + ts3P, '', kbNoKey, cmSaveConfig, hcOSaveConfig,
      NewItem(Ph(phMRetrConf) + ts3P, '', kbNoKey, cmRetrieveConfig, hcORetrieveConfig,
      NewLine(
      NewItem(Ph(phMSaveDsk) + ts3P, '', kbNoKey, cmSaveDesktop, hcOSaveDesktop,
      NewItem(Ph(phMRetrDsk) + ts3P, '', kbNoKey, cmRetrieveDesktop, hcORetrieveDesktop,
      NewLine(
      NewItem(Ph(phMSavePal) + ts3P, '', kbNoKey, cmSavePalette, hcOSavePalette,
      NewItem(Ph(phMRetrPal) + ts3P, '', kbNoKey, cmRetrievePalette, hcORetrievePalette,
      NewLine(
      NewItem(Ph(phMLastDesktop), Ph(phKShiftF7), kbShiftF7, cmLastDesktop, hcOLastDesktop,
      NewItem(Ph(phMDesktopStack) + ts3P, Ph(phKShiftF8), kbShiftF8, cmDesktopStack, hcODesktopStack,
      nil))))))))))))))),
  nil)))));

  NewPackMenu := NewMenu(
    NewSubMenu(Ph(phM_), hcSystem, NewMenu(
      NewItem(Ph(phMAbout) + ts3P, '', kbNoKey, cmAbout, hcSAbout,
      NewLine(
      NewItem(Ph(phMRefreshDisplay), '', kbNoKey, cmRefreshDisplay, hcSRefreshDisplay,
      NewItem(Ph(phMScreenRest), '', kbNoKey, cmScreenRest, hcSScreenRest,
      NewLine(
      NewItem(Ph(phMAsciiTab), '', kbNoKey, cmAsciiTab, hcSAsciiTable,
      NewItem(Ph(phMCalendar), '', kbNoKey, cmCalendar, hcSCalendar,
      NewItem(Ph(phMCalculator), '', kbNoKey, cmCalculator, hcSCalculator,
      NewLine(
      NewItem(Ph(phMAlarmClock) + ts3P, '', kbNoKey, cmAlarmClock, hcSAlarmClock,
      nil))))))))))),
    FilesMenu));
end;

procedure UpdateClosedFilesMenu(CFColl: PClosedFilesColl);

procedure DisposeItems;
var
  P, Q: PMenuItem;
begin
  P := ClosedFilesItemPtr^.Next;

  while Assigned(P) do
  begin
    if Assigned(P^.Name) then
    begin
      DisposeStr(P^.Name);
      if P^.Command <> 0 then
        DisposeStr(P^.Param) else
        DisposeMenu(P^.SubMenu);
    end;
    Q := P;
    P := P^.Next;
    Dispose(Q);
  end;
  ClosedFilesItemPtr^.Next := nil;
end;

var
  AddCount: byte;

function AddCFItem(Num: byte): PMenuItem;
var
  FileName: FNameStr;
  N: String;

function FindWin(P: PView): boolean;
begin
  FindWin := (TypeOf(TEditWindow) = TypeOf(P^)) and
    FNamesEqual(PEditWindow(P)^.GetTitle(SizeOf(FNameStr)-1), FileName)
end;

begin
  AddCFItem:= nil;
  if Num = 6 then Exit;

  FileName := GetClosedFileName(CFColl, Num);
  if FileName = '' then Exit;
  Inc(AddCount);
  Str(Num, N);
  AddCFItem := NewItem('~' + N + '~. ' + GetShortFName(FileName, 25),
                       '', kbNoKey, cmClosedFile1 + Num - 1, hcClosedFile,
                       AddCFItem(Num + 1));
end;

begin
  if not Assigned(ClosedFilesItemPtr) then Exit;
  DisposeItems;
  if not Assigned(CFColl) or (CFColl^.Count = 0) then Exit;
  AddCount := 0;
  ClosedFilesItemPtr^.Next := NewLine(AddCFItem(1));
  if AddCount = 0
    then begin
      DisposeItems;
{      FilesMenu^.SubMenu^.Default := FilesMenu^.SubMenu^.Items;}
    end;
{
  else FilesMenu^.SubMenu^.Default := ClosedFilesItemPtr^.Next^.Next;
}
end;

end.
