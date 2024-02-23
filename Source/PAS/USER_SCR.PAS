{$define ForPacket}

{*********************************************************************}
{                                                                     }
{       Turbo Pascal Version 7.0                                      }
{       User Screen Unit                                              }
{                                                                     }
{       Copyright (c) 1993-95 by VULCAN ( Constantine Vulakh )        }
{                                                                     }
{       15.09.93                                                      }
{                                                                     }
{*********************************************************************}

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit User_Scr;

interface

uses
  Objects, Drivers,
{$ifdef ForPacket}
  App,
{$else}
  App,
{$endif}
  Crt, Cursor, Dos, Blink;

type

  PUserScreen = ^TUserScreen;
  TUserScreen = object(TObject)
    ScrBuff: Pointer;
    BuffSize: Word;
    ScrMode: Word;
    ScrSize: TPoint;
    CursSize: Word;
    CursPos: TPoint;
    constructor Init;
    destructor Done; virtual;
    procedure Reset;
    procedure Show;
    procedure Store;
    procedure Restore;
    procedure GetScreenSizes;
  end;

  function GetVideoMode: Word;

implementation

{$ifdef ForPacket}
uses PMApp;

  {$L smouse.obj}
  procedure ChangeFont9to8; external;
{$endif}

constructor TUserScreen.Init;
begin
  inherited Init;
  ScrBuff := nil;
end;

destructor TUserScreen.Done;
begin
  Reset;
  inherited Done;
end;

procedure TUserScreen.Reset;
begin
  if Assigned(ScrBuff) then
  begin
    FreeMem(ScrBuff, BuffSize);
    ScrBuff := nil;
  end;
end;

procedure TUserScreen.Restore;
var
  Ev: TEvent;
begin
  if ScreenMode <> ScrMode then
    TextMode(ScrMode);
  SetBlink;
  if Assigned(ScrBuff) then
    Move(ScrBuff^, ScreenBuffer^, BuffSize);
  SetCurPos(CursPos.X, CursPos.Y);
end;

procedure TUserScreen.Show;
var
  EvK, EvM: TEvent;
  Mode: Word;
begin
  NoCursor;
  if ScreenMode <> ScrMode
    then begin
      ClearScreen;
      TextMode(ScrMode);
      {$ifdef ForPacket}
      if SMInstalled then ChangeFont9to8;
      {$endif}
    end;
  SetBlink;
  if Assigned(ScrBuff) then
    Move(ScrBuff^, ScreenBuffer^, BuffSize);
  ky;
  SetCurPos(CursPos.X, CursPos.Y);
  repeat
    GetKeyEvent(EvK);
    GetMouseEvent(EvM);
    if EvM.What <> evMouseDown then EvM.What := evNothing;
  until (EvK.What <> evNothing) or (EvM.What <> evNothing);
  if ScreenMode <> ScrMode
    then begin
      Mode := ScreenMode;
      Application^.SetScreenMode(ScreenMode);
      ScreenMode := Mode;
      {$ifdef ForPacket}
      if SMInstalled then ChangeFont9to8;
      {$endif}
    end;
  if WhereY = 1
    then kn
  else YesCursor;
  SetIntensity;
  Application^.Redraw;
end;

procedure TUserScreen.GetScreenSizes;
var
  Regs: Registers;
begin
  with Regs do
  begin
    ah := $f;
    Intr($10, Regs);
    ScrSize.X := ah;
  end;
  if ScrMode and smFont8x8 = 0
    then ScrSize.Y := 25
  else with Regs do
  begin
    ah := $11;
    al := $30;
    bh := 0;
    Intr($10, Regs);
    ScrSize.Y := dl + 1;
  end;
end;

procedure TUserScreen.Store;
begin
  Reset;
  ScrMode := GetVideoMode;
  if WhereY > 25 then ScrMode := smCO80 + smFont8x8;
  if not ((ScrMode in [smMono, smBW80, smCO80])
    or (ScrMode and smFont8x8 <> 0)) then
  begin
    ScrBuff := nil;
    CursPos.X := 0;
    CursPos.Y := 0;
    exit;
  end;
  if ScrMode and smMono = smMono
    then ScreenBuffer := Ptr(SegB000, $0)
    else ScreenBuffer := Ptr(SegB800, $0);
  GetScreenSizes;
  BuffSize := ScrSize.X * ScrSize.Y * 2;
  CursPos.X := WhereX;
  CursPos.Y := WhereY;
  GetMem(ScrBuff, BuffSize);
  Move(ScreenBuffer^, ScrBuff^, BuffSize);
end;


{  !!! Написать по-другому !!!  }
function GetVideoMode: Word;
begin
  GetVideoMode := LastMode;
end;

end.
