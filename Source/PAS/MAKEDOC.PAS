(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль MakeDoc                                         *)
(* Создание текстовых документов по оглавлениям           *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995-96 by VULCAN                        *)
(*                                                        *)
(* Начат         : 12.03.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit MakeDoc;

interface

uses Objects, Views, Drivers, Dialogs, App, Dir_Wind, TextProc, Language,
     PackLng, Pack_Hlp, Pack_Dlg, Hist_Ind, StrServ, PackText, StdDlg,
     HistList, Validate, MyMsgBox, Dos, ProcMess, Disp_Obj, SubDirs, CrossRef,
     Items, FileOps, HFilter, LineColl, Editors, Pack_Cmd, Memory;

const
  DefUnderlines = '=~-';
  sTopicHeading = CRLF + '.topic';
  sHelpHeading = CRLF +
                 '; This file was created by means of Integrator "Packet"'
                 + CRLF + sTopicHeading + ' Index';

type

  TMakeDocData = record
    TargetFile    : FNameStr;
    TitPageName   : FNameStr;
    LineNums      : Word;
    Annotations   : Word;
    LeftMargin    : String[3];
    RightMargin   : String[3];
    Contents      : Word;
    OtherModes    : Word;
    LinesPerPage  : String[3];
    IndentWidth   : String[2];
    UpMargin      : String[2];
    Underlines    : String[10];
    PageBeg       : String[5];
    NumBeg        : String[10];
  end;

  PMakeDocumentDlg = ^TMakeDocumentDlg;
  TMakeDocumentDlg = object(TDialog)
    TargetIL: PInputLine;
    TitPageIL: PInputLine;

    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure FileList;
    procedure SelectInputLines;
  end;

  procedure MakeDocument(var DirBox: TDirectoryBox);

const
  LastDocName: FNameStr = '';

  DocDataInitialized: boolean = False;
var
  DocData: TMakeDocData;
  NumByLetters: boolean;
  BegLetterNum: Integer;

implementation

uses PathStk;

var
  HeadlinesNums: array[1..100] of Integer;
  CurLevel: byte;
  TempName: FNameStr;
  DirectoryBox: PDirectoryBox;
  PrfFile: Text;
  Stack: PPathStack;

const

  Protocol: PLineCollection = nil;
  OldFN4Prot: FNameStr = '';

{ --------------VVV-- Методы объекта TMakeDocumentDlg --VVV-------------- }
constructor TMakeDocumentDlg.Init;
var
  R: TRect;
  Bruce: PCluster;
  IL: PInputLine;
begin
  R.Assign(0, 0, 74, 21);
  inherited Init(R, Ph(phCollectDocument));
  HelpCtx := hcMakeDocDlg;
  Options := Options or ofCentered;

  R.Assign(3, 3, 58, 4);
  TargetIL := New(PInputLine, Init(R, 79));
  Insert(TargetIL);
  TargetIL^.HelpCtx := hcMDDocName;
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCTargetDocFile), TargetIL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, TargetIL, hiTargetDoc, cmFileList)));

  R.Assign(3, 5, 58, 6);
  TitPageIL := New(PInputLine, Init(R, 79));
  Insert(TitPageIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCTitPageFile), TitPageIL)));
  TitPageIL^.HelpCtx := hcMDTitlePage;
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, TitPageIL, hiTitPage, cmFileList)));

  R.Assign(4, 7, 23, 10);
  Bruce := New(PRadioButtons, Init(R,
    NewSItem(Ph(phCNone),
    NewSItem(Ph(phCInTop),
    NewSItem(Ph(phCInBottom),
    nil)))));
  Insert(Bruce);
  with Bruce^ do
  begin
    Options := Options or ofFramed;
    HelpCtx := hcMDPageNumbers;
  end;
  R.Move(0, -1);
  R.B.Y := R.A.Y + 1;
  R.B.X := R.A.X + CStrLen(Ph(phCPageNumbers)) + 2;
  Insert(New(PLabel, Init(R, Ph(phCPageNumbers), Bruce)));

  R.Assign(26, 7, 47, 10);
  Bruce := New(PRadioButtons, Init(R,
    NewSItem(Ph(phCNone1),
    NewSItem(Ph(phCInContents),
    NewSItem(Ph(phCInText),
    nil)))));
  Insert(Bruce);
  with Bruce^ do
  begin
    Options := Options or ofFramed;
    HelpCtx := hcMDAnnot;
  end;
  R.Move(0, -1);
  R.B.Y := R.A.Y + 1;
  R.B.X := R.A.X + CStrLen(Ph(phCAnnotations)) + 2;
  Insert(New(PLabel, Init(R, Ph(phCAnnotations), Bruce)));

  R.Assign(49, 7, 56, 8);
  IL := New(PInputLine, Init(R, 3));
  Insert(IL);
  R.Move(-1, -1);
  Inc(R.B.X, 6);
  Insert(New(PLabel, Init(R, Ph(phCLeftMargin), IL)));
  IL^.HelpCtx := hcMDMargins;
  Dec(R.B.X, 6);
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiLeftMargin)));
  IL^.SetValidator(New(PRangeValidator, Init(1, 200)));

  R.Assign(49, 9, 56, 10);
  IL := New(PInputLine, Init(R, 3));
  Insert(IL);
  R.Move(-1, -1);
  Inc(R.B.X, 6);
  Insert(New(PLabel, Init(R, Ph(phCRightMargin), IL)));
  IL^.HelpCtx := hcMDMargins;
  Dec(R.B.X, 6);
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiRightMargin)));
  IL^.SetValidator(New(PRangeValidator, Init(20, 250)));

  R.Assign(4, 12, 23, 15);
  Bruce := New(PRadioButtons, Init(R,
    NewSItem(Ph(phCAbsent),
    NewSItem(Ph(phCInBegin),
    NewSItem(Ph(phCInEnd),
    nil)))));
  Insert(Bruce);
  with Bruce^ do
  begin
    Options := Options or ofFramed;
    HelpCtx := hcMDContents;
  end;
  R.Move(0, -1);
  R.B.Y := R.A.Y + 1;
  R.B.X := R.A.X + CStrLen(Ph(phCDocContents)) + 2;
  Insert(New(PLabel, Init(R, Ph(phCDocContents), Bruce)));

  R.Assign(26, 12, 54, 19);
  Bruce := New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCNumber1stPage),
    NewSItem(Ph(phCCentreTitles),
    NewSItem(Ph(phCNumberTitles),
    NewSItem(Ph(phCMakeOnlyCont),
    NewSItem(Ph(phCMakeHelpFile),
    NewSItem(Ph(phCUseFilter),
    NewSItem(Ph(phCShowProtocol),
    nil)))))))));
  Insert(Bruce);
  with Bruce^ do
  begin
    Options := Options or ofFramed;
    HelpCtx := hcMDOtherButtons;
  end;
  R.Move(0, -1);
  R.B.Y := R.A.Y + 1;
  R.B.X := R.A.X + CStrLen(Ph(phCDocModes)) + 2;
  Insert(New(PLabel, Init(R, Ph(phCDocModes), Bruce)));

  R.Assign(57, 12, 62, 13);
  IL := New(PInputLine, Init(R, 3));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiLinesPerPage)));
  IL^.SetValidator(New(PRangeValidator, Init(0, 999)));
  IL^.HelpCtx := hcMDPageSize;
  R.Assign(56, 11, 72, 12);
  Insert(New(PLabel, Init(R, Ph(phCLinesPerPage), IL)));

  R.Assign(57, 14, 62, 15);
  IL := New(PInputLine, Init(R, 2));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiIndentWidth)));
  IL^.SetValidator(New(PRangeValidator, Init(0, 5)));
  IL^.HelpCtx := hcMDIndentWidth;
  R.Assign(56, 13, 72, 14);
  Insert(New(PLabel, Init(R, Ph(phCIndentWidth), IL)));

  R.Assign(18, 16, 22, 17);
  IL := New(PInputLine, Init(R, 2));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiUpMargin)));
  IL^.SetValidator(New(PRangeValidator, Init(0, 99)));
  IL^.HelpCtx := hcMDUpMargin;
  R.Assign(2, 16, 18, 17);
  Insert(New(PLabel, Init(R, Ph(phCUpMargin), IL)));

  R.Assign(57, 16, 64, 17);
  IL := New(PInputLine, Init(R, 10));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiUnderlines)));
  IL^.HelpCtx := hcMDUnderlines;
  R.Assign(56, 15, 72, 16);
  Insert(New(PLabel, Init(R, Ph(phCUnderlines), IL)));

  R.Assign(15, 17, 22, 18);
  IL := New(PInputLine, Init(R, 5));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiPageBeg)));
  IL^.SetValidator(New(PRangeValidator, Init(1, 32000)));
  IL^.HelpCtx := hcMDPageBeg;
  R.Assign(2, 17, 15, 18);
  Insert(New(PLabel, Init(R, Ph(phCPageBeg), IL)));

  R.Assign(15, 18, 22, 19);
  IL := New(PInputLine, Init(R, 10));
  Insert(IL);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, IL, hiNumBeg)));
  IL^.SetValidator(New(PFilterValidator, Init(['0'..'9', '.'])));
  IL^.HelpCtx := hcMDNumBeg;
  R.Assign(2, 18, 15, 19);
  Insert(New(PLabel, Init(R, Ph(phCNumBeg), IL)));

  R.Assign(62, 3, 72, 5);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));

  SelectNext(False);
