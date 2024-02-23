{  Copyright (C) 1994 by VULCAN  }
{  22.10.94  }
unit Err_Exit;
{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

interface

const
  FatalErrorFlag: boolean = False;

implementation

uses crt, cursor, App;

var
  OldExit:Pointer;

Procedure FatErrorBell;
Var
  i:byte;
begin
  for i:=1 to 10 do
    begin
      Sound(350);
      Delay(30);
      NoSound;
      Delay(20)
    end
end;

procedure PrintErrorMessage;
begin
  Case ExitCode of
{$ifdef debug}
    201: writeln('Range check error');
{$endif}
    203: writeln('Out of memory');
    216: writeln('General protection fault');
  end;
end;

{$F+}
Procedure ErrExitProc;
{ Процедура выполняется при завершении работы программы }
var
  ch: Char;
  i: byte;
Begin
  ExitProc := OldExit;
  if ErrorAddr <> nil
    then
      begin
        FatalErrorFlag := True;
        if Assigned(Application) then Application^.Done;
        TextMode(LastMode);
        TextAttr := $7;
        writeln(#13#10'Internal error No. ', ExitCode);
        PrintErrorMessage;
        TextAttr := $F;
        writeln('Please report to author !');
        TextAttr := $7;
        FatErrorBell;
        while KeyPressed do ch := ReadKey;
{$ifndef Debug}
        ErrorAddr := nil;
{$endif}
      end;
  ky;
End;

begin
  OldExit:=ExitProc;
  ExitProc:=@ErrExitProc;
end.
