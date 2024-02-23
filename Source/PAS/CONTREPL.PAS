(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль ContRepl                                        *)
(* Контекстная замена в оглавлениях                       *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1995 by VULCAN                           *)
(*                                                        *)
(* Начат         : 28.08.1995                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit ContRepl;

interface

uses
  Objects, App, Views, Drivers, Dialogs, Dirs, Items, ProcMess, SubDirs,
  Disp_Obj, StrServ, Language, PackLng, Pack_Hlp, PackText, Pack_Dlg, Dos,
  BaseApp, StdDlg, Hist_Ind, Pack_Cmd, HotKeys;

const
  ReplStrLen = 80;

  rmCaseSensitive = 1;
  rmReplTitles    = 2;
  rmReplFNames    = 4;
  rmReplParams    = 8;
  rmReplStartDir  = 16;

  ReplModes: Word = rmReplFNames;

type

  PContReplDlg = ^TContReplDlg;
  TContReplDlg = object(TDialog)
    OldTextIL, NewTextIL: PInputLine;

    constructor Init;
    procedure HandleEvent(var Event: TEvent); virtual;
    procedure DirList;
  end;

function ContReplaceDlg(DirHandler: PDirHandler; Focused: Integer): boolean;

implementation

uses PathStk;

var
  Stack: PPathStack;

function DoRepl4Item(Item: PItem; Old, New: String;
                     Directory: PDirectory): boolean; forward;

procedure DoRepl4SubDir(SDName, Old, New: String; Directory: PDirectory);
var
  Dir: PDirectory;
  SD: PSubDir;
  i: Integer;
  flag: boolean;
begin
  Stack^.Insert(System.New(PPathItem, Init(SDName, 0)));
  SD := Directory^.ReadSubDir(SDName);
  flag := False;
  for i := 0 to SD^.CountItems - 1 do
    flag := DoRepl4Item(SD^.GetItem(i), Old, New, Directory) or flag;

  if flag then Directory^.WriteSubDir(SDName, SD);
  DisposeObj(SD);
  Stack^.DelTop;
end;

function DoRepl4Item(Item: PItem; Old, New: String;
                     Directory: PDirectory): boolean;
var
  ItemData: TFileItemData;
  SDItemData: TSubDirItemData;
  flag: boolean;
  SDName, s: String;
begin
  DoRepl4Item := False;
  Item^.Unselect;
  if Item^.GetItemType = itSubDirItem
    then begin
      PSubDirItem(Item)^.GetData(SDItemData);
      s := GetStr(SDItemData.Title);
      if (ReplModes and rmReplTitles <> 0) and
        ContReplace(s, Old, New, ReplModes and rmCaseSensitive <> 0)
      then begin
        SetNewStr(SDItemData.Title, s);
        PSubDirItem(Item)^.SetData(SDItemData);
        DoRepl4Item := True;
      end;
      SDItemData.Done;
      SDName := PSubDirItem(Item)^.GetSubDirName;
      if Stack^.GetSDPos(SDName) = -1
        then DoRepl4SubDir(SDName, Old, New, Directory);
    end
  else if Item^.GetItemType = itFileItem
  then begin
    flag := False;
    PFileItem(Item)^.GetData(ItemData);

    s := GetStr(ItemData.Title);
    if (ReplModes and rmReplTitles <> 0) and
      ContReplace(s, Old, New, ReplModes and rmCaseSensitive <> 0)
    then begin
      flag := True;
      SetNewStr(ItemData.Title, s);
    end;

    s := GetStr(ItemData.FileName);
    if (ReplModes and rmReplFNames <> 0) and
      ContReplace(s, Old, New, ReplModes and rmCaseSensitive <> 0)
    then begin
      flag := True;
      SetNewStr(ItemData.FileName, s);
    end;

    s := GetStr(ItemData.Parameters.Str);
    if (ReplModes and rmReplParams <> 0) and
      ContReplace(s, Old, New, ReplModes and rmCaseSensitive <> 0)
    then begin
      flag := True;
      SetNewStr(ItemData.Parameters.Str, s);
    end;

    s := GetStr(ItemData.StartDir.Str);
    if (ReplModes and rmReplStartDir <> 0) and
      ContReplace(s, Old, New, ReplModes and rmCaseSensitive <> 0)
    then begin
      flag := True;
      SetNewStr(ItemData.StartDir.Str, s);
    end;

    if flag
      then begin
        PFileItem(Item)^.SetData(ItemData);
        if Item^.GetHotKey <> #0
          then WriteHotKey(Directory^, Item^.GetHotKey, Item);
        DoRepl4Item := True;
      end;
    ItemData.Done;
  end;
end;

procedure DoReplace(Old, New: String; DirHandler: PDirHandler;
                    Focused: Integer);
var
  SubDir: PSubDir;
  CountSelected: Integer;
  Mess: PProcMess;
  i: Integer;
  flag: boolean;
begin
  flag := False;
  SubDir := DirHandler^.SubDir;
  CountSelected := DirHandler^.CalcCountSelected;
  if CountSelected = 0
    then SubDir^.SelectItem(Focused);

  System.New(Mess, Init(Ph(phRoundingSubdirs) + ts3p));
  System.New(Stack, Init(10, 10));

  repeat
    i := DirHandler^.GetFirstSelected;
    if i >= 0
      then flag := DoRepl4Item(DirHandler^.GetItemPtr(i), Old, New,
                               DirHandler^.Directory) or flag;
  until i = -1;

  if flag then
    DirHandler^.Directory^.WriteSubDir(DirHandler^.SubDirName^, SubDir);
  DirHandler^.Directory^.Flush;

  DisposeObj(Stack);
  DisposeObj(Mess);
end;

{------------------------------------------------------------------------}
constructor TContReplDlg.Init;
var
  D: PDialog;
  Control: PView;
  R: TRect;
begin
  R.Assign(0, 0, 40, 17);
  inherited Init(R, Ph(phReplace));
  Options := Options or ofCentered;
  HelpCtx := hcContReplDlg;

  R.Assign(3, 3, 34, 4);
  Control := New(PInputLine, Init(R, ReplStrLen));
  Insert(Control);
  R.Assign(2, 2, 30, 3);
  Insert(New(PLabel, Init(R, Ph(phCText2Find), Control)));
  R.Assign(34, 3, 37, 4);
  Insert(New(PCombHistory, Init(R, PInputLine(Control), 10, cmDirList)));
  OldTextIL := PInputLine(Control);

  R.Assign(3, 6, 34, 7);
  Control := New(PInputLine, Init(R, ReplStrLen));
  Insert(Control);
  R.Assign(2, 5, 30, 6);
  Insert(New(PLabel, Init(R, Ph(phCNewText), Control)));
  R.Assign(34, 6, 37, 7);
  Insert(New(PCombHistory, Init(R, PInputLine(Control), 11, cmDirList)));
  NewTextIL := PInputLine(Control);

  R.Assign(3, 8, 37, 13);
  Insert(New(PCheckBoxes, Init(R,
    NewSItem(Ph(phCCaseSensitive),
    NewSItem(Ph(phCReplTitles),
    NewSItem(Ph(phCReplFNames),
    NewSItem(Ph(phCReplParams),
    NewSItem(Ph(phCReplStartDir),
    nil))))))));

  R.Assign(17, 14, 27, 16);
  Insert(New(PButton, Init(R, Ph(phCOk), cmOk, bfDefault)));
  R.Move(11, 0);
  Insert(New(PButton, Init(R, Ph(phCancel), cmCancel, bfNormal)));

  SelectNext(False);
end;

procedure TContReplDlg.HandleEvent(var Event: TEvent);
begin
  inherited HandleEvent(Event);
  if (Event.What = evCommand) and (Event.Command = cmDirList)
    then begin
      ClearEvent(Event);
      DirList;
    end;
end;

procedure TContReplDlg.DirList;
var
  Dir: DirStr;
  IL: PInputLine;
begin
  if BaseApplication^.AppExecuteDialog(New(PChDirDialog,
                                          Init(Ph(phSelectDir),
                                          cdNormal + cdHelpButton,
                                          hiStartDir, hcSelectDir)),
                   @Dir) <> cmOk
    then Exit;
  IL := PInputLine(Current);
  if Current <> PView(NewTextIL)
    then IL := OldTextIL;
  InsertText(IL, Dir);
  IL^.SelectAll(True);
  Message(Application, evCommand, cmRestCurrDir, nil);
end;
{------------------------------------------------------------------------}

function ContReplaceDlg(DirHandler: PDirHandler; Focused: Integer): boolean;
var
  ReplData: record
    s1, s2: String[ReplStrLen];
    Modes: Word;
  end;
begin
  ContReplaceDlg := False;
  ReplData.s1 := '';
  ReplData.s2 := '';
  ReplData.Modes := ReplModes;
  if Application^.ExecuteDialog(New(PContReplDlg, Init), @ReplData) = cmOk
    then begin
      ContReplaceDlg := True;
      ReplModes := ReplData.Modes;
      if ReplData.s1 = ''
        then Exit;
      DoReplace(ReplData.s1, ReplData.s2, DirHandler, Focused);
    end;
end;

end.