end;

procedure TMakeDocumentDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if Event.What = evCommand
    then begin
      Case Event.Command of
        cmFileList: FileList;
      else
        Exit
      end;
      ClearEvent(Event);
    end;
end;

function BuildingHelp: boolean;
begin
  BuildingHelp := DocData.OtherModes and 16 <> 0;
end;

function UseFilter: boolean;
begin
  UseFilter := DocData.OtherModes and 32 <> 0;
end;

function ShowProtocol: boolean;
begin
  ShowProtocol := DocData.OtherModes and 64 <> 0;
end;

procedure TMakeDocumentDlg.FileList;
var
  FileName: FNameStr;
begin
  FileName := '';
  if Current = PView(TitPageIL)
    then FileName := TitPageIL^.Data^
  else FileName := TargetIL^.Data^;
  FileName := FullTrim(FileName);
  if FileName = '' then FileName := AllFilesMask;
  if Application^.ExecuteDialog(New(PFileDialog, Init(AllFilesMask,
                                    Ph(phSelectFile),
                                    Ph(phCName),
                                    fdOkButton + fdHelpButton,
                                    hiFileName, hcSelectFile)),
                  @FileName) = cmCancel
    then Exit;
  if Current = PView(TitPageIL)
    then InsertText(TitPageIL, FileName)
  else begin
    if Current <> PView(TargetIL)
      then TargetIL^.SelectAll(True);
    InsertText(TargetIL, FileName);
  end;
  SelectInputLines;
