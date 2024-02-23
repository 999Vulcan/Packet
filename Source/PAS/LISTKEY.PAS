Unit ListKey;
interface
uses Objects, Drivers, kbxxx;

const
 Sep : Char = '+';
 SepInNameKey : Char = '-';

type
 PStrKey = ^StrKey;
 StrKey = string[30];
 KeyItem = record
  code : Word;
  name : StrKey;
 end;

 PKeyObject = ^TKeyObject;
 TKeyObject = object(TObject)
  KeyCode : Word;
  NameKey : PString;
  constructor Init(Item:KeyItem);
  constructor Load(var S:TStream);
  procedure Store(var S:TStream) ; virtual;
  destructor Done; virtual;
 end;

 PListKey = ^TListKey;
 TListKey = object(TCollection)
  constructor Init(ALimit, ADelta: Integer; ASeparator : Char);
  constructor Load(var S:TStream);
  procedure Store(var S:TStream) ; virtual;
  function GetKeyName(keycode : Word; AShiftState : byte) : StrKey;
  function GetKeyCode(NK : PStrKey) : Word;
  private
   Separator : Char;
   procedure InsertSeparator(var S: StrKey);
   procedure DisposeSeparator(var S: StrKey);
 end;

 function InitListKey : PListKey;
 procedure RegisterListKey;

const

  RKeyObject: TStreamRec = (
     ObjType: 2500;
     VmtLink: Ofs(TypeOf(TKeyObject)^);
     Load:    @TKeyObject.Load;
     Store:   @TKeyObject.Store
  );
  RListKey: TStreamRec = (
     ObjType: 2501;
     VmtLink: Ofs(TypeOf(TListKey)^);
     Load:    @TListKey.Load;
     Store:   @TListKey.Store
  );

implementation
{$DEFINE __PACKET_VER__}

