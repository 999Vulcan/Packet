(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль AlarmDlg                                        *)
(* Диалоги будильника                                     *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 29.03.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit AlarmDlg;

interface

uses Objects, Views, App, Dialogs, Alarm, Pack_Hlp, PackLng,
     Language, Pack_Cmd, Validate, Hist_Ind, HistList, Drivers, MyMsgBox;

type

  TAlarmData = record
    Time: String[5];
    Info: String[250];
  end;

  PSetAlarmDlg = ^TSetAlarmDlg;
  TSetAlarmDlg = object(TDialog)
    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

procedure AlarmClock;

var
  AlarmData: TAlarmData;

implementation

uses PMApp;

constructor TSetAlarmDlg.Init;
var
  R: TRect;
  IL: PInputLine;
begin
  R.Assign(0, 0, 50, 9);
  inherited Init(R, Ph(phSetAlarmClock));
  Options := Options or ofCentered;
  HelpCtx := hcSetAlarm;

  R.Assign(3, 3, 10, 4);
  New(IL, Init(R, 5));
  Insert(IL);
  IL^.SetValidator(New(PPXPictureValidator, Init('##:##', True)));
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiAlarmTime)));
  R.Assign(2, 2, 15, 3);
  Insert(New(PLabel, Init(R, Ph(phCAlarmTime), IL)));

  R.Assign(3, 6, 33, 7);
  New(IL, Init(R, 250));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiAlarmInfo)));
  R.Assign(2, 5, 45, 6);
  Insert(New(PLabel, Init(R, Ph(phCAlarmInfo), IL)));

  R.Assign(36, 2, 48, 4);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(0, 2);
  Insert(New(PButton, Init(R, Ph(phCReset), cmResetAlarm, bfNormal)));
  R.Move(0, 2);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));

  SelectNext(False);
end;

procedure TSetAlarmDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmResetAlarm)
    then EndModal(cmResetAlarm);
end;

procedure DoSetAlarmClock;
begin
  ResetAlarmClock;
  SetAlarmClock(AlarmData.Time);
  Message(Application, evCommand, cmResetAlarmFlag, nil);
end;

procedure AlarmClock;
var
  Cmd: Word;
begin
  if HistoryStr(hiAlarmTime, 0) = ''
    then AlarmData.Time := '12:00'
  else AlarmData.Time := HistoryStr(hiAlarmTime, 0);
  AlarmData.Info := HistoryStr(hiAlarmInfo, 0);

  Cmd := Application^.ExecuteDialog(New(PSetAlarmDlg, Init),
                                    @AlarmData);
  if AlarmData.Info = ''
    then HistoryAdd(hiAlarmInfo, ' ');
  Case Cmd of
            cmOk: DoSetAlarmClock;
    cmResetAlarm: ResetAlarmClock;
  end;
end;

end.
