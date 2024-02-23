(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль ExtServ                                         *)
(* Обработка расширений и масок                           *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 04.08.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Ext_Serv;

interface

uses
  Objects, Dos, LineColl, Menus, Disp_Obj, StrServ, Pack_Hlp, Drivers,
  PackText;

const
  CommandsOffset = 30000;

type

  PMenuByExt = ^TMenuByExt;
  TMenuByExt = object(TObject)
    Menu: PMenu;
    Commands: PLineCollection;

    constructor Init(AParams: ComStr);
    destructor Done; virtual;
    procedure AddItem(s: String);
    procedure AddLine;
    function GetCommand(Cmd: Word): ComStr;
    function IsEmpty: boolean;
    procedure CreateMenu;

    private

    Names: PLineCollection;
    FreeNum: Word; { Первый незанятый номер команды }
    Params: ComStr;

    procedure AddCommand(Name: TMenuStr; Command: ComStr);
    function BuildMenuItems(Num: Word): PMenuItem;
  end;

function GlobalExtName: PathStr;
function MaskMatch(FileName, Mask: PathStr): boolean;
function TreatMacro(Macro, Par: ComStr; ExpandDir: boolean): ComStr;

implementation

constructor TMenuByExt.Init(AParams: ComStr);
begin
  inherited Init;
  New(Commands, Init(10, 5));
  New(Names, Init(10, 5));
  Menu := nil;
  Params := AParams;
  FreeNum := 0;
end;

destructor TMenuByExt.Done;
begin
  DisposeObj(Commands);
  if Assigned(Menu) then DisposeMenu(Menu);
  DisposeObj(Names);
  inherited Done;
end;

procedure TMenuByExt.AddItem(s: String);
var
  s1, s2: String;
begin
  s := FullTrim(s);
  if s = '' then Exit;
  s1 := FullTrim(Copy(s, 1, Pos(ParamsDivider, s) - 1));
  s2 := Copy(s, Pos(ParamsDivider, s) + 1, 255);
  DelFinalSpaces(s2);
  if (s1 = '') and (Pos(ParamsDivider, s) = 0)
    then s1 := FullTrim(s2);
  if s2 <> ''
    then AddCommand(s2, s1);
end;

procedure TMenuByExt.AddLine;
begin
  AddCommand('', '');
end;

function TMenuByExt.GetCommand(Cmd: Word): ComStr;
begin
  Cmd := Cmd - CommandsOffset;
  if Cmd < Commands^.Count
    then GetCommand := TreatMacro(GetStr(Commands^.At(Cmd)), Params, True)
  else GetCommand := '';
end;

function TMenuByExt.IsEmpty: boolean;
begin
  IsEmpty := FreeNum = 0;
end;

procedure TMenuByExt.AddCommand(Name: TMenuStr; Command: ComStr);
begin
  if FreeNum > 50
    then Exit;
  Commands^.Insert(NewStr(Command));
  Names^.Insert(NewStr(Name));
  Inc(FreeNum);
end;

procedure TMenuByExt.CreateMenu;
begin
  Menu := NewMenu(BuildMenuItems(0));
end;

function TMenuByExt.BuildMenuItems(Num: Word): PMenuItem;
begin
  if Num = FreeNum
    then begin
      BuildMenuItems := nil;
      Exit;
    end;
  if GetStr(Commands^.At(Num)) = ''
    then BuildMenuItems := NewLine(BuildMenuItems(Num + 1))
  else BuildMenuItems :=
          NewItem(GetStr(Names^.At(Num)), '', kbNoKey, Num + CommandsOffset,
                  hcMenuByExt, BuildMenuItems(Num + 1));
end;

{------------------------------------------------------------}

function GlobalExtName: PathStr;
begin
  GlobalExtName := GetExeDir + ExtFileName;
end;

function CharsMatch(c1, c2: char): boolean;
begin
  CharsMatch := (c1 = c2) or (c2 = '?');
end;

function StrMatch(s1, s2: String): boolean;
var
  p, i: byte;
begin
  if s2 = '' then s2 := '*';
  if s2 = '.' then s2 := '';
  if s1 = '.' then s1 := '';
  StrMatch := False;
  s1 := s1 + Spaces;
  p := Pos('*', s2);
  if p > 0
    then begin
      s1 := Copy(s1, 1, p - 1);
      s2 := Copy(s2, 1, p - 1);
    end;
  for i := 1 to Length(s2) do
    if not CharsMatch(s1[i], s2[i]) then Exit;
  s1 := FullTrim(Copy(s1, Length(s2) + 1, Length(s1)));
  if s1 <> '' then Exit;
  StrMatch := True;
end;

function MaskMatch(FileName, Mask: PathStr): boolean;
var
  Name: NameStr;
  Ext: ExtStr;
begin
  FileName := StrUpCase(FileName);
  if Pos('.', FileName) = 0
    then FileName := fileName + '.';
  Mask := StrUpCase(Mask);
  MaskMatch := StrMatch(GetFName(FileName), GetFName(Mask))
               and StrMatch(GetFExt(FileName), GetFExt(Mask));
end;

function TreatMacro(Macro, Par: ComStr; ExpandDir: boolean): ComStr;
var
  p: byte;
  NewCommand: ComStr;
begin
  TreatMacro := Macro + ' ' + Par;
  if Pos('!', Macro) = 0 then Exit;
  Par := GetWord(Par, 1);
  NewCommand := '';
  repeat
    p := Pos('!', Macro);
    NewCommand := NewCommand + Copy(Macro, 1, p - 1);
    Macro := Copy(Macro, p, 255);
    if Length(Macro) = 1
      then begin
        NewCommand := NewCommand + GetFName(Par);
        Break;
      end;
    if Macro[2] = '!'
      then begin
        NewCommand := NewCommand + '!';
        Macro := Copy(Macro, 3, 255);
        Continue;
      end;
    if (Macro[2] = '\') and ExpandDir
      then begin
        NewCommand := NewCommand + GetFDir(Par);
        Dec(NewCommand[0]);
        Macro := Copy(Macro, 3, 255);
        Continue;
      end;
    if Copy(Macro, 2, 2) = '.!'
      then begin
        NewCommand := NewCommand + GetFName(Par) + GetFExt(Par);
        Macro := Copy(Macro, 4, 255);
        Continue;
      end;
    NewCommand := NewCommand + GetFName(Par);
    Macro := Copy(Macro, 2, 255);
  until Pos('!', Macro) = 0;
  TreatMacro := NewCommand + Macro;
end;

end.

