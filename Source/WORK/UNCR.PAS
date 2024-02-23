var
  i: integer;
  f: file of byte;
  b: byte;
begin
  assign(f, paramstr(1));
  reset(f);
  repeat
    read(f, b);
    b := b xor 133;
    write(chr(b));
  until eof(f);
  close(f);
end.