(***********************************************************)
(*                                                         *)
(* Интегратор "Packet"                                     *)
(*                                                         *)
(* Модуль SelSDDlg                                         *)
(* Диалоговое окно выбора подоглавления для переноса и др. *)
(*                                                         *)
(* Автор : Константин Вулах                                *)
(* Copyright (C) 1994 by VULCAN                            *)
(*                                                         *)
(* Начат         : 12.05.1994                              *)
(*                                                         *)
(***********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit SelSDDlg;

interface

uses
  Objects, Memory, App, BaseApp, Dialogs, Drivers, Views, Language,
  PackLng, PackText, Pack_Hlp, Pack_Cmd, Hist_Ind, SubDirs, Items,
  StrServ, StdDlg, Disp_Obj, MyMsgBox, Dos, FileOps, Pack_Dlg, Dir_Wind,
  Dirs, PathStk;

type

  PSelectSubDirDlg = ^TSelectSubDirDlg;
  TSelectSubDirDlg = object(TDialog)
    constructor Init
     (ATitle: String; AHelpCtx: Word;
      Dir: PDirectory; AStack: PPathStack; SubDirName: String;
      Focused: Integer; ProhSubDirNames: PStringCollection;
      ProhCurr: boolean);
  end;

  PDlgDirBox = ^TDlgDirBox;
  TDlgDirBox = object(TDirectoryBox)

    ProhSubDirNames: PStringCollection;
    ProhCurrent: boolean;
    SourceSDName: String;

    constructor Init
      (var Bounds: TRect;
       AHScrollBar, AVScrollBar: PScrollBar;
       Dir: PDirectory; AStack: PPathStack; SubDirName: String;
       AFocused: Integer; AProhSubDirNames: PStringCollection;
       AProhCurr: boolean);
    destructor Done; virtual;
    procedure HandleEvent(var Event: TEvent); virtual;
    function GetPalette: PPalette; virtual;
    function ProhibitedSubDir: boolean;
    procedure FocusItem(Item: Integer); virtual;
    procedure GetData(var Rec); virtual;
  end;

  PDlgDirHandler = ^TDlgDirHandler;
  TDlgDirHandler = object(TDirHandler)
    constructor Init
      (Dir: PDirectory; AStack: PPathStack; ASubDirName: String);
  end;

const

  CDlgDirectoryBox = #26#26#27#26#26#26#26#26#26#26#26;

implementation

{ Методы объекта TSelectSubDirDlg }
constructor TSelectSubDirDlg.Init
  (ATitle: String; AHelpCtx: Word;
   Dir: PDirectory; AStack: PPathStack; SubDirName: String;
   Focused: Integer; ProhSubDirNames: PStringCollection; ProhCurr: boolean);
var
  R: TRect;
  DirBox: PDlgDirBox;
  HSB, VSB: PScrollBar;
begin
  if ProhCurr then Application^.DisableCommands([cmOk]);
  R.Assign(0, 0, 75, 20);
  inherited Init(R, ATitle);
  HelpCtx := AHelpCtx;
  Options := Options or ofCentered;

  R.Assign(4, 18, 57, 19);
  New(HSB, Init(R));
  with HSB^ do Options := Options or ofPostProcess;
  R.Assign(58, 4, 59, 18);
  New(VSB, Init(R));
  with VSB^ do Options := Options or ofPostProcess;
  Insert(VSB);
  Insert(HSB);

  R.Assign(3, 4, 58, 18);
  New(DirBox,
      Init(R, HSB, VSB, Dir, AStack, SubDirName, Focused,
           ProhSubDirNames, ProhCurr));
  with DirBox^ do Options := Options or ofFramed;
  Insert(DirBox);

  R.Assign(3, 2, 55, 3);
  Insert(New(PLabel, Init(R, Ph(phCDirectory), DirBox)));

  R.Assign(60, 4, 72, 6);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));
  R.Move(0, 3);
  Insert(New(PButton, Init(R, Ph(phHelp), cmHelp, bfNormal)));

  DirBox^.Select;
end;

{ Методы объекта TDlgDirBox }
constructor TDlgDirBox.Init
 (var Bounds: TRect; AHScrollBar, AVScrollBar: PScrollBar;
  Dir: PDirectory; AStack: PPathStack; SubDirName: String;
  AFocused: Integer; AProhSubDirNames: PStringCollection; AProhCurr: boolean);
begin
  TListViewer.Init(Bounds, 1, AHScrollBar, AVScrollBar);
  DirHandler := New(PDlgDirHandler,
                    Init(Dir, AStack, SubDirName));

  ChangeRange;
  FocusItem(AFocused);
  SourceSDName := SubDirName;
  ProhSubDirNames := AProhSubDirNames;
  ProhCurrent := AProhCurr;
end;

destructor TDlgDirBox.Done;
begin
  DisposeObj(ProhSubDirNames);
  Application^.SetCmdState([cmOk], True);
  inherited Done;
end;

function TDlgDirBox.ProhibitedSubDir: boolean;
var
  SDName: String;
  c: Integer;
begin
  ProhibitedSubDir := False;
  if not Assigned(ProhSubDirNames) then Exit;
  if GetFocusedItem^.GetItemType <> itSubDirItem
    then Exit;
  SDName := (PSubDirItem(GetFocusedItem)^.GetSubDirName);
  ProhibitedSubDir := ProhSubDirNames^.Search(@SDName, c);
end;

procedure TDlgDirBox.HandleEvent(var Event: TEvent);
var
  CheckOkBtn: boolean;
begin
  CheckOkBtn := False;
  if Event.What = evKeyDown
    then begin
      if (Event.KeyCode = kbEsc) or (Event.KeyCode = kbCtrlEnter)
        then Exit;
      if Event.KeyCode = kbEnter
        then if (not(GetFocusedItem^.GetItemType
                     in [itUpDirItem, itSubDirItem]))
                or ProhibitedSubDir
             then ClearEvent(Event)
             else CheckOkBtn := True;
    end;

  if (Event.What = evKeyDown) and (Event.Buttons = mbRightButton)
    then ClearEvent(Event);

  inherited HandleEvent(Event);

  if CheckOkBtn and ProhCurrent
    then Application^.SetCmdState([cmOk], SourceSDName <> GetSubDirName);
end;

procedure TDlgDirBox.FocusItem(Item: Integer);
begin
  TListViewer.FocusItem(Item);
end;

function TDlgDirBox.GetPalette: PPalette;
const
  P: String[Length(CDlgDirectoryBox)] = CDlgDirectoryBox;
begin
  GetPalette := @P;
end;

procedure TDlgDirBox.GetData(var Rec);
var
  Data: TSelSDData absolute Rec;
begin
  Data.SubDirName := GetSubDirName;
  Data.Item := Focused;
end;

{ Методы объекта TDlgDirHandler }
constructor TDlgDirHandler.Init
  (Dir: PDirectory; AStack: PPathStack; ASubDirName: String);
begin
  TObject.Init;

  Directory := Dir;
  if not Assigned(Directory)
    then begin
      Done;
      Fail;
    end;
  SubDir := nil;
  Stack := nil;
  SelNumbers := nil;
  ComParams := nil;
  DirFileName := nil;
  EnteredPW := nil;

  Directory^.Connect;
  Stack := CopyStack(AStack);
  SubDirName := NewStr(ASubDirName);
  SubDir := Directory^.ReadSubDir(SubDirName^);
end;

end.

