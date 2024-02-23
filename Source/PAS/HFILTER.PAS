{ Модуль HFILTER.TPU содержит функцию, предназначенную для
  преобразования строк из формата файла помощи GUID в текстовый формат.
  При этом удаляются специальные символы и строки, не отображаемые на экране
  при интерпретации гипертекста.
}
unit HFilter;

interface

{ Функция удаления из строки текста специальной неотображаемой информации:
    S        - входная строка,
    Protocol - список удаленных фрагментов текста.
  Если HelpFilter возвращает символ #0, то это означает, что данная строка
  должна быть выброшена.
}
function HelpFilter(S: string; var Protocol: string): string;

implementation

const
  OpenBracket  = #0;  { символ, открывающий ссылку в нормализованных строках }
  CloseBracket = #1;  { символ, закрывающий ссылку в нормализованных строках }
  Separator    = #2;  { символ - разделитель в расширенных ссылках           }
  SpecSymbols  = [OpenBracket, CloseBracket, Separator];

{  Преобразовать денормализованную строку в видимую :
}
function Dtov(S: string; var Protocol: string): string;
type
  TState = (Inside, Outside, Reference);
var
  State : TState;
  I     : word;
  C     : char;
  { Перенести символы из строки в протокол :
  }
  procedure Del(var S: string; I, C: word);
  begin
    Insert(Copy(S, I, C), Protocol, Length(Protocol) + 1);
    Delete(S, I, C);
  end;
  { Если следующий символ = С, то удалить его и вернуть Истину.
  }
  function Reduced(C: char): boolean;
  begin
    if (I < Length(S)) and (S[I+1] = C) then begin
      Del(S, I, 1);  Reduced := True;
    end
    else Reduced := False;
  end;
begin
  I := 1;  State := Outside;  Protocol := '';
  while I <= Length(S) do
  begin
    if S[I] in SpecSymbols then begin Del(S, I, 1); Continue; end;

    if (S[I] in ['{', '}', ':']) and not Reduced(S[I]) then
    begin
      case S[I] of
        '{' : if State = Outside then begin
                Del(S, I, 1);  State := Inside;
              end;
        '}' : if State = Inside then begin
                Del(S, I, 1);  State := Outside;
              end;
        ':' : if State = Inside then begin
                Del(S, I, 1);
                repeat
                  if S[I] in ['{', ':', '}'] then Reduced(S[I]);
                  C := S[I];  Del(S, I, 1);
                until (C = '}') or (I > Length(S));
                State := Outside;  Dec(I);
              end;
      end;
    end;
    Inc(I);
  end;
  Dtov := S;
end; { normalized string }

function HelpFilter(S: string; var Protocol: string): string;
begin
  if Pos('.topic ', S) = 1 then begin
    Protocol := S;
    HelpFilter := #0;
  end
  else HelpFilter := Dtov(S, Protocol);
end;

end.