(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль AddItDlg                                        *)
(* Диалоговое окно добавления/модификации пункта          *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit AddItDlg;

interface

uses
  Objects, Memory, App, BaseApp, Dialogs, Drivers, Views, Language,
  PackLng, PackText, Pack_Hlp, Pack_Cmd, Hist_Ind, SubDirs, Items, ShtState,
{$ifdef ForPacket}
  PackConf,
{$endif}
  StrServ, StdDlg, Disp_Obj, MyMsgBox, Dos, FileOps, Pack_Dlg;

type

  PAddFileItemsDlg = ^TAddFileItemsDlg;
  TAddFileItemsDlg = object(TDialog)
    constructor Init(AMode: byte; Position: Integer);
    destructor Done; virtual;

    private

    Mode: byte;

    InsPosition: Integer;
    CountInserted: LongInt;

    TitleIL: PInputLine;
    FileIL: PInputLine;
    ParametersIL: PInputLine;
    DiskIL: PInputLine;
    StartDirIL:  PInputLine;
    AttributesCB: PCheckBoxes;
    InheritanceCB: PCheckBoxes;
    Indicator: PParamText;

    FileItem: PFileItem;

    procedure HandleEvent(var Event: TEvent); virtual;
    function CreateFileName: FNameStr;
    function CreateFileItem: PFileItem;
    procedure AddItem;
    procedure FillFileItem;
    procedure ReplaceItem;
    procedure SelectInputLines;
    procedure GetFileItem;
    procedure FileList;
    procedure DirList;
    function FileFound: boolean;
    function EmptyTitle: boolean;
    procedure SetItemTitle(var Titl: String; FileName: PathStr);
  end;

implementation

uses

  Dirs, Dir_Wind;

{ Методы объекта TAddFileItemsDlg }
constructor TAddFileItemsDlg.Init(AMode: byte; Position: Integer);
var
  R: TRect;
  IndStr: String;
  Tit: TTitleStr;
begin
  R.Assign(0, 0, 69, 23);
  Case AMode of
        wtAdd: Tit := Ph(phAddFileItems);
    wtReplace: Tit := Ph(phReplFileItem);
  end;

  inherited Init(R, Tit);

  Mode := AMode;

  if AddFileItemCoord.Y = -1
    then Options := Options or ofCentered
    else MoveTo(AddFileItemCoord.X, AddFileItemCoord.Y);

  Case Mode of
        wtAdd: begin
                 InsPosition := Position;
                 HelpCtx := hcAddFileItems;
               end;
    wtReplace: begin
                 InsPosition := PDirWindow(
                   Desktop^.Current)^.GetDirHandler^.GetFirstSelected;
                 HelpCtx := hcModifyFileItems;
               end;
  end;

  CountInserted := 0;

  R.Assign(3, 3, 48, 4);
  TitleIL := New(PInputLine, Init(R, 250));
  Insert(TitleIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCItemTitle), TitleIL)));
  TitleIL^.HelpCtx := hcItemTitleIL;
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, TitleIL, hiTitle)));

  R.Assign(3, 6, 48, 7);
  FileIL := New(PInputLine, Init(R, 79));
  Insert(FileIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCFileName), FileIL)));
  FileIL^.HelpCtx := hcItemFileNameIL;
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, FileIL, hiFileName, cmFileList)));

  R.Assign(3, 9, 48, 10);
  ParametersIL := New(PInputLine, Init(R, 127));
  Insert(ParametersIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCParameters), ParametersIL)));
  ParametersIL^.HelpCtx := hcItemParamsIL;
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, ParametersIL, hiParameters, cmFileList)));

  R.Assign(3, 12, 48, 13);
  StartDirIL := New(PInputLine, Init(R, 67));
  Insert(StartDirIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCStartDir), StartDirIL)));
  StartDirIL^.HelpCtx := hcItemStartDirIL;
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PCombHistory, Init(R, StartDirIL, hiStartDir, cmDirList)));

  R.Assign(4, 14, 45, 22);
  New(AttributesCB, Init(R,
    NewSItem(Ph(phCSearchBeforeProcess),
    NewSItem(Ph(phCNotRunWithoutParams),
    NewSItem(Ph(phCRestCD),
    NewSItem(Ph(phCDelayScreen),
    NewSItem(Ph(phCClearKbd),
    NewSItem(Ph(phCAutoSaveEdFiles),
    NewSItem(Ph(phCDontNumberItem),
    NewSItem(Ph(phCDontPutInContents),
    nil))))))))));
  Insert(AttributesCB);
  with AttributesCB^ do begin
    Options := Options or ofFramed;
    Value := iaRestCD + iaSearchBeforeProcess;
    HelpCtx := hcSearchBeforeProcess;
  end;
  R.Move(0, -1);
  R.B.Y := R.A.Y + 1;
  R.B.X := R.A.X + Length(Ph(phCAttributes));
  Insert(New(PLabel, Init(R, Ph(phCAttributes), AttributesCB)));

  GetExtent(R);
  Case Mode of
        wtAdd: IndStr := Ph(phAdded);
    wtReplace: IndStr := Ph(phReplaced);
  end;
  IndStr := ' ' + IndStr + ': %3d ';
  R.A.Y := R.B.Y - 1;
  R.B.X := R.B.X - 5;
  R.A.X := R.B.X - Length(IndStr);
  New(Indicator, Init(R, IndStr, 1));
  Indicator^.ParamList := @CountInserted;
  Insert(Indicator);

  R.Assign(52, 3, 67, 5);
  Case Mode of
        wtAdd: Insert(New(PButton, Init(R, Ph(phCAdd), cmAdd, bfDefault)));
    wtReplace: Insert(New(PButton, Init(R, Ph(phCReplace), cmRepl, bfDefault)));
  end;
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phCFiles), cmFileList, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phCDirs), cmDirList, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phEnd), cmCancel, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));

  SelectNext(False);
  FileItem := nil;
  if Mode = wtReplace then GetFileItem;
  if InsPosition = -1
    then begin
      Done;
      Fail;
    end;
