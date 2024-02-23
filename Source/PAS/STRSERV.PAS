{*********************************************************************}
{                                                                     }
{       Turbo Pascal Version 7.0                                      }
{       String Service Unit                                           }
{                                                                     }
{       Copyright (c) 1993-95 by VULCAN ( Constantine Vulakh )        }
{                                                                     }
{       Начат : 13.12.93                                              }
{                                                                     }
{*********************************************************************}
{$A+,B-,E-,F+,N-,O-,V-,X+,I-}

unit StrServ;

interface

uses Objects, Dos;

const
  Spaces = '                                                          '+
           '                                                          ';
  CRLF = #13#10;

function GetShortFName(FN: String; Len: byte): String;
function StrUpCase(s: String): String;
procedure DelFirstSpaces(var s: String);
procedure DelFinalSpaces(var s: String);
function GetWord(s: String; N: byte): String;
procedure SetNewStr(var P: PString; s: String);
procedure SetNewStrByP(var P: PString; NewP: PString);
procedure SetNewPStr(var P, NewP: PString);
procedure DispStr(var P: PString);
function FullTrim(const Original: String): String;
function GetCurrDir: DirStr;
function GetFDir(FN: PathStr): DirStr;
function GetFName(FN: PathStr): NameStr;
function GetFExt(FN: PathStr): ExtStr;
function GetExeName: PathStr;
function GetExeDir: DirStr;
function FNamesEqual(f1, f2: PathStr): boolean;
function GetStr(P: PString): String;
function IsExeFile(FileName: PathStr): boolean;
function IsBatFile(FileName: PathStr): boolean;
function GetRandString(Len: byte): String;
function GetNumberByStr(s: String): Integer;
function GetStringByN(n: Integer): String;
function JustifyString(s: String; Width: byte): String;
function GetFirstNonSpacePos(s: String): byte;
function ContReplace(var Source: String; Old, New: String;
                     CaseSent: boolean): boolean;
function AddPath(FileName, Path: PathStr): PathStr;
procedure MakeFNRelative(var FileName: PathStr; Dir: DirStr);

implementation

function GetShortFName(FN: String; Len: byte): String;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  if Length(FN) <= Len
    then GetShortFName := FN
    else begin
      FSplit(FN, Dir, Name, Ext);
      if Length(Name + Ext) + 6 <= Len
        then GetShortFName := Copy(FN, 1, 3) + '...' +
               Copy(FN, Length(FN) - Len + 7, Length(FN))
        else if Length(Name + Ext) <= Len
               then GetShortFName := Name + Ext
             else GetShortFName := Name;
    end;
end;

function StrUpCase(s: String): String;
var
  i: byte;
begin
  for i := 1 to Length(s) do s[i] := UpCase(s[i]);
  StrUpCase := s;
end;

procedure DelFirstSpaces(var s: String);
var
  i, j, L: byte;
  tmpS: String;
begin
  i := 1; L := Length(s);
  tmpS := '';
  while (i < L) and (s[i] = ' ') do Inc(i);
  if s[i] <> ' ' then
    for j := i to L do tmpS := tmpS + s[j];
  s := tmpS;
end;

procedure DelFinalSpaces(var s: String);
begin
  while s[ord(s[0])] = ' ' do Dec(s[0]);
end;

function GetWord(s: String; N: byte): String;
var
  i, j, L: byte;
  tmpS: String;
begin
  s := FullTrim(s);
  s := s + ' ';
  L := Length(s);
  i := 1; j := 0;
  tmpS := '';
  while (i <= L) and (j < N-1) do
  begin
    while (s[i] <> ' ') and (i < L)  do Inc(i);
    while (s[i] = ' ') and (i < L) do Inc(i);
    Inc(j);
  end;
  if (j = N-1) then
    while (i <= L) and (s[i] <> ' ') do
    begin
      tmpS := tmpS + s[i];
      Inc(i);
    end;
  GetWord := tmpS;
end;

procedure SetNewStr(var P: PString; s: String);
begin
  DispStr(P);
  P := NewStr(s);
end;

procedure SetNewStrByP(var P: PString; NewP: PString);
begin
  SetNewStr(P, GetStr(NewP));
end;

procedure SetNewPStr(var P, NewP: PString);
begin
  DispStr(P);
  P := NewP;
end;

procedure DispStr(var P: PString);
begin
  if Assigned(P) then DisposeStr(P);
  P := nil;
end;

function FullTrim(const Original: String): String;
var
  S: String;