end;

procedure TMakeDocumentDlg.SelectInputLines;
begin
  TargetIL^.SelectAll(True);
  TitPageIL^.SelectAll(True);
end;

{ --------------^^^-- Методы объекта TMakeDocumentDlg --^^^-------------- }

procedure SolveRefs(F: PTextFile);
var
  i, Len: Integer;
  s: String;
  ErrMsg: record
    Ref: PString;
    FileName: PString;
  end;
begin
  with F^ do
  begin
    for i := 0 to Refs^.Count - 1 do
    begin
      s := Names^.GetNumber(Refs^.GetName(i));
      if FullTrim(s) = ''
      then begin
        if Assigned(MakeDoc.Protocol)
        then begin
          ErrMsg.Ref := NewStr(Refs^.GetName(i));
          ErrMsg.FileName := NewStr(Refs^.GetItemTitle(i));
          FormatStr(s, Ph(phUndefinedRef), ErrMsg);
          DispStr(ErrMsg.Ref);
          DispStr(ErrMsg.FileName);
          MakeDoc.Protocol^.Insert(NewStr(s));
        end;
        Continue;
      end;
      Seek(Refs^.GetPos(i));
      Len := Refs^.GetLength(i);
      while Length(s) < Len do s := ' ' + s;
      s := Copy(s, 1, Len);
      Write(s[1], Len);
    end;
    Seek(GetSize);
  end;
end;

