program FastBase64_AVX2_4D;

{$APPTYPE CONSOLE}

{$R *.res}

{$I ..\Definitions.inc}

uses
  System.SysUtils,
  System.Classes,
  System.Threading,
  System.Win.Crtl,
  System.Diagnostics,
  System.Types,
  System.Math,
  System.Net.Mime,
  System.NetEncoding,
  IdGlobal,
  IdCoderMIME,
  FastBase64U in '.\Source\FastBase64U.pas';


function StreamToString(const Stream: TStream; const Encoding: TEncoding): string;
var
  StringBytes: TBytes;

begin
  Stream.Position := 0;
  SetLength(StringBytes, Stream.Size);
  Stream.ReadBuffer(StringBytes, Stream.Size);
  Result := Encoding.GetString(StringBytes);
end;

function SaveBytesToFile(const _Bytes: TBytes; FileName: String; const Encoding: TEncoding): string;
var
  StringBytes: TBytes;
  Stream     : TStringStream;

begin
 try
  Stream     := TStringStream.Create('', Encoding);
  Stream.Position := 0;
  Stream.WriteData( _Bytes, Length(_Bytes) );
  Stream.SaveToFile( FileName );
 finally
  FreeAndNil(Stream);
 end;

end;

// These are from stackoverflow....
function FileMayBeUTF8(FileName: String): Boolean;
var
 Stream: TMemoryStream;
 BytesRead: integer;
 ArrayBuff: array[0..127] of byte;
 PreviousByte: byte;
 i: integer;
 YesSequences, NoSequences: integer;

begin
   if not FileExists(FileName) then Exit;
   YesSequences := 0;
   NoSequences  := 0;
   Stream       := TMemoryStream.Create;
   try
     Stream.LoadFromFile(FileName);
     repeat
       {read from the TMemoryStream}
       BytesRead := Stream.Read(ArrayBuff, High(ArrayBuff) + 1);
       {Do the work on the bytes in the buffer}
       if BytesRead > 1 then begin
           for i := 1 to BytesRead-1 do begin
               PreviousByte := ArrayBuff[i-1];
               if ((ArrayBuff[i] and $c0) = $80) then begin
                   if ((PreviousByte and $c0) = $c0) then begin
                    inc(YesSequences);
                   end else begin
                    if ((PreviousByte and $80) = $0) then inc(NoSequences);
                   end;
               end;
           end;
       end;
     until (BytesRead < (High(ArrayBuff) + 1));
      //Below, >= makes ASCII files = UTF-8, which is no problem. Simple > would catch only UTF-8;
      Result := (YesSequences >= NoSequences);
   finally
     Stream.Free;
   end;
end;

function UTF8CharLength(const c: BYTE): Integer;
begin
 if ((c and $80) = $00) then begin  // First Byte: 0xxxxxxx
  result := 1;
 end else if ((c and $E0) = $C0) then begin // First Byte: 110yyyyy
  result := 2;
 end else if ((c and $F0) = $E0) then begin // First Byte: 1110zzzz
  result := 3;
 end else if ((c and $F8) = $F0) then begin // First Byte: 11110uuu
  result := 4;
 end else begin // not valid, return the error value
  result := -1;
 end;
end;

//After than you check all the trail bytes for that characters (if any)
//for conformity with this:
function UTF8IsTrailChar(const c: BYTE): BOOLEAN;
begin
 result := ((c and $C0) = $80); // trail bytes have this form: 10xxxxxx
end;

//You can easily go over any byte stream to check if it is valid UTF-8,
//like this:
function IsUTF8Memory(AMem: PByte; ASize: Int64): BOOLEAN;
var
 i: Int64;
 c: Integer;

