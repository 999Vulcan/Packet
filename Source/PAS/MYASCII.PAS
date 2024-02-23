{******************************************************************}
{                                                                  }
{   Turbo Vision Demo                                              }
{   Copyright (c) 1990 by Borland International                    }
{                                                                  }
{   Corrected by Constantine Vulakh                                }
{   28.09.1993                                                     }
{                                                                  }
{******************************************************************}
unit MyAscii;

{$F+,O+,X+}

interface

uses

 Objects, App, Views, Drivers, Language, PackLng, RepMChrs,
 PackText, StreamID;

type
  PTable = ^TTable;
  TTable = object(TView)
    procedure Draw; virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
    procedure GenerateChar;
    function GetPalette: PPalette; virtual;
  end;

  PReport = ^TReport;
  TReport = object(TView)
    AsciiChar: LongInt;
    constructor Load(var S: TStream);
    procedure Draw; virtual;
    procedure HandleEvent(var Event:TEvent); virtual;
    procedure Store(var S: TStream);
    function GetPalette: PPalette; virtual;
  end;

  PAsciiChart = ^TAsciiChart;
  TAsciiChart = object(TWindow)
    constructor Init;
    function GetPalette: PPalette; virtual;
    function GetTitle(MaxSize: Integer): TTitleStr; virtual;
  end;

const

  CAsciiMonochrome = #$07#$0F#$07#$07;
  CAsciiColor      = #$70#$7F#$7A#$70;
  CAsciiBlackWhite = #$70#$7F#$70#$70;
  CAsciiChart = #154#155#156#157;
  CReport     = #4;
  CTable      = #4;

  AsciiTableCommandBase: Word = 910;

  RTable: TStreamRec = (
     ObjType: idTable;
     VmtLink: Ofs(TypeOf(TTable)^);
     Load:    @TTable.Load;
     Store:   @TTable.Store
  );
  RReport: TStreamRec = (
     ObjType: idReport;
     VmtLink: Ofs(TypeOf(TReport)^);
     Load:    @TReport.Load;
     Store:   @TReport.Store
  );
  RAsciiChart: TStreamRec = (
     ObjType: idAsciiChart;
     VmtLink: Ofs(TypeOf(TAsciiChart)^);
     Load:    @TAsciiChart.Load;
     Store:   @TAsciiChart.Store
  );

procedure RegisterAsciiTab;

implementation

uses Dir_Wind;

const
  cmCharacterFocused = 0;

procedure TTable.Draw;
var
  Buf: TDrawBuffer;
  X, Y: Integer;
  Color: Byte;
begin
  Color := GetColor(1);
  for Y := 0 to Size.Y - 1 do
  begin
    MoveChar(Buf, ' ', Color, Size.X);
    for X := 0 to Size.X - 1 do
      if not ((Y = 0) and (Chr(Lo(x)) in MouseCharsSet))
        then MoveChar(Buf[x], Chr(32 * y + x), Color, 1)
      else MoveChar(Buf[x], Chr(tsReplCharNo), Color, 1);
    WriteLine(0, y, Size.X, 1, Buf);
  end;
  ShowCursor;
end;

procedure TTable.GenerateChar;
var
  key: record
         ch: char;
         scan: byte;
       end;
begin
  key.ch := chr(Cursor.Y * 32 + Cursor.X);
  key.scan := 0;
  Desktop^.Lock;
  Desktop^.SelectNext(True);
  if Desktop^.Current <> PView(FirstDirWindow)
    then Message(Desktop^.Current, evKeyDown, Word(Key), nil);
  Desktop^.SelectNext(True);
  Desktop^.Unlock;
end;

procedure TTable.HandleEvent(var Event:TEvent);
var
  CurrentSpot: TPoint;

procedure CharFocused;
begin
  Message(Owner, evBroadcast, AsciiTableCommandBase + cmCharacterFocused,
    Pointer(Cursor.X + 32 * Cursor.Y));
end;

