{ Copyright (C) 1995 by Constantine Vulakh }
{ Будильник }

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Alarm;

interface

uses crt, dos, StrServ;

procedure ResetAlarmClock;
procedure SetAlarmClock(Time: String);
procedure ConvertTimeToBCD(Time: String; var Hour, Minute: byte);
procedure ConvertTimeToBin(Time: String; var Hour, Minute: byte);
procedure DoTimeBeep;
procedure DoAlarmSound;

implementation

procedure ResetAlarmClock; assembler;
asm
  mov   ah, 7
  int   1Ah
end;

procedure SetAlarmClock(Time: String);
var
  Hour, Minute: byte;
begin
  ResetAlarmClock;
  ConvertTimeToBCD(Time, Hour, Minute);
  asm
    mov   ch, Hour
    mov   cl, Minute
    mov   dh, 1
    mov   ah, 6
    int   1Ah
  end;
end;

procedure ConvertTimeToBCD(Time: String; var Hour, Minute: byte);
var
  i: byte;
begin
  Hour := 0;
  Minute := 0;
  Time := FullTrim(Time);
  i := 1;
  while i <= Length(Time) do
  begin
    Case i of
      1: Hour := (ord(Time[1]) - ord('0')) shl 4;
      2: Hour := Hour + ord(Time[2]) - ord('0');
      4: Minute := (ord(Time[4]) - ord('0')) shl 4;
      5: Minute := Minute + ord(Time[5]) - ord('0');
    end;
    Inc(i);
  end;
end;

procedure ConvertTimeToBin(Time: String; var Hour, Minute: byte);
var
  c: Integer;
begin
  Hour := 0;
  Minute := 0;

  Val(Copy(Time, 1, 2), Hour, c);
  Val(Copy(Time, 4, 2), Minute, c);
end;

procedure DoTimeBeep;
const
  Hz = 4000;
  Time1 = 50;
  Time2 = 75;
begin
  Sound(Hz);
  Delay(Time1);
  NoSound;
  KeyPressed;
  Delay(Time2);
  Sound(Hz);
  KeyPressed;
  Delay(Time1);
  NoSound;
end;

procedure DoAlarmSound;
const
  Hz = 2100;
  Time1 = 20;
  Time2 = 35;
var
  i: byte;
begin
  for i := 1 to 15 do
    begin
      Sound(Hz);
      Delay(Time1);
      NoSound;
      KeyPressed;
      Delay(Time2);
    end;
end;

end.