const
 NumbKey = 134;
 KeyList : array[0..NumbKey-1] of KeyItem=
 (
   (code:kbF1       ; name:'F1'),
   (code:kbF2       ; name:'F2'),
   (code:kbF3       ; name:'F3'),
   (code:kbF4       ; name:'F4'),
   (code:kbF5       ; name:'F5'),
   (code:kbF6       ; name:'F6'),
   (code:kbF7       ; name:'F7'),
   (code:kbF8       ; name:'F8'),
   (code:kbF9       ; name:'F9'),
   (code:kbF10      ; name:'F10'),
   (code:kbShiftF1  ; name:'Shift-F1'),
   (code:kbShiftF2  ; name:'Shift-F2'),
   (code:kbShiftF3  ; name:'Shift-F3'),
   (code:kbShiftF4  ; name:'Shift-F4'),
   (code:kbShiftF5  ; name:'Shift-F5'),
   (code:kbShiftF6  ; name:'Shift-F6'),
   (code:kbShiftF7  ; name:'Shift-F7'),
   (code:kbShiftF8  ; name:'Shift-F8'),
   (code:kbShiftF9  ; name:'Shift-F9'),
   (code:kbShiftF10 ; name:'Shift-F10'),
   (code:kbCtrlF1   ; name:'Ctrl-F1'),
   (code:kbCtrlF2   ; name:'Ctrl-F2'),
   (code:kbCtrlF3   ; name:'Ctrl-F3'),
   (code:kbCtrlF4   ; name:'Ctrl-F4'),
   (code:kbCtrlF5   ; name:'Ctrl-F5'),
   (code:kbCtrlF6   ; name:'Ctrl-F6'),
   (code:kbCtrlF7   ; name:'Ctrl-F7'),
   (code:kbCtrlF8   ; name:'Ctrl-F8'),
   (code:kbCtrlF9   ; name:'Ctrl-F9'),
   (code:kbCtrlF10  ; name:'Ctrl-F10'),
   (code:kbAltF1    ; name:'Alt-F1'),
   (code:kbAltF2    ; name:'Alt-F2'),
   (code:kbAltF3    ; name:'Alt-F3'),
   (code:kbAltF4    ; name:'Alt-F4'),
   (code:kbAltF5    ; name:'Alt-F5'),
   (code:kbAltF6    ; name:'Alt-F6'),
   (code:kbAltF7    ; name:'Alt-F7'),
   (code:kbAltF8    ; name:'Alt-F8'),
   (code:kbAltF9    ; name:'Alt-F9'),
   (code:kbAltF10   ; name:'Alt-F10'),
   (code:kbAltA     ; name:'Alt-A'),
   (code:kbAltB     ; name:'Alt-B'),
   (code:kbAltC     ; name:'Alt-C'),
   (code:kbAltD     ; name:'Alt-D'),
   (code:kbAltE     ; name:'Alt-E'),
   (code:kbAltF     ; name:'Alt-F'),
   (code:kbAltG     ; name:'Alt-G'),
   (code:kbAltH     ; name:'Alt-H'),
   (code:kbAltI     ; name:'Alt-I'),
   (code:kbAltJ     ; name:'Alt-J'),
   (code:kbAltK     ; name:'Alt-K'),
   (code:kbAltL     ; name:'Alt-L'),
   (code:kbAltM     ; name:'Alt-M'),
   (code:kbAltN     ; name:'Alt-N'),
   (code:kbAltO     ; name:'Alt-O'),
   (code:kbAltP     ; name:'Alt-P'),
   (code:kbAltQ     ; name:'Alt-Q'),
   (code:kbAltR     ; name:'Alt-R'),
   (code:kbAltS     ; name:'Alt-S'),
   (code:kbAltT     ; name:'Alt-T'),
   (code:kbAltU     ; name:'Alt-U'),
   (code:kbAltV     ; name:'Alt-V'),
   (code:kbAltW     ; name:'Alt-W'),
   (code:kbAltX     ; name:'Alt-X'),
   (code:kbAltY     ; name:'Alt-Y'),
   (code:kbAltZ     ; name:'Alt-Z'),
   (code:kbCtrlA    ; name:'Ctrl-A'),
   (code:kbCtrlB    ; name:'Ctrl-B'),
   (code:kbCtrlC    ; name:'Ctrl-C'),
   (code:kbCtrlD    ; name:'Ctrl-D'),
   (code:kbCtrlE    ; name:'Ctrl-E'),
   (code:kbCtrlF    ; name:'Ctrl-F'),
   (code:kbCtrlG    ; name:'Ctrl-G'),
   (code:kbCtrlH    ; name:'Ctrl-H'),
   (code:kbCtrlI    ; name:'Ctrl-I'),
   (code:kbCtrlJ    ; name:'Ctrl-J'),
   (code:kbCtrlK    ; name:'Ctrl-K'),
   (code:kbCtrlL    ; name:'Ctrl-L'),
   (code:kbCtrlM    ; name:'Ctrl-M'),
   (code:kbCtrlN    ; name:'Ctrl-N'),
   (code:kbCtrlO    ; name:'Ctrl-O'),
   (code:kbCtrlP    ; name:'Ctrl-P'),
   (code:kbCtrlQ    ; name:'Ctrl-Q'),
   (code:kbCtrlR    ; name:'Ctrl-R'),
   (code:kbCtrlS    ; name:'Ctrl-S'),
   (code:kbCtrlT    ; name:'Ctrl-T'),
   (code:kbCtrlU    ; name:'Ctrl-U'),
   (code:kbCtrlV    ; name:'Ctrl-V'),
   (code:kbCtrlW    ; name:'Ctrl-W'),
   (code:kbCtrlX    ; name:'Ctrl-X'),
   (code:kbCtrlY    ; name:'Ctrl-Y'),
   (code:kbCtrlZ    ; name:'Ctrl-Z'),
   (code:kbAlt0     ; name:'Alt-0'),
   (code:kbAlt1     ; name:'Alt-1'),
   (code:kbAlt2     ; name:'Alt-2'),
   (code:kbAlt3     ; name:'Alt-3'),
   (code:kbAlt4     ; name:'Alt-4'),
   (code:kbAlt5     ; name:'Alt-5'),
   (code:kbAlt6     ; name:'Alt-6'),
   (code:kbAlt7     ; name:'Alt-7'),
   (code:kbAlt8     ; name:'Alt-8'),
   (code:kbAlt9     ; name:'Alt-9'),

   (code:kbAltSpace ; name:'Alt-Space'),
   (code:kbCtrlIns  ; name:'Ctrl-Ins'),
   (code:kbShiftIns ; name:'Shift-Ins'),
   (code:kbCtrlDel  ; name:'Ctrl-Del'),
   (code:kbShiftDel ; name:'Shift-Del'),
   (code:kbBack     ; name:'Back'),
   (code:kbCtrlBack ; name:'Ctrl-Back'),
   (code:kbShiftTab ; name:'Shift-Tab'),
   (code:kbTab      ; name:'Tab'),
   (code:kbCtrlEnter; name:'Ctrl-Enter'),
   (code:kbHome     ; name:'Home'),
   (code:kbUp       ; name:'Up'),
   (code:kbPgUp     ; name:'PgUp'),
   (code:kbGrayMinus; name:'GrayMinus'),
   (code:kbLeft     ; name:'Left'),
   (code:kbRight    ; name:'Right'),
   (code:kbGrayPlus ; name:'GrayPlus'),
   (code:kbEnd      ; name:'End'),
   (code:kbDown     ; name:'Down'),
   (code:kbPgDn     ; name:'PgDn'),
   (code:kbIns      ; name:'Ins'),
   (code:kbDel      ; name:'Del'),
   (code:kbCtrlPrtSc; name:'Ctrl-PrtSc'),
   (code:kbCtrlLeft ; name:'Ctrl-Left'),
   (code:kbCtrlRight; name:'Ctrl-Right'),
   (code:kbCtrlEnd  ; name:'Ctrl-End'),
   (code:kbCtrlPgDn ; name:'Ctrl-PgDn'),
   (code:kbCtrlHome ; name:'Ctrl-Home'),
   (code:kbAltMinus ; name:'Alt-Minus'),
   (code:kbAltEqual ; name:'Alt-Equal'),
   (code:kbCtrlPgUp ; name:'Ctrl-PgUp'),
   (code:kbAltBack  ; name:'Alt-Back')
 );


