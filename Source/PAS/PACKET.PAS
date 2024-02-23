(**********************************************************)
(*                                                        *)
(* ˆ­â¥£à â®à "Packet"                                    *)
(*                                                        *)
(* Œ®¤ã«ì Packet.Exe                                      *)
(* Ÿ„Ž                                                   *)
(*                                                        *)
(* €¢â®à : Š®­áâ ­â¨­ ‚ã« å                               *)
(* Copyright (C) 1994-97 by VULCAN                        *)
(*                                                        *)
(*  ç â         : 24.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$M 3500,1000,1000}
{$A-,B-,E-,F-,N-,O-,V-,X+,I-,S-,R-}

Program Packet;

uses crt, dos, PackLink, StrServ, Alarm;

var
   OldIntDFh: pointer;
   BodyIntDF: Word;
   CheckDLoad: Boolean;
   OldAlarmClock: pointer;
   PMLoaded: boolean;

   LB: PLinkBlock;
   PS: TPointerStr;   { ‘âà®ª®¢®¥ ¯à¥¤áâ ¢«¥­¨¥ ãª § â¥«ï ­  LinkBlock }

  Dir: DirStr;
 Name: NameStr;
  Ext: ExtStr;

  Params: ComStr;

  i: Integer;

procedure WriteTitle;
const
  Col1 = White;
  Col2 = White;
  Col3 = White;
  Col4 = LightGreen;
  Col5 = DarkGray;
  Col6 = Col4;
  BackGr = Blue;
begin
  writeln;
  TextBackground(BackGr);
  TextColor(Col1);
  write('ÉÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ»');
  TextBackground(Black);
  writeln;
  TextBackground(BackGr);
  write  ('º ');
  TextColor(Col2); write('ú');
  TextColor(Col3); write('      Copyright (C) 1990-97 by       ');
  TextColor(Col2); write('ú');
  TextColor(Col1); write(' º');
  TextBackground(Black); TextColor(Col5);
  writeln('°°');
  TextBackground(BackGr);
  TextColor(Col1); write('º');
  TextColor(Col6); write('  Michael Dolinsky ');
  TextColor(Col3); write('&');
  TextColor(Col6); write(' Constantine Vulakh  ');
  TextColor(Col1); write('º');
  TextBackground(Black); TextColor(Col5);
  writeln('°°');
  TextBackground(BackGr);
  TextColor(Col1); write('º');
  TextColor(Col2); write(' ú');
  TextColor(Col3); write('     Integrator "');
  TextColor(Col4); write('Packet');
  TextColor(Col3); write('" v. ', VerNum, '      ');
  TextColor(Col2); write('ú ');
  TextColor(Col1); write('º');
  TextBackground(Black); TextColor(Col5);
  writeln('°°');
  TextBackground(BackGr);
  TextColor(Col1); write('ÈÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼');
  TextBackground(Black);
  TextColor(Col5);
  writeln('°°');
  write('  °°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°°');
  TextAttr := 7;
  writeln;
  writeln;
end;

{$F+}
procedure MyAlarmClock; interrupt;
begin
  if not PMLoaded then DoAlarmSound;
  LB^.SetAlarmFlag(True);
end;
{$F-}

procedure InstallAlarmClock;
begin
  ResetAlarmClock;
  GetIntVec($4A, OldAlarmClock);
  SetIntVec($4A, @MyAlarmClock);
end;

procedure UninstallAlarmClock;
begin
  ResetAlarmClock;
  SetIntVec($4A, OldAlarmClock);
end;

procedure ExitPacket;
begin
  if CheckDLoad then SetIntVec($DF, nil);
  UninstallAlarmClock;
  TextBackground(Black);
  TextColor(White);
  writeln;
  write('Thank You for use Integrator "');
  TextColor(LightGreen);
  write('Packet');
  TextColor(White);
  write('" !');
  TextColor(LightGray);
  writeln;
  Dir := LB^.GetStartDir;
  if (Dir[Length(Dir)] = '\') and (Length(Dir) > 3)
    then Dec(Dir[0]);
  if Dir[2] = ':'
    then ChDir(Copy(Dir, 1, 2));
  if IOResult = 0 then;
  ChDir(Dir);
  Halt;
end;

procedure ReportError;
begin
  TextColor(LightRed);
  Case DosError of
      2: write('File "Packmain.exe" not found'^G);
      8: write('Not enough memory'^G);
    else write('Error reading file "Packmain.exe"'^G)
  end;
  TextColor(LightGray);
  writeln;
end;

procedure CheckDoubleLoad;
begin
  if not CheckDLoad then Exit;
  BodyIntDF := $CF90;
  GetIntVec($DF,OldIntDFh);
  if ((OldIntDFh<>Nil) and (Word(OldIntDFh^)=BodyIntDF))
    then
      begin
        TextColor(12);
        writeln('Integrator "Packet" is already loaded !'^G);
        TextColor(7);
        writeln;
        Halt(1);
      end;
  SetIntVec($DF,@BodyIntDF);
end;

procedure SetParamString;
var
  Par: ComStr;
  ComPart: PathStr;
begin
  CheckDLoad := True;
  Params := '';
  for i := 1 to ParamCount do
    begin
      Par := StrUpCase(ParamStr(i));
      if Par = '/NM'
        then LB^.SetSMProh(True)
      else if Par = '/ND'
        then CheckDLoad := False
      else if Copy(Par, 1, 2) = '/C'
        then begin
          if Length(Par) < 3 then Continue;
          Par := Copy(Par, 3, 255);
          ComPart := GetFDir(Par) + GetFName(Par);
          LB^.SetTmpDskFile(FExpand(ComPart + '.DSK'));
          LB^.SetTmpConfFile(ComPart + '.CNF');
          LB^.SetDskFile(FExpand(ComPart + '.DSK'));
          LB^.SetConfFile(ComPart + '.CNF');
        end
      else Params := Params + ' ' + ParamStr(i);
    end;
end;

procedure ClearKbd;
begin
  while KeyPressed do ReadKey;
end;

procedure DelayScreen;
begin
  if not LB^.GetDelayScreen
    then Exit;
  writeln(#13#10'Press any key to return to Integrator "Packet"...');
  ClearKbd;
  ReadKey;
  ClearKbd;
end;

begin
  CheckBreak:=False;
  PMLoaded := False;
  WriteTitle;
  PS := CreateLinkBlock(LB);
  GetDir(0, Dir);
  LB^.SetStartDir(Dir);
  FSplit(ParamStr(0), Dir, Name, Ext);
  SetParamString;
  CheckDoubleLoad;
  LB^.SetClearKbd(False);
  InstallAlarmClock;
  Repeat
    LB^.SetExitFlag(True);
    LB^.SetDelayScreen(False);
    PMLoaded := True;
    Exec(Dir + 'PackMain.Exe', PackVerID + ' ' + PS + Params);
    PMLoaded := False;
    Params := '';
    if DosError > 0 then
    begin
      ReportError;
      LB^.SetExitFlag(True);
    end;
    if LB^.GetExitFlag
      then ExitPacket;

    SwapVectors;
    if LB^.GetDosCmd <> #0
      then
        if LB^.GetDosCmd = ''
          then begin
            writeln('Type EXIT to return to Integrator "Packet"...');
            Exec(GetEnv('comspec'),'');
          end
        else Exec(GetEnv('comspec'), '/e:' + LB^.GetEnvSize
                  + ' /c ' + LB^.GetDosCmd + ' ' + LB^.GetParams);
    SwapVectors;
    DelayScreen;
  Until False;
end.

