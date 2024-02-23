(***********************************************************)
(*                                                         *)
(* Интегратор "Packet"                                     *)
(*                                                         *)
(* Модуль FileOps                                          *)
(* Операции с файлами DOS (удаление, переименование и др.) *)
(*                                                         *)
(* Автор : Константин Вулах                                *)
(* Copyright (C) 1994 by VULCAN                            *)
(*                                                         *)
(* Начат         : 25.03.1994                              *)
(*                                                         *)
(***********************************************************)

{$A+,B-,E-,F+,N-,O-,V-,X+,I-}
unit FileOps;

interface

uses Dos, Language, PackLng, StrServ;

  procedure ClearError;
  procedure ChangeDirectory(Dir: DirStr);
  function EraseFile(FileName: PathStr): Integer;
  function RenameFile(OldFileName, NewFileName: PathStr): Integer;
  function FileExist(FileName: PathStr): boolean;
  function GetFileSize(FileName: PathStr): LongInt;
  function GetErrMsg(ErrNo: Integer): String;
  function GetRndFileName(Template: PathStr): PathStr;

implementation

procedure ClearError;
var
  c: Integer;
begin
  c := IOResult;
end;

procedure ChangeDirectory(Dir: DirStr);
begin
  Dir := FullTrim(Dir);
  if Dir = '' then Exit;
  if (Dir[Length(Dir)] = '\') and (Length(Dir) > 3)
    then Dec(Dir[0]);
  if Dir[2] = ':'
    then ChDir(Copy(Dir, 1, 2));
  ClearError;
  ChDir(Dir);
  ClearError;
end;

function EraseFile(FileName: PathStr): Integer;
var
  f: file;
begin
  Assign(f, FileName);
  Erase(f);
  EraseFile := IOResult;
end;

function RenameFile(OldFileName, NewFileName: PathStr): Integer;
var
  f: file;
begin
  Assign(f, OldFileName);
  Rename(f, NewFileName);
  RenameFile := IOResult;
end;

function FileExist(FileName: PathStr): boolean;
begin
  FileExist := FSearch(FileName, GetEnv('path')) <> '';
end;

function GetFileSize(FileName: PathStr): LongInt;
var
  SR: SearchRec;
begin
  FindFirst(FileName, AnyFile, SR);
  if DosError <> 0
    then GetFileSize := 0
  else GetFileSize := SR.Size;
end;

function GetRndFileName(Template: PathStr): PathStr;
var
  i: byte;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(Template, Dir, Name, Ext);
  Name := Copy(Name, 1, 3);
  Randomize;
  for i := Length(Name) to 8 do
    Name := Name + chr(ord('A') + Random(26));
  GetRndFileName := Dir + Name + Ext;
end;

function GetErrMsg(ErrNo: Integer): String;
var
  No: string[5];
begin
  Case ErrNo of
      2: GetErrMsg := Ph(phFileNotFound);
      3: GetErrMsg := Ph(phPathNotFound);
    150: GetErrMsg := Ph(phDiskIsWP);
  else
    Str(ErrNo, No);
    GetErrMsg := Ph(phError) + ' ' + No;
  end;
end;

end.

