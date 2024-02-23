(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль LocMenus                                        *)
(* Локальные меню                                         *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат   : 14.12.1994                                   *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit LocMenus;

interface

uses

  Objects, Memory, Menus, Views, Drivers, App, Editors, Pack_Cmd,
  Language, PackLng, PackText, Pack_Hlp, Disp_Obj;

  procedure LocalMenu;
  procedure DoneLocalMenus;

implementation

{ Вместо PMApp подставляется имя модуля, }
{ где описана переменная CriticalArea    }
uses PMApp, PackMenu;

const

  BackgrMenu: PMenu = nil;
  EditorMenu: PMenu = nil;
  DirWinMenu: PMenu = nil;

function InitBackgrMenu: PMenuPopup;
var
  R: TRect;
begin

  R.Assign(25, 7, 75, 20);

  if not Assigned(BackgrMenu)
    then BackgrMenu := NewMenu(
      NewItem(Ph(phMAbout) + ts3P, '', kbNoKey, cmAbout, hcSAbout,
      NewLine(
      NewItem(Ph(phMNewFile), Ph(phKShiftF4), kbShiftF4, cmNewFile, hcNewFile,
      NewItem(Ph(phMNewDir) + ts3P, Ph(phKF4), kbF4, cmNewDir, hcNewDir,
      NewItem(Ph(phMOpenLoc) + ts3P, Ph(phKF3), kbF3, cmOpen, hcOpen,
      NewLine(
      NewSubMenu(Ph(phMConfigLoc), hcOConfig, NewMenu(
        NewItem(Ph(phMPreferences) + ts3P, '', kbNoKey, cmPreferences, hcOPreferences,
        NewItem(Ph(phMMouse) + ts3P, '', kbNoKey, cmMouse, hcOMouse,
        NewItem(Ph(phMColors) + ts3P, '', kbNoKey, cmColors, hcOColors,
        NewItem(Ph(phMLanguage) + ts3P, '', kbNoKey, cmLanguage, hcOLanguage,
        NewItem(Ph(phMWorkDir) + ts3P, '', kbNoKey, cmWorkDir, hcOWorkDir,
        nil)))))),
      NewLine(
      NewItem(Ph(phMHotKeysListLoc) + ts3P, Ph(phKShiftF10), kbShiftF10, cmHotKeysList, hcDHotKeysList,
      NewItem(Ph(phMWinListLoc) + ts3P, Ph(phKAlt0), kbAlt0, cmWinList, hcWinList,
    nil)))))))))));
  InitBackgrMenu := New(PMenuPopup, Init(R, BackgrMenu));
end;

function InitEditorMenu: PMenuPopup;
var
  R: TRect;
begin
  R.Assign(15, 7, 75, 22);

  if not Assigned(EditorMenu)
    then EditorMenu := NewMenu(
      NewItem(Ph(phMUndo), Ph(phKAltBksp), kbAltBack, cmUndo, hcUndo,
      NewSubMenu(Ph(phMSearch), hcSearch, NewMenu(
        NewItem(Ph(phMFind) + ts3P, Ph(phKCtrlQF), kbNoKey, cmFind, hcFind,
        NewItem(Ph(phMReplace) + ts3P, Ph(phKCtrlQA), kbNoKey, cmReplace, hcReplace,
        NewItem(Ph(phMSearchAgain), Ph(phKCtrlL), kbNoKey, cmSearchAgain, hcSearchAgain,
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
      NewLine(
      NewItem(Ph(phMHotKeysListLoc) + ts3P, Ph(phKShiftF10), kbShiftF10, cmHotKeysList, hcDHotKeysList,
      NewLine(
      NewItem(Ph(phMOpenLoc) + ts3P, Ph(phKF3), kbF3, cmOpen, hcOpen,
      NewItem(Ph(phMSaveLoc), Ph(phKF2), kbF2, cmSave, hcSave,
      NewItem(Ph(phMSaveAsLoc) + ts3P, '', kbNoKey, cmSaveAs, hcSaveAs,
      NewItem(Ph(phMSaveAllLoc), '', kbNoKey, cmSaveAll, hcSaveAll,
      NewLine(
      NewItem(Ph(phMWinListLoc) + ts3P, Ph(phKAlt0), kbAlt0, cmWinList, hcWinList,
    nil))))))))))))))))))));
  InitEditorMenu := New(PMenuPopup, Init(R, EditorMenu));
