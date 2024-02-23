(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PackLink                                        *)
(* Объект LinkBlock для связи между                       *)
(* Packet.Exe и PackMain.Exe                              *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 24.02.1994                             *)
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

  ServParamCount = 3;  { Кол-во служебных параметров }

type

  TVerStr = String[Length(PackVerID)];
  TEnvString = String[5];

  PPointerStr = ^TPointerStr;
  TPointerStr = string[11];

  PLinkBlock = ^TLinkBlock;
  TLinkBlock = object

    private

    VersionID: TVerStr;      { Поле проверки на соответствие версий       }
    FirstStart: boolean;     { Признак первого запуска PM                 }
    EnvSize: TEnvString;     { Размер окружения для запускаемой программы }
    DosCmd: String;          { Имя запускаемой программы или команда      }
    Params: ComStr;          { Командная строка                           }
    ExitFlag: Boolean;       { Признак выхода                             }

    DskFile: PathStr;        { Имя файла Desktop'а                        }
    ConfFile: PathStr;       { Имя файла конфигурации                     }
    TmpDskFile: PathStr;     { Имя файла временного Desktop'а             }
    TmpConfFile: PathStr;    { Имя файла временной конфигурации           }
    DelTmpDsk: boolean;      { Признак необх-ти удалять врем. Dsk         }
    DelTmpConf: boolean;     { Признак необх-ти удалять врем. Cnf         }
    StartDir: DirStr;        { Каталог запуска Интегратора                }

    CurrDir: DirStr;         { Текущий каталог                            }
    WorkDir: DirStr;         { Рабочий каталог                            }
    RestCurrDir: boolean;    { Признак необходимости восстановить         }
                             { текущий каталог                            }
    DelayScreen: boolean;    { Признак необходимости задержать экран      }
    ClearKbd: boolean;       { Признак необходимости очищать буфер клав.  }
    DelProg: boolean;        { Признак необходимости удалять              }
                             { файл с именем DosCmd                       }
    SMProhibited: boolean;   { Признак запрета на плавную мышь            }
    ProtWord: Word;          { Контрольная сумма для временного Dsk-файла }
    RandWord: Word;          { Случайное число для временного Dsk-файла   }
    AlarmFlag: boolean;      { Признак срабатывания будильника            }
    AlarmText: String[250];  { Текст напоминания будильника               }
    AlarmTime: String[5];    { Текст времени срабатывания будильника      }

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


{ Выделяет память под LinkBlock и заносит указатель на него в P      }
{ Возвращает строку, содержащую через пробел строковое представление }
{ указателя P                                                        }

  function CreateLinkBlock(var P: PLinkBlock): TPointerStr;


{ Возвращает указатель, сегмент и смещение которого }
{ заданы во 2-м и 3-м параметрах командной строки   }

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
