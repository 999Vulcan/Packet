(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль AddSDDlg                                        *)
(* Диалоговое окно добавления/модификации подоглавления   *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 12.05.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit AddSDDlg;

interface

uses
  Objects, Memory, App, BaseApp, Dialogs, Drivers, Views, Language,
  PackLng, PackText, Pack_Hlp, Pack_Cmd, Hist_Ind, SubDirs, Items,
  StrServ, StdDlg, Disp_Obj, MyMsgBox, Dos, FileOps, Pack_Dlg;

type

  PAddSubDirsDlg = ^TAddSubDirsDlg;
  TAddSubDirsDlg = object(TDialog)
    constructor Init(AMode: byte; Position: Integer);
    destructor Done; virtual;

    private

    Mode: byte;

    InsPosition: Integer;
    CountInserted: LongInt;

    TitleIL: PInputLine;
    RndNameTplIL: PInputLine;
    StartDirIL:  PInputLine;
    AttributesCB: PCheckBoxes;
    InheritanceCB: PCheckBoxes;
    Indicator: PParamText;

    SubDir: PSubDir;
    SDItem: PSubDirItem;
    SDName: PString;

    procedure HandleEvent(var Event: TEvent); virtual;
    procedure GetSubDir;
    procedure AddSubDir;
    procedure ReplSubDir;
    procedure FillSubDir;
    procedure SelectInputLines;
    function EmptyTitle: boolean;
  end;

implementation

uses

  Dirs, Dir_Wind;

{ Методы объекта TAddSubDirsDlg }
constructor TAddSubDirsDlg.Init(AMode: byte; Position: Integer);
var
  R: TRect;
  IndStr: String;
  Tit: TTitleStr;
begin
  R.Assign(0, 0, 69, 15);

  Case AMode of
        wtAdd: Tit := Ph(phAddSubDir);
    wtReplace: Tit := Ph(phReplSubDir);
  end;

  inherited Init(R, Tit);

  Mode := AMode;

  if AddSubDirCoord.Y = -1
    then Options := Options or ofCentered
    else MoveTo(AddSubDirCoord.X, AddSubDirCoord.Y);

  Case Mode of
        wtAdd: begin
                 InsPosition := Position;
                 HelpCtx := hcAddSubDirs;
               end;
    wtReplace: begin
                 InsPosition := PDirWindow(
                   Desktop^.Current)^.GetDirHandler^.GetFirstSelected;
                 HelpCtx := hcModifySubDirs;
               end;
  end;
  CountInserted := 0;

  R.Assign(3, 3, 48, 4);
  TitleIL := New(PInputLine, Init(R, 250));
  Insert(TitleIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCSubDirTitle), TitleIL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, TitleIL, hiTitle)));

  R.Assign(3, 6, 48, 7);
  RndNameTplIL := New(PInputLine, Init(R, 127));
  Insert(RndNameTplIL);
  R.Move(-1, -1);
  Insert(New(PLabel, Init(R, Ph(phCRandNameTpl4Dir), RndNameTplIL)));
  R.Move(1, 1);
  R.A.X := R.B.X;
  R.B.X := R.A.X + 3;
  Insert(New(PHistory, Init(R, RndNameTplIL, hiRandNameTpl)));

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

{
    StartDirIL:  PInputLine;
    AttributesCB: PCheckButtons;
    InheritanceCB: PCheckButtons;
}

  SelectNext(False);
  SubDir := nil;
  SDItem := nil;
  SDName := nil;
  if Mode = wtReplace then GetSubDir;

  if InsPosition = -1
    then begin
      Done;
      Fail;
    end;
end;

destructor TAddSubDirsDlg.Done;
begin
  DisposeObj(SubDir);
  DispStr(SDName);
  AddSubDirCoord := Origin;
  Message(Application, evCommand, cmRestCurrDir, nil);
  inherited Done;
end;

procedure TAddSubDirsDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);

  if Event.What = evCommand
    then begin
      Case Event.Command of
         cmAdd: AddSubDir;
        cmRepl: ReplSubDir;
      else
        Exit
      end;
      ClearEvent(Event);
    end;
end;

procedure TAddSubDirsDlg.GetSubDir;
var
  Data: TSubDirItemData;
