(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PackStLn                                        *)
(* Объект TPackStatusLine                                 *)
(* ( строка статуса программы Packet )                    *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 04.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit PackStLn;

interface

uses Objects, Menus;

type

  PPackStatusLine = ^TPackStatusLine;
  TPackStatusLine = object(TStatusLine)
    constructor Init(R: TRect);
    function Hint(AHelpCtx: Word): String; virtual;
  end;

implementation

uses Views, Drivers, Pack_Hlp, Language, PackLng, PackText, Pack_Cmd;

constructor TPackStatusLine.Init(R: TRect);
begin
  inherited Init(R,
    NewStatusDef(hcDragging, hcDragging,
      NewStatusKey('~' + tsArrows + '~ ' + Ph(phMove), kbNoKey, 0,
      NewStatusKey('~' + Ph(phKShift) + tsPArrows + '~ ' + Ph(phResize), kbNoKey, 0,
      NewStatusKey('~' + tsEnter + '~ ' + Ph(phDone), kbNoKey, 0,
      NewStatusKey('~' + Ph(phKEsc) + '~ ' + Ph(phCancel), kbNoKey, 0,
      NewStatusKey('', kbF1, cmHelp,
      NewStatusKey('', kbAltF1, cmLastHelp,
      NewStatusKey('', kbShiftF1, cmHelpIndex,
      nil))))))),
    NewStatusDef(0, hcHelpWindow - 1,
      NewStatusKey('~' + Ph(phKF1) + '~ ' + Ph(phHelp), kbF1, cmHelp,
      NewStatusKey('~' + Ph(phKAltF3) + '~ ' + Ph(phClose), kbAltF3, cmClose,
      NewStatusKey('~' + Ph(phKF10) + '~ ' + Ph(phMenu), kbF10, cmMenu,
      NewStatusKey('~' + Ph(phKAltF10) + '~ ' + Ph(phLocalMenu), kbAltF10, cmLocalMenu,
      NewStatusKey('~' + Ph(phKAltX) + '~ ' + Ph(phExit), $FFFF, cmQuit,
      NewStatusKey('', kbAltF1, cmLastHelp,
      NewStatusKey('', kbShiftF1, cmHelpIndex,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbF6, cmNext,
      NewStatusKey('', kbShiftF6, cmPrev,
      NewStatusKey('', kbAltBack, cmUndo,
      nil)))))))))))),
    NewStatusDef(hcHelpWindow, hcHelpWindow,
      NewStatusKey('~' + Ph(phKShiftF1) + '~ ' + Ph(phHelpIndex), kbShiftF1, cmHelpIndex,
      NewStatusKey('~' + Ph(phKAltF1) + '~ ' + Ph(phLastHelp), kbAltF1, cmLastHelp,
      NewStatusKey('~' + Ph(phKF5) + '~ ' + Ph(phZoom), kbF5, cmZoom,
      NewStatusKey('~' + Ph(phKEsc) + '~ ' + Ph(phClose), kbAltF3, cmClose,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbBack, cmLastHelp,
      nil)))))),
    NewStatusDef(hcBegShortStatusLine, hcEndShortStatusLine,
      NewStatusKey('~' + Ph(phKF1) + '~ ' + Ph(phHelp), kbF1, cmHelp,
      NewStatusKey('', kbAltF1, cmLastHelp,
      NewStatusKey('', kbShiftF1, cmHelpIndex,
      NewStatusKey('', kbF10, cmMenu,
      NewStatusKey('', kbAltF3, cmClose,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbF6, cmNext,
      NewStatusKey('', kbShiftF6, cmPrev,
      nil))))))))),
    NewStatusDef(hcAnnotateWin, hcEditLocalExtWin,
      NewStatusKey('~' + Ph(phKF1) + '~ ' + Ph(phHelp), kbF1, cmHelp,
      NewStatusKey('~' + Ph(phKF2) + '~ ' + Ph(phDone), kbF2, cmOk,
      NewStatusKey('~' + Ph(phKCtrlF8) + '~ ' + Ph(phDelete), kbCtrlF8, cmDelRes,
      NewStatusKey('~' + Ph(phKEsc) + '~ ' + Ph(phCancel), kbEsc, cmCancel,
      NewStatusKey('', kbCtrlF5, cmResize,
      NewStatusKey('', kbAltF1, cmLastHelp,
      NewStatusKey('', kbAltF3, cmCancel,
      NewStatusKey('', kbShiftF1, cmHelpIndex,
      NewStatusKey('', kbF5, cmZoom,
      NewStatusKey('', kbAltBack, cmUndo,
      nil)))))))))),
    nil))))));
end;

function TPackStatusLine.Hint(AHelpCtx: Word): String;
var
  phInd: integer;