end;

function InitDirWinMenu: PMenuPopup;
var
  R: TRect;
begin
  R.Assign(15, 10, 75, 20);

  if not Assigned(DirWinMenu)
    then DirWinMenu := NewMenu(
      NewItem(Ph(phMAddFileItems) + ts3P, Ph(phKIns), kbIns, cmAddFileItems, hcDAddFileItems,
      NewItem(Ph(phMAddSubDirs) + ts3P, Ph(phKF7), kbF7, cmAddSubDirs, hcDAddSubDirs,
      NewItem(Ph(phMModifyItems) + ts3P, Ph(phKCtrlF2), kbCtrlF2, cmModifyItems, hcDModifyItems,
      NewItem(Ph(phMDeleteItems), Ph(phKDel), kbDel, cmDelItems, hcDDeleteItems,
      NewItem(Ph(phMMoveItems) + ts3P, Ph(phKAltF6), kbAltF6, cmMoveItems, hcDMoveItems,
      NewItem(Ph(phMSelectItem), Ph(phKGrayPlus), kbGrayPlus, cmSelectItem, hcDSelectItem,
      NewItem(Ph(phMTranspose), Ph(phKShiftSlash), kbNoKey, cmTranspose, hcDTranspose,
      NewLine(
      TreatmentMenu(
      NewSubMenu(Ph(phMHotKeys), hcDHotKeys, NewMenu(
        NewItem(Ph(phMSetHotKey) + ts3P, Ph(phKShiftF2), kbShiftF2, cmSetHotKey, hcDSetHotKey,
        NewItem(Ph(phMHotKeysList) + ts3P, Ph(phKShiftF10), kbShiftF10, cmHotKeysList, hcDHotKeysList,
      nil))),
      NewItem(Ph(phMAnnotate) + ts3P, Ph(phKCtrlF3), kbCtrlF3, cmAnnotate, hcDAnnotate,
      NewItem(Ph(phMAnnWindowLoc), Ph(phKCtrlF4), kbCtrlF4, cmOpenAnnWindow, hcOpenAnnWin,
      NewLine(
      NewItem(Ph(phMDirConfig) + ts3P, '', kbNoKey, cmDirConfig, hcDDirConfig,
      NewItem(Ph(phMSetProtect) + ts3P, Ph(phKShiftF3), kbShiftF3, cmSetProtect, hcDSetProtect,
      NewItem(Ph(phMCompress), Ph(phKF8), kbF8, cmCompressDir, hcDCompressDir,
      NewLine(
      NewItem(Ph(phMOpenLoc) + ts3P, Ph(phKF3), kbF3, cmOpen, hcOpen,
      NewItem(Ph(phMWinListLoc) + ts3P, Ph(phKAlt0), kbAlt0, cmWinList, hcWinList,
    nil))))))))))))))))))));
  InitDirWinMenu := New(PMenuPopup, Init(R, DirWinMenu));
end;

procedure LocalMenu;
var
  Menu: PMenuPopup;
  Cmd: Word;
begin
  if CriticalArea
     or (Application^.Current <> PView(Desktop))
     or (Assigned(Desktop^.Current) and
         (Desktop^.Current^.State and (sfModal + sfDragging) <> 0))
  then Exit;
  Case Application^.GetHelpCtx of
                  hcDirWindow: Menu := InitDirWinMenu;

        hcEditor, hcClipboard: Menu := InitEditorMenu;

    hcAsciiTable, hcCalendar, hcAnnWindow, hcOutputWindow, hcEditGlobalExt,
    hcCalculator, hcBackgrCtx: Menu := InitBackgrMenu;
  else
    Menu := nil;
  end;

  if not Assigned(Menu) then Exit;

  with Menu^ do Options := Options or ofCentered;
  Message(Menu, evBroadcast, cmCommandSetChanged, nil);
  Cmd := Application^.ExecView(Menu);
  DisposeObj(Menu);
  Message(Application, evCommand, Cmd, nil);
end;

procedure DoneLocalMenus;
begin
  DisposeMenu(BackgrMenu);
  DisposeMenu(EditorMenu);
  DisposeMenu(DirWinMenu);
  BackgrMenu := nil;
  EditorMenu := nil;
  DirWinMenu := nil;
end;

end.
