(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль DirConf                                         *)
(* Объект TDirConf ( конфигурация оглавления )            *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 19.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit DirConf;

interface

uses Objects, Views, StreamID, StrServ, Crypt;

type

  TCheckSum = Word;

  { Используется для хранения информации о конфигурации оглавления }
  PDirConfData = ^TDirConfData;
  TDirConfData = record
    Title: TTitleStr;
    Protection: Word;
    Password: String[80];
    ExtEditor: FNameStr;
  end;

  PDirConfig = ^TDirConfig;
  TDirConfig = object(TObject)

    private

    Title: PString;      { Название оглавления                             }
    Protection: Word;    { Тип защиты : prNothing, prWrite или prReadWrite }
    Password: PString;      { Пароль для доступа к защищенному оглавлению     }
    ExtEditor: PString;  { Имя файла внешнего текстового редактора         }
    ComprFlags: Word;    { Флаги необходимости сжатия файла оглавления     }
                         { в различных ситуациях                           }
    CheckSum: TCheckSum;

    public

    constructor Init(ATitle, APassword, AExtEditor: String;
                     AProtection, AComprFlags: Word);
    destructor Done; virtual;
    procedure Store(var S: TStream);
    constructor Load(var S: TStream);
    procedure SetData(var ConfigData: TDirConfData);
    procedure GetData(var ConfigData: TDirConfData);
    procedure SetCheckSum(ChS: TCheckSum);
    function GetTitle: String;
    function GetPassword: String;
    procedure CryptPassword;
    function CalcCheckSum: TCheckSum;
    function GetProtection: Word;
    function GetExtEditor: String;
    function Valid: boolean;
  end;

const

  { Константы, задающие тип защиты оглавления }
  prNothing     = 0;
  prWrite       = 1;
  prReadWrite   = 2;

  RDirConfig: TStreamRec = (
    ObjType: idDirConfig;
    VmtLink: Ofs(TypeOf(TDirConfig)^);
    Load: @TDirConfig.Load;
    Store: @TDirConfig.Store
  );

implementation

constructor TDirConfig.Init(ATitle, APassword, AExtEditor: String;
                           AProtection, AComprFlags: Word);
begin
  Title := NewStr(ATitle);
  Protection := AProtection;
  Password := NewStr(CryptStr(APassword));
  ExtEditor := NewStr(AExtEditor);
  ComprFlags := AComprFlags;
end;

destructor TDirConfig.Done;
begin
  DispStr(Title);
  DispStr(Password);
  DispStr(ExtEditor);
end;

procedure TDirConfig.Store(var S: TStream);
begin
  CryptPassword;
  CheckSum := CalcCheckSum;
  WriteString(S, Title);
  S.Write(Protection, SizeOf(Protection));
  WriteString(S, Password);
  WriteString(S, ExtEditor);
  S.Write(ComprFlags, SizeOf(ComprFlags));
  S.Write(CheckSum, SizeOf(TCheckSum));
  CryptPassword;
end;

constructor TDirConfig.Load(var S: TStream);
var
  ChkSum: TCheckSum;
begin
  Title := ReadString(S);
  S.Read(Protection, SizeOf(Protection));
  Password := ReadString(S);
  ExtEditor := ReadString(S);
  S.Read(ComprFlags, SizeOf(ComprFlags));
  S.Read(CheckSum, SizeOf(TCheckSum));
  CryptPassword;
end;

procedure TDirConfig.SetData(var ConfigData: TDirConfData);
begin
  SetNewStr(Title, ConfigData.Title);
  Protection := ConfigData.Protection;
  SetNewStr(Password, CryptStr(ConfigData.Password));
  SetNewStr(ExtEditor, ConfigData.ExtEditor);
end;

procedure TDirConfig.GetData(var ConfigData: TDirConfData);
begin
  ConfigData.Title := GetStr(Title);
  ConfigData.Protection := Protection;
  ConfigData.Password := CryptStr(GetStr(Password));
  ConfigData.ExtEditor := GetStr(ExtEditor);
end;

procedure TDirConfig.SetCheckSum(ChS: TCheckSum);
begin
  CheckSum := ChS;
end;

function TDirConfig.GetTitle: String;
begin
  GetTitle := GetStr(Title);
end;

function TDirConfig.GetPassword: String;
begin
  GetPassword := GetStr(Password);
end;

procedure TDirConfig.CryptPassword;
begin
  if Assigned(Password)
    then Password^ := CryptStr(Password^);
end;

function TDirConfig.GetProtection: Word;
begin
  GetProtection := Protection;
end;

function TDirConfig.GetExtEditor: String;
begin
  GetExtEditor := GetStr(ExtEditor);
end;

function TDirConfig.CalcCheckSum: TCheckSum;
var
  ChS: TCheckSum;
  i: Integer;
begin
  ChS := 0;
  CalcCheckSum := ChS;
end;

function TDirConfig.Valid: boolean;
begin
  Valid := CalcCheckSum = CheckSum;
end;

end.

