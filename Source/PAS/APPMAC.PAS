Unit AppMac;
 interface
 uses App, Objects, Drivers, Memory, kbxxx, Views, Menus, Dialogs, BaseApp,
      ListKey, MyMsgBox;
 const
 { константы команд работы с макро }
  cmCreateMacro = 190;
  cmStopMacro = cmCreateMacro + 1;
  cmRemoveMacro = cmStopMacro + 1;
  cmDeleteMacros = cmRemoveMacro + 1;
  cmSaveMacros = cmDeleteMacros + 1;
  cmLoadMacros = cmSaveMacros + 1;
  cmPlayMacro = cmLoadMacros + 1;

 { константы номеров регистрируемых объектов }
  csmMacApplication = 1800;
  csmObjectEvent = 1801;
  csmMacro = 1802;
  csmWinInputKey = 1803;
  csmMacrosCollection = 1804;
  csmMacrosListBox = 1805;
  csmExtMacrosListBox = 1806;
  csmStateMacro = 1807;
  csmCollectionStatesOutMacros = 1808;

 { Константы номеров строк }
  phmNothingDelete = 1;
  phmExistanceMacro = 2;
  phmNotSavedMacros = 3;
  phmWarningForDeleteMacros = 4;
  phmNotMacrosForDeleteMacros = 5;
  phmWinCreateMacro = 6;
  phmNameWinRemoveMacro = 7;
  phmNameWinPlayMacro = 8;
  phmCreateMacro = 9;
  phmStopMacro = 10;
  phmPlayMacro = 11;
  phmRemoveMacro = 12;
  phmDeleteMacros = 13;
  phmCreateMacroHotKey = 14;
  phmStopMacroHotKey = 15;
  phmPlayMacroHotKey = 16;
  phmWarning = 17;
  phmCancel = 18;
  phmMacro = 19;
  phmOK = 20;

 { Константы контекстов помощи }
  hcmWinCreateMacro = 1;
  hcmWinPlayMacro   = 2;
  hcmWinRemoveMacro = 3;
  hcmCreateMacro    = 4;
  hcmStopMacro      = 5;
  hcmPlayMacro      = 6;
  hcmRemoveMacro    = 7;
  hcmDeleteMacros   = 8;

 const
  imCreateMacro = kbAltEqual;
  imStopMacro   = kbAltMinus;
  imPlayMacro   = kbCtrlP;

 type
  PSCollection = ^TSCollection;
  TSCollection = object(TSortedCollection)
   function Compare(Key1, Key2: Pointer): Integer; virtual;
  end;

 { Объект - список названий макро }
  PMacrosListBox = ^TMacrosListBox;
  TMacrosListBox = object(TListBox)
   function GetText( Index : Integer; MaxLen : Integer) : String; virtual;
   procedure HandleEvent( var Event : TEvent); virtual;
  end;

 {}
  PExtMacrosListBox = ^TExtMacrosListBox;
  TExtMacrosListBox = object(TMacrosListBox)
   procedure HandleEvent( var Event : TEvent); virtual;
  end;

 { Объект - Макро }
  PMacro = ^TMacro;
  TMacro = object(TCollection)
   Key : Word;
   ShtSt : byte;
   SaveEnd : boolean;
   constructor Init(ALimit, ADelta: Integer);
   procedure AssignKey(KeyCode : Word; AShiftState : byte);
   function Saved : boolean;
   constructor Load(var S : TStream);
   procedure Store(var S : TStream);
  end;

 { Объект - состояние проигрываемого макро }
  PStateMacro = ^TStateMacro;
  TStateMacro = object(TObject)
   Index : Word;
   constructor Init(No : Word);
   function GetEvent(var Event : TEvent) : boolean;
   procedure RetShiftState;
   constructor Load(var S : TStream);
   procedure Store(var S : TStream);
   destructor Done; virtual;
  private
   PMac : PMacro;
   cur_event : Word;
   OldShiftState : byte;
  end;

 { Объект - коллекция состояний проигрываемых макро }
  PCollectionStatesOutMacros = ^TCollectionStatesOutMacros;
  TCollectionStatesOutMacros = object(TCollection)
   function InsertOutMacro(P : PStateMacro) : boolean;
  end;

 { Объект - коллекция макро }
  PMacrosCollection = ^TMacrosCollection;
  TMacrosCollection = object(TCollection)
   function HowManySavedMacros : integer;
  end;

  PMacApplication = ^TMacApplication;
  TMacApplication = object(TBaseApp)
   constructor Init;
   function InitMacro(PMac : PMacrosCollection; PStMac : PCollectionStatesOutMacros) : boolean;
   procedure HandleEvent( var Event : TEvent ); virtual;
   procedure GetEvent(var Event: TEvent); virtual;
   procedure PutEvent(var Event: TEvent); virtual;
   function GetMacros : PMacrosCollection;
   function GetMacro(HKey : Word; enable : boolean) : PMacro;
   function GetIndexMacro(HKey : Word) : integer;
   procedure CreateMacro;
   procedure StopMacro;
   procedure PlayMacro;
   procedure SaveStream(S : PStream);
   procedure LoadStream(S : PStream);
   function SaveMacros(const NameFile : string) : boolean;
   function LoadMacros(const NameFile : string) : boolean;
   function IsModMacro : boolean;
   procedure Idle; virtual;
   procedure MacroIdle; virtual;
   function CreateListMacros(ListKey : PListKey) : PSCollection; virtual;
   function RemoveMacroUsedName(PObjKey : PKeyObject) : Word;
   function PhMacro(ANo : Byte) : String; virtual;
   function RunMsgBox(No: Word; Params: Pointer; AOptions: Word) : Word; virtual;
   function ExtGetHelpCtx(AHelpCtx : Word) : Word; virtual;
   private
    PMacros : PMacrosCollection;              { коллекция макро }
    cur_macro : Integer;                      { номер в коллекции текущего
                                                записываемого макро }
    record_macro : boolean;                   { true, если идет запись
                                                макро }
    ismodoutmacro : boolean;                  { true, если идет проигрывание
                                                макро }
   { коллекция состояний проигрываемых макро }
    PCollStatesOutMacros : PCollectionStatesOutMacros;

    function NewOutMacro(No : Word) : boolean;
    procedure DisposeOutMacro;
   { Вспомомог. ф-ии }
    procedure SetDisSection(EnabComm : TCommandSet);
    procedure CleareDisSection(enable : boolean);
  end;

 { Объект - событие. Используется для сохранения его в коллекции }
  PObjectEvent = ^TObjectEvent;
  TObjectEvent = object(TObject)
   E : TEvent;
   ShtSt : byte;
   constructor Init(AEvent : TEvent; AShtSt : byte);
   destructor Done; virtual;
   constructor Load(var S : TStream);
   procedure Store(var S : TStream);
  end;

 {Объект - диалоговое окно. Предназначет для чтения "горячей" клавиши макро}
  PWinInputKey = ^TWinInputKey;
  TWinInputKey = object(TDialog)
   constructor Init(var Bounds: TRect; ATitle: TTitleStr);
   procedure HandleEvent(var Event: TEvent); virtual;
   procedure GetData(var Rec); virtual;
   destructor Done; virtual;
   private
    Key : Word;
    ShiftSt : byte;
  end;

  TWinInputKeyRec = record
   Key : Word;
   ShiftSt : byte;
  end;

 const
  RMacApplication: TStreamRec = (
     ObjType: csmMacApplication;
     VmtLink: Ofs(TypeOf(TMacApplication)^);
     Load:    @TMacApplication.Load;
     Store:   @TMacApplication.Store
  );
  RObjectEvent: TStreamRec = (
     ObjType: csmObjectEvent;
     VmtLink: Ofs(TypeOf(TObjectEvent)^);
     Load:    @TObjectEvent.Load;
     Store:   @TObjectEvent.Store
  );
  RMacro: TStreamRec = (
     ObjType: csmMacro;
     VmtLink: Ofs(TypeOf(TMacro)^);
     Load:    @TMacro.Load;
     Store:   @TMacro.Store
  );
  RWinInputKey: TStreamRec = (
     ObjType: csmWinInputKey;
     VmtLink: Ofs(TypeOf(TWinInputKey)^);
     Load:    @TDialog.Load;
     Store:   @TDialog.Store
  );
  RMacrosCollection: TStreamRec = (
     ObjType: csmMacrosCollection;
     VmtLink: Ofs(TypeOf(TMacrosCollection)^);
     Load:    @TCollection.Load;
     Store:   @TCollection.Store
  );
  RMacrosListBox: TStreamRec = (
     ObjType: csmMacrosListBox;
     VmtLink: Ofs(TypeOf(TMacrosListBox)^);
     Load:    @TListBox.Load;
     Store:   @TListBox.Store
  );
  RExtMacrosListBox: TStreamRec = (
     ObjType: csmExtMacrosListBox;
     VmtLink: Ofs(TypeOf(TExtMacrosListBox)^);
     Load:    @TListBox.Load;
     Store:   @TListBox.Store
  );
  RStateMacro: TStreamRec = (
     ObjType: csmStateMacro;
     VmtLink: Ofs(TypeOf(TStateMacro)^);
     Load:    @TStateMacro.Load;
     Store:   @TStateMacro.Store
  );
  RCollectionStatesOutMacros: TStreamRec = (
     ObjType: csmCollectionStatesOutMacros;
     VmtLink: Ofs(TypeOf(TCollectionStatesOutMacros)^);
     Load:    @TCollection.Load;
     Store:   @TCollection.Store
  );

