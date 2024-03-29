(**********************************************************)
(*                                                        *)
(* ��⥣��� "Packet"                                    *)
(*                                                        *)
(* ����� PM_Cmd                                          *)
(* ���ᠭ�� ����⠭� ������                               *)
(*                                                        *)
(* ���� : ����⠭⨭ �㫠�                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* ����         : 21.02.1994                             *)
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

{ # 251 ��१�ࢨ஢�� ��� Pack_Dlg }

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
  cmSearchDirWindow = 1028;  { ����饭�� }
  cmDirChanged      = 1029;  { ����饭�� }
  cmExecuteCmd      = 1030;
  cmNewAnn          = 1031;  { ����饭�� }
  cmSearchAnnWindow = 1032;  { ����饭�� }
  cmSearchFirstDirW = 1033;  { ����饭�� }
  cmOpenAnnWindow   = 1034;
  cmRestCurrDir     = 1035;
  cmOpenIntEditor   = 1036;
  cmUpdateGadgets   = 1037;
  cmDelHK           = 1038;
  cmHotKey          = 1039;
  cmUpdateCalendar  = 1040;  { ����饭�� }
  cmSearchHotKey    = 1041;  { ����饭�� }
  cmLocalMenu       = 1042;
  cmSetPasswords    = 1043;  { ����饭�� }
  cmSetProtections  = 1044;  { ����饭�� }
  cmResetTarget     = 1045;  { ����饭�� }
  cmSearchTarget    = 1046;  { ����饭�� }
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
  cmSearchOutputWin = 1059;  { ����饭�� }
  cmSearchAnnViewer = 1060;  { ����饭�� }
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
  cmRedrawCnt       = 1073;  { ����饭�� }
  cmSetDelProgFlag  = 1074;

implementation

end.

