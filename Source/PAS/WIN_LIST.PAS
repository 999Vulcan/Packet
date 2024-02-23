{$define UseBaseApp}
(**********************************************************)
(*                                                        *)
(* Модуль Win_List                                        *)
(* Список окон с возможностью перехода и удаления         *)
(*                                                        *)
(* Если Вы не используете объект TBaseApp,                *)
(* удалите  "{$define UseBaseApp}"  в первой строке.      *)
(*                                                        *)
(* Если при закрытии окно выводит какое - либо диалоговое *)
(* окно, то это диалоговое окно необходимо вставлять      *)
(* в Application ( можно использовать метод               *)
(* AppExecuteDialog объекта TBaseApp ).                   *)
(*                                                        *)
(* Авторы : Константин Вулах, Игорь Зисельман             *)
(*                                                        *)
(* Начат         : 18.02.1993                             *)
(*                                                        *)
(**********************************************************)

Unit Win_List;

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

interface

procedure WindowList(AHelpCtx: Word);

implementation

uses

 Objects,
 Drivers,
 Views,
 App,
{$ifdef UseBaseApp}
 BaseApp,
{$endif}
{***}
 Language,
 PackLng,
{***}
 Dialogs;

const

  cmDeleteWindow = 255;

type

 PPWindow = ^PWindow;

 PWinListBox    = ^TWinListBox;
 TWinListBox    = object(TListBox)

   constructor Init(var Bounds: TRect; ANumCols: Word;
                    AScrollBar: PScrollBar;nC:PCollection);
   procedure   HandleEvent(var Event: TEvent); virtual;
   function    GetText(Item:Integer;MaxLen:Integer):String; virtual;
   procedure   SetData(var Rec); virtual;
 end;

 PWinCollection = ^TWinCollection;
 TWinCollection = object(TSortedCollection)
   procedure FreeItem(Item: Pointer); virtual;
   function Compare(Key1, Key2: Pointer): Integer; virtual;
 end;


 PWindowList = ^TWindowList;
 TWindowList = object(TDialog)
                     nNW         : PWinCollection;
                     WLB         : PWinListBox;

                     constructor Init;
                     destructor  Done;                         virtual;
                     procedure   ReadList;
                     procedure   GetData(var Rec); virtual;
                     procedure   HandleEvent(var Event:TEvent);virtual;
                     function    GetActItemNum: Integer;
                     { включение / отключение кнопки Delete }
                     procedure   SetDeleteButton;
                     procedure   SelectWindow(N: Integer);
                     procedure   DeleteWindow;
 end;

procedure WindowList(AHelpCtx: Word);
var
  P: PWindowList;
  W: PWindow;
  Cmd: Word;

begin
  New(P, Init);
  P^.HelpCtx := AHelpCtx;
  Application^.EnableCommands([cmClose, cmResize]);

  Application^.Redraw;

{$ifdef UseBaseApp}
  Cmd := BaseApplication^.AppExecuteDialog(P, @W);
{$else}
  if Application^.ValidView(P) = nil then Exit;
  Cmd := Application^.ExecView(P);
  if Cmd <> cmCancel then P^.GetData(W);
{$endif}

  if (Cmd = cmOk) and Assigned(W) then W^.Select;
  if not Assigned(Desktop^.Current)
    then Application^.DisableCommands
           ([cmClose, cmResize, cmNext, cmPrev, cmZoom])
    else if (PWindow(Desktop^.Current)^.Flags and wfZoom) <> 0
           then Application^.EnableCommands([cmZoom]);
end;

procedure TWinCollection.FreeItem(Item: Pointer);
begin

end;

function TWinCollection.Compare(Key1, Key2: Pointer): Integer;

function sign(A: Integer): Integer;
begin
  Case A of
       0: sign := 0;
   1..10: sign := 1
  else sign := -1
  end;
end;

begin
  if PWindow(Key1)^.Number = 0 then
  begin
    Compare := 1;
    exit;
  end;
  if PWindow(Key2)^.Number = 0 then
  begin
    Compare := -1;
    exit;
  end;
  Compare := sign(PWindow(Key1)^.Number - PWindow(Key2)^.Number)
end;

(************* TWinListBox ****************)

constructor TWinListBox.Init(var Bounds: TRect; ANumCols: Word;
  AScrollBar: PScrollBar;nC:PCollection);
begin
  inherited Init(Bounds, ANumCols, AScrollBar);
  NewList(nC);
end;

procedure TWinListBox.HandleEvent(var Event: TEvent);
begin
  if (Event.What = evMouseDown) and Event.Double
    then begin
      Message(Owner, evCommand, cmOk, nil);
      ClearEvent(Event);
    end;
  inherited HandleEvent(Event);
end;

function TWinListBox.GetText
           (Item:Integer;MaxLen:Integer): String;
var
 tmpLine : String;
 CNumber : byte;
begin
 tmpLine := PWindow(List^.At(Item))^.GetTitle(MaxLen - 5);
 CNumber := PWindow(List^.At(Item))^.Number;
 if (CNumber > 0) and (CNumber < 10)
   then tmpLine := Concat(chr(ord('0') + CNumber), ' ', tmpLine)
 else tmpLine := Concat('  ', tmpLine);
 GetText := tmpLine;
end;

procedure TWinListBox.SetData(var Rec);
begin
end;

(************* TWindowList ****************)

constructor TWindowList.Init;
var
 R         : TRect;
 Control   : PView;
 tmpNumb   : Word;
 tmpNameW  : String;
 tmpSign   : Byte;
 cl        : Word;