{ инициализация списка имен всех клавиш }
 function InitListAllKey(var List : PListKey) : boolean;
{ инициализация ДО "Удаление макро" }
 function InitWinDeleteMacro(var D : PDialog) : boolean;
{ инициализация ДО "Вывести макро" }
 function InitWinPlayMacro(var D : PDialog) : boolean;

 function TreatmentShiftState(AState : byte) : byte;
 procedure MoveMouse(X, Y : Word);

 function StdMacroMenuItems(Next: PMenuItem): PMenuItem;
 function StdMacroStatusKey(Next : PStatusItem) : PStatusItem;
 procedure RegisterAppMac;

implementation
{$DEFINE __PACKET_VER__}
const

{ Private variables }

  Pending: TEvent = (What: evNothing);
  EnableOutMacro : boolean = true;
  DisableSection : boolean = false;
  old_flag       : boolean = false;
  SetDisCom      : TCommandSet = [cmCreateMacro, cmStopMacro, cmRemoveMacro,
                                  cmPlayMacro, cmDeleteMacros];
  CurDisCom      : TCommandSet = [cmCreateMacro, cmStopMacro, cmRemoveMacro,
                                  cmPlayMacro, cmDeleteMacros];

{------------------Реализация объекта TMacrosListBox-----------------------}
type
 TMacrosListBoxRec = record
  List : PSCollection;
  Selection : Word;
  ListAll : PListKey;
 end;

 function TMacrosListBox.GetText( Index : Integer; MaxLen : Integer) : String;
 var Name : String;
 begin
  if List <> nil then GetText := PKeyObject(List^.At(Index))^.NameKey^
  else GetText := '';
 end;

 procedure TMacrosListBox.HandleEvent(var Event : TEvent);
 begin
  if (Event.What and evMouseDown <> 0) and Event.Double then
  begin
   Event.What := evBroadcast;
   Event.Command := cmDefault;
   Event.InfoPtr := nil;
   PutEvent(Event);
   ClearEvent(Event);
   Exit;
  end;
  TListBox.HandleEvent(Event);
 end;

{--------------------------------------------------------------------------}

