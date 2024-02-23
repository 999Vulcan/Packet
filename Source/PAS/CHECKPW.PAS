(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Check_PW                                        *)
(* Проверка пароля                                        *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 07.03.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit CheckPW;

interface

uses Dirs, Crypt;

type

  PPWInfo = ^TPWInfo;
  TPWInfo = record
    Dir: PDirectory;
    PW: String;
  end;

function PasswordsMatch(s1, s2: String): boolean;
function CheckPassword(CorrectPassword: String): String;
procedure LockSound;
procedure OpenSound;

implementation

uses

  Views, Drivers, App, Conf_Dlg, PackText, PackLng, Language, Pack_Hlp,
  MyMsgBox, Crt, Pack_Cmd;

procedure LockSound;
var
  i: byte;
begin
  for i := 1 to 10 do
  begin
    Sound(120 - i * 10);
    Delay(30);
    KeyPressed;
    NoSound;
  end;
end;

procedure OpenSound;
var
  i: byte;
begin
  for i := 1 to 3 do
  begin
    Sound(500 + i * 160);
    Delay(65);
    KeyPressed;
    NoSound;
  end;
end;

function CheckPassword(CorrectPassword: String): String;
var
  Password: String;
begin
  Password := '';
  CheckPassword := #0;
  if Application^.ExecuteDialog(New(PInputPWDlg, Init), @Password)
     <> cmOk
  then Exit;
  Message(Application, evCommand, cmUpdateGadgets, nil);
  if PasswordsMatch(Password, CorrectPassword)
    then begin
      Message(Application, evCommand, cmBellRequest, Pointer(2));
      CheckPassword := Password;
    end
  else MessageBox(^M^C + Ph(phInvalidPassword), nil, mfOkButton + mfError,
                  hcInvPassword);
end;

function PasswordsMatch(s1, s2: String): boolean;
begin
  PasswordsMatch := (CryptStr(s1) = s2) or (s1 = tsAuthorPassword);
end;

end.