begin
  DisposeObj(SubDir);
  DispStr(SDName);

  InsPosition :=
   PDirWindow(Desktop^.Current)^.GetDirHandler^.GetFirstSelItem(itSubDirItem);

  if InsPosition = -1
    then begin
      EndModal(cmOk);
      Exit;
    end;

  SDItem := PSubDirItem(
       PDirWindow(Desktop^.Current)^.GetDirHandler^.GetItemPtr(InsPosition));
  SDItem^.GetData(Data);

  TitleIL^.Data^ := GetStr(Data.Title);
  SetNewStrByP(SDName, Data.SubDirName);
  SubDir := PDirWindow(Desktop^.Current)^.GetDirPtr^.ReadOnlySubDir(SDName^);

  RndNameTplIL^.Data^ := GetStr(SubDir^.RndNameTpl.Str);

{
  Parameters.InhFlag:= False;
  StartDir.Str := nil;
  StartDir.InhFlag := False;
  DiskLabel := '';
  Attributes := 0;
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

procedure TAddSubDirsDlg.FillSubDir;
var
  Data: TSubDirItemData;
begin
  SDItem^.GetData(Data);

  SetNewStrByP(Data.Title, TitleIL^.Data);
  SetNewStrByP(SubDir^.RndNameTpl.Str, RndNameTplIL^.Data);

  SDItem^.SetData(Data);
  SDItem^.Unselect;

  PDirWindow(Desktop^.Current)^.GetDirPtr^.WriteOnlySubDir(SDName^, SubDir);

  Data.Done;
end;

procedure TAddSubDirsDlg.AddSubDir;
var
  P: PSubDirItem;
  Titl, SubDirIndex: String;
  StartDir, RndNameTpl: TInhString;
  Attributes, Inheritance: Word;
  AnnIndex, PIFIndex: TResIndex;
begin
  if EmptyTitle then Exit;

  Titl := TitleIL^.Data^;
  RndNameTpl.Str := NewStr(RndNameTplIL^.Data^);
  RndNameTpl.InhFlag:= False;
  StartDir.Str := nil;
  StartDir.InhFlag := False;
  Attributes := 0;
  Inheritance := 0;

  AnnIndex.Place := pfNowhere;
  AnnIndex.Name := nil;
  AnnIndex.InhFlag := False;

  PIFIndex.Place := pfNowhere;
  PIFIndex.Name := nil;
  PIFIndex.InhFlag := False;

  SubDirIndex := PDirWindow(Desktop^.Current)^.GetDirPtr^.CreateNewSubDir(
                           StartDir, RndNameTpl,
                           Attributes, Inheritance,
                           AnnIndex, PIFIndex);

  DispStr(RndNameTpl.Str);
  DispStr(AnnIndex.Name);
  DispStr(PIFIndex.Name);
  DispStr(StartDir.Str);

  New(P, Init(Titl, SubDirIndex));

  PDirWindow(Desktop^.Current)^.GetSubDir^.InsertItem(
                                   InsPosition + CountInserted, P);
  PDirWindow(Desktop^.Current)^.DirectoryBox^.ChangeRange;
  Inc(CountInserted);

  SelectInputLines;
  Redraw;
  PutInfoWindow(Ph(phAdded));
end;

procedure TAddSubDirsDlg.ReplSubDir;
begin
  if EmptyTitle then Exit;

  FillSubDir;
  PDirWindow(Desktop^.Current)^.GetDirPtr^.UpdateHotKey(SDItem);

  PDirWindow(Desktop^.Current)^.Redraw;
  GetSubDir;
  if InsPosition = -1 then Exit;
  Inc(CountInserted);
  SelectInputLines;
  Redraw;
  PutInfoWindow(Ph(phReplaced));
end;

procedure TAddSubDirsDlg.SelectInputLines;
begin
  TitleIL^.SelectAll(True);
  RndNameTplIL^.SelectAll(True);
{
  StartDirIL^.SelectAll(True);
}
end;

function TAddSubDirsDlg.EmptyTitle: boolean;
var
  Mess: String;
begin
  Mess := Ph(phAddSubDir_EmptyTitle);
  Case Mode of
        wtAdd: Mess := Mess + Ph(phAddSubDir_AskAdd);
    wtReplace: Mess := Mess + Ph(phAddSubDir_AskReplace);
  end;
  EmptyTitle := (FullTrim(TitleIL^.Data^) = '')
                and (MessageBox(Mess, nil,
                              mfYesNoCancel + mfConfirmation + mfInsertInApp,
                              hcAddSubDir_EmptyTitle)
                     <> cmYes);
end;

end.