{------------------Реализация объекта TExtMacrosListBox--------------------}

 procedure TExtMacrosListBox.HandleEvent( var Event : TEvent );
 var
   N : Word;
   P : PKeyObject;
 begin
  if(Event.What and evKeyDown <> 0) and (Event.KeyCode = kbDel) and
    (State and sfActive <> 0) then
  begin
   P := PKeyObject(List^.At(Focused));
   N := PMacApplication(Application)^.RemoveMacroUsedName(P);
   List^.Free(P);
   SetRange(List^.Count);
   DrawView;
   if N = 0 then
   begin
    PMacApplication(Application)^.RunMsgBox(phmNothingDelete, nil, mfWarning + mfOKButton);
    EndModal(cmCancel);
    ClearEvent(Event);
   end;
  end;
  Inherited HandleEvent(Event);
 end;

{--------------------------------------------------------------------------}

{---------------------Реализация объекта TMacApplication-------------------}

 constructor TMacApplication.Init;
 begin
  inherited Init;
  PMacros := nil; PCollStatesOutMacros := nil;
  InitMacro(nil, nil);
 end;

 function TMacApplication.InitMacro(PMac : PMacrosCollection;
  PStMac : PCollectionStatesOutMacros) : boolean;
 begin
  if PMacros <> nil then Dispose(PMacros, Done);
  if PCollStatesOutMacros <> nil then Dispose(PCollStatesOutMacros, Done);
  PMacros := nil; PCollStatesOutMacros := nil;
  if PMac = nil then begin
   PMacros := New(PMacrosCollection, Init(4, 4));
   PCollStatesOutMacros := New(PCollectionStatesOutMacros, Init(4, 4));
   cur_macro := 0;
   record_macro := false;
   ismodoutmacro := false;
  end else begin
   PMacros := PMac;
   if PStMac = nil then PCollStatesOutMacros := New(PCollectionStatesOutMacros, Init(4, 4))
   else PCollStatesOutMacros := PStMac;
  end;

  if PCollStatesOutMacros <> nil
  then if PCollStatesOutMacros^.Count <> 0 then ismodoutmacro := true;
  if (PMacros <> nil) and (PCollStatesOutMacros <> nil) then begin
   if LowMemory then begin
    Dispose(PMacros, Done);
    Dispose(PCollStatesOutMacros, Done);
    OutOfMemory;
    Exit;
   end;
   InitMacro := true
  end else OutOfMemory;
 end;

 procedure TMacApplication.Idle;
 const
   Comm1 : TCommandSet = [cmPlayMacro, cmRemoveMacro, cmDeleteMacros, cmSaveMacros];
   Comm2 : TCommandSet = [cmStopMacro];
 begin
  inherited Idle;
  if PMacros^.HowManySavedMacros = 0 then DisableCommands(Comm1)
  else EnableCommands(Comm1);
  if record_macro then EnableCommands(Comm2)
  else DisableCommands(Comm2);
  if IsModOutMacro then MacroIdle;
 end;

 procedure TMacApplication.MacroIdle;
 begin
 end;

 function TMacApplication.IsModMacro : boolean;
 begin
  IsModMacro := record_macro;
 end;

 function TMacApplication.GetMacros : PMacrosCollection;
 begin
  GetMacros := PMacros;
 end;

 function TMacApplication.GetMacro(HKey : Word; enable : boolean) : PMacro;
 var St : byte;
 function Test(Item : Pointer) : boolean; far;
 begin
  if not enable then Test := PMacro(Item)^.Key = HKey
  else Test := (PMacro(Item)^.Key = HKey) and (PMacro(Item)^.ShtSt = St)
 end;

 begin
 { если проверять состояние Shift-клавиш }
  if enable then St := TreatmentShiftState(GetShiftState);
  GetMacro := PMacros^.FirstThat(@Test);        { поиск макро по коду }
 end;

 function TMacApplication.GetIndexMacro(HKey : Word) : integer;
 var PMac : Pointer;
 begin
  GetIndexMacro := -1;
  PMac := GetMacro(HKey, false);
  if PMac <> nil then GetIndexMacro := PMacros^.IndexOf(PMac);
 end;

 procedure TMacApplication.SetDisSection;
 begin
  DisableSection := true;      { запрещенная секция }
  EnableOutMacro := false;     { запрещение проигрывания макро }
  old_flag := record_macro;    { сохраняем флаг записи }
  record_macro := false;       { запрещение записи макро }
  CurDisCom := SetDisCom - EnabComm;
  DisableCommands(CurDisCom);
 end;

 procedure TMacApplication.CleareDisSection(enable : boolean);
 begin
  EnableCommands(CurDisCom);
  if enable then record_macro := old_flag;
  EnableOutMacro := true;      { разрешение проигрывания макро }
  DisableSection := false;     { отмена запрещенной секции }
 end;

 procedure TMacApplication.StopMacro;
 var
  Mac : PMacro;
 begin
  if record_macro then
  begin
   Mac := PMacros^.At(cur_macro - 1); { берем записываемое макро }
   if Mac^.Count = 0 then begin       { если пустое, то удалить }
    PMacros^.Free(Mac);
    dec(cur_macro);
   end
    else begin
     Mac^.SaveEnd := true;              { оно записано }
    { Вставляем в начало }
     PMacros^.AtDelete(cur_macro - 1);
     PMacros^.AtInsert(0, Mac);
    end;
   record_macro := false;             { конец записи макро }
   if cur_macro > 1 then
   begin
   { проверка недозаписи макро }
    Mac := PMacros^.At(cur_macro - 1);
    if not Mac^.Saved then record_macro := true;
   end;
  end;
 end;

 procedure TMacApplication.CreateMacro;
 var old_fl : boolean;