procedure InitDocData(var DocData: TMakeDocData);
begin
  with DocData do
    begin
      TargetFile := HistoryStr(hiTargetDoc, 0);
      TitPageName := HistoryStr(hiTitPage, 0);
      PageBeg := HistoryStr(hiPageBeg, 0);
      if PageBeg = '' then PageBeg := '1';
      NumBeg := HistoryStr(hiNumBeg, 0);
      if NumBeg = '' then NumBeg := '1';
      UpMargin := HistoryStr(hiUpMargin, 0);
      if UpMargin = '' then UpMargin := '0';
      LeftMargin := HistoryStr(hiLeftMargin, 0);
      if LeftMargin = '' then LeftMargin := '1';
      RightMargin := HistoryStr(hiRightMargin, 0);
      if RightMargin = '' then RightMargin := '80';
      LinesPerPage := HistoryStr(hiLinesPerPage, 0);
      if LinesPerPage = '' then LinesPerPage := '0';
      IndentWidth := HistoryStr(hiIndentWidth, 0);
      if IndentWidth = '' then IndentWidth := '2';
      if HistoryStr(hiUnderlines, 0) <> ''
        then Underlines := HistoryStr(hiUnderlines, 0)
      else Underlines := DefUnderlines;
      if not DocDataInitialized
        then begin
          LineNums := 1;
          Annotations := 0;
          Contents := 1;
          OtherModes := 6;
        end;
    end;
  DocDataInitialized := True;
end;

function CheckExistance: boolean;
var
  p: Pointer;
  F: file;
  Attr: Word;
begin
  CheckExistance := False;
  Assign(F, DocData.TargetFile);
  GetFAttr(F, Attr);
  if not (DosError in [0, 2])
    then Exit;
  p := @DocData.TargetFile;
  CheckExistance := (DosError <> 0) or
                    (MessageBox(Ph(phFileExist_Overvrite), @p,
                     mfConfirmation + mfYesNoCancel, hcFileExist) = cmYes);
end;

function GetUnderlines(Level: byte; NumFlag: boolean): char;
begin
  if (Level > Length(DocData.Underlines)) or not NumFlag
    then GetUnderlines := ' '
  else GetUnderlines := DocData.Underlines[Level];
end;

function CreateTitlePage(var TargFile: TTextFile): boolean;
begin
  CreateTitlePage := True;
  TargFile.AppEnd(AddPath(DocData.TitPageName,
                  FirstDirWindow^.DirectoryBox^.GetStartDir));
  CreateTitlePage := TargFile.Status = stOk;
end;

procedure DoneProtocol;
begin
  DisposeObj(Protocol);
end;

procedure InitProtocol;
begin
  DoneProtocol;
  New(Protocol, Init(100, 100));
  if UseFilter then Protocol^.Insert(NewStr(Ph(phProtocolHeader)));
  OldFN4Prot := '';
end;

procedure WriteToProtocol(s: String; FileName: FNameStr; LineNum: LongInt);
var
  LNStr: String[10];
begin
  if not Assigned(Protocol) then Exit;
  if (Protocol^.Count >= (MaxCollectionSize - 1)) or
     (FullTrim(s)= '') or LowMemory
  then Exit;
  if OldFN4Prot <> FileName
    then Protocol^.Insert(NewStr(CRLF + Ph(phItem) + ' ' + FileName));
  Str(LineNum, LNStr);
  if LineNum <> 0
    then Protocol^.Insert(NewStr('   ' + Ph(phLine) + ' ' + LNStr + ' : ' + s))
  else Protocol^.Insert(NewStr(s));
  OldFN4Prot := FileName;
end;

function InitTarget(var Target: TTextFile; FileName: FNameStr): boolean;
var
  Margins: TMarginsRec;
  Name: String[8];
