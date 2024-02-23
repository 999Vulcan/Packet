(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PM_Cmd                                          *)
(* Описания констант команд                               *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 21.02.1994                             *)
(*                                                        *)
(**********************************************************)

unit Pack_Cmd;

interface

uses HelpFile;

const

  cmLastHelp        = cmBackHelp;

  cmAddFileItems    = 101;
  cmAddSubDirs      = 102;
  cmDelItems        = 103;
  cmCompressDir     = 104;
  cmSelectItem      = 105;
  cmModifyItems     = 106;
  cmAnnotate        = 107;
  cmDelRes          = 108;
  cmEditFile        = 109;
  cmEditParameters  = 110;
  cmComParameters   = 111;
  cmMoveItems       = 112;
  cmSetHotKey       = 113;
  cmHotKeysList     = 114;
  cmRenumber        = 115;
  cmDirConfig       = 116;
  cmSetProtect      = 117;
  cmMarkTarget      = 118;
  cmCollectDocument = 119;
  cmVerticalTile    = 120;
  cmHorisontalTile  = 121;
  cmLocalExt        = 122;
  cmLastDesktop     = 123;
  cmDesktopStack    = 124;
  cmAlarmClock      = 125;
  cmTranspose       = 126;
  cmLastDocument    = 127;
  cmInsRef          = 128;
  cmOpenCopy        = 129;
  cmCrossRef        = 130;
  cmRemoveItems     = 131;
  cmCreateBatch     = 132;

{ # 251 зарезервирован для Pack_Dlg }

  cmGoToLine        = 254;

  cmAbout           = 1000;
  cmExitPM          = 1001;
  cmSaveDesktop     = 1004;
  cmRetrieveDesktop = 1005;
  cmRefreshDisplay  = 1006;
  cmMouse           = 1007;
  cmColors          = 1008;
  cmPreferences     = 1009;
  cmSaveConfig      = 1010;
  cmRetrieveConfig  = 1011;
  cmShowClip        = 1012;
  cmCalculator      = 1013;
  cmAsciiTab        = 1014;
  cmCalendar        = 1015;
  cmWinList         = 1016;
  cmUserScreen      = 1017;
  cmDosCommand      = 1018;
  cmDosShell        = 1019;
  cmSavePalette     = 1020;
  cmRetrievePalette = 1021;
  cmScreenRest      = 1022;
  cmBellRequest     = 1023;
  cmLanguage        = 1024;
  cmWorkDir         = 1025;
  cmNewFile         = 1026;
  cmNewDir          = 1027;
  cmSearchDirWindow = 1028;  { Сообщение }
  cmDirChanged      = 1029;  { Сообщение }
  cmExecuteCmd      = 1030;
  cmNewAnn          = 1031;  { Сообщение }
  cmSearchAnnWindow = 1032;  { Сообщение }
  cmSearchFirstDirW = 1033;  { Сообщение }
  cmOpenAnnWindow   = 1034;
  cmRestCurrDir     = 1035;
  cmOpenIntEditor   = 1036;
  cmUpdateGadgets   = 1037;
  cmDelHK           = 1038;
  cmHotKey          = 1039;
  cmUpdateCalendar  = 1040;  { Сообщение }
  cmSearchHotKey    = 1041;  { Сообщение }
  cmLocalMenu       = 1042;
  cmSetPasswords    = 1043;  { Сообщение }
  cmSetProtections  = 1044;  { Сообщение }
  cmResetTarget     = 1045;  { Сообщение }
  cmSearchTarget    = 1046;  { Сообщение }
  cmRegLastEvTime   = 1047;
  cmHelpIndex       = 1048;
  cmInterface       = 1049;
  cmDemoInfo        = 1050;
  cmResetAlarm      = 1052;
  cmResetAlarmFlag  = 1053;
  cmSetAlarmFlag    = 1054;
  cmEditorClosed    = 1055;
  cmGlobalExt       = 1056;
  cmUnlockDesktop   = 1057;
  cmOutputWindow    = 1058;
  cmSearchOutputWin = 1059;  { Сообщение }
  cmSearchAnnViewer = 1060;  { Сообщение }
  cmClosedFile1     = 1061;
  cmClosedFile2     = 1062;
  cmClosedFile3     = 1063;
  cmClosedFile4     = 1064;
  cmClosedFile5     = 1065;
  cmRemind          = 1066;
  cmCallExtEditor   = 1067;
  cmCallMenu4Editor = 1068;
  cmCheckDocSize    = 1069;
  cmOpenDirWindow   = 1070;
  cmStoreCurrDir    = 1071;
  cmCloseWin        = 1072;
  cmRedrawCnt       = 1073;  { Сообщение }
  cmSetDelProgFlag  = 1074;

implementation

end.

