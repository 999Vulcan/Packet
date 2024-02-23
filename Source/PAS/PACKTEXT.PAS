(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль PackText                                        *)
(* Некоторые текстовые строки и константы                 *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 21.02.1994                             *)
(*                                                        *)
(**********************************************************)

unit PackText;

interface

uses PackLink;

const

  tsAb =     ^M^C'Integrator "Packet"' +
             ^M^M^C'Version ' + VerNum +
{$ifdef DPMI}
             ' for DPMI' +
{$endif}
             ^M^M^C'January 5, 1997' +
             ^M^M^C'Copyright (C) 1990-97 by' +
             ^M^C'Michael Dolinsky &' +
             ^M^C'Constantine Vulakh' +
             ^M^M^C'Gomel State University';

  tsAbout: String[Length(tsAb)] = tsAb;

{ Save heap for main program (KB) }

  HeapSize = 100 * (1024 div 16);

{$ifndef DPMI}
  PackLowMemSize = 10 * (1024 div 16); { Пул надежности }
  MaxTextResSize = 1024 * 4 - 5;
  StreamBuffSize = 2 * 1024;  { B }
{$else}
  PackLowMemSize = 20 * (1024 div 16); { Пул надежности для DPMI }
  MaxTextResSize = 1024 * 20 - 5;
  StreamBuffSize = 5 * 1024;  { B }
{$endif}

  tsAuthorPassword = 'dctktyyfz';

  HistSize = 1024 * 5;

  AllFilesMask = '*.*';
  ExeFilesMask = '*.exe';
  ExtFileName  = 'Packet.Ext';
  ConfFileName = 'Packet.Cnf';
  ConfExt      = '*.cnf';
  ConfExtUp    = '.CNF';
  DskFileName  = 'Packet.Dsk';
  DskExt       = '*.dsk';
  DskExtUp     = '.DSK';
  PalExtUp     = '.PAL';
  PalExt       = '*.pal';
  LngExt       = '*.lng';
  DirExt       = '*.cnt';
  DirExtUp     = '.CNT';
  PalDir       = 'PAL\';
  EXEFileName  = 'PackMain.Exe';
  TmpConf      = 'PCnf____.$$$';
  TmpDsk       = 'PDsk____.$$$';
  TmpExt       = '.$$$';
  DefaultLngFile = 'english.lng';

  tsPacket = 'Packet';
  tsTitle  = '<<PACKET>>';

  tsLngReadError = ^C'Can not read language file';
  tsOvrInitError = ^C'Can not install overlay manager';

  tsArrows  = chr(24) + chr(25) + chr(26) + chr(27);
  tsPArrows = '+' + tsArrows;
  tsEnter   = chr(17) + chr(196) + chr(217);

  PrefixLen = 3;  { Длина префикса названия пункта }
  tsSubDirPrefix = ' ' + chr(16);
  tsLeftPartSkiped = chr(250);
  tsUpDirTitle = '..';
  ts3P = '...';
  tsReplCharNo = 250;
  tsTargetDirChar = #11;
  tsCharsAboveFigures = ')!@#$%^&*(';

  ParamsDivider = '^';
  ExtBeginner   = '>';
  MenuDivider   = '-';
  CommentChar   = ';';
  SecondTreatmentChar = '#';

  IndLen = 5;       { Длина окончания в имени ресурса }
  tsRootDirIndex      = 'Integrator "Packet" 3.0. Root Directory';
  tsStartDirIndex     = 'StartDir';
  tsRootDirItemsIndex = 'RDI';
  tsDirConfIndex      = 'DirConfig';
  tsSubDirIndex       = 'SD';
  tsItemsIndex        = 'I';
  tsAnnIndex          = 'A';
  tsParIndex          = 'PL';
  tsHotKeyIndex       = 'HK';
  tsLocalExtIndex     = 'LE';
  tsRndNameTplIndex   = 'RNTpl<<VULCAN>>';

  ItemNameStr = '.NAME';

  AnnDelay = 26; { * 0.01 sec }
  ClosedFilesCount = 10;
  DskStackSize = 11;

implementation

end.