begin
  UpdateGadgets; {!}
  InitTarget := False;

  Name := StrUpCase(FullTrim(GetFName(FileName)));
  if (Name = 'CON') or (Name = 'PRN') or (Name = 'LPT1') or (Name = 'LPT2')
    then Exit;

  with DocData do
    begin
      Target.Init(FileName, GetNumberByStr(LinesPerPage),
                  stCreate, StreamBuffSize);
      Margins.Up := GetNumberByStr(UpMargin);
      Margins.Left := GetNumberByStr(LeftMargin);
      Margins.Right := GetNumberByStr(RightMargin);
      Target.SetMargins(Margins);
      Target.SetNumbersPos(TNumPos(LineNums));
      Target.SetCentreTitles(OtherModes and 2 <> 0);
      Target.SetMarkFirstPage(DocData.OtherModes and 1 <> 0);
      InitTarget := True;
    end;
end;

function GetCurItemNumStr(NumFlag: boolean): String;
var
  s: String;
  i: byte;
begin
  s := '';
  if DocData.OtherModes and 4 <> 0  { если включена нумерация названий }
    then for i := 1 to CurLevel do
      begin
        if (i = 1) and NumByLetters
          then s := s + chr(ord('A') + HeadlinesNums[1] - BegLetterNum)
                    + '.'
        else s := s + GetStringByN(HeadlinesNums[i]) + '.';
        if (HeadlinesNums[i] < 10) or (NumByLetters and (i = 1))
          then s := ' ' + s;
      end;
  if not NumFlag then
    FillChar(s[1], Length(s), ' ');
  GetCurItemNumStr := Copy(Spaces, 1,
    (CurLevel - 1) * GetNumberByStr(DocData.IndentWidth)) + s + ' ';
end;

function GetTopicReference(NumStr, TitStr, RefStr: String): String;
var
  i: byte;
  s: String;
