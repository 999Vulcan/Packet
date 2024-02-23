(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль EditResg                                        *)
(* Диалоговое окно редактирования текстовых ресурсов      *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit EditRes;

interface

uses
  Objects, Memory, App, BaseApp, Dialogs, Drivers, Views, Language,
  PackLng, PackText, Pack_Hlp, Pack_Cmd, Hist_Ind, Dirs, SubDirs, Items,
  StrServ, StdDlg, Disp_Obj, Editors, MyMsgBox, Dos, FileOps,
{$ifdef ForPacket}
  Conf_Var,
{$endif}
  Pack_Dlg;

type

  { TResEditor }
  PResEditor = ^TResEditor;
  TResEditor = object(TMemo)
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar:
                     PScrollBar; AIndicator: PIndicator; ABufSize: Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
  end;

  PEditResDlg = ^TEditResDlg;
  TEditResDlg = object(TWindow)
    Memo: PResEditor;

    constructor Init(ATitle: TTitleStr; AHelpCtx: Word);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  { Объект для чтения строк из текстовых ресурсов }
  PResReader = ^TResReader;
  TResReader = object(TObject)
    MemoData: TShortMemoData;
    Dir: PDirectory;
    CurPos: Word;

    constructor Init(ADir: PDirectory; Name: String);
    function ReadString: String;
    function EndOfRes: boolean;
  end;

const

  CResEditor   = #6#7;

implementation

{  Методы объекта TEditResDlg  }
constructor TEditResDlg.Init
  (ATitle: TTitleStr; AHelpCtx: Word);
var
  R: TRect;
  HSB, VSB: PScrollBar;
  Ind: PIndicator;
begin
  Desktop^.GetExtent(R);
  inherited Init(R, ATitle, wnNoNumber);
  HelpCtx := AHelpCtx;
  if EditResCoord.A.Y <> -1
    then ChangeBounds(EditResCoord);

  HSB := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  Inc(HSB^.Origin.X, 14);
  Dec(HSB^.Size.X, 14);
  VSB := StandardScrollBar(sbVertical + sbHandleKeyboard);

  GetExtent(R);
  R.A.Y := R.B.Y - 1;
  R.A.X := 2;
  R.B.X := R.A.X + 11;
  New(Ind, Init(R));

  GetExtent(R);
  R.Grow(-1, -1);
  New(Memo, Init(R, HSB, VSB, Ind, MaxTextResSize));
{$ifdef ForPacket}
  Memo^.Autoindent := Config.Autoindent;
{$else}
  Memo^.Autoindent := True;
{$endif}
  Insert(Memo);

  Insert(Ind);

  Memo^.Select;
end;

destructor TEditResDlg.Done;
begin
  GetBounds(EditResCoord);
  inherited Done;
end;

procedure TEditResDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evCommand
  then Case Event.Command of
    cmCancel, cmOk, cmDelRes: begin
                                EndModal(Event.Command);
                                ClearEvent(Event);
                              end;
  end;
end;

constructor TResEditor.Init(var Bounds: TRect; AHScrollBar, AVScrollBar:
                 PScrollBar; AIndicator: PIndicator; ABufSize: Word);
begin
  inherited Init(Bounds, AHScrollBar, AVScrollBar, AIndicator, ABufSize);
{$ifdef ForPacket}
  Autoindent := Config.Autoindent;
{$else}
  Autoindent := True;
{$endif}
end;

procedure TResEditor.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evCommand) and (Event.Command = cmCancel)
    and Modified
    then begin
      Case MessageBox(Ph(phAskSave), nil,
           mfConfirmation + mfYesNoCancel + mfInsertInApp, hcAskSave)
      of
        cmCancel: ClearEvent(Event);
        cmYes: Event.Command := cmOk;
      end;
    end;

  inherited HandleEvent(Event);
end;

function TResEditor.GetPalette: PPalette;
const
  P: String[Length(CResEditor)] = CResEditor;
begin
  GetPalette := @P;
end;

{-----------------------------------------------------------------}

constructor TResReader.Init(ADir: PDirectory; Name: String);
var
  Resource: PTextResource;
begin
  inherited Init;
  CurPos := 0;
  Dir := ADir;
  Resource := Pointer(Dir^.ReadObj(Name));
  if Assigned(Resource)
    then MemoData.Length := Resource^.Length
  else Fail;
  if MemoData.Length > MaxTextResSize
    then MemoData.Length := MaxTextResSize;
  if MemoData.Length > 0
    then Move(Resource^.Text^, MemoData.Buffer, MemoData.Length);
  DisposeObj(Resource);
end;

function TResReader.ReadString: String;
var
  s: String;
begin
  s := '';
  while (CurPos <= MaxTextResSize) and (CurPos < MemoData.Length) and (MemoData.Buffer[CurPos] <> 13) do
  begin
    s := s + chr(MemoData.Buffer[CurPos]);
    Inc(CurPos);
  end;
  Inc(CurPos, 2);
  ReadString := s;
end;

function TResReader.EndOfRes: boolean;
begin
  EndOfRes := CurPos >= MemoData.Length;
end;

end.