end;

destructor TAddFileItemsDlg.Done;
begin
  AddFileItemCoord := Origin;
  Message(Application, evCommand, cmRestCurrDir, nil);
  inherited Done;
end;

procedure TAddFileItemsDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evCommand
    then begin
      Case Event.Command of
        cmAdd: AddItem;
        cmRepl: ReplaceItem;
        cmFileList: FileList;
        cmDirList: DirList;
      else
        Exit
      end;
      ClearEvent(Event);
    end;
end;

procedure TAddFileItemsDlg.FileList;
var
  FileName: FNameStr;
begin
  FileName := '';
  if Current = PView(ParametersIL)
    then FileName := ParametersIL^.Data^
  else FileName := FileIL^.Data^;
  FileName := FullTrim(FileName);
  if FileName = '' then FileName := AllFilesMask;
  if BaseApplication^.AppExecuteDialog(New(PFileDialog, Init(AllFilesMask,
                                         Ph(phSelectFile),
                                         Ph(phCName),
                                         fdOkButton + fdHelpButton,
                                         hiFileName, hcSelectFile)),
                    @FileName) = cmCancel
    then Exit;

  if (PDirWindow(Desktop^.Current)^.DirectoryBox^.GetStartDir <> '')
      and not ShiftDown
    then MakeFNRelative(FileName,
           PDirWindow(Desktop^.Current)^.DirectoryBox^.GetStartDir);
  if Current = PView(ParametersIL)
    then InsertText(ParametersIL, FileName)
  else begin
    if Current <> PView(FileIL)
      then FileIL^.SelectAll(True);
    InsertText(FileIL, FileName);
  end;
  ChangeDirectory(GetFDir(FileName));
  SelectInputLines;
end;

procedure TAddFileItemsDlg.DirList;
var
  Dir: DirStr;