begin
  inherited HandleEvent(Event);
  if Event.What = evMouseDown then
  begin
    repeat
      if MouseInView(Event.Where) then  { ! Changed ! }
        Case Event.Double of
           True: GenerateChar;
          False: begin
                   MakeLocal(Event.Where, CurrentSpot);
                   SetCursor(CurrentSpot.X, CurrentSpot.Y);
                   CharFocused;
                 end;
        end;
    until not MouseEvent(Event, evMouseMove);
    ClearEvent(Event);
  end
  else if Event.What = evKeyDown then
    with Cursor do begin
      case Event.KeyCode of
        kbHome: SetCursor(0,0);
        kbEnd: SetCursor(Size.X - 1, Size.Y - 1);
        kbUp: if Y > 0 then SetCursor(X, Y - 1);
        kbDown: if Y < Size.Y - 1 then SetCursor(X, Y + 1);
        kbLeft: if X > 0 then SetCursor(X - 1, Y);
        kbRight: if X < Size.X - 1 then SetCursor(X + 1, Y);
     { ! Changed ! }
        kbEnter: GenerateChar;
        kbEsc: Message(Owner, evCommand, cmClose, nil);
      else
        SetCursor(ord(Event.CharCode) mod 32, ord(Event.CharCode) div 32);
      end;
    { ! Changed ! }
      if (Event.KeyCode <> kbEnter) and (Event.KeyCode <> kbEsc)
        then CharFocused;
      ClearEvent(Event);
    end;
end;

function TTable.GetPalette: PPalette;
const
  P: String[Length(CTable)] = CTable;
begin
  GetPalette := @P;
end;

{ TReport }

constructor TReport.Load(var S: TStream);
begin
  inherited Load(S);
  S.Read(AsciiChar, SizeOf(AsciiChar));
end;

procedure TReport.Draw;
var
  TempStr: string;
begin
  FormatStr(TempStr, '  Char: %c Decimal: %0#%3d Hex: %0#%02x  ', AsciiChar);
  ReplCharsInStr(TempStr);
  WriteStr(0, 0, TempStr, 1);
end;

function TReport.GetPalette: PPalette;
const
  P: String[Length(CReport)] = CReport;
begin
  GetPalette := @P;
end;

procedure TReport.HandleEvent(var Event: TEvent);
var
  Table: PTable;
begin
  inherited HandleEvent(Event);
  if Event.What = evBroadcast then
    if Event.Command = AsciiTableCommandBase + cmCharacterFocused then
    begin
      AsciiChar := Event.InfoLong;
      DrawView;
    end;
end;

procedure TReport.Store(var S: TStream);
begin
  inherited Store(S);
  S.Write(AsciiChar, SizeOf(AsciiChar));
end;

constructor TAsciiChart.Init;
var
  R: TRect;
  Control: PVIew;
begin
  R.Assign(0, 0, 34, 12);
  inherited Init(R, '', wnNoNumber);
  Flags := Flags and not (wfGrow + wfZoom);
  Options := Options or ofFirstClick;
  GrowMode := 0;

  R.Grow(-1,-1);
  R.A.Y := R.B.Y - 1;
  Control := New(PReport, Init(R));
  with Control^ do
  begin
    Options := Options or ofFramed;
    EventMask := EventMask or evBroadcast;
  end;
  Insert(Control);

  GetExtent(R);
  R.Grow(-1,-1);
  R.B.Y := R.B.Y - 2;
  Control := New(PTable, Init(R));
  with Control^ do
  begin
    Options := Options or ofFramed or ofSelectable;
    BlockCursor;
  end;
  Insert(Control);
  Control^.Select;
end;

function TAsciiChart.GetPalette: PPalette;
const
  P: String[Length(CAsciiChart)] = CAsciiChart;
begin
  GetPalette := @P;
end;

function TAsciiChart.GetTitle(MaxSize: Integer): TTitleStr;
begin
  GetTitle := Ph(phAsciiTab)
end;

procedure RegisterAsciiTab;
begin
  RegisterType(RTable);
  RegisterType(RReport);
  RegisterType(RAsciiChart);
end;

end.

