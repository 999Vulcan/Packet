(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Registr                                         *)
(* Регистрация и построение ключей                        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 02.05.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-,Q-}

unit Registr;

interface

const
  UserName: String[40] = #255;
  UserCompany: String[40] = '';
  UserNum: String[12] = '48273';

  KeyFileName  = 'Packet.Key';
  InitialNumber: LongInt = 12138125;
  CountHeadlines = 5;
  Headlines: array[1..CountHeadlines] of String[55] =
    ('Integrator "Packet". Version 3.15',
     'Copyright (C) 1990-96 by VULCAN (Constantine Vulakh)',
     'Registration Key',
     'Please, don''t copy this key file !',
     '────────────────────────────────────────────────────');

  HackersHere: boolean = False;

procedure GetUserInfo(FileName: String; var Name, Company, Number: String);
procedure BuildKeyFile(Name, Company, FileName: String);
procedure Remind;
procedure LockUp;
function CalculateRegNumStr(Name, Company: String): String;
function CalculateRegNum(Name, Company: String): LongInt;

implementation

uses
  Objects, TextProc, StrServ, Crt, App, MyMsgBox, Language, PackLng,
  Pack_Hlp, Crypt;

procedure Remind;
var
  R: TRect;
begin
  R.Assign(0, 0, 50, 10);
  R.Move((Application^.Size.X - R.B.X) div 2,
         (Application^.Size.Y - R.B.Y) div 2);
  MessageBoxRect(R, Ph(phPleaseRegister), nil,
                 mfInsertInApp + mfOkButton + mfWarning,
                 hcShareware);
end;

procedure GetUserInfo(FileName: String; var Name, Company, Number: String);
var
  KeyFile: TTextFile;
  s: String;
  i: byte;
begin
  Name := '';
  Company := '';
  Number := '';

  KeyFile.Init(FileName, 0, stOpenRead, 1024);
  for i := 1 to CountHeadlines do
    if KeyFile.ReadString <> Headlines[i]
      then begin
        KeyFile.Done;
        Exit;
      end;

  Name := CryptStr(KeyFile.ReadString);
  Company := CryptStr(KeyFile.ReadString);
  Number := CryptStr(KeyFile.ReadString);

  KeyFile.Done;
end;

function CalculateRegNum(Name, Company: String): LongInt;
var
  Num: LongInt;
  i: byte;
begin
  Num := InitialNumber;
  for i := 1 to Length(Name) do
    Inc(Num, (not ord(Name[i])) xor (Num shl 2));
  for i := 1 to Length(Company) do
    Inc(Num, ord(Company[i]) + Num);
  Num := Abs(Num);
  Num := Trunc(sqrt(Num)) + Num;
  if Num = 0 then Num := 1023941231;
  CalculateRegNum := Abs(Num);
  Num := Random(MaxInt);
end;

function CalculateRegNumStr(Name, Company: String): String;
var
  NumStr: string[12];
  i: byte;
begin
  Str(CalculateRegNum(Name, Company), NumStr);
  CalculateRegNumStr := NumStr;
  for i := 1 to Length(NumStr) do
    NumStr[i] := chr(Random(256));
end;

procedure BuildKeyFile(Name, Company, FileName: String);
var
  KeyFile: TTextFile;
  s: String;
  i: byte;
begin
  KeyFile.Init(FileName, 0, stCreate, 1024);

  for i := 1 to CountHeadlines do
    KeyFile.WriteString(Headlines[i]);

  KeyFile.WriteString(Name);
  KeyFile.WriteString(Company);
  KeyFile.WriteString(CalculateRegNumStr(Name, Company));

  KeyFile.Done;
end;

procedure LockUp;
begin
  Application := Pointer(Desktop);
  Desktop := Pointer(Desktop^.Background);
end;

end.