begin
  if BaseApplication^.AppExecuteDialog(New(PChDirDialog,
                                          Init(Ph(phSelectStartDir),
                                          cdNormal + cdHelpButton,
                                          hiStartDir, hcSelectStartDir)),
                   @Dir) <> cmOk
    then Exit;
  if Current <> PView(StartDirIL)
    then StartDirIL^.SelectAll(True);
  InsertText(StartDirIL, Dir);
  SelectInputLines;
end;

procedure TAddFileItemsDlg.GetFileItem;
var
  Data: TFileItemData;
begin
  InsPosition :=
    PDirWindow(Desktop^.Current)^.GetDirHandler^.GetFirstSelItem(itFileItem);
  if InsPosition = -1
    then begin
      Message(Owner, evCommand, cmClose, nil);
      Exit;
    end;

  FileItem := PFileItem(
       PDirWindow(Desktop^.Current)^.GetDirHandler^.GetItemPtr(InsPosition));
  FileItem^.GetData(Data);

  TitleIL^.Data^ := GetStr(Data.Title);
  FileIL^.Data^ := GetStr(Data.FileName);
  ParametersIL^.Data^ := GetStr(Data.Parameters.Str);
  StartDirIL^.Data^ := GetStr(Data.StartDir.Str);
  AttributesCB^.Value := Data.Attributes;

{
  Parameters.InhFlag:= False;
  StartDir.InhFlag := False;
  DiskLabel := '';
  Inheritance := 0;

  AnnIndex.Place := pfNowhere;
  AnnIndex.Name := nil;
  AnnIndex.InhFlag := False;

  PIFIndex.Place := pfNowhere;
  PIFIndex.Name := nil;
  PIFIndex.InhFlag := False;
}
  Data.Done;
end;

{ Используется при модификации пункта }
procedure TAddFileItemsDlg.FillFileItem;
var
  Data: TFileItemData;
  s: String;
begin
  FileItem^.GetData(Data);

  SetNewStrByP(Data.Title, TitleIL^.Data);
  if FullTrim(GetStr(TitleIL^.Data)) = ''
    then begin
      s := '';
      SetItemTitle(s, FileIL^.Data^);
      SetNewStr(Data.Title, s);
    end;

  SetNewStrByP(Data.FileName, FileIL^.Data);
  SetNewStrByP(Data.Parameters.Str, ParametersIL^.Data);
  SetNewStrByP(Data.StartDir.Str, StartDirIL^.Data);
  Data.Attributes := AttributesCB^.Value;

  FileItem^.SetData(Data);
  FileItem^.Unselect;
  Data.Done;
end;

{ Используется при добавлении пункта }
function TAddFileItemsDlg.CreateFileName: FNameStr;
begin
  CreateFileName := GetRndFileName(
                PDirWindow(Desktop^.Current)^.DirectoryBox^.GetRndNameTpl);
end;

{ Используется при добавлении пункта }
function TAddFileItemsDlg.CreateFileItem: PFileItem;
var
  P: PFileItem;
  Titl: String;
  FileName: FNameStr;
  DiskLabel: String[11];
  StartDir, Parameters: TInhString;
  Attributes, Inheritance: Word;
  AnnIndex, PIFIndex: TResIndex;
begin
  Titl := TitleIL^.Data^;
  if FullTrim(Titl) = ''
    then SetItemTitle(Titl, FileIL^.Data^);

  FileName := FileIL^.Data^;
  if (FullTrim(FileName) = '') and CreateFileNames
    then FileName := CreateFileName;
  Parameters.Str := NewStr(ParametersIL^.Data^);
  Parameters.InhFlag := False;
  StartDir.Str := NewStr(StartDirIL^.Data^);
  StartDir.InhFlag := False;
  DiskLabel := '';
  Attributes := AttributesCB^.Value;  {!!! Временно}
  Inheritance := 0;

  AnnIndex.Place := pfNowhere;
  AnnIndex.Name := nil;
  AnnIndex.InhFlag := False;

  PIFIndex.Place := pfNowhere;
  PIFIndex.Name := nil;
  PIFIndex.InhFlag := False;

  New(P, Init(Titl,
              FileName,
              DiskLabel,
              StartDir,
              Parameters,
              Attributes,
              Inheritance,
              AnnIndex,
              PIFIndex));

  DispStr(Parameters.Str);
  DoneResIndex(AnnIndex);
  DoneResIndex(PIFIndex);
  DispStr(StartDir.Str);

  CreateFileItem := P;