begin
  Case AHelpCtx of
    hcAbout: phInd := phHAboutWin;
    hcSystem: phInd := phHSystemMenu;
    hcSAbout: phInd := phHAbout;
    hcFiles: phInd := phHFiles;
    hcEdit: phInd := phHEdit;
    hcWindows: phInd := phHWindows;
    hcOptions: phInd := phHOptions;
    hcSRefreshDisplay: phInd := phHRefreshDisplay;
    hcSScreenRest: phInd := phHScreenRest;
    hcSAsciiTable: phInd := phHAsciiTab;
    hcSCalculator: phInd := phHCalculator;
    hcSCalendar: phInd := phHCalendar;
    hcSAlarmClock: phInd := phHAlarmClock;
    hcNewFile: phInd := phHNewFile;
    hcNewDir: phInd := phHNewDir;
    hcOpen: phInd := phHOpen;
    hcSave: phInd := phHSave;
    hcSaveAs: phInd := phHSaveAs;
    hcSaveAll: phInd := phHSaveAll;
    hcChangeDir: phInd := phHChangeDir;
    hcDosShell: phInd := phHDosShell;
    hcDosCommand: phInd := phHDosCommand;
    hcUserScreen: phInd := phHUserScreen;
    hcExit: phInd := phHExit;
    hcClosedFile: phInd := phHClosedFile;
    hcEdit: phInd := phHEdit;
    hcUndo: phInd := phHUndo;
    hcSearch: phInd := phHSearch;
    hcFind: phInd := phHFind;
    hcReplace: phInd := phHReplace;
    hcSearchAgain: phInd := phHSearchAgain;
    hcGoToLine: phInd := phHGoToLine;
    hcCut: phInd := phHCut;
    hcCopy: phInd := phHCopy;
    hcPaste: phInd := phHPaste;
    hcClear: phInd := phHClear;
    hcInsRef: phInd := phHInsRef;
    hcShowClip: phInd := phHShowClip;
    hcMarkTarget: phInd := phHMarkTarget;
    hcLastDocument: phInd := phHLastDocument;
    hcWindows: phInd := phHWindows;
    hcVerticalTile: phInd := phHVerticalTile;
    hcHorisontalTile: phInd := phHHorisontalTile;
    hcCascade: phInd := phHCascade;
    hcCloseAll: phInd := phHCloseAll;
    hcResize: phInd := phHResize;
    hcZoom: phInd := phHZoom;
    hcNext: phInd := phHNext;
    hcPrevious: phInd := phHPrevious;
    hcClose: phInd := phHClose;
    hcOpenAnnWin: phInd := phHOpenAnnWin;
    hcOutputWin: phInd := phHOpenOutputWin;
    hcRenumber: phInd := phHRenumber;
    hcWinList: phInd := phHWinList;
    hcOptions: phInd := phHOptions;
    hcOConfig: phInd := phHConfig;
    hcOPreferences: phInd := phHPreferences;
    hcOInterface: phInd := phHInterface;
    hcOMouse: phInd := phHMouse;
    hcOColors: phInd := phHColors;
    hcOLanguage: phInd := phHLanguage;
    hcOWorkDir: phInd := phHWorkDir;
    hcOSaveConfig: phInd := phHSaveConfig;
    hcORetrieveConfig: phInd := phHRetrieveConfig;
    hcOSaveDesktop: phInd := phHSaveDesktop;
    hcORetrieveDesktop: phInd := phHRetrieveDesktop;
    hcOSavePalette: phInd := phHSavePalette;
    hcORetrievePalette: phInd := phHRetrievePalette;
    hcOLastDesktop: phInd := phHLastDesktop;
    hcODesktopStack: phInd := phHDesktopStack;
    hcDirectories: phInd := phHDirectories;
    hcDAddFileItems: phInd := phHAddFileItems;
    hcDAddSubDirs: phInd := phHAddSubDirs;
    hcDSelectItem: phInd := phHSelectItem;
    hcDModifyItems: phInd := phHModifyItems;
    hcDDeleteItems: phInd := phHDeleteItems;
    hcDMoveItems: phInd := phHMoveItems;
    hcDAnnotate: phInd := phHAnnotate;
    hcDCompressDir: phInd := phHCompressDir;
    hcDTreatment: phInd := phHTreatment;
    hcDEditFile: phInd := phHEditFile;
    hcDCollectDocument: phInd := phHCollectDocument;
    hcDEditParameters: phInd := phHEditParameters;
    hcDComParameters: phInd := phHCommonParameters;
    hcDHotKeys: phInd := phHHotKeys;
    hcDSetHotKey: phInd := phHSetHotKey;
    hcDHotKeysList: phInd := phHHotKeysList;
    hcDDirConfig: phInd := phHDirConfig;
    hcDSetProtect: phInd := phHSetProtect;
    hcDGlobalExt: phInd := phHGlobalExt;
    hcDLocalExt: phInd := phHLocalExt;
    hcDTranspose: phInd := phHTranspose;
    hcm_CreateMacro: phInd := phHm_CreateMacro;
    hcm_StopMacro: phInd := phHm_StopMacro;
    hcm_PlayMacro: phInd := phHm_PlayMacro;
    hcm_RemoveMacro: phInd := phHm_RemoveMacro;
    hcm_DeleteMacros: phInd := phHm_DeleteMacros;
    hcOMacro: phInd := phHMacro;
    hcShareware: phInd := phHRegisterNow;
    hcDOpenCopy: phInd := phHOpenCopy;
    hcDCrossRef: phInd := phHCrossRef;
  else
    Hint := '';
    Exit;
  end;
  Hint := Ph(phInd);
end;

end.

