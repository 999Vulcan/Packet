{ ����� HFILTER.TPU ᮤ�ন� �㭪��, �।�����祭��� ���
  �८�ࠧ������ ��ப �� �ଠ� 䠩�� ����� GUID � ⥪�⮢� �ଠ�.
  �� �⮬ 㤠������ ᯥ樠��� ᨬ���� � ��ப�, �� �⮡ࠦ���� �� ��࠭�
  �� ������樨 �����⥪��.
}
unit HFilter;

interface

{ �㭪�� 㤠����� �� ��ப� ⥪�� ᯥ樠�쭮� ���⮡ࠦ����� ���ଠ樨:
    S        - �室��� ��ப�,
    Protocol - ᯨ᮪ 㤠������ �ࠣ���⮢ ⥪��.
  �᫨ HelpFilter �����頥� ᨬ��� #0, � �� ����砥�, �� ������ ��ப�
  ������ ���� ���襭�.
}
function HelpFilter(S: string; var Protocol: string): string;

implementation

const
  OpenBracket  = #0;  { ᨬ���, ���뢠�騩 ��뫪� � ��ଠ���������� ��ப�� }
  CloseBracket = #1;  { ᨬ���, ����뢠�騩 ��뫪� � ��ଠ���������� ��ப�� }
  Separator    = #2;  { ᨬ��� - ࠧ����⥫� � ���७��� ��뫪��           }
  SpecSymbols  = [OpenBracket, CloseBracket, Separator];

{  �८�ࠧ����� ����ଠ���������� ��ப� � ������� :
}
function Dtov(S: string; var Protocol: string): string;
type
  TState = (Inside, Outside, Reference);
var
  State : TState;
  I     : word;
  C     : char;
  { ��७��� ᨬ���� �� ��ப� � ��⮪�� :
  }
  procedure Del(var S: string; I, C: word);
  begin
    Insert(Copy(S, I, C), Protocol, Length(Protocol) + 1);
    Delete(S, I, C);
  end;
  { �᫨ ᫥���騩 ᨬ��� = �, � 㤠���� ��� � ������ ��⨭�.
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