begin
 result := TRUE;
 i := 0;
 while (i < ASize) do begin
  c := UTF8CharLength(AMem^);  // get the length if the current UTF-8 character
  // check if it is valid and fits into ASize
  if ((c>= 1) and (c <= 4) and ((i+c-1) < ASize)) then begin
   inc(i, c);
   inc(AMem);
   // if it is a multi-byte character, check the trail bytes
   while (c>1) do begin
    if (not UTF8IsTrailChar(AMem^)) then begin
     Result := FALSE;
     break;
    end else begin
     dec(c);
     inc(AMem);
    end;
   end;
  end else begin
   Result := FALSE;
  end;
  if (not result) then break;
 end;
end;

//I use this function in a slightly different form but it should work, I
//never compiled it though.
//You can use the function to check a memory stream or string. For stream
//usage try
//isutf8 := IsUTF8Memory(PBYTE(AStream.Memory), AStream.Size);
//for string checking try
//isutf8 := IsUTF8Memory(PBYTE(PChar(AString)), Length(AString));


// Will ONLY check the ending of the buffer for valid UTF8 charecter
// Will return accepted size beased on the trailing bytes ( max 4 bytes )
// Will return -1 if last bytes in buffer are not valid UTF8 char
function GetMaxUTF8String(Buffer: Pointer; Size: Integer): Integer;
var
  BB: TBytes absolute Buffer;

begin
  Result := Size;
  if Result = 0 then Exit;
  repeat
    dec(Result);
    if BB[Result] and $C0 <> $80 then Break;
  until (Result <= 0) or (Size - Result > 4);
  if Size - Result > 4 then Result := -1;
end;


Procedure SaveStringToFile(const FileName: String; SaveStr: String; const Enc: TEncoding );
var
 ss: TStringStream;

begin
 try
  ss := TStringStream.Create(SaveStr, Enc);
  ss.SaveToFile(FileName)
 finally
  FreeAndNil(ss);
 end;
end;

// Test files : current tests just for text files, and later binary files.
const BigFileName     = 'BigFile-1.log';
const VeryBigFileName = 'VeryBigFile.txt';

