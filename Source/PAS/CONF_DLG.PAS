(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Conf_Dlg                                        *)
(* Диалоги конфигурации                                   *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 28.04.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Conf_Dlg;

interface

uses
  Objects, Views, Drivers, App, Dialogs, Validate, Language, PackLng,
  Pack_Hlp, Hist_Ind, Pack_Dlg, StrServ, PackText, StdDlg, MyMsgBox, Dos,
  Pack_Cmd, FileOps;

type

  PPrefDialog = ^TPrefDialog;
  TPrefDialog = object(TDialog)
    constructor Init;
  end;

  PInterfaceDialog = ^TInterfaceDialog;
  TInterfaceDialog = object(TDialog)
    constructor Init;
  end;

  PDirConfDialog = ^TDirConfDialog;
  TDirConfDialog = object(TDialog)
    ExtEditorIL: PInputLine;
    RandNameTplIL: PInputLine;
    StartDirIL: PInputLine;
    FileName: FNameStr;

    constructor Init(AFileName: FNameStr);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure FileList;
    procedure DirList;
  end;

  PPassWordIL = ^TPassWordIL;
  TPasswordIL = object(TInputLine)
    Mode: byte;

    constructor Init(var Bounds: TRect; AMaxLen: Integer; AMode: byte);
    procedure Draw; virtual;
  end;

  PInputPWDlg = ^TInputPWDlg;
  TInputPWDlg = object(TDialog)
    constructor Init;
  end;

implementation

constructor TPrefDialog.Init;
var
  Bruce: PView;
  R: TRect;
  IL: PInputLine;
begin
  R.Assign(0, 0, 55, 20);
  inherited Init(R, Ph(phPreferences));
  Options := Options or ofCentered;
  HelpCtx := hcPrefDialog;

  R.Assign(4, 3, 29, 8);
  Bruce := New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCClock),
    NewSItem(Ph(phCHeap),
    NewSItem(Ph(phCShadow),
    NewSItem(Ph(phCErrBell),
    NewSItem(Ph(phCTimeBeep),
    nil)))))));
  Insert(Bruce);
  R.Assign(4, 2, 29, 3);
  Insert(New(PLabel, Init(R, Ph(phCLook), Bruce)));

  R.Assign(31, 3, 51, 7);
  Bruce := New(PRadioButtons, Init(R,
    NewSItem(Ph(phCCGAlines),
    NewSItem(Ph(phCEGAlines),
    NewSItem(Ph(phCSVGAMode1),
    NewSItem(Ph(phCSVGAMode2),
    nil))))));
  Insert(Bruce);
  R.Assign(31, 2, 51, 3);
  Insert(New(PLabel, Init(R, Ph(phCScreenSize), Bruce)));

  R.Assign(47, 7, 51, 8);
  IL := New(PInputLine, Init(R, 2));
  Insert(IL);
  IL^.SetValidator(New(PFilterValidator,
                       Init(['0'..'9', 'A'..'F', 'a'..'f'])));
  R.Assign(31, 7, 47, 8);
  Insert(New(PLabel, Init(R, Ph(phCMode1IL), IL)));

  R.Assign(47, 8, 51, 9);
  IL := New(PInputLine, Init(R, 2));
  Insert(IL);
  IL^.SetValidator(New(PFilterValidator,
                       Init(['0'..'9', 'A'..'F', 'a'..'f'])));
  R.Assign(31, 8, 47, 9);
  Insert(New(PLabel, Init(R, Ph(phCMode2IL), IL)));

  R.Assign(4, 10, 29, 12);
  Bruce := New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCCreateBak),
    NewSItem(Ph(phCAutoIndent),
    nil))));
  Insert(Bruce);
  R.Assign(4, 9, 29, 10);
  Insert(New(PLabel, Init(R, Ph(phCEditor), Bruce)));

  R.Assign(31, 11, 51, 16);
  Bruce := New(PRadioButtons, Init(R,
    NewSItem(Ph(phCOffScrRest),
    NewSItem(Ph(phCAfter1m),
    NewSItem(Ph(phCAfter3m),
    NewSItem(Ph(phCAfter5m),
    NewSItem(Ph(phCAfter10m),
    nil)))))));
  Insert(Bruce);
  R.Assign(31, 10, 51, 11);
  Insert(New(PLabel, Init(R, Ph(phCScreenRest), Bruce)));

  R.Assign(4, 14, 29, 16);
  Bruce := New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCASConf),
    NewSItem(Ph(phCASDsk),
    nil))));
  Insert(Bruce);
  R.Assign(4, 13, 29, 14);
  Insert(New(PLabel, Init(R, Ph(phCAutoSave), Bruce)));

  R.Assign(16, 17, 26, 19);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOK, bfDefault)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  SelectNext(False);
end;

constructor TInterfaceDialog.Init;
var
  Bruce: PView;
  R: TRect;
begin
  R.Assign(0, 0, 50, 19);
  inherited Init(R, Ph(phInterface));
  Options := Options or ofCentered;
  HelpCtx := hcInterfaceDlg;

  R.Assign(2, 3, 48, 15);
  Bruce := New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCAskExit),
    NewSItem(Ph(phCEsc4Editor),
    NewSItem(Ph(phCEsc4DirWin),
    NewSItem(Ph(phCAddConfirm),
    NewSItem(Ph(phCAddNonExistConfirm),
    NewSItem(Ph(phCRestoreCurPos),
    NewSItem(Ph(phCDontCompressDir),
    NewSItem(Ph(phCAlt4Menu),
    NewSItem(Ph(phCCalendarInClock),
    NewSItem(Ph(phCChangeDirOnSelDir),
    NewSItem(Ph(phCItemTitleOnEditor),
    NewSItem(Ph(phCCreateFileNames),
    nil))))))))))))));
  Insert(Bruce);
  R.Assign(2, 2, 29, 3);
  Insert(New(PLabel, Init(R, Ph(phCOptions), Bruce)));

  R.Assign(7, 16, 17, 18);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOK, bfDefault)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  SelectNext(False);