{ Возвращает true, когда не надо восстанавливать старые флаги }
 function CreateMacroRun : boolean;
 var
  D : PWinInputKey;
  Rec : TWinInputKeyRec;
  R : TRect;
  Mac : PMacro;
{ Вставка макро в список }
 function InsertMacro : boolean;
 begin
  InsertMacro := true; Mac := nil;
  Mac := New(PMacro, Init(4, 4));
  if Mac <> nil then
  begin
   if LowMemory then begin
    Dispose(Mac, Done);
    OutOfMemory;
    Exit;
   end;
   Mac^.AssignKey(Rec.Key, Rec.ShiftSt);
   PMacros^.Insert(Mac);
   record_macro := true;
   CreateMacroRun := true;
   exit;
  end else OutOfMemory;
  InsertMacro := false;
 end;

 function SearchKey(Item : Pointer) : boolean; far;
 begin
  SearchKey := (PMacro(Item)^.Key = Rec.Key) and
   (PMacro(Item)^.ShtSt = Rec.ShiftSt);
 end;

 begin
  CreateMacroRun := false; Mac := nil;
  R.Assign(10, 5, 45, 13);
  D := New(PWinInputKey, Init(R, ''));
  if BaseApplication^.AppExecuteDialog(D, @Rec) <> cmCancel then
  begin
   Mac := PMacros^.FirstThat(@SearchKey);
   if Mac <> nil then
   begin
    if RunMsgBox(phmExistanceMacro, nil, mfWarning + mfYesNoCancel) = cmYes
    then begin
     PMacros^.Free(Mac);
     InsertMacro;
     exit;
    end
   end
   else if InsertMacro then inc(cur_macro);
  end;
 end;

 const EComm : TCommandSet = [];
 begin
  SetDisSection(EComm);
  if not CreateMacroRun then   { если нужно восстанавливать старые флаги }
   CleareDisSection(true)
  else CleareDisSection(false);
 end;

 procedure TMacApplication.PlayMacro;
 var old_fl : boolean;

 procedure RunPlayMacro;
 var
   Dialog : PDialog;
   Rec : TMacrosListBoxRec;

 begin
 { если нет еще макро }
  if PMacros^.HowManySavedMacros = 0 then
  begin
   RunMsgBox(phmNotSavedMacros, nil, mfInformation+mfOKButton);
   Exit;
  end;

  if InitListAllKey(Rec.ListAll) then
  begin
   With Rec do
   begin
    List := CreateListMacros(ListAll);
    Selection := 0;
   end;
   if Rec.List <> nil then
    if InitWinPlayMacro(Dialog) then
     if Application^.ValidView(Dialog) <> nil then
     begin
      Dialog^.SetData(Rec);
      if Application^.ExecView(Dialog) <> cmCancel then
      begin
       Dialog^.GetData(Rec);
      { Делаем выбранное макро как текущее проигрываемое }
       NewOutMacro(GetIndexMacro(PKeyObject(Rec.List^.At(Rec.Selection))^.KeyCode));
      end;
      Dispose(Dialog,Done);
     end;
   if Rec.List <> nil then Dispose(Rec.List, Done);
   if Rec.ListAll <> nil then Dispose(Rec.ListAll, Done);
  end;
 end;

 const EComm : TCommandSet = [];
 begin
  SetDisSection(EComm);
  RunPlayMacro;
  CleareDisSection(true);
 end;

 procedure TMacApplication.HandleEvent( var Event : TEvent );
 var
  old_fl : boolean;

 procedure RemoveMacro;
 var
   Dialog : PDialog;
   Rec : TMacrosListBoxRec;

 begin
 { если нет еще макро }
  if PMacros^.HowManySavedMacros = 0 then
  begin
   RunMsgBox(phmNotSavedMacros, nil, mfError+mfOKButton);
   Exit;
  end;

  if InitListAllKey(Rec.ListAll) then
  begin
   With Rec do
   begin
    List := CreateListMacros(ListAll);
    Selection := 0;
   end;
   if Rec.List <> nil then
    if InitWinDeleteMacro(Dialog) then
     if Application^.ValidView(Dialog) <> nil then
     begin
      Dialog^.SetData(Rec);
      if Application^.ExecView(Dialog) <> cmCancel then
      begin
       Dialog^.GetData(Rec);
      { Удаляем макро по названию ее горячей клавиши }
       RemoveMacroUsedName(PKeyObject(Rec.List^.At(Rec.Selection)));
      end;
      Dispose(Dialog,Done);
     end;
   if Rec.List <> nil then Dispose(Rec.List, Done);
   if Rec.ListAll <> nil then Dispose(Rec.ListAll, Done);
  end;
 end;

 procedure DeleteMacros;
 begin
  if cur_macro > 0 then
  begin
   if RunMsgBox(phmWarningForDeleteMacros, nil, mfConfirmation+mfYesNoCancel) <> cmYes
   then Exit;
  end
  else
  begin
   RunMsgBox(phmNotMacrosForDeleteMacros,nil,mfError+mfOKButton);
   Exit;
  end;
  PMacros^.FreeAll;
  record_macro := false;
  cur_macro := 0;
  ismodoutmacro := false;
 end;

 const EComm : TCommandSet = [];
 begin
  inherited HandleEvent(Event);
  case Event.What of
   evCommand:
    case Event.Command of
     cmCreateMacro : CreateMacro;

     cmStopMacro   : StopMacro;

     cmPlayMacro   : PlayMacro;

     cmRemoveMacro :
      begin
       SetDisSection(EComm);
       RemoveMacro;
       CleareDisSection(true);
      end;

     cmDeleteMacros:
      begin
       SetDisSection(EComm);
       DeleteMacros;
       CleareDisSection(true);
      end;

    end;
  end;
 end;

 procedure TMacApplication.GetEvent(var Event: TEvent);

 function ContainsMouse(P: PView): Boolean; far;
 begin
  ContainsMouse := (P^.State and sfVisible <> 0) and
    P^.MouseInView(Event.Where);
 end;

{ Сохранение события в текущем записываемом макро }
 procedure SaveEventInMacro;
 var
  Mac : PMacro;
  PEv : PObjectEvent;
 begin
  DisableSection := true;
 { Запись события в макро }
  Mac := PMacro(PMacros^.At(cur_macro - 1));
  if Mac^.Key <> Event.KeyCode then begin
   PEv := nil;
   PEv := New(PObjectEvent, Init(Event, TreatmentShiftState(GetShiftState)));
   if PEv <> nil then begin
    if LowMemory then begin
     Dispose(PEv);
     OutOfMemory;
     StopMacro;
     Exit;
    end;
    Mac^.Insert(PEv);
   end else OutOfMemory;
  end;
  DisableSection := false;
 end;