begin
  S := Original;
  while (S[0] > #0) and (S[Length(S)] = #32) do Dec(S[0]);  { trim left }
  while (S[0] > #0) and (S[1] = #32) do
  begin
    Move(S[2], S[1], Pred(Length(S)));
    Dec(S[0]);
  end;
  FullTrim := S;
end;

function GetCurrDir: DirStr;
var
  CD: DirStr;
begin
  GetDir(0, CD);
  GetCurrDir := CD
end;

function GetFDir(FN: PathStr): DirStr;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FN := FullTrim(FExpand(FN));
  FSplit(FN, Dir, Name, Ext);
  GetFDir := Dir;
end;

function GetFName(FN: PathStr): NameStr;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(FN, Dir, Name, Ext);
  GetFName := Name;
end;

function GetFExt(FN: PathStr): ExtStr;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FSplit(FN, Dir, Name, Ext);
  GetFExt := StrUpCase(Ext);
end;

function GetExeName: PathStr;
begin
  GetExeName := FExpand(ParamStr(0));
end;

function GetExeDir: DirStr;
begin
  GetExeDir := GetFDir(GetExeName);
end;

function FNamesEqual(f1, f2: PathStr): boolean;
begin
  f1 := FullTrim(StrUpCase(FExpand(f1)));
  f2 := FullTrim(StrUpCase(FExpand(f2)));
  if f1[Length(f1)] = '.'
    then Dec(f1[0]);
  if f2[Length(f2)] = '.'
    then Dec(f2[0]);
  FNamesEqual := f1 = f2;
end;

function GetStr(P: PString): String;
begin
  if Assigned(P)
    then GetStr := P^
  else GetStr := ''
end;

function IsExeFile(FileName: PathStr): boolean;
var
  Ext: ExtStr;
begin
  Ext := GetFExt(FileName);
  IsExeFile := (Ext = '.EXE') or (Ext = '.COM') or (Ext = '.BAT');
end;

function IsBatFile(FileName: PathStr): boolean;
var
  Ext: ExtStr;
begin
  Ext := GetFExt(FileName);
  IsBatFile := Ext = '.BAT';
end;

function GetRandString(Len: byte): String;
var
  i: Integer;
  s: String;
begin
  s[0] := chr(Random(Len) + 1);
  for i := 1 to Length(s) do
    s[i] := chr(Random(256));
  GetRandString := s;
end;

function GetNumberByStr(s: String): Integer;
var
  n, c: Integer;
begin
  Val(s, n, c);
  if c <> 0
    then GetNumberByStr := 0
  else GetNumberByStr := n;
end;

function GetStringByN(n: Integer): String;
var
  s: String;
begin
  Str(n, s);
  GetStringByN := s;
end;

function JustifyString(s: String; Width: byte): String;
var
  i: byte;
begin
  s := FullTrim(s);
  JustifyString := s;
  if Pos(' ', s) = 0 then Exit;
  while Length(s) < Width do
  begin
    i := Random(Length(s)) + 1;
    for i := i to Length(s) do
      if s[i] = ' ' then Break;
    if i <> Length(s) then Insert(' ', s, i);
  end;
  JustifyString := s;
end;

function GetFirstNonSpacePos(s: String): byte;
var
  i: byte;
begin
  GetFirstNonSpacePos := 0;
  for i := 1 to Length(s) do
    if s[i] <> ' '
      then begin
        GetFirstNonSpacePos := i;
        Exit;
      end;
end;

function ContReplace(var Source: String; Old, New: String;
                     CaseSent: boolean): boolean;
var
  p: byte;
begin
  ContReplace := False;
  if CaseSent
    then p := Pos(Old, Source)
  else p := Pos(StrUpCase(Old), StrUpCase(Source));
  if p = 0 then Exit;
  Source := Copy(Source, 1, p - 1) +
            New +
            Copy(Source, p + Length(Old), 255);
  ContReplace := True;
end;

function AddPath(FileName, Path: PathStr): PathStr;
begin
  if (FullTrim(Path) <> '') and (FullTrim(FileName) <> '') and
    (((Length(FileName) > 1) and (FileName[2] <> ':')
       and (FileName[1] <> '\'))
     or (Length(FileName) < 2))
  then begin
    if Path[Length(Path)] <> '\' then Path := Path + '\';
    FileName := FExpand(Path + FileName);
  end;
  AddPath := FileName;
end;

procedure MakeFNRelative(var FileName: PathStr; Dir: DirStr);
var
  p: byte;
begin
  if (FullTrim(Dir) = '') or (FullTrim(FileName) = '') then Exit;
  if Dir[Length(Dir)] <> '\' then Dir := Dir + '\';
  Dir := StrUpCase(FExpand(Dir));
  FileName := StrUpCase(FileName);
  p := Pos(Dir, FileName);
  if p <> 1 then Exit;
  FileName := Copy(FileName, Length(Dir) + 1, 255);
end;

end.