end;

constructor TDirConfDialog.Init(AFileName: FNameStr);
var
  Bruce: PView;
  R: TRect;
  IL: PInputLine;
begin
  R.Assign(0, 0, 65, 19);
  inherited Init(R, Ph(phDirConf));
  Options := Options or ofCentered;
  HelpCtx := hcDirConfDialog;
  FileName := AFileName;

  R.Assign(3, 2, 64, 3);
  Insert(New(PStaticText, Init(R, Ph(phDirFile) + ': ' +
    GetShortFName(FileName, Size.X - Length(Ph(phDirFile)) - 8))));

  R.Assign(3, 5, 60, 6);
  IL := New(PInputLine, Init(R, 80));
  Insert(IL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCDirTitle), IL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiDirTitle)));

  R.Assign(3, 8, 25, 11);
  Bruce := New(PRadioButtons, Init(R,
    NewSItem(Ph(phCNoneProtection),
    NewSItem(Ph(phCWriteProtect),
    NewSItem(Ph(phCFullProtect),
    nil)))));
  Insert(Bruce);
  with Bruce^ do Options := Options or ofFramed;
  R.B.Y := R.A.Y;
  R.A.Y := R.B.Y - 1;
  R.B.X := R.A.X + Length(Ph(phCProtectType));
  Insert(New(PLabel, Init(R, Ph(phCProtectType), Bruce)));

  R.Assign(28, 8, 63, 9);
  IL := New(PPassWordIL, Init(R, 80, 1));
  Insert(IL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCPassword), IL)));

  R.Move(1, 4);
  Dec(R.B.X, 3);
  ExtEditorIL := New(PInputLine, Init(R, 79));
  Insert(ExtEditorIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCExtEditor), ExtEditorIL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, ExtEditorIL, hiExtEditor, cmFileList)));

  R.Assign(3, 14, 36, 15);
  Dec(R.B.X, 3);
  RandNameTplIL := New(PInputLine, Init(R, 79));
  Insert(RandNameTplIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCRandNameTpl4Dir), RandNameTplIL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, RandNameTplIL, hiRandNameTpl)));

  R.Assign(38, 14, 63, 15);
  Dec(R.B.X, 3);
  StartDirIL := New(PInputLine, Init(R, 67));
  Insert(StartDirIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCStartDir4Dir), StartDirIL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, StartDirIL, hiStartDir, cmDirList)));

  R.Assign(27, 16, 37, 18);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOK, bfDefault)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  SelectNext(False);
end;

procedure TDirConfDialog.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmFileList)
    then FileList;
  if (Event.What = evCommand) and (Event.Command = cmDirList)
    then DirList;
end;

procedure TDirConfDialog.FileList;
var
  FN: FNameStr;
begin
  FN := FullTrim(ExtEditorIL^.Data^);
  if FN = '' then FN := ExeFilesMask;
  if Application^.ExecuteDialog(New(PFileDialog, Init(ExeFilesMask,
                                    Ph(phSelectFile),
                                    Ph(phCName),
                                    fdOkButton + fdHelpButton,
                                    hiFileName, hcSelectFile)),
                   @FN) = cmCancel
    then Exit;
  ExtEditorIL^.Data^ := FN;
  ExtEditorIL^.SelectAll(True);
end;

procedure TDirConfDialog.DirList;
var
  Dir: DirStr;
begin
  Dir := FullTrim(StartDirIL^.Data^);
  if Dir = '' then Dir := GetFDir(FileName);
  ChangeDirectory(Dir);
  if Application^.ExecuteDialog(New(PChDirDialog,
                                    Init(Ph(phSelectStartDir),
                                    cdNormal + cdHelpButton,
                                    hiStartDir, hcSelectStartDir)),
                   @Dir) <> cmOk
    then Exit;
  StartDirIL^.Data^ := Dir;
  StartDirIL^.SelectAll(True);
  Message(Application, evCommand, cmRestCurrDir, nil);
end;

constructor TPasswordIL.Init(var Bounds: TRect; AMaxLen: Integer; AMode: byte);
begin
  inherited Init(Bounds, AMaxLen);
  Mode := AMode;
end;

procedure TPasswordIL.Draw;
var
  s: String;
begin
  s := Data^;
  if (Mode = 0) or (State and sfFocused = 0)
    then FillChar(Data^[1], Length(Data^), '*');
  inherited Draw;
  Data^ := s;
end;

constructor TInputPWDlg.Init;
var
  R: TRect;
  IL: PInputLine;
begin
  R.Assign(0, 0, 40, 8);
  inherited Init(R, Ph(phInputPW));
  Options := Options or ofCentered;
  HelpCtx := hcInputPWDlg;

  R.Assign(3, 3, 37, 4);
  IL := New(PPasswordIL, Init(R, 80, 0));
  Insert(IL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCPassword), IL)));
  R.Move(1, 1);

  R.Assign(2, 5, 12, 7);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOK, bfDefault)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(13, 0);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  SelectNext(False);
end;

end.