begin
 R.Assign(0, 0, 61, 20);
 inherited Init(R, Ph(phWindowList));
 Options:=Options or ofCentered;
 R.Assign(44, 4, 45, 18);
 Control:=New(PScrollBar,Init(R));
 Insert(Control);

 R.Assign(46, 4, 58, 6);
 Insert(New(PButton, Init(R, Ph(phCOk), cmOK, bfDefault)));
 Inc(R.A.Y, 3); Inc(R.B.Y, 3);
 Insert(New(PButton, Init(R, Ph(phCDeleteWin), cmDeleteWindow, bfNormal)));
 Inc(R.A.Y, 3); Inc(R.B.Y, 3);
 Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
 Inc(R.A.Y, 7); Inc(R.B.Y, 7);
 Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
 nNW := nil;
 ReadList;
 R.Assign(3, 4, 44, 18);
 WLB:=New(PWinListBox,Init(R,1,PScrollBar(Control),nNW));
 with WLB^ do Options := Options or ofFramed;
 WLB^.FocusItem(GetActItemNum);
 Insert(WLB);
 R.Assign(3, 2, 44, 3);
 Insert(New(PLabel, Init(R, Ph(phCWindows),WLB)));
 SetDeleteButton;
end;

procedure TWindowList.ReadList;

procedure GetNameWindow(P: PView); far;
begin
  if (not Assigned(P)) or (P = Desktop^.Last)
    or (P^.State and sfVisible = 0)
  then exit;
  nNW^.Insert(PPWindow(P));
end;

begin
  nNW := New(PWinCollection, Init(1,1));
  Desktop^.ForEach(@GetNameWindow);
end;

procedure TWindowList.GetData(var Rec);
begin
  if WLB^.List^.Count <> 0
    then PWindow(Rec) := WLB^.List^.At(WLB^.Focused)
  else PWindow(Rec) := nil;
end;

function TWindowList.GetActItemNum: Integer;
var
  P: PWindow;
  i: Integer;

function IsFirstWin(P: PView): Boolean; far;
var
  i: Integer;
  P1: PView;

function IsWin(P: PView): Boolean; far;
begin
  IsWin := Assigned(P) and (P <> Desktop^.Last)
           and (P^.State and sfVisible <> 0)
end;

begin
  P1 := Desktop^.FirstThat(@IsWin);
  IsFirstWin := P = P1;
end;

function SearchNextWin(P: PWindow): PWindow;
var
  NewWin: PWindow;
begin
  NewWin := P;
  repeat
    if Assigned(NewWin)
      then NewWin := PWindow(NewWin^.Next);
    if not Assigned(NewWin) then Break;
    if (NewWin <> PWindow(Desktop^.Last))
      and (NewWin^.State and sfVisible <> 0)
    then Break;
  until NewWin = P;
  SearchNextWin := NewWin;
end;

begin
  P := WLB^.List^.FirstThat(@IsFirstWin);
  P := SearchNextWin(P);

  GetActItemNum := 0;
  for i := 0 to WLB^.List^.Count - 1 do
    if P = WLB^.List^.At(i) then GetActItemNum := i;
end;

procedure TWindowList.SetDeleteButton;
begin
  Case WLB^.List^.Count > 0 of
    True:Application^.EnableCommands([cmDeleteWindow]);
   False:begin
           Application^.DisableCommands([cmDeleteWindow]);
           if (TypeOf(Current^) = TypeOf(TButton))
             and (PButton(Current)^.Command = cmDeleteWindow)
           then SelectNext(True);
         end;
  end;
end;

procedure TWindowList.HandleEvent;
begin
  inherited HandleEvent(Event);
  if (Event.What = evKeyDown) then
    begin
      Case Event.KeyCode of
        kbDel: begin
                 ClearEvent(Event);
                 Message(@Self, evCommand, cmDeleteWindow, nil);
               end;
      end;
      Case Event.CharCode of
        '1'..'9': SelectWindow(ord(Event.CharCode) - ord('0'));
        else Exit;
      end;
    end;
  if (Event.What = evBroadcast) or
     (Event.What = evCommand)   then
  Case Event.Command of
   cmDeleteWindow:if WLB^.List^.Count > 0
                    then DeleteWindow;
  else
    exit;
  end;
  ClearEvent(Event);
end;

procedure TWindowList.DeleteWindow;
var
  oldCount: Integer;
begin
  if Assigned(nNW) then
  Message(PView(WLB^.List^.At(WLB^.Focused)),
    evCommand, cmClose, nil);
  Application^.EnableCommands([cmClose, cmResize]);
  oldCount := WLB^.List^.Count;
  Dispose(WLB^.List, Done);
  ReadList;
  WLB^.List := nNW;
  if nNW^.Count <> oldCount then
  begin
    if (WLB^.TopItem > 0) and
       ((WLB^.List^.Count - WLB^.TopItem) < WLB^.Size.Y)
    then Dec(WLB^.TopItem);
    WLB^.SetRange(nNW^.Count);
    WLB^.DrawView;
  end;
  SetDeleteButton;
end;

procedure TWindowList.SelectWindow(N: Integer);
var
  i: Integer;
begin
  for i := 0 to 8 do
    if (WLB^.List^.Count > i) and (PWindow(WLB^.List^.At(i))^.Number = N)
      then begin
        WLB^.FocusItem(i);
        Message(@Self, evCommand, cmOk, nil);
      end;
end;

destructor TWindowList.Done;
begin
 if nNW <> nil then Dispose(nNW,Done);
 inherited Done;
end;


end.