begin
  s := '  ' + NumStr + TitStr;
  i := 1; { номер первого непробельного символа в s }
  while (i < Length(s)) and (s[i] = ' ') do Inc(i);
  Insert('{', s, i);
  DelFinalSpaces(s);
  if RefStr = '' then RefStr := #0;
  if (RefStr <> #0) and (GetFExt(RefStr) = '')
    then RefStr := RefStr + '.';
  if RefStr = #0
    then s := s + '}'
  else s := s + ':' + RefStr + '.}';
  GetTopicReference := s;
end;

function GetTopicHeading(Title: String): String;
begin
  GetTopicHeading := sTopicHeading + ' ' + FullTrim(Title);
end;

procedure SetHeadlinesNums(s: String);
var
  n, c: Integer;
  Num: String;
begin
  CurLevel := 1;
  HeadlinesNums[1] := 0;
  if s = '' then Exit;
  CurLevel := 0;
  while s <> '' do
  begin
    Inc(CurLevel);
    if s[1] = '.'
      then s := Copy(s, 2, Length(s) - 1);
    n := Pos('.', s);
    if n = 0
      then begin
        Num := s;
        s := '';
      end
    else begin
      Num := Copy(s, 1, n - 1);
      s := Copy(s, n + 1, Length(s));
    end;
    Val(Num, n, c);
    if c <> 0
      then n := 1;
    HeadlinesNums[CurLevel] := n;
  end;
  Dec(HeadlinesNums[CurLevel]);
end;

function BuildMainText(TextTarget, ContentsTarget: PTextFile): boolean;
var
  BuildContents, BuildText: boolean;
  i: Word;

procedure ProcessSubDir(SDName: String); forward;

procedure ProcessItem(P: PItem);
var
  Annot: PTextResource;
  AnnIndex: TResIndex;
  Title, CurPage, SDName: String;
  NumFlag: boolean;
begin
  UpdateGadgets; {!}

  NumFlag := P^.NeedNumber;
  if NumFlag then Inc(HeadlinesNums[CurLevel]);

  if Assigned(TextTarget) then TextTarget^.CurItemTitle := P^.GetTitle;

  if BuildingHelp and (GetItemName(P, DirectoryBox^.DirHandler) <> '')
    then begin
      writeln(PrfFile, P^.GetTitle);
      writeln(PrfFile, GetItemName(P, DirectoryBox^.DirHandler));
    end;
  Title := GetCurItemNumStr(NumFlag) + P^.GetTitle;
  if (Names^.GetNumber(GetItemName(P, DirectoryBox^.DirHandler)) = '')
    and Assigned(TextTarget)
  then Names^.Add(GetItemName(P, DirectoryBox^.DirHandler),
                  GetCurItemNumStr(NumFlag), Item)
  else if Assigned(Protocol) and Assigned(TextTarget)
          and Assigned(TextTarget^.Refs)
    then WriteToProtocol(Ph(phRedefinedName) + ' ' +
      GetItemName(P, DirectoryBox^.DirHandler), P^.GetTitle, 0);
  DirectoryBox^.GetAnnIndex(P, AnnIndex);

  NumByLetters := NumByLetters or
                  ((P^.GetItemType = itFileItem) and
                  (Pos('/NBL', StrUpCase(PFileItem(P)^.GetOwnParams)) <> 0));
  if NumByLetters and (BegLetterNum = -1)
    then begin
      BegLetterNum := HeadlinesNums[1];
      if not (NumFlag and P^.PutInContents) and (CurLevel = 1)
        then Inc(BegLetterNum);
    end;

  if not P^.PutInContents and
     (Pos('/NI', StrUpCase(PFileItem(P)^.GetOwnParams)) <> 0)
  then Exit;

  if BuildContents
    then begin
      if BuildingHelp  { строится help-файл }
        then Case P^.GetItemType of
          itSubDirItem: ContentsTarget^.WriteString('  ' +
                                GetCurItemNumStr(NumFlag) + P^.GetTitle);
            itFileItem: ContentsTarget^.WriteString(GetTopicReference(
                                      GetCurItemNumStr(NumFlag), P^.GetTitle,
                                      PFileItem(P)^.GetFileName));
        end
      else if DocData.OtherModes and 8 = 0 { строить текст }
        then begin
          if Assigned(TextTarget)
            then CurPage := TextTarget^.GetCurPage
          else CurPage := '1';
          if P^.PutInContents
            then ContentsTarget^.WriteContentsItem
                   (GetCurItemNumStr(NumFlag), P^.GetTitle, CurPage);
        end else if P^.PutInContents
                   then ContentsTarget^.WriteContentsItem
                     (GetCurItemNumStr(NumFlag), P^.GetTitle, '');

      if (DocData.Annotations = 1) { если аннотации в оглавлении }
        and Assigned(AnnIndex.Name) then
          ContentsTarget^.AppEndText(DirectoryBox^.GetDirPtr, AnnIndex.Name^);
    end;

  UpdateGadgets; {!}

  if BuildText
    then begin
      if BuildingHelp
        then TextTarget^.WriteString(GetTopicHeading(Title))
      else TextTarget^.WriteTitle(Title, GetUnderlines(CurLevel, NumFlag));

      if (DocData.Annotations = 2) { если аннотации в тексте }
        and Assigned(AnnIndex.Name) then
          TextTarget^.AppEndText(DirectoryBox^.GetDirPtr, AnnIndex.Name^);

      if P^.GetItemType = itFileItem
        then TextTarget^.AppEnd(AddPath(PFileItem(P)^.GetFileName,
                            FirstDirWindow^.DirectoryBox^.GetStartDir));
    end;

  UpdateGadgets; {!}

  DoneResIndex(AnnIndex);
  if P^.GetItemType = itSubDirItem
    then begin
      SDName := PSubDirItem(P)^.GetSubDirName;
      if Stack^.GetSDPos(SDName) = -1
        then ProcessSubDir(SDName);
    end;
end;

procedure ProcessSubDir(SDName: String);
var
  i: Word;
  SD: PSubDir;
begin
  Stack^.Insert(New(PPathItem, Init(SDName, 0)));
  SD := DirectoryBox^.GetDirPtr^.ReadSubDir(SDName);
  UpdateGadgets; {!}
  if not Assigned(SD) then Exit;
  Inc(CurLevel);
  HeadlinesNums[CurLevel] := 0;

  for i := 1 to SD^.CountItems - 1 do
    ProcessItem(SD^.GetItem(i));

  DisposeObj(SD);
  Dec(CurLevel);
  Stack^.DelTop;
end;

begin { of BuildMainText }
  BuildMainText := True;

  BuildText := Assigned(TextTarget);
  BuildContents := Assigned(ContentsTarget);
  if not (BuildContents or BuildText)
    then Exit;

  BuildMainText := False;
  New(Stack, Init(10, 10));

  for i := 0 to DirectoryBox^.CountItems - 1 do
    if DirectoryBox^.IsSelected(i)
      then ProcessItem(DirectoryBox^.GetItem(i));

  DisposeObj(Stack);
  BuildMainText := True;
end;

procedure ProcessNoContents(var TargFile: TTextFile);
begin
  if UseFilter and not BuildingHelp
    then TargFile.SetFilter(HelpFilter);
  if ShowProtocol
    then TargFile.SetProtocol(WriteToProtocol);
  InitProtocol;

  TargFile.InitRefs;
  BuildMainText(@TargFile, nil);
  SolveRefs(@TargFile);
end;

procedure ProcessOnlyContents(var TargFile: TTextFile);
begin
  BuildMainText(nil, @TargFile);
end;

procedure ProcessContentsInTop(var TargFile: TTextFile);
var
  TempFile: TTextFile;
  SizeOfCont: Word; { Размер титульного листа + оглавления в страницах }
begin
  { Подсчет длины оглавления }
  SizeOfCont := 1;
  if (GetNumberByStr(DocData.LinesPerPage) <> 0)
     and (DocData.LineNums <> 0)
  then begin
    InitTarget(TempFile, TempName);
    TempFile.PageBeg := TargFile.PageBeg;
    UpdateGadgets; {!}
    CreateTitlePage(TempFile);
    BuildMainText(nil, @TempFile);
    UpdateGadgets; {!}
    SizeOfCont := TempFile.CurPage;
    TempFile.Done;
    SetHeadlinesNums(DocData.NumBeg);
  end;

  NumByLetters := False;
  BegLetterNum := -1;

  { Формирование документа }
  InitTarget(TempFile, TempName);
  TempFile.InitRefs;

  if UseFilter and not BuildingHelp
    then TempFile.SetFilter(HelpFilter);
  if ShowProtocol
    then TempFile.SetProtocol(WriteToProtocol);
  InitProtocol;

  TempFile.CurPage := SizeOfCont;
  TempFile.PageBeg := TargFile.PageBeg;
  if DocData.LineNums = ord(npBottom)
    then Inc(TempFile.CurPage);

  BuildMainText(@TempFile, @TargFile);
  SolveRefs(@TempFile);
  TempFile.Done;

  { Отделение оглавления от текста.    }
  { Если страницы нумеруются сверху,   }
  { то основной текст уже содержит #12 }
  if (DocData.LineNums <> ord(npTop))
    and (GetNumberByStr(DocData.LinesPerPage) <> 0)
  then TargFile.WriteString(^L);

  UpdateGadgets; {!}
  TargFile.SetPageSize(0);
  TargFile.AppEnd(TempName);
end;

procedure MakeHelpFile(var TargFile: TTextFile);
begin
  TargFile.LinesPerPage := 0;
  TargFile.WriteString(sHelpHeading);
  BuildMainText(nil, @TargFile);
end;

procedure ProcessContentsInBottom(var TargFile: TTextFile);
var
  TempFile: TTextFile;
begin
  InitTarget(TempFile, TempName);
  TempFile.SetPageSize(0);

  if GetNumberByStr(DocData.LinesPerPage) <> 0
    then TempFile.WriteString(^L);

  if UseFilter and not BuildingHelp
    then TargFile.SetFilter(HelpFilter);
  if ShowProtocol
    then TargFile.SetProtocol(WriteToProtocol);
  InitProtocol;

  TargFile.InitRefs;
  BuildMainText(@TargFile, @TempFile);
  SolveRefs(@TargFile);
  TempFile.Done;
  TargFile.AppEnd(TempName);
end;

procedure DoShowProtocol;
var
  OldCur: PView;
  Editor: PEditor;
  i: Word;
  s: String;
  Mess: PProcMess;
begin
  if not Assigned(Protocol) or (Protocol^.Count = 0)
    then Exit;
  OldCur := Desktop^.Current;
  Message(Application, evCommand, cmNewFile, nil);
  if OldCur = Desktop^.Current
    then Exit;
  Editor := PEditWindow(Desktop^.Current)^.Editor;
  PEditWindow(Desktop^.Current)^.Lock;
  Editor^.SetState(sfCursorVis, False);
  New(Mess, Init(Ph(phCreatingProtocol) + ts3p));
  for i := 0 to Protocol^.Count - 1 do
  begin
    s := Protocol^.AtStr(i) + CRLF;
    if not Editor^.InsertText(@s[1], Length(s), False)
      then Break;
  end;
  s := CRLF;
  Editor^.InsertText(@s[1], Length(s), False);
  Editor^.Modified := False;
  Editor^.SetCurPtr(0, 0);
  Dec(Editor^.BufLen, 2);
  Editor^.SetState(sfCursorVis, True);
  PEditWindow(Desktop^.Current)^.Unlock;
  DisposeObj(Mess);
end;

function DoMakeDocument: boolean;
var
  Target: TTextFile;
begin
  DoMakeDocument := False;
  if BuildingHelp then DocData.LinesPerPage := '0';
  if not InitTarget(Target, DocData.TargetFile) then Exit;
  SetHeadlinesNums(DocData.NumBeg);
  Target.PageBeg := GetNumberByStr(DocData.PageBeg);

  with DocData do
  begin
    TempName := GetFDir(TargetFile) + GetFName(TargetFile);
    if GetFExt(TargetFile) <> '.$$$'
      then TempName := TempName + '.$$$'
    else TempName := TempName + '.$_$'
  end;

  if Target.Status <> stOk
    then begin
      Target.Done;
      DoneProtocol;
      Exit;
    end;

  if not CreateTitlePage(Target)
    then begin
      Target.Done;
      DoneProtocol;
      Exit;
    end;

  NumByLetters := False;
  BegLetterNum := -1;

  if BuildingHelp { режим построения help-файла }
    then MakeHelpFile(Target)
  else if DocData.OtherModes and 8 = 0 { нужно собирать текст }
  then Case DocData.Contents of
{None}    0: ProcessNoContents(Target);
{Top}     1: ProcessContentsInTop(Target);
{Bottom}  2: ProcessContentsInBottom(Target);
  end else ProcessOnlyContents(Target);

  DoMakeDocument := Target.Status = stOk;
  Target.Done;
  EraseFile(TempName);
  if ShowProtocol
    then DoShowProtocol;
  DoneProtocol;
end;

procedure InitPrfFile;
begin
  Assign(PrfFile, GetFDir(DocData.TargetFile) +
            GetFName(DocData.TargetFile) + '.prf');
  Rewrite(PrfFile);
end;

procedure MakeDocument(var DirBox: TDirectoryBox);
var
  P: PProcMess;
  Successful: boolean;
begin
  if FirstDirWindow = nil
    then Exit;

  Message(Application, evCommand, cmRemind, nil);

  InitDocData(DocData);

  if Application^.ExecuteDialog(New(PMakeDocumentDlg, Init), @DocData)
     = cmCancel
  then Exit;

  if DocData.TitPageName = ''
    then HistoryAdd(hiTitPage, ' ');
  if DocData.NumBeg = ''
    then HistoryAdd(hiNumBeg, '1');
  if DocData.Underlines = ''
    then HistoryAdd(hiUnderlines, ' ');

  DocData.TargetFile := AddPath(DocData.TargetFile,
                  FirstDirWindow^.DirectoryBox^.GetStartDir);
  if not CheckExistance then Exit;

  New(P, Init(Ph(phCollectingDoc) + ' "' + StrUpCase(DocData.TargetFile)
              + '"...'));

  if DirBox.DirHandler^.CalcCountSelected = 0
    then DirBox.GetSubDir^.SelectItem(DirBox.Focused);


  DirectoryBox := @DirBox;

  New(Names, Init(10, 10));
  if BuildingHelp then InitPrfFile;
  Successful := DoMakeDocument;
  if BuildingHelp then Close(PrfFile);
  DisposeObj(Names);

  DisposeObj(P);
  DirBox.UnselectAll;
  if not Successful
    then MessageBox(^M^C + Ph(phErrorCreateDoc), nil, mfError + mfOkButton,
                    hcErrorCreateDoc)
  else LastDocName := DocData.TargetFile;
  Message(Application, evCommand, cmCheckDocSize, @DocData.TargetFile);
end;

end.
