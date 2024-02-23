(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль HKDlg                                           *)
(* Диалоги горячих клавиш для оглавлений                  *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат   : 08.12.1994                                   *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit HKDlg;

interface

uses
  Objects, App, Views, Drivers, Dirs, Disp_Obj, StrServ, Language, PackLng,
  Pack_Hlp, Items, PackText, HotKeys, Dialogs, Pack_Cmd, Validate, LineColl,
  XListBox, MUpCase;

type

  PHotKeyIL = ^THotKeyIL;
  THotKeyIL = object(TInputLine)
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PSetHotKeyDlg = ^TSetHotKeyDlg;
  TSetHotKeyDlg = object(TDialog)
    KeyIL: PInputLine;

    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure GetData(var Rec); virtual;
    procedure SetData(var Rec); virtual;
  end;

  PHotKeysViewer = ^THotKeysViewer;
  THotKeysViewer = object(TXListBox)
    HotKeysColl: PLineCollection;
    HotKey: Char;

    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    procedure InitHotKeys;
    procedure FocusItem(Item: Integer); virtual;
  end;

  PHotKeysListDlg = ^THotKeysListDlg;
  THotKeysListDlg = object(TDialog)
    HotKeysList: PHotKeysViewer;

    constructor Init;
    procedure GetData(var Rec); virtual;
  end;

implementation

constructor TSetHotKeyDlg.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 40, 7);
  inherited Init(R, Ph(phSetHotKey));
  Options := Options or ofCentered;
  HelpCtx := hcSetHKDlg;

  R.Assign(33, 2, 36, 3);
  KeyIL := New(PHotKeyIL, Init(R, 1));
  KeyIL^.SetValidator(New(PFilterValidator, Init(HotKeysSet)));
  Insert(KeyIL);
  R.Assign(3, 2, 22, 3);
  Insert(New(PLabel, Init(R, Ph(phCHotKey), KeyIL)));
  R.Assign(24, 2, 33, 3);
  Insert(New(PStaticText, Init(R, Ph(phKCtrlAlt) + '+')));

  R.Assign(2, 4, 14, 6);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(12, 0);
  Insert(New(PButton, Init(R, Ph(phCDelete), cmDelHK, bfNormal)));
  R.Move(12, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));

  SelectNext(False);
end;

procedure TSetHotKeyDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if (Event.What = evCommand) and (Event.Command = cmDelHK)
    then begin
      KeyIL^.Data^ := '';
      EndModal(cmDelHK);
    end;
end;

procedure TSetHotKeyDlg.GetData(var Rec);
var
  Key: Char absolute Rec;
begin
  if KeyIL^.Data^ = ''
    then Key := #0
  else Key := KeyIL^.Data^[1];
end;

procedure TSetHotKeyDlg.SetData(var Rec);
var
  Key: Char absolute Rec;
begin
  if Key = #0
    then KeyIL^.Data^ := ''
  else KeyIL^.Data^ := Key;
end;

procedure THotKeyIL.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evKeyboard) and (Event.CharCode <> #0) and
     not (Event.CharCode in HotKeysSet)
  then Event.CharCode := MyUpCase(Event.CharCode);

  inherited HandleEvent(Event);
end;

constructor THotKeysListDlg.Init;
var
  R: TRect;
  HSB, VSB: PScrollBar;
begin
  R.Assign(0, 0, 65, 21);
  inherited Init(R, Ph(phHotKeysList));
  Options := Options or ofCentered;
  HelpCtx := hcHotKeysList;

  R.Assign(4, 18, 47, 19);
  New(HSB, Init(R));
  with HSB^ do Options := Options or ofPostProcess;
  R.Assign(48, 4, 49, 18);
  New(VSB, Init(R));
  with VSB^ do Options := Options or ofPostProcess;
  Insert(VSB);
  Insert(HSB);

  R.Assign(3, 4, 48, 18);
  HotKeysList := New(PHotKeysViewer, Init(R, HSB, VSB));
  with HotKeysList^ do Options := Options or ofFramed;
  Insert(HotKeysList);

  R.B.Y := R.A.Y - 1;
  Dec(R.A.Y, 2);
  Insert(New(PLabel, Init(R, Ph(phCHotKeysList), HotKeysList)));

  R.Assign(50, 4, 62, 6);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));

  HotKeysList^.Select;
