(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Edit_Dlg                                        *)
(* Функция DoEditDialog                                   *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 17.03.1994                             *)
(* Корректирован : 20.09.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

Unit Edit_Dlg;

interface

uses

  Objects, Views, Drivers, Dialogs, PackLng, Language, MyMsgBox, Editors,
  App, BaseApp, StdDlg, Pack_Hlp, Hist_Ind, Pack_Cmd;

  function DoEditDialog(Dialog: Integer; Info: Pointer): Word;

implementation

function DoEditDialog(Dialog: Integer; Info: Pointer): Word;
var
  R: TRect;
  T: TPoint;
begin
  case Dialog of
{$ifndef Demo}
    edOutOfMemory:
      DoEditDialog := MessageBox(^C + Ph(phNotEnoughMem), nil,
         mfError + mfOkButton + mfInsertInApp, hcNoMemory);
{$else}
    edOutOfMemory:
      begin
        DoEditDialog := cmOk;
        Message(Application, evCommand, cmDemoInfo, nil);
      end;
{$endif}
    edReadError:
      DoEditDialog := MessageBox(^C + Ph(phErrorReadingFile) + ^M^M^C +'%s',
        @Info, mfError + mfOkButton + mfInsertInApp, hcErrReadTxtFile);
    edWriteError:
      DoEditDialog := MessageBox(^C + Ph(phErrorWritingFile) + ^M^M^C + '%s',
        @Info, mfError + mfOkButton + mfInsertInApp, hcErrWriteTxtFile);
    edCreateError:
      DoEditDialog := MessageBox(^C + Ph(phErrorCreatingFile) + ^M^M^C + '%s',
        @Info, mfError + mfOkButton + mfInsertInApp, hcErrorCreateFile);
    edSaveModify:
      DoEditDialog := MessageBox(^C'%s ' + Ph(phHasBeenModified_Save),
        @Info, mfInformation + mfYesNoCancel + mfInsertInApp, hcSaveModified);
    edSaveUntitled:
      DoEditDialog := MessageBox(Ph(phSaveUntitledFile),
        nil, mfInformation + mfYesNoCancel + mfInsertInApp, hcSaveUntitled);
    edSaveAs:
      DoEditDialog := BaseApplication^.AppExecuteDialog(New(PFileDialog, Init('*.*',
        Ph(phSaveFileAs), Ph(phCName), fdOkButton, hiOpen, hcSaveAsDlg)), Info);
    edFind:
      DoEditDialog := BaseApplication^.AppExecuteDialog(CreateFindDialog, Info);
    edSearchFailed:
      DoEditDialog := MessageBox(^M^C + Ph(phSearchStrNotFound),
        nil, mfInformation + mfOkButton + mfInsertInApp, hcStringNotFound);
    edReplace:
      DoEditDialog := BaseApplication^.AppExecuteDialog(CreateReplaceDialog, Info);
    edReplacePrompt:
      begin
        { Avoid placing the dialog on the same line as the cursor }
        R.Assign(0, 1, 40, 8);
        R.Move((Desktop^.Size.X - R.B.X) div 2, 0);
        Desktop^.MakeGlobal(R.B, T);
        Inc(T.Y);
        if TPoint(Info).Y <= T.Y then
          R.Move(0, Desktop^.Size.Y - R.B.Y - 2);
        DoEditDialog := MessageBoxRect(R, ^C + Ph(phReplaceThisOccurence),
          nil, mfYesNoCancel + mfConfirmation, hcReplaceRequest);
      end;
  end;
end;

end.

