(**********************************************************)
(*                                                        *)
(* Модуль Base Application                                *)
(* TBaseApp - расширение объекта TApplication             *)
(*                                                        *)
(* Авторы : Константин Вулах, Игорь Зисельман             *)
(*                                                        *)
(* Начат         : 24.09.1993                             *)
(*                                                        *)
(**********************************************************)
{$A+,B-,E-,F+,N-,O-,V-,X+,I-}
unit BaseApp;

interface

uses
  Objects, Drivers, Views, Dialogs, App, Dos, cursor, Crt;

type

  PBaseApp = ^TBaseApp;
  TBaseApp = object(TApplication)
    constructor Init;
    procedure GetEvent(var Event: TEvent); virtual;
    procedure Idle; virtual;
    procedure CheckScreenOff;
    procedure InitScreen; virtual;
    procedure SetShadows; virtual;
    function FirstFreeWin: Integer;
    function AppExecuteDialog(P: PDialog; Data: Pointer): Word;
    function ShowShadow: Boolean; virtual;
    function ScreenDelay: LongInt; virtual;
    procedure ScreenOff; virtual;
    procedure RegisterLastEventTime;
    function CheckMouseInCorner: boolean;
    {  Возвращает время от последнего события в сотых долях секунды  }
    function GetIdleTime: LongInt;

    private
      H, M, S, S100: word;
      MouseInCorner: boolean;
  end;

const
  BaseApplication: PBaseApp = nil;

  StarColorIndex = 136;
  NewStarColorIndex = 137;
  CScreenRestColor       = #$0B#$0F;
  CScreenRestBlackWhite  = #$07#$0F;
  CScreenRestMonochrome  = #$07#$0F;

implementation

uses WinCheck;

constructor TBaseApp.Init;
begin
  inherited Init;
  BaseApplication := @Self;
  MouseInCorner := CheckMouseInCorner;

  SpecialChars[0] := #16;
  SpecialChars[1] := #17;

  RegisterLastEventTime;
end;

function TBaseApp.FirstFreeWin: Integer;
var
  WinFlags: array[1..9] of boolean;
  i: byte;

procedure CheckWinNum(P: PWindow); far;
begin
  if (Hi(P^.Number) = 0) and (Lo(P^.Number) in [1..9])
   and (P^.State and sfVisible <> 0) then
    WinFlags[P^.Number] := False;
end;

begin
  for i := 1 to 9 do WinFlags[i] := True;  { все свободны }
  Desktop^.ForEach(@CheckWinNum);
  for i := 1 to 9 do
    if WinFlags[i] then
    begin
      FirstFreeWin := i;
      Exit;
    end;
  FirstFreeWin := wnNoNumber;
end;

function TBaseApp.CheckMouseInCorner: boolean;
var
  R: TRect;
begin
  GetExtent(R);
  R.A.X := R.B.X - 2;
  R.B.Y := R.A.Y + 1;
  CheckMouseInCorner := R.Contains(MouseWhere) and (MouseButtons = 0);
  if MouseButtons <> 0
    then MouseInCorner := R.Contains(MouseWhere);
end;

function TBaseApp.ShowShadow: Boolean;
begin
  ShowShadow := True;
end;

procedure TBaseApp.InitScreen;
begin
  inherited InitScreen;

  if Lo(ScreenMode) <> smMono
    then if ScreenHeight > 40
           then ShadowSize.X := 1
         else ShadowSize.X := 2;

  if not ShowShadow then
    begin
      ShadowSize.X := 0;
      ShadowSize.Y := 0;
    end;
end;

procedure TBaseApp.SetShadows;
begin
  InitScreen;
  Desktop^.Redraw;
end;

function TBaseApp.AppExecuteDialog(P: PDialog; Data: Pointer): Word;
var
  C: Word;
begin
  AppExecuteDialog := cmCancel;
  if ValidView(P) <> nil then
  begin
    if Data <> nil then P^.SetData(Data^);
    C := ExecView(P);
    if (C <> cmCancel) and (Data <> nil) then P^.GetData(Data^);
    Dispose(P, Done);
    AppExecuteDialog := C;
  end;
end;

procedure TBaseApp.GetEvent(var Event: TEvent);
var
  InCorner: boolean;
begin
  inherited GetEvent(Event);
  if Event.What <> evNothing
    then RegisterLastEventTime;
  if Event.What = evMouseMove
    then begin
      InCorner := CheckMouseInCorner;
      if (InCorner <> MouseInCorner) and InCorner
        then ScreenOff;
      MouseInCorner := CheckMouseInCorner;
    end;
end;

procedure TBaseApp.Idle;
begin
  inherited Idle;
  CheckScreenOff;
end;

procedure TBaseApp.CheckScreenOff;
var
  HH, MM, SS, SS100: word;
  Delta: LongInt;
