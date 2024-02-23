(**********************************************************)
(*                                                        *)
(* Интегратор "Packet"                                    *)
(*                                                        *)
(* Модуль Pack_CS                                         *)
(* Функции инициализации окна изменения цветов            *)
(*                                                        *)
(* Автор : Константин Вулах                               *)
(* Copyright (C) 1994-95 by VULCAN                        *)
(*                                                        *)
(* Начат         : 14.03.1994                             *)
(*                                                        *)
(**********************************************************)

{$A+,B-,E-,F+,N-,O+,V-,X+,I-}

unit Pack_CS;

interface

uses MyColSel, PackLng, Language;

  function PackMenusColorItems: PColorItem;
  function PackDialogsColorItems: PColorItem;
  function PackEditorColorItems: PColorItem;
  function PackAsciiColorItems: PColorItem;
  function PackAnnColorItems: PColorItem;
  function PackCalendarColorItems: PColorItem;
  function PackHelpColorItems: PColorItem;
  function PackDirColorItems: PColorItem;

implementation

function PackMenusColorItems: PColorItem;
begin
  PackMenusColorItems :=
      ColorItem(Ph(phNormalItem),       2,
      ColorItem(Ph(phDisabled),         3,
      ColorItem(Ph(phShortcut),         4,
      ColorItem(Ph(phSelected),         5,
      ColorItem(Ph(phSelectedDisabled), 6,
      ColorItem(Ph(phShortcutSelected), 7,
      nil))))));
end;

function PackDialogsColorItems: PColorItem;
begin
  PackDialogsColorItems :=
      ColorItem(Ph(phFramePassive),       32,
      ColorItem(Ph(phFrameBackground),    33,
      ColorItem(Ph(phFrameIcons),         34,
      ColorItem(Ph(phScrollBarPage),      35,
      ColorItem(Ph(phScrollBarIcons),     36,
      ColorItem(Ph(phStaticText),         37,
      ColorItem(Ph(phLabelNormal),        38,
      ColorItem(Ph(phLabelSelected),      39,
      ColorItem(Ph(phLabelShortcut),      40,
      ColorItem(Ph(phButtonNormal),       41,
      ColorItem(Ph(phButtonDefault),      42,
      ColorItem(Ph(phButtonSelected),     43,
      ColorItem(Ph(phButonDisabled),      44,
      ColorItem(Ph(phButtonShortcut),     45,
      ColorItem(Ph(phButtonShadow),       46,
      ColorItem(Ph(phClusterNormal),      47,
      ColorItem(Ph(phClusterSelected),    48,
      ColorItem(Ph(phClusterShortcut),    49,
      ColorItem(Ph(phInputNormal),        50,
      ColorItem(Ph(phInputSelected),      51,
      ColorItem(Ph(phInputArrow),         52,
      ColorItem(Ph(phHistoryButton),      53,
      ColorItem(Ph(phHistorySides),       54,
      ColorItem(Ph(phHistoryBarPage),     55,
      ColorItem(Ph(phHistoryBarIcons),    56,
      ColorItem(Ph(phListNormal),         57,
      ColorItem(Ph(phListFocused),        58,
      ColorItem(Ph(phListSelected),       59,
      ColorItem(Ph(phListDivider),        60,
      ColorItem(Ph(phInformationPane),    61,
      nil))))))))))))))))))))))))))))));
end;

function PackEditorColorItems: PColorItem;
begin
  PackEditorColorItems :=
      ColorItem(Ph(phFramePassive),       8,
      ColorItem(Ph(phFrameActive),        9,
      ColorItem(Ph(phFrameIcons),         10,
      ColorItem(Ph(phScrollBarPage),      11,
      ColorItem(Ph(phScrollBarIcons),     12,
      ColorItem(Ph(phNormalText),         13,
      ColorItem(Ph(phSelectedText),       14,
      nil)))))));
end;

function PackAnnColorItems: PColorItem;
begin
  PackAnnColorItems :=
      ColorItem(Ph(phFramePassive),       24,
      ColorItem(Ph(phFrameActive),        25,
      ColorItem(Ph(phFrameIcons),         26,
      ColorItem(Ph(phScrollBarPage),      27,
      ColorItem(Ph(phScrollBarIcons),     28,
      ColorItem(Ph(phNormalText),         29,
      ColorItem(Ph(phSelectedText),       30,
      nil)))))));
end;

function PackAsciiColorItems: PColorItem;
begin
  PackAsciiColorItems :=
      ColorItem(Ph(phFramePassive),       154,
      ColorItem(Ph(phFrameActive),        155,
      ColorItem(Ph(phFrameIcons),         156,
      ColorItem(Ph(phNormalText),         157,
      nil))));
end;

function PackCalendarColorItems: PColorItem;
begin
  PackCalendarColorItems :=
      ColorItem(Ph(phFramePassive),       16,
      ColorItem(Ph(phFrameActive),        17,
      ColorItem(Ph(phFrameIcons),         18,
      ColorItem(Ph(phNormalText),         21,
      ColorItem(Ph(phCurrentDay),         22,
      nil)))));
end;

function PackHelpColorItems: PColorItem;
begin
  PackHelpColorItems :=
{
      ColorItem(Ph(phFramePassive),     128,
}
      ColorItem(Ph(phFrameActive),      129,
      ColorItem(Ph(phFrameIcons),       130,
      ColorItem(Ph(phScrollBarPage),    131,
      ColorItem(Ph(phScrollBarIcons),   132,
      ColorItem(Ph(phNormalText),       133,
      ColorItem(Ph(phNormalKeyword),    134,
      ColorItem(Ph(phHighlightKeyword), 135,
      nil)))))));
end;

function PackDirColorItems: PColorItem;
begin
  PackDirColorItems :=
      ColorItem(Ph(phFramePassive),     138,
      ColorItem(Ph(phFrameActive),      139,
      ColorItem(Ph(phFrameIcons),       140,
      ColorItem(Ph(phScrollBarPage),    141,
      ColorItem(Ph(phScrollBarIcons),   142,
      ColorItem(Ph(phSubdirectory),     146,
      ColorItem(Ph(phNormalItem),       143,
      ColorItem(Ph(phListFocused),      144,
      ColorItem(Ph(phListSelected),     145,
      ColorItem(Ph(phSelFocused),       147,
      ColorItem(Ph(phItemType),         148,
      ColorItem(Ph(phHotKey4CS),        149,
{
      ColorItem(Ph(phItemType1),        150,
      ColorItem(Ph(phItemType2),        151,
      ColorItem(Ph(phItemType3),        152,
      ColorItem(Ph(phItemType4),        153,
}
      nil))))))))))));
end;

end.

