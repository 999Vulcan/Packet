(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PackMain.Exe                                    *)
(* Основная программа                                     *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 21.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$ifndef DPMI}

{$M 65520,153600,655360}
{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

{$else}

{$M 65520}
{$A+,B-,D+,E+,F-,G+,I-,L+,N-,P-,Q-,T-,V+,X+,Y+}

{$endif}

Program PackMain;

uses

   PMApp,
{$ifndef DPMI}
   Pack_Ovr,
{$endif}
   Crt,
   Dos,
   Cursor;

{$ifndef DPMI}

 {$O Editors}

 {$O Dir_Wind}
 {$O Dirs}
 {$O SubDirs}
 {$O Items}
 {$O PathStk}
 {$O DirConf}
 {$O Ann_Wind}

 {$O StdDlg}
 {$O RunDlg}
 {$O Conf_Dlg}
 {$O Pack_Dlg}
 {$O AddItDlg}
 {$O AddSDDlg}
 {$O SelSDDlg}
 {$O EditRes}
 {$O XListBox}
 {$O ParamDlg}
 {$O HotKeys}
 {$O HKDlg}

 {$O MyAscii}
 {$O MyCalc}
 {$O MyCalend}

 {$O MyMouDlg}
 {$O Line_Num}
 {$O Validate}
 {$O Edit_Dlg}
 {$O Win_List}
 {$O MyColSel}
 {$O Pack_CS}
 {$O HelpFile}
 {$O LocMenus}

 {$O TextProc}
 {$O MakeDoc}
 {$O AlarmDlg}
 {$O Alarm}
 {$O EditServ}
 {$O Ext_Serv}
 {$O WinCheck}
 {$O ContRepl}
 {$O Outp_Win}
 {$O StrStack}

{$endif}

var

  PM: TPMApp;

procedure CheckDosVersion;
var
  DosVer: Word;
begin
  DosVer := DosVersion;
  if (Lo(DosVer) > 3) or
     ((Lo(DosVer) = 3) and (Hi(DosVer) >= 30))
    then Exit;
  writeln('Too old DOS version');
  writeln('You need DOS 3.30 at least to use Integrator "Packet"'^G);
  Halt;
end;

procedure CheckCPU;
begin
  if Test8086 > 1 then Exit;
  writeln('Need 80386 at least to run DPMI-version');
  Halt(1);
end;

begin
  CheckDosVersion;

{$ifdef DPMI}
  CheckCPU;
{$endif}

  if not (LastMode in [2, 3, 7])
    then begin
      TextMode(3);
      LastMode := 3;
    end;
  ky;

{$ifndef DPMI}
  OvrInitError := not InitPackOvr;
{$else}
  OvrInitError := False;
{$endif}

  US.Init;
  US.Store;

  ClrScr;

  if PM.Init
    then begin
      PM.Run;
      PM.Done;
    end;

  US.Restore;
  US.Done;
end.