{ Вставка нового проигрываемого макро. Макро интерпретируется }
{ по Event.KeyCode. Возвращает true, если есть такое макро.   }
 function InsertNewOutMacro : boolean;
 var P : PMacro;
 begin
  InsertNewOutMacro := false;
  P := GetMacro(Event.KeyCode, true);
  if (P <> nil) and EnableOutMacro then
  { не текущее записываемое }
   if not (record_macro and (P = PMacros^.At(PMacros^.Count-1)) )
   then InsertNewOutMacro := NewOutMacro(PMacros^.IndexOf(P));
 end;

{ Проверка клавиш, которые не могут попасть ни в одно макро }
 function CheckKey : boolean;
 begin
  CheckKey := (Event.KeyCode = imCreateMacro) or (Event.KeyCode = imStopMacro) or
   (Event.KeyCode = imPlayMacro);
 end;

 procedure RunFunc(var E : TEvent);
 begin
  if E.What and evCommand <> 0 then
   case E.Command of
    cmCreateMacro : CreateMacro;
    cmStopMacro   : StopMacro;
    cmPlayMacro   : PlayMacro;
   else Exit;
   end
  else
   if E.What and evKeyDown <> 0 then
    case E.KeyCode of
     imCreateMacro : CreateMacro;
     imStopMacro   : StopMacro;
{
     imPlayMacro   : PlayMacro;
}
    else Exit;
    end
   else Exit;
  E.What := evNothing;
 end;

{ Получить событие из проигрываемого макро(если таково есть) }
{ Событие в Event                                            }
 procedure GetEventFromOutMacro;
 begin
  if ismodoutmacro then
   if not PStateMacro(PCollStatesOutMacros^.At(PCollStatesOutMacros^.Count-1))^.GetEvent(Event)
   then begin
    DisposeOutMacro;
    GetEventFromOutMacro;
   end;
 end;

 procedure RunGetEvent;
 begin
  {!!!}
   inherited GetEvent(Event);

   if Event.What = evNothing then Idle
   else if Event.What = evKeyDown then
   begin
     if InsertNewOutMacro
       then ClearEvent(Event)
     else if not CheckKey and record_macro and not DisableSection
       then SaveEventInMacro;
   end;
{
   GetMouseEvent(Event);
   if Event.What = evNothing then
   begin
     GetKeyEvent(Event);
     if Event.What = evNothing then Idle
     else
     begin
       if InsertNewOutMacro then ClearEvent(Event)
       else if not CheckKey and record_macro and not DisableSection then SaveEventInMacro;
     end;
   end;
}
   { else if (Event.What and evMouseDown <> 0) and record_macro
             then SaveEventInMacro;}
 end;

 begin
 { Запуск глобальных ф-ций(если есть необходимость) }
  if not DisableSection then RunFunc(Pending);


  if Pending.What <> evNothing then
  begin
    Event := Pending;
    Pending.What := evNothing;
  end else
  begin
    Event.What := evNothing;
    if EnableOutMacro then GetEventFromOutMacro;
    if Event.What = evNothing then RunGetEvent
    else begin
      if InsertNewOutMacro then ClearEvent(Event)
      else if not CheckKey and record_macro and not DisableSection then SaveEventInMacro;
    end;
  end;

  if not DisableSection then RunFunc(Event);

  if StatusLine <> nil then
    if (Event.What and evKeyDown <> 0) or
      (Event.What and evMouseDown <> 0) and
      (FirstThat(@ContainsMouse) = PView(StatusLine)) then
      StatusLine^.HandleEvent(Event);
 end;

 procedure TMacApplication.PutEvent(var Event: TEvent);
 begin
  Pending := Event;
 end;

 procedure TMacApplication.SaveStream(S : PStream);
 begin
  S^.Put(PMacros);                     { пишем макро }
  S^.Write(record_macro,sizeof(boolean));
  S^.Write(cur_macro,sizeof(integer));
  S^.Write(ismodoutmacro, sizeof(boolean));
  if ismodoutmacro then S^.Put(PCollStatesOutMacros);
 end;

 procedure TMacApplication.LoadStream(S : PStream);
 var
   P : PMacrosCollection;
   PSt : PCollectionStatesOutMacros;
   i : integer;
 begin
  P := PMacrosCollection(S^.Get);
  if P <> nil then
  begin
   S^.Read(record_macro,sizeof(boolean));
   S^.Read(cur_macro,sizeof(integer));
  {  пока не знаю что  }
   S^.Read(ismodoutmacro ,sizeof(boolean));
   PSt := nil;
   if ismodoutmacro then PSt := PCollectionStatesOutMacros(S^.Get);
   InitMacro(P, PSt);
  end;
 end;

type
 THeader = record
  Signature : string[7];
  Ver : Word;
 end;

