(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Line_Num                                        *)
(* Диалог ввода номера строки для перехода                *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 17.03.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit Line_Num;

interface

uses

  Objects, Views, Dialogs, Validate, PackLng, Language,
  MyMsgBox, App, Editors, Hist_Ind, Pack_Hlp;

const

  LineNumLen = 5;

type

  PLineNumValidator = ^TLineNumValidator;
  TLineNumValidator = object(TRangeValidator)
    procedure Error; virtual;
  end;

  PLineNumDialog = ^TLineNumDialog;
  TLineNumDialog = object(TDialog)
    constructor Init;
  end;

implementation

procedure TLineNumValidator.Error;
var
  Bounds: array[0..1] of LongInt;
begin
  Bounds[0] := Min; Bounds[1] := Max;
  MessageBox(^C + Ph(phInvLineNum) + ^M^M^C +
    Ph(phValidRange) + ': %d - %d',
    @Bounds, mfError + mfOkButton, hcInvLineNum);
end;

constructor TLineNumDialog.Init;
var
  R: TRect;
  LineNum: Word;
  Input: PInputLine;
  Dialog: PDialog;

begin
  R.Assign(0, 0, 39, 7);
  inherited Init(R, Ph(phGotoLineNum));
  Options := Options or ofCentered;
  HelpCtx := hcGoToLineDialog;

  R.Assign(25, 2, 33, 3);
  Input := New(PInputLine, Init(R, LineNumLen));
  Insert(Input);
  R.Assign(2, 2, 24, 3);
  Insert(New(PLabel, Init(R, Ph(phCEnterNewLineNum), Input)));
  Input^.SetValidator(New(PLineNumValidator,
    Init(1, PEditor(PEditWindow(Desktop^.Current)^.Editor)^.Limit.Y)));
  R.Assign(33,2,36,3);
  Insert(New(PHistory, Init(R, Input, hiLine)));
  R.Assign(2, 4, 12, 6);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Assign(14, 4, 24, 6);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Assign(26, 4, 36, 6);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  SelectNext(False);
end;

end.