{----------------------Реализация объекта TKeyObject-------------------------}


 constructor TKeyObject.Init(Item:KeyItem);
 begin
  KeyCode := Item.code;
  NameKey := NewStr(Item.name);
 end;

 constructor TKeyObject.Load(var S:TStream);
 begin
  S.Read(KeyCode,sizeof(Word));
  NameKey := S.ReadStr;
 end;

 procedure TKeyObject.Store(var S:TStream);
 begin
  S.Write(KeyCode,sizeof(Word));
  S.WriteStr(NameKey);
 end;

 destructor TKeyObject.Done;
 begin
  DisposeStr(NameKey);
 end;

{----------------------------------------------------------------------------}

{----------------------Реализация объекта TListKey---------------------------}

 constructor TListKey.Init(ALimit, ADelta: Integer; ASeparator : Char);
 begin
  TCollection.Init(ALimit, ADelta);
  Separator := ASeparator;
 end;

 constructor TListKey.Load(var S:TStream);
 begin
  S.Read(Separator,sizeof(Char));
  TCollection.Load(S);
 end;

 procedure TListKey.Store(var S:TStream) ;
 begin
  S.Write(Separator,sizeof(Char));
  TCollection.Store(S);
 end;

 function TListKey.GetKeyName(keycode : Word; AShiftState : byte) : StrKey;
 var
   Item : PKeyObject;
   S : StrKey;

 function Test(P : Pointer) : boolean; far;
 begin
  Test := PKeyObject(P)^.KeyCode = keycode;
 end;

 procedure TreatmentShift(var Name: StrKey);
 var
   P : byte;
 const
  S_Shift : string[5] = 'Shift';
  S_Ctrl : string[4] = 'Ctrl';
  S_Alt : string[3] = 'Alt';
  S_Right : string[5] = 'Right';
  S_Left : string[4] = 'Left';
 function SearchPos(What,InsS : string) : boolean;
 begin
  P := Pos(What, Name);
  SearchPos := P <> 0;
{$IFNDEF __PACKET_VER__}
  if P <> 0 then
   if (P > 1) and (What = S_Shift) then Name := Concat(InsS, What, Separator, Name)
   else Name := Concat(InsS, Name);
{$ENDIF}
 end;
 begin
{$IFDEF __PACKET_VER__}
  if AShiftState and kbLeftShift <> 0 then
   if not SearchPos(S_Shift,'') then
    Name := Concat(S_Shift, Separator, Name);
{$ELSE}
  if AShiftState and kbRightShift <> 0 then
   if not SearchPos(S_Shift,S_Right) then
    Name := Concat(S_Right, S_Shift, Separator, Name);
  if AShiftState and kbLeftShift <> 0 then
   if not SearchPos(S_Shift,S_Left) then
    Name := Concat(S_Left, S_Shift, Separator, Name);
{$ENDIF}
  if AShiftState and kbCtrlShift <> 0 then
   if not SearchPos(S_Ctrl,'') then
    Name := Concat(S_Ctrl, Separator, Name);
  if AShiftState and kbAltShift <> 0 then
   if not SearchPos(S_Alt,'') then
    Name := Concat(S_Alt, Separator, Name);
 end;

 begin
  GetKeyName := '';
  Item := PKeyObject(FirstThat(@Test));
  if Item <> nil then
  begin
   S := Item^.NameKey^;
   InsertSeparator(S);
   TreatmentShift(S);
   GetKeyName := S;
  end;
 end;

 procedure TListKey.InsertSeparator(var S: StrKey);
 var I : byte;
 begin
  I := Pos(SepInNameKey, S);
  if I <> 0 then S[I] := Separator;
 end;

 procedure TListKey.DisposeSeparator(var S: StrKey);
 var I : byte;
 begin
  I := Pos(S,Separator);
  if I <> 0 then S[I] := SepInNameKey;
 end;

 function TListKey.GetKeyCode(NK : PStrKey) : Word;
 var Item : PKeyObject;

 function Test(P : Pointer) : boolean; far;
 begin
  Test := PKeyObject(P)^.NameKey^ = NK^;
 end;

 begin
  GetKeyCode := 0;
  DisposeSeparator(NK^);
  Item := PKeyObject(FirstThat(@Test));
  if Item <> nil then GetKeyCode := Item^.KeyCode;
 end;

{----------------------------------------------------------------------------}

 function InitListKey : PListKey;
 var
   P : PListKey;
   I : Integer;
 begin
  P := New(PListKey, Init(10, 10, Sep));
  if P <> nil then
   for I := 0 to NumbKey - 1 do
    P^.Insert(New(PKeyObject, Init(KeyList[I])));
  InitListKey := P;
 end;

 procedure RegisterListKey;
 begin
  RegisterType(RKeyObject);
  RegisterType(RListKey);
 end;

end.