end;

procedure TAddFileItemsDlg.SetItemTitle(var Titl: String; FileName: PathStr);
var
  Dir: PDirectory;
begin
  if Titl <> '' then Exit;
  Titl := FileName;
  if GetFExt(FileName) <> DirExtUp then Exit;
  FileName := AddPath(FileName,
                      FirstDirWindow^.GetDirPtr^.GetStartDir(False));
  if not IsDirectoryFile(FileName) then Exit;
  New(Dir, Init(FileName));
  if Assigned(Dir) then Titl := Dir^.GetTitle;
  DisposeObj(Dir);
end;

function TAddFileItemsDlg.FileFound: boolean;
var
  Mess: String;
  TmpDir: DirStr;
  File2Find: FNameStr;
begin
  FileFound := True;
{$ifdef ForPacket}
  if not AddNonExistConfirm then
{$endif}
    Exit;
  Mess := Ph(phAddItem_FileNotFound);
  Case Mode of
        wtAdd: Mess := Mess + Ph(phAddItem_AskAdd);
    wtReplace: Mess := Mess + Ph(phAddItem_AskReplace);
  end;
  GetDir(0, TmpDir);
  Message(Application, evCommand, cmRestCurrDir, nil);
  File2Find := FileIL^.Data^;
  if StartDirIL^.Data^ <> ''
    then File2Find := AddPath(File2Find, StartDirIL^.Data^)
  else File2Find := AddPath(File2Find,
               PDirWindow(Desktop^.Current)^.DirectoryBox^.GetStartDir);
  FileFound := FileExist(File2Find)
               or (MessageBox(Mess, nil,
                              mfYesNoCancel + mfConfirmation + mfInsertInApp,
                              hcAddItem_FileNotFound)
                   = cmYes);
  ChangeDirectory(TmpDir);
end;

function TAddFileItemsDlg.EmptyTitle: boolean;
var
  Mess: String;
begin
  Mess := Ph(phAddItem_EmptyTitle);
  Case Mode of
        wtAdd: Mess := Mess + Ph(phAddItem_AskAdd);
    wtReplace: Mess := Mess + Ph(phAddItem_AskReplace);
  end;
  EmptyTitle := (FullTrim(TitleIL^.Data^) = '')
                and (MessageBox(Mess, nil,
                              mfYesNoCancel + mfConfirmation + mfInsertInApp,
                              hcAddItem_EmptyTitle)
                     <> cmYes);
end;

procedure TAddFileItemsDlg.AddItem;
var
  P: PFileItem;
begin
  if (not FileFound) or EmptyTitle
    then Exit;

  P := CreateFileItem;
  PDirWindow(Desktop^.Current)^.GetSubDir^.InsertItem(
                                   InsPosition + CountInserted, P);
  PDirWindow(Desktop^.Current)^.DirectoryBox^.ChangeRange;
  Inc(CountInserted);
  SelectInputLines;
  Redraw;
  PutInfoWindow(Ph(phAdded));
end;

procedure TAddFileItemsDlg.ReplaceItem;
begin
  if (not FileFound) or EmptyTitle
    then Exit;

  FillFileItem;
  PDirWindow(Desktop^.Current)^.GetDirPtr^.UpdateHotKey(FileItem);
  PDirWindow(Desktop^.Current)^.Redraw;
  GetFileItem;
  if InsPosition = -1 then Exit;
  Inc(CountInserted);
  SelectInputLines;
  Redraw;
  PutInfoWindow(Ph(phReplaced));
end;

procedure TAddFileItemsDlg.SelectInputLines;
begin
  TitleIL^.SelectAll(True);
  FileIL^.SelectAll(True);
  ParametersIL^.SelectAll(True);
  StartDirIL^.SelectAll(True);
{
  DiskIL^.SelectAll(True);
}
end;

end.

