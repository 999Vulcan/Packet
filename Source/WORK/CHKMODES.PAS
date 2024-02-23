{$A-,B-,D+,E-,F-,G-,I-,L+,N-,O-,P-,Q-,R-,S-,T-,V-,X+,Y+}
{$M 1024,0,0}

Program CheckModes;

uses Crt;

const

  CRLF = #13#10;

  Copyright1 =
  'Integrator "Packet"  ver. 3.0   Copyright (C) 1990-95 by VULCAN';
  Copyright2 =
  'SVGA text video modes detector  ver. 1.5   Copyright (C) 1995 by VULCAN & NVS';

  S1 = '────═════ SuperVGA text modes are not detected ═════────' + CRLF;
  sVGAModesNotDetected: String[Length(S1)] = S1;

  TabOffset = 20;

var

  flag: boolean;
  IsSVGA: boolean;

function IsVGA: boolean; assembler;
asm
  xor    bx, bx
  mov    ax, 1007h
  mov    bl, 0fh
  int    10h
  mov    al, bh
  cbw
end;

procedure SetVMode(Mode: byte); assembler;
asm
  mov    ah, 0
  mov    al, Mode
  int    10h
end;

procedure Help;
begin
  writeln('Use:');
  writeln('  ChkModes   ReportName');
  writeln;
end;

procedure Greeting;
begin
  TextBackground(Black);
  TextColor(White);
  writeln;
  writeln(Copyright1);
  writeln(Copyright2);
  TextColor(LightGray);
  writeln;
end;

procedure GreetingToFile(var f: text);
begin
  writeln(f, Copyright1);
  writeln(f, Copyright2);
  writeln(f);
  writeln(f, '':TabOffset, ' Following text modes are detected:');
  writeln(f);
  writeln(f, '':TabOffset, '╔═════╤════════════╤═══════════════╗');
  writeln(f, '':TabOffset, '║ No. │ Resolution │    Remarks    ║');
  writeln(f, '':TabOffset, '╠═════╪════════════╪═══════════════╣');
end;

procedure ClearKbd;
begin
  while KeyPressed do ReadKey;
end;

procedure CheckError;
begin
  if IOResult <> 0
    then begin
      if flag
        then TextMode(LastMode);
      writeln('Error creating report file');
      ClearKbd;
      Halt(1);
    end;
end;

function GetHex(i: byte): String;
const
  HexFigures: String = '0123456789ABCDEF';
var
  Hex: String[2];
begin
  Hex := '00';
  Hex[2] := HexFigures[i and $0F + 1];
  Hex[1] := HexFigures[(i and $F0) shr 4 + 1];
  GetHex := Hex;
end;

function GetRemark(Mode: byte): String;
begin
  Case Mode of
    0: GetRemark := 'Black & white';
    1: GetRemark := 'Color        ';
    2: GetRemark := 'Black & white';
    3: GetRemark := 'Color        ';
    7: GetRemark := 'Monochrome   ';
    else
       GetRemark := 'SuperVGA mode'
  end;
end;

function IsGraphMode: boolean;
begin
  Port[$3CE] := 6;
  IsGraphMode := Port[$3CF] and 1 = 1;
end;

function GetResolution: String;
var
  s1, s2: String;
begin
  Str(mem[0:$044A], s1);
  Str(mem[0:$0484] + 1, s2);
  s1 := Copy('     ', 1, 3 - Length(s1)) + s1;
  GetResolution := s1 + 'x' + s2;
end;

procedure WriteMenu;
begin
  writeln('Now Your display will be tested to detect text video modes.');
  writeln('Testing may take up to 30 sec.');
  writeln('See results in ', ParamStr(1));
  writeln('Press any key to begin testing or Esc to exit to DOS...');
  writeln;
  writeln('Ваш монитор будет протестирован для обнаружения текстовых видеорежимов.');
  writeln('Тестирование может длиться до 30 сек.');
  writeln('Результаты тестирования - в файле ', ParamStr(1));
  writeln('Нажмите любую клавишу для начала тестирования или ESC для выхода в DOS...');
  ClearKbd;
  if ReadKey = #27
    then Halt(1);
end;

procedure Melody;
begin
  Sound(1000);
  Delay(100);
  NoSound;
end;

procedure Process;
var
  f: text;
  i: byte;
begin
  if not IsVGA
    then begin
      writeln('This is not a VGA display'^G);
      Halt(1);
    end;
  WriteMenu;
  Assign(f, ParamStr(1));
  Rewrite(f);
  GreetingToFile(f);
  CheckError;
  flag := True;
  ClrScr;
  for i := 0 to 127 do
  begin
    if i in [8..13]
      then Continue;

    SetVMode(i);

    if IsGraphMode
      then Continue;

    if not IsSVGA and (i > 10)
      then writeln(f, '':TabOffset, '╟─────┼────────────┼───────────────╢');
    IsSVGA := i > 10;

    writeln(f, '':TabOffset, '║ ', GetHex(i), 'h │  ', GetResolution,
      '    │ ', GetRemark(i), ' ║');
    writeln('Text videomode ', GetHex(i),  ' detected');
    writeln(GetResolution, ' ', GetRemark(i));
    Delay(500);
  end;
  writeln(f, '':TabOffset, '╚═════╧════════════╧═══════════════╝',CRLF);
  if not IsSVGA
    then writeln(f, '':10, sVGAModesNotDetected);
  writeln(f, '':9,
           'See Your SuperVGA card documentation for more information.')         ;
  Close(f);
  CheckError;
  TextMode(LastMode);
  Greeting;
  if not IsSVGA
    then writeln('':10, sVGAModesNotDetected)
  else writeln('':12,
    '────═════ SuperVGA text modes are detected ═════────', CRLF);
  writeln('See ', ParamStr(1), ' for information');
  Melody;
  ClearKbd;
end;

begin
  CheckBreak := False;
  ClrScr;
  flag := False;
  IsSVGA := False;
  Greeting;
  if (ParamCount <> 1) or (ParamStr(1) = '/?')
    then Help
  else Process;
end.
