program FastBase64_AVX2_4D;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  FastBase64U in 'Source\FastBase64U.pas';

begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
