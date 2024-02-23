(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Hist_Ind                                        *)
(* Константы номеров блоков историй                       *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994 by VULCAN                           *)
(*                                                        *)
(* Начат         : 10.02.1994                             *)
(*                                                        *)
(**********************************************************)

unit Hist_Ind;

interface

const

  hiDsk          = 100;
  hiChDir        = 101;
  hiDosCmd       = 102;
  hiConf         = 103;
  hiLine         = 104;
  hiOpen         = 105;
  hiReadLng      = 106;
  hiPal          = 107;
  hiChWorkDir    = 108;
  hiNewDir       = 109;
  hiTitle        = 110;     {  Название пункта    }
  hiFileName     = hiOpen;  {  Имя файла пункта   }
  hiParameters   = 112;     {  Параметры          }
  hiStartDir     = 113;     {  Стартовый каталог  }
  hiComStr       = 114;
  hiDirTitle     = 115;
  hiExtEditor    = 116;
  hiTargetDoc    = 117;
  hiTitPage      = 118;
  hiLeftMargin   = 119;
  hiRightMargin  = 120;
  hiLinesPerPage = 121;
  hiIndentWidth  = 122;
  hiUnderlines   = 123;
  hiAlarmTime    = 124;
  hiAlarmInfo    = 125;
  hiUpMargin     = 126;
  hiPageBeg      = 127;
  hiNumBeg       = 128;
  hiRandNameTpl  = 129;

implementation

end.