const
 Header : THeader = (Signature : 'Macros'#26; Ver : $0103);

 function TMacApplication.SaveMacros(const NameFile : string) : boolean;
 var S : PBufStream;
 begin
  SaveMacros := false;
  S := New(PBufStream, Init(NameFile, stCreate, 512));
  if S^.Status = stOK then                { если без ошибок создание потока }
  begin
   S^.Write(Header, SizeOf(THeader));     { пишем начало }
   SaveStream(PStream(S));                { пишем макро  }
   SaveMacros := true;
  end;
  if S <> nil then Dispose(S, Done);
 end;

 function TMacApplication.LoadMacros(const NameFile : string) : boolean;
 var
  S : PStream;
  H : THeader;
 begin
  LoadMacros := false;
  S := New(PBufStream, Init(NameFile, stOpenRead, 512));
  if S^.Status = stOK then           { если без ошибок открытие потока }
  begin
   S^.Read(H, SizeOf(THeader));      { читаем начало }
  { если файл макро и известная версия файла }
   if (H.Signature = Header.Signature) and (H.Ver = Header.Ver)
   then
   begin
    LoadStream(PStream(S));          { читаем макро }
    LoadMacros := true;
   end;
  end;
  if S <> nil then Dispose(S, Done);
 end;

{ Возвращает коллекию имен текущих созданных макро }
 function TMacApplication.CreateListMacros(ListKey : PListKey) : PSCollection;
 var
   C : PSCollection;
   S : StrKey;

 procedure Test(P: Pointer); far;
 var
   Item : KeyItem;
 begin
  if PMacro(P)^.Saved then
   With Item do
   begin
    name := '';
    code := PMacro(P)^.Key;
    name := ListKey^.GetKeyName(code, PMacro(P)^.ShtSt);
    if name = '' then name := Concat(name, Chr(Lo(code)));
    C^.Insert(New(PKeyObject, Init(Item)));
   end;
 end;

 begin
  C := nil;
  C := New(PSCollection, Init(5, 5));
  if C <> nil then PMacros^.ForEach(@Test);
  CreateListMacros := C;
 end;

 function TMacApplication.RemoveMacroUsedName(PObjKey : PKeyObject) : Word;
 var Mac : PMacro;
 begin
  Mac := GetMacro(PObjKey^.KeyCode, false);         { поиск макро по коду }
  if Mac <> nil then begin
   PMacros^.Free(Mac);
   dec(cur_macro);
  end;
  RemoveMacroUsedName := PMacros^.HowManySavedMacros;
 end;

 function TMacApplication.NewOutMacro(No : Word) : boolean;
 var PStMac : PStateMacro;
 begin
  DisableSection := true;
  NewOutMacro := false;
  PStMac := nil; PStMac := New(PStateMacro, Init(No));
  if PStMac <> nil then begin
   if LowMemory then begin
    Dispose(PStMac, Done);
    OutOfMemory;
    DisableSection := false;
    Exit;
   end else if PCollStatesOutMacros^.InsertOutMacro(PStMac)
   then begin
    ismodoutmacro := true;
    NewOutMacro := true;
   end
  end else OutOfMemory;
  DisableSection := false;
 end;


 procedure TMacApplication.DisposeOutMacro;
 var
   PSt : PStateMacro;
 begin
  if PCollStatesOutMacros^.Count > 0 then
  begin
   PSt := PStateMacro(PCollStatesOutMacros^.At(PCollStatesOutMacros^.Count-1));
   PSt^.RetShiftState;
   PCollStatesOutMacros^.Free(PSt);
   if PCollStatesOutMacros^.Count = 0 then ismodoutmacro := false;
  end;
 end;

 function TMacApplication.PhMacro(ANo : Byte) : String;
 var S : String;
 begin
  S := '';
  case ANo of
   phmNothingDelete : S := 'Нечего больше удалять!';
   phmExistanceMacro : S := 'Макро существует. Перезаписать?';
   phmNotSavedMacros : S := 'Еще нет дописанных макро!';
   phmWarningForDeleteMacros : S := 'Вы действительно хотите удалить все макро?';
   phmNotMacrosForDeleteMacros : S := 'Нечего удалять!';
   phmWinCreateMacro : S := ^C'Нажмите горячую клавишу макро';
   phmNameWinRemoveMacro : S := 'Удалить макро';
   phmNameWinPlayMacro : S := 'Вывести макро';
   phmCreateMacro : S := '~C~reate...';
   phmStopMacro : S := '~S~top';
   phmPlayMacro : S := '~P~lay';
   phmRemoveMacro : S := '~R~emove...';
   phmDeleteMacros : S := '~D~elete All';
   phmCreateMacroHotKey : S := 'Alt =';
   phmStopMacroHotKey : S := 'Alt -';
   phmPlayMacroHotKey : S := 'Ctrl+P';
   phmWarning : S := 'Внимание! Все существующие макро будут потеряны. Перезаписать макро?';
   phmCancel : S := 'Отмена';
   phmMacro : S := '~М~акро';
   phmOK : S := '~В~ыбор';
  end;
  PhMacro := S;
 end;

 function TMacApplication.RunMsgBox(No: Word; Params: Pointer; AOptions: Word) : Word;
 begin
{$IFNDEF __PACKET_VER__}
  RunMsgBox := MessageBox(PhMacro(No), Params, AOptions);
{$ENDIF}
 end;

 function TMacApplication.ExtGetHelpCtx(AHelpCtx : Word) : Word;
 begin
  ExtGetHelpCtx := AHelpCtx;
 end;

{--------------------------------------------------------------------------}

{---------------------Реализация объекта TObjectEvent----------------------}

 constructor TObjectEvent.Init(AEvent : TEvent; AShtSt : byte);
 begin
  E := AEvent;
  ShtSt := TreatmentShiftState(AShtSt);
 end;

 destructor TObjectEvent.Done;
 begin
 end;

 constructor TObjectEvent.Load(var S : TStream);
 begin
  S.Read(E, SizeOf(TEvent));
  S.Read(ShtSt, SizeOf(byte));
 end;

 procedure TObjectEvent.Store(var S : TStream);
 begin
  S.Write(E, SizeOf(TEvent));
  S.Write(ShtSt, SizeOf(byte));
 end;

{--------------------------------------------------------------------------}

{---------------------Реализация объекта TMacro----------------------------}

 constructor TMacro.Init(ALimit, ADelta: Integer);
 begin
  TCollection.Init(ALimit, ADelta);
  SaveEnd := false;
 end;

 procedure TMacro.AssignKey(KeyCode : Word; AShiftState : byte);
 begin
  Key := KeyCode;
  ShtSt := TreatmentShiftState(AShiftState);
 end;

 function TMacro.Saved : boolean;
 begin
  Saved := SaveEnd;
 end;

 constructor TMacro.Load(var S : TStream);
 begin
  S.Read(Key, SizeOf(Word));
  S.Read(ShtSt, SizeOf(byte));
  S.Read(SaveEnd, SizeOf(boolean));
  TCollection.Load(S);
 end;

 procedure TMacro.Store(var S : TStream);
 begin
  S.Write(Key, SizeOf(Word));
  S.Write(ShtSt, SizeOf(byte));
  S.Write(SaveEnd, SizeOf(boolean));
  TCollection.Store(S);
 end;

{--------------------------------------------------------------------------}

{--------------------Реализация объекта TStateMacro------------------------}

 constructor TStateMacro.Init(No : Word);
 begin
  OldShiftState := GetShiftState;
  Index := No;
  cur_event := 1;
  PMac := PMacApplication(Application)^.GetMacros^.At(Index);
 end;

 function TStateMacro.GetEvent(var Event : TEvent) : boolean;
 var
   PEv : PObjectEvent;
 begin
  GetEvent := false;
  if PMac = nil then PMac := PMacApplication(Application)^.GetMacros^.At(Index);
  if PMac <> nil then
   if cur_event <= PMac^.Count then
   begin
    PEv := PObjectEvent(PMac^.At(cur_event - 1));
    Event := PEv^.E;
{    if (Event.What and evMouseDown <> 0) and MouseEvents then
     MoveMouse(Event.Where.X, Event.Where.Y)
    else} ShiftState := PEv^.ShtSt or (GetShiftState and not kbClearShiftState);
    inc(cur_event);
    GetEvent := true;
   end;
 end;

 procedure TStateMacro.RetShiftState;
 begin
{
  ShiftState := OldShiftState;
}
{!!!}
  ShiftState := OldShiftState and
                not (kbLeftShift + kbRightShift + kbCtrlShift);
 end;

 constructor TStateMacro.Load(var S : TStream);
 begin
  S.Read(Index, sizeof(Word));
  S.Read(cur_event, sizeof(Word));
  S.Read(OldShiftState, sizeof(byte));
  PMac := nil;
 end;

 procedure TStateMacro.Store(var S : TStream);
 begin
  S.Write(Index, sizeof(Word));
  S.Write(cur_event, sizeof(Word));
  S.Write(OldShiftState, sizeof(byte));
 end;

 destructor TStateMacro.Done;
 begin
 end;

{--------------------------------------------------------------------------}

{---------------Реализация объекта TCollectionStatesOutMacros--------------}

{ Необходима для предотвращения бесконечного цикла проигрывания макро }
 function TCollectionStatesOutMacros.InsertOutMacro(P : PStateMacro) : boolean;

 function Test(Item : Pointer) : boolean; far;
 begin
  Test := PStateMacro(Item)^.PMac^.Key = P^.PMac^.Key;
 end;

 begin
  InsertOutMacro := false;
  if P <> nil then
   if FirstThat(@Test) = nil then
   begin
    Insert(P);
    InsertOutMacro := true;
   end;
 end;


{--------------------------------------------------------------------------}

{----------------Реализация объекта TMacrosCollection----------------------}

  function TMacrosCollection.HowManySavedMacros : integer;
  var C : integer;

  procedure TestMacro(Item : Pointer); far;
  begin
   if PMacro(Item)^.Saved then inc(C);
  end;

  begin
   C := 0;
   ForEach(@TestMacro);
   HowManySavedMacros := C;
  end;

{--------------------------------------------------------------------------}

{---------------------Реализация объекта TWinInputKey----------------------}

  constructor TWinInputKey.Init(var Bounds: TRect; ATitle: TTitleStr);
  var
    R : TRect;
    I : Integer;
  begin
   EnableOutMacro := false;         { запрещение проигрывания макро }
   DisableSection := true;          { запрещенная секция }
   TDialog.Init(Bounds, ATitle);
   R.Assign(2, 2, Size.X - 2, 4);
   Insert(New(PStaticText, Init(R, PMacApplication(Application)^.PhMacro(phmWinCreateMacro))));
   I := (Size.X - 10) div 2;
   R.Assign(I, Size.Y - 3, I + 10, Size.Y - 1);
   Insert(New(PButton, Init(R, PMacApplication(Application)^.PhMacro(phmCancel), cmCancel, bfDefault)));
   HelpCtx := PMacApplication(Application)^.ExtGetHelpCtx(hcmWinCreateMacro);
   Options := Options or ofCentered;
  end;

  procedure TWinInputKey.HandleEvent(var Event: TEvent);
  begin
   if(Event.What and evKeyDown <> 0) then
    if (Event.KeyCode <> kbEsc) and (Event.KeyCode <> kbEnter) then
    begin
     Key := Event.KeyCode;
     ShiftSt := TreatmentShiftState(GetShiftState);
{$IFDEF __PACKET_VER__}
     if (ShiftSt and kbLeftShift <> 0) and (ShiftSt and kbCtrlShift <> 0) and
        (ShiftSt and not (kbLeftShift+kbCtrlShift) = 0) and (Key >= kbCtrlF1) and
        (Key <= kbCtrlF10)
     then EndModal(cmOK);
     ClearEvent(Event);
{$ELSE}
     EndModal(cmOK);
     ClearEvent(Event);
{$ENDIF}
    end;
   TDialog.HandleEvent(Event);
  end;

  procedure TWinInputKey.GetData(var Rec);
  begin
   TWinInputKeyRec(Rec).Key := Key;
   TWinInputKeyRec(Rec).ShiftSt := ShiftSt;
  end;

  destructor TWinInputKey.Done;
  begin
   EnableOutMacro := true;         { разрешение проигрывания макро }
   DisableSection := false;        { отмена запрещенной секции }
   Inherited Done;
  end;

{---------------------Реализация объекта TSCollection----------------------}

 function TSCollection.Compare(Key1, Key2: Pointer): Integer;
 begin
  if PString(Key1)^ = PString(Key2)^ then Compare := 0
  else if PString(Key1)^ < PString(Key2)^ then Compare := -1
       else Compare := 1
 end;

{--------------------------------------------------------------------------}


{--------------------------------------------------------------------------}

 function TreatmentShiftState(AState : byte) : byte;
 var St : byte;
 begin
  St := AState and kbClearShiftState;
{$IFDEF __PACKET_VER__}
  if (St and kbLeftShift <> 0) or (St and kbRightShift <> 0) then
  begin
   St := St or kbLeftShift;
   St := St and not kbRightShift;
  end;
{$ENDIF}
  TreatmentShiftState := St;
 end;

 function InitListAllKey(var List : PListKey) : boolean;
 begin
  List := InitListKey;
  InitListAllKey := true;
 end;

 function InitWinDeleteMacro(var D : PDialog) : boolean;
 var
   R : TRect;
   AVScrollBar : PScrollBar;
   L : PExtMacrosListBox;
 begin
  R.Assign(0, 0, 49, 10);
  D := New(PDialog, Init(R, PMacApplication(Application)^.PhMacro(phmNameWinRemoveMacro)));
  With D^ do
  begin

   Options := Options or ofCentered;
   HelpCtx := PMacApplication(Application)^.ExtGetHelpCtx(hcmWinRemoveMacro);

   R.Assign(35,2,36,9);
   AVScrollBar:=New(PScrollBar,Init(R));
   Insert(AVScrollBar);

   R.Assign(2, 2, 35, 9);
   L := New(PExtMacrosListBox,Init(R,1,AVScrollBar));
   Insert(L);

   R.Assign(1, 1, 7, 2);
   Insert(New(PLabel,Init(R,PMacApplication(Application)^.PhMacro(phmMacro),L)));

   R.Assign(37, 2, 47, 4);
   Insert(New(PButton, Init(R, PMacApplication(Application)^.PhMacro(phmOK), cmOk, bfDefault)));

   R.Assign(37, 4, 47, 6);
   Insert(New(PButton, Init(R, PMacApplication(Application)^.PhMacro(phmCancel), cmCancel, bfNormal)));

   SelectNext(false);
  end;
  InitWinDeleteMacro := true;
 end;

 function InitWinPlayMacro(var D : PDialog) : boolean;
 var
   R : TRect;
   AVScrollBar : PScrollBar;
   L : PMacrosListBox;
 begin
  R.Assign(0, 0, 49, 10);
  D := New(PDialog, Init(R, PMacApplication(Application)^.PhMacro(phmNameWinPlayMacro)));
  With D^ do
  begin

   Options := Options or ofCentered;
   HelpCtx := PMacApplication(Application)^.ExtGetHelpCtx(hcmWinPlayMacro);

   R.Assign(35,2,36,9);
   AVScrollBar:=New(PScrollBar,Init(R));
   Insert(AVScrollBar);

   R.Assign(2, 2, 35, 9);
   L := New(PMacrosListBox,Init(R,1,AVScrollBar));
   Insert(L);

   R.Assign(1, 1, 7, 2);
   Insert(New(PLabel,Init(R,PMacApplication(Application)^.PhMacro(phmMacro),L)));

   R.Assign(37, 2, 47, 4);
   Insert(New(PButton, Init(R, PMacApplication(Application)^.PhMacro(phmOK), cmOk, bfDefault)));

   R.Assign(37, 4, 47, 6);
   Insert(New(PButton, Init(R, PMacApplication(Application)^.PhMacro(phmCancel), cmCancel, bfNormal)));

   SelectNext(false);
  end;
  InitWinPlayMacro := true;
 end;

 procedure MoveMouse(X, Y : Word); assembler;
 asm
	CMP	ButtonCount,0
	JE	@@1
        MOV     BX,X
        MOV     DX,Y
        MOV     CL,3
        SHL	BX,CL
	SHL	DX,CL
        XCHG    CX,BX
	MOV	AX,4
	INT	33H
        MOV     BL,1
        MOV     AX,07FH
        PUSH    CX
        PUSH    DX
        PUSH    AX
{
        CALL    MouseInt
}
        POP     AX
        POP     DX
        POP     CX
        XOR     BL,BL
{
        CALL    MouseInt
}
 @@1:
 end;


 function StdMacroMenuItems(Next: PMenuItem): PMenuItem;
 begin
  StdMacroMenuItems :=
   NewItem(PMacApplication(Application)^.PhMacro(phmCreateMacro),
    PMacApplication(Application)^.PhMacro(phmCreateMacroHotKey),
    imCreateMacro,cmCreateMacro,PMacApplication(Application)^.ExtGetHelpCtx(hcmCreateMacro),
   NewItem(PMacApplication(Application)^.PhMacro(phmStopMacro),
    PMacApplication(Application)^.PhMacro(phmStopMacroHotKey),
    imStopMacro,cmStopMacro,PMacApplication(Application)^.ExtGetHelpCtx(hcmStopMacro),
   NewItem(PMacApplication(Application)^.PhMacro(phmPlayMacro),
    PMacApplication(Application)^.PhMacro(phmPlayMacroHotKey),
    imPlayMacro,cmPlayMacro,PMacApplication(Application)^.ExtGetHelpCtx(hcmPlayMacro),
   NewItem(PMacApplication(Application)^.PhMacro(phmRemoveMacro),
    '',kbNoKey,cmRemoveMacro,PMacApplication(Application)^.ExtGetHelpCtx(hcmRemoveMacro),
   NewItem(PMacApplication(Application)^.PhMacro(phmDeleteMacros),
    '',kbNoKey,cmDeleteMacros,PMacApplication(Application)^.ExtGetHelpCtx(hcmDeleteMacros),
   Next)))));
 end;

 function StdMacroStatusKey(Next : PStatusItem) : PStatusItem;
 begin
  StdMacroStatusKey :=
   NewStatusKey('', imCreateMacro, cmCreateMacro,
   NewStatusKey('', imStopMacro, cmStopMacro,
   NewStatusKey('', imPlayMacro, cmPlayMacro,
   Next)));
 end;

 procedure RegisterAppMac;
 begin
  RegisterType(RMacApplication);
  RegisterType(RObjectEvent);
  RegisterType(RMacro);
  RegisterType(RWinInputKey);
  RegisterType(RMacrosCollection);
  RegisterType(RMacrosListBox);
  RegisterType(RExtMacrosListBox);
  RegisterType(RStateMacro);
  RegisterType(RCollectionStatesOutMacros);
 end;

end.
