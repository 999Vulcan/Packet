(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Pack_Dlg                                        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit Pack_Dlg;

interface

uses
  Objects, Memory, App, BaseApp, Dialogs, Drivers, Views, Language,
  PackLng, PackText, Pack_Hlp, Pack_Cmd, Hist_Ind, SubDirs, Items, Crt,
  StrServ, StdDlg, Disp_Obj, Editors, MyMsgBox, Dos,
{$ifdef ForPacket}
  PackConf,
{$endif}
  FileOps;

const
  wtAdd           = 1;
  wtReplace       = 2;
  wtRunWithParams = 3;
  wtComParams     = 4;

  AddFileItemCoord: TPoint = (X: -1; Y: -1);
  AddSubDirCoord: TPoint = (X: -1; Y: -1);
  EditResCoord: TRect = (A:(X: -1; Y: -1));
  ParamsCoord: TPoint = (X: -1; Y: -1);
  ParamListCoord: TPoint = (X: -1; Y: -1);

type

  TShortMemoData = record
    Length: Word;
    Buffer: array[0..MaxTextResSize + 5] of byte;
  end;

  PCombHistory = ^TCombHistory;
  TCombHistory = object(THistory)
    Command: Word;
    constructor Init(var Bounds: TRect;
      ALink: PInputLine; AHistoryId: Word; Cmd: Word);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Draw; virtual;
  end;

  PInfoWin = ^TInfoWin;
  TInfoWin = object(TDialog)
    constructor Init(Mess: String);
    function Execute: Word; virtual;
  end;

  procedure InitPackDlgCoord;
  procedure InsertText(P: PInputLine; Text: String);
  procedure PutInfoWindow(Mess: String);

const

  cmAdd       = 11000;
  cmRepl      = 11001;
  cmFileList  = 11002;
  cmDirList   = 11003;
  cmExtParams = 11004;
  cmParamList = 251;

implementation

{  Методы объекта TCombHistory  }
constructor TCombHistory.Init(var Bounds: TRect;
  ALink: PInputLine; AHistoryId: Word; Cmd: Word);
begin
  inherited Init(Bounds, ALink, AHistoryId);
  Command := Cmd;
end;

procedure TCombHistory.HandleEvent(var Event: TEvent);
begin
  if ((Event.What = evMouseDown) and (Event.Buttons = mbRightButton))
   or ((Event.What = evKeyDown) and (Event.KeyCode = kbUp) and
      (Link^.State and sfFocused <> 0))
    then begin
      Link^.Select;
      Message(Owner, evCommand, Command, nil);
      ClearEvent(Event);
    end;

  inherited HandleEvent(Event);
end;

procedure TCombHistory.Draw;
var
  B: TDrawBuffer;
begin
  MoveCStr(B, #222'~'#18'~'#221, GetColor($0102));
  WriteLine(0, 0, Size.X, Size.Y, B);
end;

procedure InsertText(P: PInputLine; Text: String);
begin
  if (not Assigned(P)) or (Text = '') then Exit;
  with P^ do
  begin
    if SelEnd <> SelStart
      then Data^ := Copy(FullTrim(Copy(Data^, 1, SelStart) + ' '
                                + Text + ' ' + Copy(Data^, SelEnd + 1, 255)),
                         1, MaxLen - 1)
    else Data^ := Copy(FullTrim(Copy(Data^, 1, CurPos) + ' '
                                + Text + ' ' + Copy(Data^, CurPos + 1, 255)),
                       1, MaxLen - 1);
    Select;
    SelectAll(True);
  end;
end;

constructor TInfoWin.Init(Mess: String);
var
  R: TRect;
begin
  R.Assign(0, 0, 20, 5);
  inherited Init(R, '');
  Flags := 0;
  EventMask := evCommand;
  Options := Options or ofCentered;
  R.Grow(-1, -1);
  Insert(New(PStaticText, Init(R, ^M^C + Mess)));
end;

function TInfoWin.Execute: Word;
var
  i: byte;
begin
  for i := 1 to 30 do
  begin
    KeyPressed;
    Delay(10);
  end;
  Message(@Self, evCommand, cmCancel, nil);
end;

procedure PutInfoWindow(Mess: String);
var
  P: PView;
begin
{$ifdef ForPacket}
  if not AddConfirm then
{$endif}
    Exit;
  P := New(PInfoWin, Init(Mess));
  Application^.ExecView(P);
  DisposeObj(P);
end;

procedure InitPackDlgCoord;
begin
  AddFileItemCoord.X := -1;
  AddFileItemCoord.Y := -1;

  AddSubDirCoord.X := -1;
  AddSubDirCoord.Y := -1;

  EditResCoord.A.X := -1;
  EditResCoord.A.Y := -1;
  EditResCoord.B.X := -1;
  EditResCoord.B.Y := -1;

  ParamsCoord.X := -1;
  ParamsCoord.Y := -1;

  ParamListCoord.X := -1;
  ParamListCoord.Y := -1;
end;

end.
