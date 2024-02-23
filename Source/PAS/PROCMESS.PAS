{ Created by VULCAN }
{ 29.09.93 - 20.09.94 }

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit ProcMess;

interface

uses Objects, Views, App, Drivers, StrServ, Pack_Cmd;

type

(*
           Объект TNameView.

   Служит для отображения символьного имени на экране.

   Поля:

   NewName : PString
   DefName : PString

   Отображается строка NewName^.
   Если NewName=nil то отображается заданное умолчание DefName.
   Если и DefName равно nil то ничего не отображается.

   Методы:

   constructor Init(var Bounds: TRect;ANewName,ADefName:String);
   procedure UpDate   (ANewName:String);   - задать новое имя
   procedure ChangeDef(ADefName:String);   - поменять умолчание

*)

  PNameView = ^TNameView;
  TNameView = object(TView)
    DefName : PString;
    NewName : PString;

    constructor Init(var Bounds: TRect;ANewName,ADefName:String);
    procedure   Draw; virtual;
    procedure   Update    (ANewName:String);
    procedure   ChangeDef (ADefName:String);
    destructor  Done; virtual;
  end;

  PTitleView = ^TTitleView;
  TTitleView = object(TNameView)
    Cmd: Word;

    constructor Init(var Bounds: TRect;ANewName,ADefName:String;
                     Command: Word);
    procedure HandleEvent(var Event: TEvent); virtual;
  end;

  PProcMess = ^TProcMess;
  TProcMess = object(TNameView)
    constructor Init(S: String);
    destructor Done; virtual;
  end;

implementation

constructor TNameView.Init(var Bounds: TRect;ANewName,ADefName:String);
begin
 inherited Init(Bounds);

 SetNewStr(DefName, ADefName);
 SetNewStr(NewName, ANewName);
end;

procedure   TNameView.Draw;
var
 CurrName : String;
 B        : TDrawBuffer;
 C        : Byte;
begin
 C:=GetColor(2);
 MoveChar(B,' ',C,Size.X);
 if NewName<>nil
   then MoveStr(B,NewName^,C)
   else if DefName<>nil then MoveStr(B,DefName^,C);
 WriteLine(0,0,Size.X,1,B)
end;

procedure TNameView.Update(ANewName:String);
begin
 SetNewStr(NewName, ANewName);
 DrawView
end;

procedure TNameView.ChangeDef(ADefName:String);
begin
 SetNewStr(DefName, ADefName);
 DrawView
end;

destructor TNameView.Done;
begin
 DispStr(DefName);
 DispStr(NewName);

 inherited Done
end;

constructor TTitleView.Init(var Bounds: TRect;ANewName,ADefName:String;
                            Command: Word);
begin
  inherited Init(Bounds, ANewName, ADefName);
  Cmd := Command;
end;

procedure TTitleView.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evMouseDown
    then Message(Application, evCommand, Cmd, nil);
end;


constructor TProcMess.Init(S: String);
var
  R: TRect;
begin
  if not Assigned(Application)
    then Fail;
  Application^.GetExtent(R);
  R.A.Y := R.B.Y - 1;
  S := Copy(S, 1, R.B.X - R.A.X);
  inherited Init(R, '', ' ' + S);
  HideMouse;
  Application^.Insert(@Self);
  ShowMouse;
end;

destructor TProcMess.Done;
begin
  inherited Done;
  Message(Application, evCommand, cmRegLastEvTime, nil);
end;

end.
