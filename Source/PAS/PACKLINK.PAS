(**********************************************************)
(*                                                        *)
(* ��⥣��� "Packet"                                    *)
(*                                                        *)
(* ����� PackLink                                        *)
(* ��ꥪ� LinkBlock ��� �裡 �����                       *)
(* Packet.Exe � PackMain.Exe                              *)
(*                                                        *)
(* ���� : ����⠭⨭ �㫠�                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* ����         : 24.02.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit PackLink;

interface

{$ifndef DPMI}
uses Dos;
{$else}
uses Dos, WinAPI;
{$endif}

const

  VerNum = '4.1';
  PackVerID = 'Packet-v.' + VerNum;

  DskFileName  = 'Packet.Dsk';
  ConfFileName = 'Packet.Cnf';

  ServParamCount = 3;  { ���-�� �㦥���� ��ࠬ��஢ }

type

  TVerStr = String[Length(PackVerID)];
  TEnvString = String[5];

  PPointerStr = ^TPointerStr;
  TPointerStr = string[11];

  PLinkBlock = ^TLinkBlock;
  TLinkBlock = object

    private

    VersionID: TVerStr;      { ���� �஢�ન �� ᮮ⢥��⢨� ���ᨩ       }
    FirstStart: boolean;     { �ਧ��� ��ࢮ�� ����᪠ PM                 }
    EnvSize: TEnvString;     { ������ ���㦥��� ��� ����᪠���� �ணࠬ�� }
    DosCmd: String;          { ��� ����᪠���� �ணࠬ�� ��� �������      }
    Params: ComStr;          { ��������� ��ப�                           }
    ExitFlag: Boolean;       { �ਧ��� ��室�                             }

    DskFile: PathStr;        { ��� 䠩�� Desktop'�                        }
    ConfFile: PathStr;       { ��� 䠩�� ���䨣��樨                     }
    TmpDskFile: PathStr;     { ��� 䠩�� �६������ Desktop'�             }
    TmpConfFile: PathStr;    { ��� 䠩�� �६����� ���䨣��樨           }
    DelTmpDsk: boolean;      { �ਧ��� �����-� 㤠���� �६. Dsk         }
    DelTmpConf: boolean;     { �ਧ��� �����-� 㤠���� �६. Cnf         }
    StartDir: DirStr;        { ��⠫�� ����᪠ ��⥣���                }

    CurrDir: DirStr;         { ����騩 ��⠫��                            }
    WorkDir: DirStr;         { ����稩 ��⠫��                            }
    RestCurrDir: boolean;    { �ਧ��� ����室����� ����⠭�����         }
                             { ⥪�騩 ��⠫��                            }
    DelayScreen: boolean;    { �ਧ��� ����室����� ����ঠ�� ��࠭      }
    ClearKbd: boolean;       { �ਧ��� ����室����� ����� ���� ����.  }
    DelProg: boolean;        { �ਧ��� ����室����� 㤠����              }
                             { 䠩� � ������ DosCmd                       }
    SMProhibited: boolean;   { �ਧ��� ����� �� ������� ����            }
    ProtWord: Word;          { ����஫쭠� �㬬� ��� �६������ Dsk-䠩�� }
    RandWord: Word;          { ���砩��� �᫮ ��� �६������ Dsk-䠩��   }
    AlarmFlag: boolean;      { �ਧ��� �ࠡ��뢠��� �㤨�쭨��            }
    AlarmText: String[250];  { ����� ����������� �㤨�쭨��               }
    AlarmTime: String[5];    { ����� �६��� �ࠡ��뢠��� �㤨�쭨��      }

    public

    constructor Init;
    destructor Done;
    function CompVer(S: TVerStr): Boolean;
    procedure SetExitFlag(f: Boolean);
    function GetExitFlag: Boolean;
    procedure SetDosCmd(Cmd: PathStr);
    function GetDosCmd: PathStr;
    procedure SetEnvSize(Size: TEnvString);
    function GetEnvSize: TEnvString;
    procedure SetParams(Par: ComStr);
    function GetParams: ComStr;
    procedure SetTmpDskFile(Name: PathStr);
    function GetTmpDskFile: PathStr;
    procedure SetTmpConfFile(Name: PathStr);
    function GetTmpConfFile: PathStr;
    procedure SetDskFile(Name: PathStr);
    function GetDskFile: PathStr;
    procedure SetConfFile(Name: PathStr);
    function GetConfFile: PathStr;
    procedure SetCurrDir(Dir: DirStr);
    function GetCurrDir: DirStr;
    procedure SetWorkDir(Dir: DirStr);
    function GetWorkDir: DirStr;
    procedure SetStartDir(Dir: DirStr);
    function GetStartDir: DirStr;
    procedure SetRestCurrDirFlag(f: boolean);
    function GetRestCurrDirFlag: boolean;
    procedure SetDelProgFlag(f: boolean);
    function GetDelProgFlag: boolean;
    procedure SetDelTmpDskFlag(f: boolean);
    function GetDelTmpDskFlag: boolean;
    procedure SetDelTmpConfFlag(f: boolean);
    function GetDelTmpConfFlag: boolean;
    procedure SetFirstStartFlag(f: boolean);
    function GetFirstStartFlag: boolean;
    procedure SetDelayScreen(f: boolean);
    function GetDelayScreen: boolean;
    procedure SetClearKbd(f: boolean);
    function GetClearKbd: boolean;
    procedure SetSMProh(f: boolean);
    function GetSMProh: boolean;
    procedure SetProtWord(PrW: Word);
    function GetProtWord: Word;
    procedure SetRandWord(PrW: Word);
    function GetRandWord: Word;
    procedure SetAlarmFlag(AF: boolean);
    function GetAlarmFlag: boolean;
    procedure SetAlarmText(AT: String);
    function GetAlarmText: String;
    procedure SetAlarmTime(AT: String);
    function GetAlarmTime: String;
  end;


{ �뤥��� ������ ��� LinkBlock � ������ 㪠��⥫� �� ���� � P      }
{ �����頥� ��ப�, ᮤ�ঠ��� �१ �஡�� ��ப���� �।�⠢����� }
{ 㪠��⥫� P                                                        }

  function CreateLinkBlock(var P: PLinkBlock): TPointerStr;


{ �����頥� 㪠��⥫�, ᥣ���� � ᬥ饭�� ���ண� }
{ ������ �� 2-� � 3-� ��ࠬ���� ��������� ��ப�   }

  function GetLinkPtr(var P: PLinkBlock): Word;

implementation

type

  PtrRec = record
    Ofs, Seg: word;
  end;

constructor TLinkBlock.Init;
begin
  VersionID := PackVerID;
  SetExitFlag(True);
  SetDosCmd('');
  SetEnvSize('512');
  SetTmpDskFile(FExpand(DskFileName));
  SetTmpConfFile(FExpand(ConfFileName));
  SetDskFile(FExpand(DskFileName));
  SetConfFile(FExpand(ConfFileName));
  SetDelTmpDskFlag(False);
  SetDelTmpConfFlag(False);
  SetCurrDir('');
  SetWorkDir('');
  SetStartDir('');
  SetRestCurrDirFlag(False);
  SetParams('');
  SetDelProgFlag(False);
  SetFirstStartFlag(True);
  SetDelayScreen(False);
  SetSMProh(False);
  SetClearKbd(False);
  SetAlarmFlag(False);
end;

destructor TLinkBlock.Done;
begin
end;

function TLinkBlock.CompVer(S: TVerStr): Boolean;
begin
  CompVer := S = VersionID
end;

procedure TLinkBlock.SetExitFlag(f: Boolean);
begin
  ExitFlag := f
end;

function TLinkBlock.GetExitFlag: Boolean;
begin
  GetExitFlag := ExitFlag
end;

procedure TLinkBlock.SetDosCmd(Cmd: PathStr);
begin
  DosCmd := Cmd
end;

function TLinkBlock.GetDosCmd: PathStr;
begin
  GetDosCmd := DosCmd
end;

procedure TLinkBlock.SetEnvSize(Size: TEnvString);
begin
  EnvSize := Size
end;

function TLinkBlock.GetEnvSize: TEnvString;
begin
  GetEnvSize := EnvSize
end;

procedure TLinkBlock.SetParams(Par: ComStr);
begin
  Params := Par
end;

function TLinkBlock.GetParams: ComStr;
begin
  GetParams := Params
end;

procedure TLinkBlock.SetTmpDskFile(Name: PathStr);
begin
  TmpDskFile := Name
end;

function TLinkBlock.GetTmpDskFile: PathStr;
begin
  GetTmpDskFile := TmpDskFile
end;

procedure TLinkBlock.SetTmpConfFile(Name: PathStr);
begin
  TmpConfFile := Name
end;

function TLinkBlock.GetTmpConfFile: PathStr;
begin
  GetTmpConfFile := TmpConfFile
end;

procedure TLinkBlock.SetDskFile(Name: PathStr);
begin
  DskFile := Name
end;

function TLinkBlock.GetDskFile: PathStr;
begin
  GetDskFile := DskFile
end;

procedure TLinkBlock.SetConfFile(Name: PathStr);
begin
  ConfFile := Name
end;

function TLinkBlock.GetConfFile: PathStr;
begin
  GetConfFile := ConfFile
end;

function TLinkBlock.GetCurrDir: DirStr;
begin
  GetCurrDir := CurrDir
end;

procedure TLinkBlock.SetCurrDir(Dir: DirStr);
begin
  CurrDir := Dir
end;

function TLinkBlock.GetWorkDir: DirStr;
begin
  GetWorkDir := WorkDir
end;

procedure TLinkBlock.SetWorkDir(Dir: DirStr);
begin
  WorkDir := Dir
end;

procedure TLinkBlock.SetRestCurrDirFlag(f: boolean);
begin
  RestCurrDir := f
end;

function TLinkBlock.GetRestCurrDirFlag: boolean;
begin
  GetRestCurrDirFlag := RestCurrDir
end;

procedure TLinkBlock.SetDelProgFlag(f: boolean);
begin
  DelProg := f;
end;

function TLinkBlock.GetDelProgFlag: boolean;
begin
  GetDelProgFlag := DelProg;
end;

procedure TLinkBlock.SetDelTmpDskFlag(f: boolean);
begin
  DelTmpDsk := f;
end;

function TLinkBlock.GetDelTmpDskFlag: boolean;
begin
  GetDelTmpDskFlag := DelTmpDsk;
end;

procedure TLinkBlock.SetDelTmpConfFlag(f: boolean);
begin
  DelTmpConf := f;
end;

function TLinkBlock.GetDelTmpConfFlag: boolean;
begin
  GetDelTmpConfFlag := DelTmpConf;
end;

procedure TLinkBlock.SetFirstStartFlag(f: boolean);
begin
  FirstStart := f;
end;

function TLinkBlock.GetFirstStartFlag: boolean;
begin
  GetFirstStartFlag := FirstStart;
end;

procedure TLinkBlock.SetSMProh(f: boolean);
begin
  SMProhibited := f;
end;

function TLinkBlock.GetSMProh: boolean;
begin
  GetSMProh := SMProhibited;
end;

procedure TLinkBlock.SetProtWord(PrW: Word);
begin
  ProtWord := PrW;
end;

function TLinkBlock.GetProtWord: Word;
begin
  GetProtWord := ProtWord;
end;

procedure TLinkBlock.SetRandWord(PrW: Word);
begin
  RandWord := PrW;
end;

function TLinkBlock.GetRandWord: Word;
begin
  GetRandWord := RandWord;
end;

procedure TLinkBlock.SetDelayScreen(f: boolean);
begin
  DelayScreen := f;
end;

function TLinkBlock.GetDelayScreen: boolean;
begin
  GetDelayScreen := DelayScreen;
end;

procedure TLinkBlock.SetClearKbd(f: boolean);
begin
  ClearKbd := f;
end;

function TLinkBlock.GetClearKbd: boolean;
begin
  GetClearKbd := ClearKbd;
end;

procedure TLinkBlock.SetAlarmFlag(AF: boolean);
begin
  AlarmFlag := AF;
end;

function TLinkBlock.GetAlarmFlag: boolean;
begin
  GetAlarmFlag := AlarmFlag;
end;

procedure TLinkBlock.SetAlarmText(AT: String);
begin
  AlarmText := AT;
end;

function TLinkBlock.GetAlarmText: String;
begin
  GetAlarmText := AlarmText;
end;

procedure TLinkBlock.SetAlarmTime(AT: String);
begin
  AlarmTime := AT;
end;

function TLinkBlock.GetAlarmTime: String;
begin
  GetAlarmTime := AlarmTime;
end;

procedure TLinkBlock.SetStartDir(Dir: DirStr);
begin
  StartDir := Dir;
end;

function TLinkBlock.GetStartDir: DirStr;
begin
  GetStartDir := StartDir;
end;

function CreateLinkBlock(var P: PLinkBlock): TPointerStr;
var
  PS1, PS2: String[5];
  p1: ^PtrRec;
begin
  New(P, Init);
  p1 := @P;
  Str(p1^.Ofs, PS1);
  Str(p1^.Seg, PS2);
  CreateLinkBlock := PS1 + ' ' + PS2;
end;

function GetLinkPtr(var P: PLinkBlock): Word;
var
  p1: ^PtrRec;
  c: Integer;
  Selector: Word;
begin
  p1 := @P;
  Val(ParamStr(2), p1^.Ofs, c);
  Val(ParamStr(3), p1^.Seg, c);
  Selector := 0;
{$ifdef DPMI}
  Selector := AllocSelector(0);
  SetSelectorBase(Selector, Longint(p1^.Seg) shl 4);
  SetSelectorLimit(Selector, $FFFF);
  p1^.Seg := Selector;
{$endif}
  GetLinkPtr := Selector;
end;

end.
