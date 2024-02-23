(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Ann_Wind                                        *)
(* Окно аннотаций                                         *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 2.11.1994                              *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Ann_Wind;

interface

uses

  Objects, Views, Drivers, Memory, MyMsgBox, App, Items, Dirs,
  BaseApp, StreamId, LineColl, Language, PackLng, StrServ, Pack_Cmd,
  Disp_Obj, Pack_Hlp, PackText,
{$ifdef ForPacket}
  RepMChrs,
{$endif}
  Editors, EditRes;

type

  { TAnnViewer }
  PAnnViewer = ^TAnnViewer;
  TAnnViewer = object(TScroller)
    Lines: PCollection;
    OldName: PString;
    OldDirWin: Pointer;
    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar);
    constructor Load(var S: TStream);
    destructor Done; virtual;
    procedure Draw; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure NewAnnotation(AnnIndex: String);
  end;

  { TAnnWindow }
  PAnnWindow = ^TAnnWindow;
  TAnnWindow = object(TWindow)
    constructor Init(R: TRect);
    function GetTitle(MaxSize: Integer): TTitleStr; virtual;
    procedure Scroll(Key: Word);
  end;

  { TAnnEdWindow }
  PAnnEdWindow = ^TAnnEdWindow;
  TAnnEdWindow = object(TWindow)
    constructor Init(var R: TRect; ANumber: Word);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

const

  RAnnViewer: TStreamRec = (
     ObjType: idAnnViewer;
     VmtLink: Ofs(TypeOf(TAnnViewer)^);
     Load:    @TAnnViewer.Load;
     Store:   @TAnnViewer.Store
  );

  RAnnWindow: TStreamRec = (
     ObjType: idAnnWindow;
     VmtLink: Ofs(TypeOf(TAnnWindow)^);
     Load:    @TAnnWindow.Load;
     Store:   @TAnnWindow.Store
  );

procedure RegisterAnn;
function SearchAnnWindow: PAnnWindow;

implementation

uses
{$ifdef ForPacket}
  Conf_Var,
{$endif}
  Dir_Wind;

{ TAnnViewer }
constructor TAnnViewer.Init(var Bounds: TRect; AHScrollBar,
  AVScrollBar: PScrollBar);
begin
  inherited Init(Bounds, AHScrollbar, AVScrollBar);
  GrowMode := gfGrowHiX + gfGrowHiY;
  HelpCtx := hcAnnWindow;
  Lines := nil;
  OldName := nil;
  NewAnnotation('');
end;

constructor TAnnViewer.Load(var S: TStream);
begin
  inherited Load(S);
  OldName := nil;
  Lines := nil;
end;

destructor TAnnViewer.Done;
begin
  DisposeObj(Lines);
  DispStr(OldName);
  inherited Done;
end;

procedure TAnnViewer.Draw;
var
  B: TDrawBuffer;
  C: Byte;
  I: Integer;
  S: String;
  P: PString;
begin
  C := GetColor(1);
  for I := 0 to Size.Y - 1 do
  begin
    MoveChar(B, ' ', C, Size.X);
    if Assigned(Lines) and (Delta.Y + I < Lines^.Count)
    then begin
      P := Lines^.At(Delta.Y + I);
      if Assigned(P)
        then S := Copy(P^, Delta.X + 1, Length(P^) - Delta.X + 1)
      else S := '';
{$ifdef ForPacket}
      ReplCharsInStr(S);
{$endif}
      S := Copy(S, 1, Size.X);
      MoveStr(B, S, C);
    end;
    WriteLine(0, I, Size.X, 1, B);
  end;
end;

procedure TAnnViewer.NewAnnotation(AnnIndex: String);
var
  Line: String;
  MaxWidth: Integer;
  DirWin: PDirWindow;
  Reader: PResReader;