begin
  GetTime(HH, MM, SS, SS100);
  if (HH = 0) and (H = 23)
    then HH := 25;
  Delta := (HH * 3600 + MM * 60 + SS) -
           (H * 3600 + M * 60 + S);
  if Delta >= 2 then ReleaseTimeSlice;
  if (ScreenDelay <> 0) and (Delta >= ScreenDelay) and (Delta > 0)
    and (HH <> 25)
  then ScreenOff;
  if (Delta < 0) or (HH = 25) then RegisterLastEventTime;
end;

function TBaseApp.ScreenDelay: LongInt;
begin
  ScreenDelay := 60;
end;

procedure TBaseApp.ScreenOff;
const
  MaxStarCount = 255;
  DelayTime1 = 10;
  DelayTime2 = 100;
  CountStarChars = 5;
  StarChar: array[0..CountStarChars - 1] of char =
     (chr(250), chr(249), chr(254), chr(4), chr(15));
var
  i: Integer;
  Stars: array[1..MaxStarCount] of TPoint;
  StarColor, NewStarColor: byte;
  ScrOffEnd: boolean;
  StarCount: byte;

procedure PutChar(Ch: Char; Attr: Byte; X, Y: byte);
begin
  PWordArray(ScreenBuffer)^[(Y - 1) * ScreenWidth + X - 1] :=
                                           Attr * 256 + ord(Ch);
end;

function ScreenOffEnd: boolean;
var
  EvK, EvM: TEvent;
begin
  GetKeyEvent(EvK);
  GetMouseEvent(EvM);
  ScrOffEnd := ScrOffEnd or (EvK.What <> evNothing)
                  or (EvM.What = evMouseDown)
                  or ((EvM.What = evMouseMove) and not CheckMouseInCorner);
  ScreenOffEnd := ScrOffEnd;
end;

function SwitchOn: boolean;
var
  i: Integer;
begin
  SwitchOn := False;
  for i := 1 to StarCount do
    if Stars[i].X = 0
      then begin
        if ScreenOffEnd
          then Exit;
        Stars[i].X := Random(ScreenWidth) + 1;
        Stars[i].Y := Random(ScreenHeight) + 1;
        PutChar(StarChar[0], StarColor, Stars[i].X, Stars[i].Y);
        SwitchOn := True;
        Exit;
      end;
end;

function SwitchOff: boolean;
var
  i, k, j: Integer;
begin
  SwitchOff := False;
  repeat
    i := Random(StarCount) + 1;
    if Stars[i].X <> 0
      then begin
        for k := 1 to Random(CountStarChars - 1) + 1 do
          begin
            if ScreenOffEnd
              then Exit;
            PutChar(StarChar[k], NewStarColor, Stars[i].X, Stars[i].Y);
            for j := 1 to 10 do
              begin
                Delay(DelayTime2 div 10);
{$ifdef ForPacket}
                ReleaseTimeSlice;
{$endif}
              end;
          end;
        PutChar(StarChar[k], 0, Stars[i].X, Stars[i].Y);
        Stars[i].X := 0;
        SwitchOff := True;
        Exit;
      end;
  until ScreenOffEnd;
end;

{$IFNDEF ForPacket}
var
  tmps: string[Length(CScreenRestColor)];
{$ENDIF}

begin { of ScreenOff }
  NoCursor;
  HideMouse;
  ClearScreen;
  Randomize;
  ScrOffEnd := False;
  StarCount := Lo(ScreenWidth * ScreenHeight div 40);
  if StarCount < 50
    then StarCount := 50;
  for i := 1 to StarCount do
    Stars[i].X := 0;
{$IFDEF ForPacket}
  StarColor := Application^.GetColor(StarColorIndex);
  NewStarColor := Application^.GetColor(NewStarColorIndex);
{$ELSE}
  tmps := CScreenRestColor;
  StarColor := ord(tmps[1]);
  NewStarColor := ord(tmps[2]);
{$ENDIF}
  repeat
    Delay(DelayTime1);
    if not SwitchOn
      then if not SwitchOff
             then Break;
  until False;
  MouseInCorner := CheckMouseInCorner;
  Redraw;
  ShowMouse;
  YesCursor;
  RegisterLastEventTime;
end;

procedure TBaseApp.RegisterLastEventTime;
begin
  GetTime(H, M, S, S100);
end;

function TBaseApp.GetIdleTime: LongInt;
var
  Hour, Minute, Second, Sec100: Word;
  IdleTime: LongInt;
begin
  GetTime(Hour, Minute, Second, Sec100);
  IdleTime := (Hour * 360000 + Minute * 6000 + Second * 100 + Sec100) -
              (H * 360000 + M * 6000 + S * 100 + S100);
  if IdleTime < 0
    then IdleTime := 0;
  GetIdleTime := IdleTime;
end;

end.