end;

procedure THotKeysListDlg.GetData(var Rec);
var
  Key: Char absolute Rec;
begin
  Key := HotKeysList^.HotKey;
end;

constructor THotKeysViewer.Init(var Bounds: TRect;
                                AHScrollBar, AVScrollBar: PScrollBar);
var
  S: String;
begin
  inherited Init(Bounds, AHScrollBar, AVScrollBar);
  InitHotKeys;
  AdjustHorScr;
  HotKey := #0;
  if Range > 0
    then begin
      S := GetText(Focused, 1);
      HotKey := S[1];
    end;
end;

destructor THotKeysViewer.Done;
begin
  DisposeObj(HotKeysColl);
  inherited Done;
end;

procedure THotKeysViewer.Draw;
var
  I, J, Item: Integer;
  NormalColor, SelectedColor, FocusedColor, Color: Word;
  ColWidth, CurCol, Indent: Integer;
  B: TDrawBuffer;
  Text: String;
  SCOff: Byte;
begin
  if State and (sfSelected + sfActive) = (sfSelected + sfActive) then
  begin
    NormalColor := GetColor(1);
    FocusedColor := GetColor(3);
    SelectedColor := GetColor(4);
  end else
  begin
    NormalColor := GetColor(2);
    SelectedColor := GetColor(4);
  end;
  if HScrollBar <> nil then Indent := HScrollBar^.Value
  else Indent := 0;
  ColWidth := Size.X div NumCols + 1;
  for I := 0 to Size.Y - 1 do
  begin
    for J := 0 to NumCols-1 do
    begin
      Item := J*Size.Y + I + TopItem;
      CurCol := J*ColWidth;
      if (State and (sfSelected + sfActive) = (sfSelected + sfActive)) and
        (Focused = Item) and (Range > 0) then
      begin
        Color := FocusedColor;
        SetCursor(CurCol+1,I);
        SCOff := 0;
      end
      else if (Item < Range) and IsSelected(Item) then
      begin
        Color := SelectedColor;
        SCOff := 2;
      end
      else
      begin
        Color := NormalColor;
        SCOff := 4;
      end;
      MoveChar(B[CurCol], ' ', Color, ColWidth);
      if Item < Range then
      begin
        Text := GetText(Item, ColWidth + Indent);
        Text := Copy(Text, 1, 3) + Copy(Text, 3 + Indent, 255);
        if Indent > 1
          then Text[3] := tsLeftPartSkiped;
        MoveStr(B[CurCol+1], Text, Color);
        if ShowMarkers then
        begin
          WordRec(B[CurCol]).Lo := Byte(SpecialChars[SCOff]);
          WordRec(B[CurCol+ColWidth-2]).Lo := Byte(SpecialChars[SCOff+1]);
        end;
      end;
      MoveChar(B[CurCol+ColWidth-1], #179, GetColor(5), 1);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure THotKeysViewer.HandleEvent(var Event: TEvent);
var
  Key: Char;
  i: Integer;
begin
  inherited HandleEvent(Event);

  if Event.What = evKeyDown
    then begin
      Key := MyUpCase(Event.CharCode);
      ConvertToFigure(Key);
      if not (Key in HotKeysSet) then Exit;
      for i := 0 to Range - 1 do
        if Key = Copy(GetText(i, 1), 1, 1)
          then begin
            HotKey := Key;
            Message(Owner, evCommand, cmOk, nil);
          end;
    end;
end;

function THotKeysViewer.GetText(Item: Integer; MaxLen: Integer): String;
begin
  GetText := Copy(HotKeysColl^.AtStr(Item), 1, MaxLen);
end;

procedure THotKeysViewer.InitHotKeys;
var
  c: char;
  Title: String;
begin
  New(HotKeysColl, Init(10, 10));
  for c := '0' to 'Z' do
  begin
    if not (c in HotKeysSet)
      then Continue;
    Title := SearchGlobalHKTitle(c);
    if Title = '' then Continue;
    HotKeysColl^.Insert(NewStr(c + '  ' + Title));
  end;
  SetRange(HotKeysColl^.Count);
end;

procedure THotKeysViewer.FocusItem(Item: Integer);
var
  S: String;
begin
  inherited FocusItem(Item);
  S := GetText(Focused, 1);
  HotKey := S[1];
end;

end.
