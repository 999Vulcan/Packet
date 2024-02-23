(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль ParamDlg                                        *)
(* Диалоговые окна работы с параметрами                   *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit ParamDlg;

interface

uses
  Objects, Memory, App, Dialogs, Drivers, Views, Language, EditRes,
  PackLng, Pack_Hlp, Pack_Cmd, Hist_Ind, StrServ, StdDlg, PackText,
  Disp_Obj, Dos, FileOps, ShtState, Pack_Dlg, Items, XListBox, Dirs;

type

  PParamsDlg = ^TParamsDlg;
  TParamsDlg = object(TDialog)
    ParamIndex: TResIndex;
    IL: PInputLine;
    Mode: byte;
    Directory: PDirectory;
    StartDir: PathStr;

    constructor Init(AMode: byte; ItemTitle: String; ADirectory: PDirectory;
                     var AParamIndex: TResIndex; AStartDir: PathStr);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure FileList;
    procedure ParamList;
  end;

  PParamItem = ^TParamItem;
  TParamItem = object(TObject)

    Title: PString;
    Parameter: PString;

    constructor Init(ATitle, AParameter: String);
    destructor Done; virtual;
    function GetTitle: String;
    function GetParameter: String;
  end;

  PParamsViewer = ^TParamsViewer;
  TParamsViewer = object(TXListBox)
    Directory: PDirectory;
    ParamsCollection: PCollection;
    ParamIndex: TResIndex;

    constructor Init(var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
                     ADirectory: PDirectory; var AParamIndex: TResIndex);
    destructor Done; virtual;
    function GetText(Item: Integer; MaxLen: Integer): String; virtual;
    function GetParameters: String;
    procedure InitParams;
  end;

  PParamListDialog = ^TParamListDialog;
  TParamListDialog = object(TDialog)

    ParamIndex: TResIndex;
    ParamsViewer: PParamsViewer;
    Directory: PDirectory;

    constructor Init(ADirectory: PDirectory; var AParamIndex: TResIndex);
    destructor Done; virtual;
    procedure GetData(var Rec); virtual;
  end;

implementation

uses

  Dir_Wind;

{  Методы объекта TParamsDlg  }
constructor TParamsDlg.Init(AMode: byte; ItemTitle: String;
  ADirectory: PDirectory; var AParamIndex: TResIndex; AStartDir: PathStr);
var
  R: TRect;
  Titl: TTitleStr;
begin
  R.Assign(0, 0, 63, 8);

  Case AMode of
    wtRunWithParams: Titl := Ph(phRunWithParams);
        wtComParams: Titl := Ph(phCommonParameters);
  end;

  inherited Init(R, Titl);

  Directory := ADirectory;
  Mode := AMode;
  StartDir := AStartDir;

  ParamIndex.Name := nil;
  SetNewResIndex(ParamIndex, AParamIndex);

  if ParamsCoord.Y = -1
    then Options := Options or ofCentered
    else MoveTo(ParamsCoord.X, ParamsCoord.Y);

  Case Mode of
    wtRunWithParams: HelpCtx := hcRunWithParams;
        wtComParams: HelpCtx := hcCommonParameters;
  end;

  if Mode = wtRunWithParams
    then begin
      R.Assign(3, 1, 60, 2);
      Insert(New(PStaticText, Init(R, ^C + ItemTitle)));
    end;

  R.Assign(3, 3, 58, 4);
  New(IL, Init(R, 127));
  Insert(IL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCComStr), IL)));

  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, IL, hiComStr, cmExtParams)));

  R.Assign(2, 5, 16, 7);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(15, 0);
  Insert(New(PButton, Init(R, Ph(phCFiles), cmFileList, bfNormal)));
  R.Move(15, 0);
  Case Mode of
    wtRunWithParams: Insert(New(PButton, Init(R, Ph(phCParamList), cmParamList, bfNormal)));
        wtComParams: Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));
  end;
  R.Move(15, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  if (Mode = wtComParams) or (ParamIndex.Place = pfNowhere)
    or not Assigned(ParamIndex.Name)
      then Application^.DisableCommands([cmParamList])
      else Application^.EnableCommands([cmParamList]);

  SelectNext(False);
end;

destructor TParamsDlg.Done;
begin
  DoneResIndex(ParamIndex);
  ParamsCoord := Origin;
  inherited Done;
end;

procedure TParamsDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evCommand
    then begin
      Case Event.Command of
        cmFileList: FileList;
        cmParamList: ParamList;
        cmExtParams: if Application^.CommandEnabled(cmParamList)
                       then ParamList
                     else FileList;
      else
        Exit
      end;
      ClearEvent(Event);
    end;
end;

procedure TParamsDlg.FileList;
var
  FileName: FNameStr;
  Cmd: Word;
begin
  ChangeDirectory(StartDir);
  FileName := AllFilesMask;
  Cmd := Application^.ExecuteDialog(New(PFileDialog, Init(AllFilesMask,
                                         Ph(phSelectFile),
                                         Ph(phCName),
                                         fdOkButton + fdHelpButton,
                                         hiFileName, hcSelectFile)),
                                    @FileName);

  Message(Application, evCommand, cmRestCurrDir, nil);
  if Cmd = cmCancel then Exit;

  if Current <> PView(IL)
    then IL^.SelectAll(True);
  InsertText(IL, FileName);
  if not ShiftDown
    then Message(@Self, evCommand, cmOk, nil);
end;

procedure TParamsDlg.ParamList;
var
  Parameters: String;
begin
  if Application^.ExecuteDialog(New(PParamListDialog,
                                    Init(Directory, ParamIndex)),
                                @Parameters)
    = cmCancel then Exit;

  if Current <> PView(IL)
    then IL^.SelectAll(True);
  InsertText(IL, Parameters);
  if (not ShiftDown) and (FullTrim(Parameters) <> '')
    then Message(@Self, evCommand, cmOk, nil);
end;

{ Методы объекта TParamsViewer }
constructor TParamsViewer.Init(var Bounds: TRect; AHScrollBar,
                               AVScrollBar: PScrollBar;
                               ADirectory: PDirectory;
                               var AParamIndex: TResIndex);
begin
  inherited Init(Bounds, AHScrollBar, AVScrollBar);
  Directory := ADirectory;
  ParamIndex.Name := nil;
  SetNewResIndex(ParamIndex, AParamIndex);
  InitParams;
  AdjustHorScr;
end;

destructor TParamsViewer.Done;
begin
  DisposeObj(ParamsCollection);
  DoneResIndex(ParamIndex);
  inherited Done;
end;

procedure TParamsViewer.InitParams;
var
  Reader: PResReader;
  Line, Line1, Line2: String;
begin
  New(ParamsCollection, Init(5, 5));
  Reader := nil;
  if Assigned(Directory) and Assigned(ParamIndex.Name)
    then New(Reader, Init(Directory, GetStr(ParamIndex.Name)));
  if not Assigned(Reader) then Exit;
  while not (Reader^.EndOfRes or LowMemory) do
  begin
    Line := Reader^.ReadString;
    Line1 := FullTrim(Copy(Line, 1, Pos(ParamsDivider, Line) - 1));
    Line2 := Copy(Line, Pos(ParamsDivider, Line) + 1, 255);
    DelFinalSpaces(Line2);
    if (Line1 = '') and (Pos(ParamsDivider, Line) = 0)
      then Line1 := FullTrim(Line2);
    if Line2 <> ''
      then ParamsCollection^.Insert(New(PParamItem, Init(Line2, Line1)));
  end;
  DisposeObj(Reader);
  SetRange(ParamsCollection^.Count);
end;

function TParamsViewer.GetText(Item: Integer; MaxLen: Integer): String;
begin
  if Range = 0
    then GetText := ''
  else GetText := PParamItem(ParamsCollection^.At(Item))^.GetTitle;
end;

function TParamsViewer.GetParameters: String;
begin
  if Range = 0
    then GetParameters := ''
  else GetParameters :=
        PParamItem(ParamsCollection^.At(Focused))^.GetParameter;
end;

{  Методы объекта TParamListDialog }
constructor TParamListDialog.Init(ADirectory: PDirectory;
                                  var AParamIndex: TResIndex);
var
  R: TRect;
  HSB, VSB: PScrollBar;
begin
  R.Assign(0, 0, 56, 21);

  inherited Init(R, Ph(phParamList));

  Directory := ADirectory;
  ParamIndex.Name := nil;
  SetNewResIndex(ParamIndex, AParamIndex);

  if ParamListCoord.Y = -1
    then Options := Options or ofCentered
    else MoveTo(ParamListCoord.X, ParamListCoord.Y);

  HelpCtx := hcParamList;

  R.Assign(4, 18, 39, 19);
  New(HSB, Init(R));
  with HSB^ do Options := Options or ofPostProcess;
  R.Assign(40, 4, 41, 18);
  New(VSB, Init(R));
  with VSB^ do Options := Options or ofPostProcess;
  Insert(VSB);
  Insert(HSB);

  R.Assign(3, 4, 40, 18);
  ParamsViewer := New(PParamsViewer, Init(R, HSB, VSB, Directory, ParamIndex));
  with ParamsViewer^ do Options := Options or ofFramed;
  Insert(ParamsViewer);

  R.B.Y := R.A.Y - 1;
  Dec(R.A.Y, 2);
  Insert(New(PLabel, Init(R, Ph(phCParamList), ParamsViewer)));

  R.Assign(42, 4, 54, 6);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));

  ParamsViewer^.Select;
end;

destructor TParamListDialog.Done;
begin
  DoneResIndex(ParamIndex);
  ParamListCoord := Origin;
  inherited Done;
end;

procedure TParamListDialog.GetData(var Rec);
var
  Parameters: string absolute Rec;
begin
  Parameters := ParamsViewer^.GetParameters;
end;

{  Методы объекта TParamItem  }
constructor TParamItem.Init(ATitle, AParameter: String);
begin
  inherited Init;
  Title := NewStr(ATitle);
  Parameter := NewStr(AParameter);
end;

destructor TParamItem.Done;
begin
  DispStr(Title);
  DispStr(Parameter);
  inherited Done;
end;

function TParamItem.GetTitle: String;
begin
  GetTitle := GetStr(Title);
end;

function TParamItem.GetParameter: String;
begin
  GetParameter := GetStr(Parameter);
end;

end.