begin
  try

    writeln('Ultrafast base64 encode/decode library');
    writeln('https://github.com/fatihtsp/FastBase64_EncDec');
    {$ifdef VCCompiler}
    writeln('Using VC Compiler produced objs files');
    {$endif}
    {$ifdef GCCCompiler}
    writeln('Using GCC Compiler produced objs files');
    {$endif}
    writeln('-------------------------------------------------------------------');

    // Not working currently, so it's gave away right now.
    {$ifdef VCCompiler}
     {$ifdef HAVE_AVX2}
      fast_avx2_checkError();
     {$endif}
    {$endif}

    const wikipediasource: AnsiString =
    'Man is distinguished, not only by his reason, but by this singular passion from ' +
    'other animals, which is a lust of the mind, that by a perseverance of delight '   +
    'in the continued and indefatigable generation of knowledge, exceeds the short '   +
    'vehemence of any carnal pleasure.';

    const wikipediacoded: AnsiString =
    'TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlz'+
    'IHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2Yg'+
    'dGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGlu'+
    'dWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRo'+
    'ZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=';

    // from https://gobyexample.com/base64-encoding
    const gosource: AnsiString = 'abc123!?$*&()''-=@~';
    const gocoded : AnsiString = 'YWJjMTIzIT8kKiYoKSctPUB+';

    // from https://www.tutorialspoint.com/java8/java8_base64.htm
    const tutosource : AnsiString = 'TutorialsPoint?java8';
    const tutocoded  : AnsiString = 'VHV0b3JpYWxzUG9pbnQ/amF2YTg=';

    chromium_checkExample(@wikipediasource[1], @wikipediacoded[1]);
    chromium_checkExample(@gosource[1],   @gocoded[1]);
    chromium_checkExample(@tutosource[1], @tutocoded[1]);

	  {$ifdef HAVE_AVX2}
    klomp_avx2_checkExample(@wikipediasource[1], @wikipediacoded[1]);
    klomp_avx2_checkExample(@gosource[1],        @gocoded[1]);
    klomp_avx2_checkExample(@tutosource[1],      @tutocoded[1]);
    {$ENDIF}


    {.$define VC_Compiler}

    // ERROR in fast_avx2_checkExample (due to fast_avx2 encoding and decoding routines
    {$ifdef VCCompiler}
    writeln;
    writeln('--------------------------------------------------------------------------------');
    writeln('The fast_avx2 routines produced by VC compiler runs well anymore...!');
    writeln('--------------------------------------------------------------------------------');
    fast_avx2_checkExample(@wikipediasource[1], @wikipediacoded[1]);
    fast_avx2_checkExample(@gosource[1],        @gocoded[1]);
    fast_avx2_checkExample(@tutosource[1],      @tutocoded[1]);
    {$else}
    writeln;
    writeln('------------------------------------------------------------------------------------------');
    writeln('The fast_avx2 routines produced by GCC compiler dont run, and fails, so commented here...!');
    writeln('------------------------------------------------------------------------------------------');
    {$endif}

    scalar_checkExample(@wikipediasource[1],  @wikipediacoded[1]);
    scalar_checkExample(@gosource[1],         @gocoded[1]);
    scalar_checkExample(@tutosource[1],       @tutocoded[1]);


    //AVX512 codes dont WORK, will check Objs for AVX512BW routines
    {$ifdef VCCompiler}
    {$ifdef HAVE_AVX512}
    writeln;
    writeln('--------------------------------------------------------------------------------');
    writeln('The fast_avx512bw routines produced by VC compiler runs well anymore...!');
    writeln('--------------------------------------------------------------------------------');
    fast_avx512bw_checkExample(@wikipediasource[1], @wikipediacoded[1]);
    fast_avx512bw_checkExample(@gosource[1],        @gocoded[1]);
    fast_avx512bw_checkExample(@tutosource[1],      @tutocoded[1]);
    {$endif}
    {$else}
    writeln;
    writeln('------------------------------------------------------------------------------------------');
    writeln('The fast_avx512bw routines produced by GCC compiler dont run, and fails, so commented here...!');
    writeln('------------------------------------------------------------------------------------------');
    {$endif}

    var sFileName: String;
    //sFileName := VeryBigFileName;
    sFileName := BigFileName;

    writeln;
    writeln('Encode File: ' + sFileName + '  klomp_avx2_base64_encode...');

    var sts : TMemoryStream;
    sts := TMemoryStream.Create;
    sts.LoadFromFile(sFileName);
    sts.Position := 0;

    var ST      : TStopwatch;
    var dest1   : PAnsiChar;
    var source  : PAnsiChar;
    var codedlen: Integer;
    var len     : Integer;

    source := PAnsiChar(sts.Memory);

    //source := (StreamToString( sts, TEncoding.UTF8 ));
    //source      := PAnsiChar(sts.Memory);
    writeln(sFileName + ' file size (bytes): ', Length(source));
    dest1     := malloc(chromium_base64_encode_len(sts.Size));
    ST        := TStopwatch.StartNew;
    klomp_avx2_base64_encode(PAnsiChar(source), sts.Size, dest1, @codedlen);
    writeln(sFileName + ' file encoded length (bytes)   : ', codedlen);
    writeLn('klomp_avx2_base64_encode --> Time (ms): ', ST.ElapsedMilliseconds);


    var dest2: PAnsiChar;
    dest2    := malloc(chromium_base64_decode_len(codedlen));
    writeLn(sFileName + 'file is decoding...');
    ST       := TStopwatch.StartNew;
    klomp_avx2_base64_decode(dest1, codedlen, dest2, @len);
    writeLn('klomp_avx2_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    writeLn(sFileName + ' file decoded length (bytes): ', len);



  {$ifdef HAVE_AVX512BW}
    {$ifdef VCCompiler}
    //fast_avx512bw_base64_encode & fast_avx512bw_base64_decode
//    sts.Position := 0;
//    source := PAnsiChar(sts.Memory);

    //source := (StreamToString( sts, TEncoding.UTF8 ));
    //source      := PAnsiChar(sts.Memory);
//    writeln(sFileName + ' file size (bytes): ', Length(source));
//    dest1     := malloc(chromium_base64_encode_len(sts.Size));
//    ST        := TStopwatch.StartNew;
//    codedlen  := fast_avx512bw_base64_encode(dest1, PAnsiChar(source), sts.Size);
//    writeln(sFileName + ' file encoded length (bytes)   : ', codedlen);
//    writeLn('klomp_avx2_base64_encode --> Time (ms): ', ST.ElapsedMilliseconds);
//
//
//    var dest2: PAnsiChar;
//    dest2    := malloc(chromium_base64_decode_len(codedlen));
//    writeLn(sFileName + 'file is decoding...');
//    ST       := TStopwatch.StartNew;
//    klomp_avx2_base64_decode(dest1, codedlen, dest2, @len);
//    writeLn('klomp_avx2_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
//    writeLn(sFileName + ' file decoded length (bytes): ', len);
    {$endif}
  {$endif}


    //Make some tests ......

    var ss  : String;
    var stm : TStringStream;
    ss  := String(dest2);
    stm := TStringStream.Create( ss );
    stm.SaveToFile( sFileName + '-Enc_Decoded_StringUTF8.log' );
    FreeAndNil(stm);

    sts.Clear;
    sts.WriteData( dest2, len );
    sts.Position := 0;
    sts.SaveToFile(sFileName + '-Enc_Decoded.log');

    Free(dest1);
    Free(dest2);



   // System.NetEncoding tests
   sts.Position := 0;

   ST       := TStopwatch.StartNew;
   ss       := System.NetEncoding.TNetEncoding.Base64String.Encode( PAnsiChar(sts.Memory) );
   writeLn('System.NetEncoding.TNetEncoding.Base64String.Encode --> Time (ms): ', ST.ElapsedMilliseconds);
   writeLn(sFileName + ' file decoded length (bytes): ', Length(ss));
   writeLn(sFileName + 'file is decoding...');

   ST       := TStopwatch.StartNew;
   ss       := System.NetEncoding.TNetEncoding.Base64String.Decode( ss );
   writeLn('System.NetEncoding.TNetEncoding.Base64String.Decode --> Time (ms): ', ST.ElapsedMilliseconds);
   writeLn(sFileName + ' file decoded length (bytes): ', Length(ss));
   SaveStringToFile( sFileName + '-TNetEncoding.Base64-EncDec.log', ss, TEncoding.Default );


   var s: String;
   dest1 := Base64EncodeTxtKindFile( sFileName, len );
   s     := Base64DecodeTxtKindFile( dest1, len, codedlen, True, 'big-txt-Enc_DecodedFunction.log');
   Free(dest1);


   // Indy IdCoderMIME encoding/decoding tests
   sts.Position    := 0;

   var Bytes       : TIdBytes;
   var Base64String: String;
   sts.Read( TBytes(Bytes), sts.Size);
   //Bytes           := TIdBytes(PAnsiChar(sts.Memory)); // array of bytes
   ST              := TStopwatch.StartNew;
   Base64String    := TIdEncoderMIME.EncodeStream( sts );

   writeLn('TIdEncoderMIME.EncodeBytes --> Time (ms): ', ST.ElapsedMilliseconds);
   writeLn(sFileName + ' file decoded length (bytes): ', Length(Base64String));

   writeLn(sFileName + 'file is decoding...');
   ST           := TStopwatch.StartNew;
   Bytes        := TIdDecoderMIME.DecodeBytes(Base64String);
   writeLn('TIdEncoderMIME.DecodeBytes --> Time (ms): ', ST.ElapsedMilliseconds);
   writeLn(sFileName + ' file decoded length (bytes): ', Length(Bytes));

   SaveBytesToFile( TBytes(Bytes), sFileName + '-TIdDecoderMIME.Base64-EncDec.log', TEncoding.Default );

   SetLength(Bytes, 0);
   FreeAndNil(sts);


    WriteLn;
    WriteLn('Program finished... Press any key to quit.');
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;

end.