begin
  DirWin := FirstDirWindow;
  if (GetStr(OldName) = AnnIndex) and (DirWin = OldDirWin)
    then Exit;
  OldDirWin := DirWin;
  SetNewStr(OldName, AnnIndex);
  Reader := nil;
  DisposeObj(Lines);
  MaxWidth := 0;
  if (Assigned(DirWin)) and (AnnIndex <> '')
    then New(Reader, Init(DirWin^.GetDirPtr, AnnIndex));
  if not Assigned(Reader)
    then begin
      SetLimit(0, 0);
      ScrollTo(0, 0);
      if Assigned(Owner) and (Owner^.State and sfVisible <> 0)
        then Owner^.Redraw;
      Exit;
    end;
  Lines := New(PLineCollection, Init(5,5));
  while not (Reader^.EndOfRes or LowMemory) do
  begin
    Line := Reader^.ReadString;
    if Length(Line) > MaxWidth then MaxWidth := Length(Line);
    Lines^.Insert(NewStr(Line));
  end;
  DisposeObj(Reader);
  SetLimit(MaxWidth + 1, Lines^.Count);
  ScrollTo(0, 0);
  if Assigned(Owner) and (Owner^.State and sfVisible <> 0)
    then Owner^.Redraw;
end;

procedure TAnnViewer.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evBroadcast
    then begin
      Case Event.Command of
        cmNewAnn: NewAnnotation(GetStr(PString(Event.InfoPtr)));
        cmSearchAnnViewer: Event.InfoPtr := @Self;
        cmSearchAnnWindow: Event.InfoPtr := Owner;
      else Exit
      end;
      Event.What := evNothing;
    end;

  if Event.What = evCommand
    then begin
      Case Event.Command of
        cmAnnotate: Message(FirstDirWindow, evCommand, cmAnnotate, nil);
      else Exit
      end;
      ClearEvent(Event);
      Event.InfoPtr := Owner;
    end;
end;

{ TAnnWindow }
constructor TAnnWindow.Init(R: TRect);
begin
  inherited Init(R, '', BaseApplication^.FirstFreeWin);
  Options := Options or (ofTileable + ofFirstClick);
  Palette := wpGrayWindow;
  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PAnnViewer, Init(R,
    StandardScrollBar(sbHorizontal + sbHandleKeyboard),
    StandardScrollBar(sbVertical + sbHandleKeyboard))));
end;

function TAnnWindow.GetTitle(MaxSize: Integer): TTitleStr;
begin
  GetTitle := Ph(phAnnotation)
end;

procedure TAnnWindow.Scroll(Key: Word);
var
  AnnViewer: PView;
begin
  AnnViewer := Message(Desktop, evBroadcast, cmSearchAnnViewer, nil);
  Message(PAnnViewer(AnnViewer)^.HScrollBar, evKeyDown, Key, nil);
  Message(PAnnViewer(AnnViewer)^.VScrollBar, evKeyDown, Key, nil);
end;

constructor TAnnEdWindow.Init(var R: TRect; ANumber: Word);
var
  HScrollBar: PScrollBar;
  Indicator: PIndicator;
begin
  inherited Init(R, Ph(phAnnotation), ANumber);
  Palette := wpGrayWindow;
  HelpCtx := hcAnnotateWin;

  HScrollBar := StandardScrollBar(sbHorizontal + sbHandleKeyboard);
  Inc(HScrollBar^.Origin.X, 14);
  Dec(HScrollBar^.Size.X, 14);

  R.Assign(2, Size.Y - 1, 16, Size.Y);
  Indicator := New(PIndicator, Init(R));
  Indicator^.Hide;
  Insert(Indicator);

  GetExtent(R);
  R.Grow(-1, -1);
  Insert(New(PResEditor, Init(R,
    HScrollBar,
    StandardScrollBar(sbVertical + sbHandleKeyboard),
    Indicator,
    MaxTextResSize)));
end;

procedure TAnnEdWindow.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evCommand
  then Case Event.Command of
    cmCancel, cmOk, cmDelRes: begin
                                Desktop^.Lock;  {!}
                                EndModal(Event.Command);
                                ClearEvent(Event);
                              end;
  end;
end;

function SearchAnnWindow: PAnnWindow;
begin
  SearchAnnWindow :=
    PAnnWindow(Message(Desktop, evBroadcast, cmSearchAnnWindow, nil));
end;

procedure RegisterAnn;
begin
  RegisterType(RAnnViewer);
  RegisterType(RAnnWindow);
end;

end.
