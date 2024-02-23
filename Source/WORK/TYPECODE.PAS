uses drivers, crt;
var
  Event: TEvent;
begin
  checkbreak := false;
  repeat
    GetKeyEvent(Event);
  until Event.What <> evNothing;
  writeln('Scan: ', Event.ScanCode);
  writeln('Char: ', ord(Event.CharCode));
end.
