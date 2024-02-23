{$define ForPacket}

(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Outp_Win                                        *)
(* Окно Output                                            *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 09.09.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Outp_Win;

interface

uses Objects, Views, Drivers,
{$ifdef ForPacket}
   StreamID,
   Pack_Cmd,
   Language,
   PackLng,
{$endif}
   User_Scr;

type

  POutputWindow = ^TOutputWindow;
  POutputInterior = ^TOutputInterior;
  TOutputInterior = object(TScroller)
    UserScreen: PUserScreen;

    constructor Init(var Bounds: TRect; US: PUserScreen;
                     AHScrollBar, AVScrollBar: PScrollBar);
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure Adjust(US: PUserScreen);
  end;

  TOutputWindow = object(TWindow)
    Interior: POutputInterior;

    constructor Init(var Bounds: TRect; ATitle: TTitleStr; ANumber: Integer;
                     US: PUserScreen; AHelpCtx: Word);
    constructor Load(var S: TStream);
    function GetTitle(MaxSize: Integer): TTitleStr; virtual;
    procedure Store(var S: TStream);
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure Adjust(US: PUserScreen);
  end;

const

{$ifndef ForPacket}
  idOutputWindow    = 54363;
  idOutputInterior  = 54364;

  cmSearchOutputWin = 53646;
{$endif}

  ROutputWindow: TStreamRec = (
     ObjType: idOutputWindow;
     VmtLink: Ofs(TypeOf(TOutputWindow)^);
     Load:    @TOutputWindow.Load;
     Store:   @TOutputWindow.Store
  );

  ROutputInterior: TStreamRec = (
     ObjType: idOutputInterior;
     VmtLink: Ofs(TypeOf(TOutputInterior)^);
     Load:    @TOutputInterior.Load;
     Store:   @TOutputInterior.Store
  );

procedure RegisterOutputWin;

implementation

constructor TOutputWindow.Init(var Bounds: TRect; ATitle: TTitleStr;
                        ANumber:Integer; US: PUserScreen; AHelpCtx: Word);
var
  HScrollBar, VScrollBar: PScrollBar;
  R: TRect;
begin
  inherited Init(Bounds, ATitle, ANumber);
  Options := Options or (ofTileable + ofFirstClick);
  HelpCtx := AHelpCtx;

  HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  VScrollBar := StandardScrollBar(sbVertical + sbHandleKeyboard);

  GetExtent(R);
  R.Grow(-1, -1);
  Interior := New(POutputInterior, Init(R, US, HScrollBar, VScrollBar));
  Insert(Interior);
end;

constructor TOutputWindow.Load(var S: TStream);
begin
  inherited Load(S);
  GetSubViewPtr(S, Interior);
end;

procedure TOutputWindow.Store(var S: TStream);
begin
  inherited Store(S);
  PutSubViewPtr(S, Interior);
end;

procedure TOutputWindow.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evBroadcast) and (Event.Command = cmSearchOutputWin)
    then ClearEvent(Event);
  inherited HandleEvent(Event);
end;

procedure TOutputWindow.Adjust(US: PUserScreen);
begin
  Interior^.Adjust(US);
  if State and sfVisible <> 0
    then Redraw;
end;

function TOutputWindow.GetTitle(MaxSize: Integer): TTitleStr;
begin
{$ifndef ForPacket}
  GetTitle := inherited GetTitle(MaxSize)
{$else}
  GetTitle := Ph(phOutputWinTitle)
{$endif}
end;

{-------------------------------------------------------------------------}

constructor TOutputInterior.Init(var Bounds: TRect; US: PUserScreen;
                                 AHScrollBar, AVScrollBar: PScrollBar);
begin
  inherited Init(Bounds, AHScrollBar, AVScrollBar);

  GrowMode := gfGrowHiX + gfGrowHiY;
  UserScreen := US;
  Adjust(US);
  SetState(sfCursorVis, True);
end;

constructor TOutputInterior.Load(var S: TStream);
begin
  inherited Load(S);
  UserScreen := nil;
end;

procedure TOutputInterior.Adjust(US: PUserScreen);
begin
  UserScreen := US;
  with UserScreen^ do
    begin
      SetLimit(ScrSize.X, ScrSize.Y);
      SetCursor(CursPos.X - 1 - Delta.X, CursPos.Y - 1 - Delta.Y);
    end;
end;

procedure TOutputInterior.Draw;
var
  B: TDrawBuffer;
  i: Integer;
  Buffer: PByteArray;
begin
  if Assigned(UserScreen)
    then Buffer := UserScreen^.ScrBuff;
  for i := Delta.Y to Delta.Y + Size.Y - 1 do
  begin
    MoveChar(B, ' ', 7, Size.X);
    if Assigned(UserScreen) and (i < UserScreen^.ScrSize.Y)
      then Move(Buffer^[i * UserScreen^.ScrSize.X * 2 + Delta.X * 2],
                B, (UserScreen^.ScrSize.X - Delta.X) * 2);
    WriteLine(0, i - Delta.Y, Size.X, 1, B);
  end;
end;

procedure RegisterOutputWin;
begin
  RegisterType(ROutputWindow);
  RegisterType(ROutputInterior);
end;

end.
