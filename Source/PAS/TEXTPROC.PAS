(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль TextProc                                        *)
(* Объекты работы с текстовыми файлами                    *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.03.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit TextProc;

interface

uses Objects, Views, Drivers, App, Disp_Obj, PackText, StrServ, Pack_Cmd,
     CrossRef, EditRes, Dirs, Language, PackLng;

type

  TFilter = function (S: string; var Protocol: string): string;
  TProtocol = procedure (s: String; FileName: FNameStr; LineNum: LongInt);

  TMarginsRec = record
                  Up, Left, Right: byte;
                end;

  TNumPos = (npNone, npTop, npBottom);

  PTextFile = ^TTextFile;
  TTextFile = object(TBufStream)
    CurItemTitle: String;
    FileName: FNameStr;

    CurLine: LongInt;
    CurLineOnPage: Word;
    PageBeg: Word;
    CurPage: Word; { Номер страницы (относительно PageBeg) }
    CurDrawing: Word;

    LinesPerPage: Word;
    Margins: TMarginsRec;
    NumbersPos: TNumPos;
    MarkFirstPage: boolean;
    CentreTitles: boolean;
    EndOfFile: boolean;

    ProcessDrawing: boolean;

    Filter: TFilter;
    Protocol: TProtocol;
    Refs: PRefsColl;

    constructor Init(AFileName: FNameStr; ALinesPerPage, Mode, Size: Word);
    destructor  Done; virtual;
    procedure   InitRefs;
    procedure   SetMargins(var AMargins: TMarginsRec);
    procedure   SetCurPage(Page: Word);
    procedure   SetNumbersPos(ANumbersPos: TNumPos);
    procedure   SetMarkFirstPage(AMark: boolean);
    procedure   SetCentreTitles(ACentreTitles: boolean);
    procedure   SetPageSize(Size: Word);
    function    GetCurPage: String;
    procedure   AppEnd(AFileName: FNameStr);
    procedure   AppEndText(ADir: PDirectory; Name: String);
    function    ReadString: String;
    procedure   WriteString(s: String);
    procedure   NewPage(Conditional: boolean);
    procedure   WriteContentsItem(Num, Item, PageNum: String);
    procedure   WriteTitle(Title: String; Underline: char);
    procedure   SetFilter(AFilter: TFilter);
    procedure   SetProtocol(AProtocol: TProtocol);
    function    GetCurDrawingNum: String;
  private
    procedure   NewLine;
    function    CentrePos: byte;
    function    BuildLineNumStr: String;
    function    BuildUpMargin: String;
    procedure   DoFilter(var s: String);
    function    CheckDrawing(s: String; SourceFile: PTextFile): boolean;
    procedure   CheckReference(var s: String);
  end;

procedure UpdateGadgets;

var
  Names: PNamesColl;

implementation

const
  PageRest = 7;

  FileName4Prot: FNameStr = '';
  LineNum4Prot: LongInt = 0;

  sDrawBeg = '.DB';
  sDrawEnd = '.DE';

constructor TTextFile.Init(AFileName: FNameStr;
                           ALinesPerPage, Mode, Size: Word);
begin
  inherited Init(AFileName, Mode, Size);

  Refs := nil;
  CurItemTitle := '';
  Filter := nil;
  Protocol := nil;

  FileName := AFileName;
  LinesPerPage := ALinesPerPage;
  if LinesPerPage < 10 then LinesPerPage := 0;
  CurLineOnPage := 0;
  CurLine := 1;
  PageBeg := 1;
  CurPage := 1;
  Margins.Up := 0;
  Margins.Left := 2;
  Margins.Right := 78;
  CurDrawing := 0;
  NumbersPos := npBottom;
  MarkFirstPage := False;
  EndOfFile := False;
  ProcessDrawing := False;
end;

destructor TTextFile.Done;
var
  Buf: String;
begin
  EndOfFile := True;
  if (NumbersPos = npBottom) and (CurLineOnPage <> 0)
    then NewPage(False);
  if (NumbersPos <> npBottom) and (LinesPerPage <> 0)
    then begin
      Buf := ^L;
      Write(Buf[1], 1);
    end;
  DisposeObj(Refs);
  inherited Done;
end;

procedure TTextFile.InitRefs;
begin
  DisposeObj(Refs);
  New(Refs, Init(10, 10));
end;

function TTextFile.GetCurDrawingNum: String;
var
  s: String;
begin
  Str(CurDrawing, s);
  GetCurDrawingNum := s;
end;

procedure TTextFile.SetMargins(var AMargins: TMarginsRec);
begin
  if AMargins.Right - AMargins.Left > 20
    then Margins := AMargins;
end;

procedure TTextFile.SetMarkFirstPage(AMark: boolean);
begin
  MarkFirstPage := AMark;
end;

procedure TTextFile.SetCentreTitles(ACentreTitles: boolean);
begin
  CentreTitles := ACentreTitles;
end;

procedure TTextFile.SetPageSize(Size: Word);
begin
  if Size < 10
    then LinesPerPage := 0
  else LinesPerPage := Size;
end;

procedure TTextFile.SetFilter(AFilter: TFilter);
begin
  Filter := AFilter;
end;

procedure TTextFile.SetProtocol(AProtocol: TProtocol);
begin
  Protocol := AProtocol;
end;

function TTextFile.CentrePos: byte;
begin
  CentrePos := (Margins.Right + Margins.Left) div 2;
end;

procedure TTextFile.SetCurPage(Page: Word);
begin
  CurPage := Page;
end;

procedure TTextFile.SetNumbersPos(ANumbersPos: TNumPos);
begin
  NumbersPos := ANumbersPos;
end;

function TTextFile.CheckDrawing(s: String; SourceFile: PTextFile): boolean;
var
  CurPosInStream: Longint;
  DrawingLength: Integer;
  Wrd: String;
  OutStr: String;
begin
  CheckDrawing := False;
  DelFinalSpaces(s);
  Wrd := StrUpCase(GetWord(s, 1));

  if (Wrd <> sDrawBeg) and (Wrd <> sDrawEnd) then Exit;
  CheckDrawing := True;

  OutStr := GetWord(s, 2);
  if (Wrd = sDrawBeg) and (OutStr <> '-') and (OutStr <> '_')
     and Assigned(Refs)
    then begin
      Inc(CurDrawing);
      if Names^.GetNumber(OutStr) = ''
        then Names^.Add(OutStr, GetCurDrawingNum, Drawing)
      else if Assigned(Protocol)
        then Protocol(Ph(phRedefinedName) + ' ' + OutStr,
                      SourceFile^.FileName, 0);
    end;

  s := FullTrim(s);
  if Wrd = sDrawBeg then s := Copy(s, Pos(' ', s) + 1, 255);
  OutStr := Copy(s, Pos(' ', s + ' ') + 1, 255);

  if Wrd = sDrawEnd
    then begin
      if FullTrim(OutStr) <> '' then WriteString(OutStr);
      ProcessDrawing := False;
      Exit;
    end;
  ProcessDrawing := True;

  CurPosInStream := SourceFile^.GetPos;
  DrawingLength := 0;
  while (SourceFile^.Status = stOk) and (Wrd <> sDrawEnd) do
  begin
    s := SourceFile^.ReadString;
    DelFinalSpaces(s);
    Wrd := StrUpCase(GetWord(s, 1));
    Inc(DrawingLength);
  end;
  SourceFile^.Reset;
  SourceFile^.Seek(CurPosInStream);
  if ((CurLineOnPage + DrawingLength > LinesPerPage + 1)
      and (NumbersPos <> npBottom))
    or ((CurLineOnPage + DrawingLength > LinesPerPage - 1)
      and (NumbersPos = npBottom))
  then NewPage(False);
  if FullTrim(OutStr) <> '' then WriteString(OutStr);
end;

procedure TTextFile.AppEnd(AFileName: FNameStr);
var
  SourceFile: PTextFile;
  s: String;
begin
  if IsExeFile(AFileName) then Exit;
  New(SourceFile, Init(AFileName, 0, stOpenRead, StreamBuffSize));
  if not Assigned(SourceFile) then Exit;

  if (LinesPerPage = 0) and not Assigned(Filter) and not Assigned(Refs)
    then CopyFrom(SourceFile^, SourceFile^.GetSize)
  else begin
    while True do
      begin
        UpdateGadgets; {!}
        s := SourceFile^.ReadString;
        if (SourceFile^.Status <> stOk) and (s = '')
          then Break;
        if not CheckDrawing(s, SourceFile)
          then WriteString(s);
      end;
  end;
  Reset;

  ProcessDrawing := False;
  DisposeObj(SourceFile);
end;

procedure TTextFile.AppEndText(ADir: PDirectory; Name: String);
var
  StrNum: LongInt;
  Line: String;
  Reader: PResReader;
begin
  New(Reader, Init(ADir, Name));

  StrNum := 1;
  while not Reader^.EndOfRes do
  begin
    Line := Reader^.ReadString;
    if (StrNum <> 1) or (StrUpCase(GetWord(Line, 1)) <> ItemNameStr)
      then WriteString(Line);
    Inc(StrNum);
  end;

  DisposeObj(Reader);
  UpdateGadgets; {!}
end;

function TTextFile.GetCurPage: String;
var
  Correction: byte;
begin
  Correction := 0;
  if (LinesPerPage - CurLineOnPage - 1 < PageRest) or
       (((CurLineOnPage = 0) or (CurLineOnPage = LinesPerPage))
        and (NumbersPos = npTop))
    then Correction := 1;
{
  if (LinesPerPage - CurLineOnPage - 1 < PageRest) or
    ((CurLineOnPage = 0) and (NumbersPos = npTop))
  then Correction := 1;
}
  if LinesPerPage = 0
    then GetCurPage := ''
  else Case NumbersPos of
           npTop: GetCurPage := GetStringByN(CurPage - 1 + Correction + PageBeg - 1);
        npBottom: GetCurPage := GetStringByN(CurPage + Correction + PageBeg - 1);
          npNone: GetCurPage := '';
       end;
end;

function TTextFile.ReadString: String;
var
  ch: char;
  s: String;
begin
  ReadString := '';
  s := '';
  ch := #0;
  while Length(s) < 250 do
    begin
      Read(ch, 1);
      if Status <> stOk
        then begin
          if FullTrim(s) <> ''
            then ReadString := s;
          Exit;
        end;
      if ch <> #13
        then s := s + ch
      else begin
        Read(ch, 1);
        Break;
      end;
      if ch = ^L
        then Break;
    end;
  ReadString := s;
  FileName4Prot := FileName;
  LineNum4Prot := CurLine;
  Inc(CurLine);
end;

procedure TTextFile.DoFilter(var s: String);
var
  ProtStr: String;
begin
  if not Assigned(Filter) then Exit;
  s := Filter(s, ProtStr);
  if Assigned(Protocol)
    then Protocol(ProtStr, FileName4Prot, LineNum4Prot);
end;

procedure TTextFile.CheckReference(var s: String);
var
  Name: String;
  Position: LongInt;
  pb, pe, Len, i: byte;
begin
  if (s[1] = ';') and Assigned(Refs)
    then begin
      s := Copy(s, 2, 255);
      Exit;
    end;
  if not Assigned(Refs) then Exit;
  pb := Pos('[', s);
  pe := Pos(']:', s);
  if (pe = 0) or (pe = 0) then Exit;
  while pb <> 0 do
  begin
    pe := Pos(']:', s);
    if pe < pb then Exit;
    s[pb] := ' ';
    s[pe] := ' ';
    s[pe + 1] := ' ';
    Name := StrUpCase(GetWord(Copy(s, pe + 2, 255), 1));
    Delete(s, pe + 1, Length(Name) + 2);
    Refs^.Add(GetPos + pb - 1, Name, pe - pb + 1, CurItemTitle);
    pb := Pos('[', s);
  end;
end;

procedure TTextFile.WriteString(s: String);
var
  Buf: String;
  AskNewPage: boolean;
begin
  DoFilter(s);
  if s = #0 then Exit;

  NewPage(True);
  AskNewPage := s[Length(s)] = ^L;
  if AskNewPage and (LinesPerPage <> 0)
    then Dec(s[0]);

  CheckReference(s);

  Buf := s + CRLF;
  Write(Buf[1], Length(Buf));
  if LinesPerPage = 0 then Exit;
  Inc(CurLineOnPage);
  if Pos(CRLF, s) <> 0
    then Inc(CurLineOnPage);
  if AskNewPage
    then NewPage(False)
  else if NumbersPos = npBottom
         then NewPage(True);
end;

procedure TTextFile.NewPage(Conditional: boolean);
var
  Buf: String;
begin
  if (LinesPerPage = 0) or (ProcessDrawing and Conditional) then Exit;

  if (NumbersPos = npTop) and Conditional
    and (CurLineOnPage < LinesPerPage) and (CurLineOnPage <> 0)
  then Exit;

  if (NumbersPos = npBottom) and (CurLineOnPage + 2 < LinesPerPage)
    and Conditional
  then begin
    if (CurLineOnPage = 0) and (CurPage = 1)
      then begin
        Buf := BuildUpMargin;
        Write(Buf[1], Length(Buf));
      end;
    Exit;
  end;

  Buf := '';

  if (NumbersPos = npNone) and
     ((CurLineOnPage >= LinesPerPage) or not Conditional)
    then begin
      Buf := ^L + BuildUpMargin;
      Write(Buf[1], Length(Buf));
      Inc(CurPage);
      CurLineOnPage := 0;
      Exit;
    end;

  if NumbersPos = npBottom
    then begin
      while CurLineOnPage + 1 < LinesPerPage do
        begin
          Inc(CurLineOnPage);
          NewLine;
        end;
      if (CurPage <> 1) or MarkFirstPage
        then Buf := BuildLineNumStr
      else Buf := '';
      Buf := Buf + CRLF + ^L;
      if not EndOfFile
        then Buf := Buf + BuildUpMargin;
      Write(Buf[1], Length(Buf));
      CurLineOnPage := 0;
      Inc(CurPage);
      Exit;
    end;

  if NumbersPos = npTop
    then begin
                           { не первая страница }
      if CurPage <> 1
        then Buf := ^L + BuildUpMargin + BuildLineNumStr + CRLF + CRLF
                           { первая страница }
      else if MarkFirstPage
        then Buf := BuildUpMargin + BuildLineNumStr + CRLF + CRLF
      else if not Conditional
        then Buf := ^L + BuildUpMargin
      else Buf := BuildUpMargin + CRLF + CRLF;

      Write(Buf[1], Length(Buf));
      Inc(CurPage);
      if Buf <> '' then CurLineOnPage := 2;
    end;
end;

function TTextFile.BuildLineNumStr: String;
var
  s: String;
begin
  Str(CurPage + PageBeg - 1, s);
  s := '-' + s + '-';
  s := Copy(Spaces, 1, CentrePos - Length(s) div 2 - Length(s) mod 2) + s;
  BuildLineNumStr := s;
end;

function TTextFile.BuildUpMargin: String;
var
  i: byte;
  s: String;
begin
  s := '';
  for i := 1 to Margins.Up do
    s := s + CRLF;
  BuildUpMargin := s;
end;

procedure TTextFile.NewLine;
const
  Line: String[2] = CRLF;
begin
  Write(Line[1], 2);
end;

procedure TTextFile.WriteContentsItem(Num, Item, PageNum: String);
const
  DecSize = 5;
var
  Size, i, j, LenOffs: byte;
  s, NextWord, Str2Print, Points: String;
begin
  with Margins do
    Size := Right - Length(Num) - Left;
  LenOffs := Length(Num) + Margins.Left - 1;

  i := 1;
  NextWord := GetWord(Item, 1);
  repeat
    s := '';
    repeat
      s := s + NextWord + ' ';
      Inc(i);
      NextWord := GetWord(Item, i);
    until (Length(s + NextWord) > Size - DecSize) or (NextWord = '');

    Str2Print[0] := chr(Margins.Left - 1);
    for j := 1 to Length(Str2Print) do Str2Print[j] := ' ';
    if NextWord <> '' then s := JustifyString(s, Size - DecSize);
    Str2Print := Str2Print + Num + s;
    if NextWord <> ''
      then WriteString(Str2Print);
    for j := 1 to Length(Num) do Num[j] := ' ';
  until NextWord = '';

  if PageNum = ''
    then Points := ''
  else begin
    if Size > Length(s) + Length(PageNum)
      then Points[0] := chr(Size - Length(s) - Length(PageNum))
    else Points[0] := chr(2);
    for j := 1 to Length(Points) do
      Points[j] := '.';
  end;

  WriteString(Str2Print + Points + ' ' + PageNum);
end;

procedure TTextFile.WriteTitle(Title: String; Underline: char);
var
  Size, i, j: byte;
  NextWord, s, Str2Print: String;
begin
  WriteString('');
  with Margins do Size := Right - Left + 1;

  i := 1;
  NextWord := GetWord(Title, 1);
  repeat
    s := '';
    repeat
      s := s + NextWord + ' ';
      Inc(i);
      NextWord := GetWord(Title, i);
    until (Length(s + NextWord) >= Size - 1) or (NextWord = '');

    Str2Print[0] := chr(Margins.Left - 1);
    for j := 1 to Length(Str2Print) do Str2Print[j] := ' ';

    s := FullTrim(s);

    if CentreTitles
      then Str2Print :=
        Copy(Spaces, 1, CentrePos - Length(s) div 2 - 1) + s
    else if NextWord <> '' { если не последняя строка }
           then Str2Print := Str2Print + JustifyString(s, Size)
         else Str2Print := Str2Print + s;

    if LinesPerPage - CurLineOnPage < PageRest
      then NewPage(False);

    WriteString(Str2Print);
    DelFinalSpaces(Str2Print);
    for j := GetFirstNonSpacePos(Str2Print) to Length(Str2Print)
      do Str2Print[j] := Underline;
    WriteString(Str2Print);
  until NextWord = '';
{
  WriteString('');
}
end;

procedure UpdateGadgets;
begin
  Message(Application, evCommand, cmUpdateGadgets, nil);
end;

end.
