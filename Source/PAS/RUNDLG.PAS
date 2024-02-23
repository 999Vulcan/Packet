(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль RunDlg                                          *)
(* Объект TRunDlg (запрос команды DOS)                    *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 10.03.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit RunDlg;

interface

uses
  Objects, Views, App, Dialogs, Drivers, StdDlg, Language, PackLng,
  Pack_Hlp, Pack_Dlg, PackText, Dos, Hist_Ind;

type

  PRunDialog = ^TRunDialog;
  TRunDialog = object(TDialog)
    CommandIL: PInputLine;

    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure FileList;
  end;

function InputDosCmd(var ClearKbd, DelayScreen, RestCurrDir: boolean): String;

implementation

constructor TRunDialog.Init;
var
  R: TRect;
  B: PCheckBoxes;
begin
  R.Assign(0, 0, 66, 10);
  inherited Init(R, Ph(phRunDosCmd));
  Options := Options or ofCentered;
  HelpCtx := hcDosCmdDlg;

  R.Assign(3, 3, 61, 4);
  New(CommandIL, Init(R, 127));
  Insert(CommandIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCCommand), CommandIL)));

  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, CommandIL, hiDosCmd, cmFileList)));

  R.Assign(3, 6, 34, 8);
  New(B, Init(R,
    NewSItem(Ph(phCRestCD),
    NewSItem(Ph(phCDelayScreen),
    nil))));
  with B^ do Options := Options or ofFramed;
  Insert(B);
  R.Move(0, -1);
  R.B.Y := R.A.Y + 1;
  R.B.X := R.A.X + Length(Ph(phCModes));
  Insert(New(PLabel, Init(R, Ph(phCModes), B)));

  R.Assign(35, 5, 49, 7);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(15, 0);
  Insert(New(PButton, Init(R, Ph(phCFiles), cmFileList, bfNormal)));
  R.Assign(35, 7, 49, 9);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  R.Move(15, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));

  SelectNext(False);
end;

procedure TRunDialog.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmFileList)
    then begin
      ClearEvent(Event);
      FileList;
    end;
end;

procedure TRunDialog.FileList;
var
  FileName: FNameStr;
begin
  FileName := AllFilesMask;
  if Application^.ExecuteDialog(New(PFileDialog, Init(AllFilesMask,
                                         Ph(phSelectFile),
                                         Ph(phCName),
                                         fdOkButton + fdHelpButton,
                                         hiFileName, hcSelectFile)),
                                @FileName) = cmCancel
    then Exit;

  if Current <> PView(CommandIL)
    then CommandIL^.SelectAll(True);
  InsertText(CommandIL, FileName);
end;

function InputDosCmd(var ClearKbd, DelayScreen, RestCurrDir: boolean): String;
var
  RunData: record
    Cmd: ComStr;
    Buttons: Word;
  end;
begin
  RunData.Cmd := '';
  RunData.Buttons := 1;
  if Application^.ExecuteDialog(New(PRunDialog, Init), @RunData) = cmCancel
    then InputDosCmd := ''
  else InputDosCmd := RunData.Cmd;
  RestCurrDir := RunData.Buttons and 1 <> 0;
  DelayScreen := RunData.Buttons and 2 <> 0;
  ClearKbd := False;
end;

end.

