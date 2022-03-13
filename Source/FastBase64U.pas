{******************************************************************************}
{                                                                              }
{               Ultrafast base64 encode/decode Library                         }
{                                                                              }
{ Orginal project: https://github.com/aklomp/base64                            }
{ This is an implementation of a base64 stream encoding/decoding library in C99}
{ with SIMD (AVX2, NEON, AArch64/NEON, SSSE3, SSE4.1, SSE4.2, AVX) and OpenMP  }
{ acceleration. It also contains wrapper functions to encode/decode simple     }
{ length-delimited strings.                                                    }
{                                                                              }
{ The actual proje motivating is at https://github.com/lemire/fastbase64       }
{ SIMD-accelerated base64 codecs.                                              }
{                                                                              }
{ This is Delphi port to Lemire's project from C code.                         }
{                                                                              }
{ Copyright (c) 2022 Fatih Taşpınar, fatihtsp@gmail.com                        }
{ All rights reserved.                                                         }
{ https://github.com/fatihtsp/FastBase64_EncDec                                }
{                                                                              }
{ Date: 10.03.2022                                                             }
{                                                                              }
{ Notes:                                                                       }
{ fast_avx2_base64_encode and fast_avx2_base64_decode routines does not work   }
{ All the other routines works well and really fast, but the fastest one is    }
{ klomp_avx2_base64_encode and klomp_avx2_base64_decode                          }
{                                                                              }
{******************************************************************************}


unit FastBase64U;

interface

uses
 System.SysUtils, System.Classes, System.Win.Crtl, System.Math,
 System.SyncObjs, System.Diagnostics;

{$Z4}

{.$define UNDERSCOREIMPORTNAME}

const
{$IFDEF UNDERSCOREIMPORTNAME}
  _PU = '_';
{$ELSE}
  _PU = '';
{$ENDIF}


type
  {$REGION 'C types'}

  bool       = System.Boolean;
  {$IF CompilerVersion < 31}
  char       = System.AnsiChar;
  {$ELSE}
  char       = System.UTF8Char;
  {$ENDIF}
  char16_t   = System.Char;
  double     = System.Double;
  float      = System.Single;
  int16_t    = System.SmallInt;
  int32_t    = System.Integer;
  int64_t    = System.Int64;
  int8_t     = System.ShortInt;
  intptr_t   = System.NativeInt;
  long       = System.LongInt;
  size_t     = System.NativeUInt;
  uint16_t   = System.Word;
  uint32_t   = System.Cardinal;
  uint64_t   = System.UInt64;
  uint8_t    = System.Byte;
  uintptr_t  = System.NativeUInt;

  pbool      = ^bool;
  pchar      = ^char;
  pchar16_t  = ^char16_t;
  pdouble    = ^double;
  pfloat     = ^float;
  pint16_t   = ^int16_t;
  pint32_t   = ^int32_t;
  pint64_t   = ^int64_t;
  pint8_t    = ^int8_t;
  pintptr_t  = ^intptr_t;
  plong      = ^long;
  psize_t    = ^size_t;
  puint16_t  = ^uint16_t;
  puint32_t  = ^uint32_t;
  puint64_t  = ^uint64_t;
  puint8_t   = ^uint8_t;
  puintptr_t = ^uintptr_t;

  {$ENDREGION}


function chromium_base64_encode(dest: PAnsiChar; const str: PAnsiChar; len: size_t ): size_t; cdecl;
         external name _PU + 'chromium_base64_encode';

function chromium_base64_decode(dest: PAnsiChar; const str: PAnsiChar; len: size_t ): size_t; cdecl;
         external name _PU + 'chromium_base64_decode';

function fast_avx2_base64_encode(dest: PAnsiChar; const str: PAnsiChar; len: size_t): size_t; cdecl;
         external name _PU + 'fast_avx2_base64_encode';

function fast_avx2_base64_decode(_out: PAnsiChar; const src: PAnsiChar; srclen: size_t): size_t; cdecl;
         external name _PU + 'fast_avx2_base64_decode';

Procedure klomp_avx2_base64_encode(const src: PAnsiChar; srclen: size_t ; _out: PAnsiChar; outlen: Psize_t); cdecl;
         external name _PU + 'klomp_avx2_base64_encode';

function klomp_avx2_base64_decode(const src: PAnsiChar; srclen: size_t; _out: PAnsiChar; outlen: Psize_t): size_t; cdecl;
         external name _PU + 'klomp_avx2_base64_decode';

Procedure scalar_base64_encode(const src: PAnsiChar; srclen: size_t; _out: PAnsiChar; outlen: Psize_t); cdecl;
         external name _PU + 'scalar_base64_encode';

function scalar_base64_decode(const src: PAnsiChar; srclen: size_t; _out: PAnsiChar; outlen: Psize_t): size_t; cdecl;
         external name _PU + 'scalar_base64_decode';


Procedure fast_avx2_checkError();
Procedure chromium_checkExample(const source: PAnsiChar; const coded: PAnsichar);
Procedure klomp_avx2_checkExample(const source: PAnsiChar; const coded: PAnsiChar);
Procedure fast_avx2_checkExample(const source: PAnsiChar; const coded: PAnsiChar);
Procedure scalar_checkExample(const source: PAnsiChar; const coded: PAnsiChar);

Function chromium_base64_encode_len(Alen: Integer): Integer; //#define chromium_base64_encode_len(A) ((A+2)/3 * 4 + 1)
Function chromium_base64_decode_len(Alen: Integer): Integer; //#define chromium_base64_decode_len(A) (A / 4 * 3 + 2)


// Use klomp_avx2_base64_encode routine to encode bytes in Filename file.
// Return the encoded data as PAnsichar and its length with EncodedLen.
Function Base64EncodeTxtKindFile( const FileName: String; out EncodedLen: Integer ): PAnsiChar;

// Use klomp_avx2_base64_decode routine to decode bytes in EncodedData which is PAnsiChar.
// Return the result as String and its length with DataLen.
// Also, one can save the decoded data to file with appropriate Saving options.
Function Base64DecodeTxtKindFile( const EncodedData: PAnsiChar; const DataLen: Integer;
                                  out DecodedLen: Integer;
                                  const saveToFile: Boolean=False;
                                  const SavingFileName: String = 'encodedTxtKindFile.txt' ): String;

const base64_table_enc: AnsiString = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ' +
                                     'abcdefghijklmnopqrstuvwxyz' +
                                     '0123456789+/';

var ST: TStopwatch;

implementation

// Not: Win32 implementation does not coded, if you need please compileLemiere's
// orginal C code via gcc for win32. Here, just Win64 obj's produced and used.

{$ifdef Win32}
  //{.$L objs\Win32\chromiumbase64.obj}
  //{.$L objs\Win32\fastavxbase64.obj}
{$else}
  {$L objs\Win64\chromiumbase64.o}
  {$L objs\Win64\fastavxbase64.o}
  {$L objs\Win64\klompavxbase64.o}
  {$L objs\Win64\scalarbase64.o}
{$endif}


Function chromium_base64_encode_len(Alen: Integer): Integer;
begin
 Result := (ceil((Alen+2)/3) * 4 + 1);
end;

Function chromium_base64_decode_len(Alen: Integer): Integer;
begin
 Result := (floor(Alen / 4 * 3) + 2);
end;


// Not: fast_avx2_encode and fast_avx2_decode routines dont work!!!!
Procedure fast_avx2_checkError();
var
 source : AnsiString; //array[0..64-1] of Ansichar;
 dest   : AnsiString; //array[0..48-1] of Ansichar;
 z      : Integer;
 zz     : Integer;
 i      : Integer;
 len    : Integer;
 in_list: boolean;
 pos    : Integer;
 pc     : PAnsiChar;

begin
 writeln('fast_avx2 codec error check.\n');
 writeln(base64_table_enc[1]);
 writeln('size of char    : ', sizeof(char));
 writeln('size of ansichar: ', sizeof(ansichar));

 SetLength(source, 65);source[65] := #0;
 SetLength(dest, 49);  dest[49]   := #0;

 //pc := @dest[0];
 for z := 0 to 64-1 do begin
  for i := 0 to 64-1 do source[i+1] := base64_table_enc[z+1];
  len := fast_avx2_base64_decode(@dest[1], @source[1], 64);
  //writeLn(len);
  //assert(len = 48);
 end;
 writeln('(1) ok\n');

// for z := 0 to 255 do begin
//  in_list := false;
//  for zz := 0 to 64-1 do
//   if (base64_table_enc[zz] = char(z)) then in_list := true;
//   if (not in_list) then begin
//    for pos := 0 to 32-1 do begin
//     for i := 0 to 64-1 do source[i] := 'A';
//     source[pos] := char(z);
//     len := fast_avx2_base64_decode(@dest, @source, 64);
//     assert(len = -1);
//    end;
//   end;
// end;

end;


Procedure chromium_checkExample(const source: PAnsiChar; const coded: PAnsichar);
begin
    writeLn('chromium codec check.');
    var len: integer;
    var codedlen: Integer;

    var dest1: PAnsiChar;
    dest1    := malloc(chromium_base64_encode_len(StrLen(source)));
    ST       := TStopwatch.StartNew;
    codedlen := chromium_base64_encode(dest1, source, Strlen(source));
    writeLn('chromium_base64_encode --> Time (ms): ', ST.ElapsedMilliseconds);

    writeLn('decoded: ');
    writeLn(dest1);
    writeLn('real   : ');
    writeLn(coded);
    //assert(strncmp(dest1, coded, codedlen) = 0);

    var dest2: PAnsiChar;
    dest2    := malloc(chromium_base64_decode_len(codedlen));
    ST := TStopwatch.StartNew;
    len      := chromium_base64_decode(dest2, coded, codedlen);
    writeLn('chromium_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len = strlen(source));
    //assert(strncmp(dest2, source, strlen(source)) == 0);

    var dest3: PAnsiChar;
    dest3    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    len      := chromium_base64_decode(dest3, dest1, codedlen);
    writeLn('chromium_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest3, source, strlen(source)) == 0);

    free(dest1);
    free(dest2);
    free(dest3);
end;


Procedure klomp_avx2_checkExample(const source: PAnsiChar; const coded: PAnsiChar);
begin
    writeln('klomp avx2 codec check.');
    var len: integer;
    var codedlen: Integer;

    var dest1: PAnsiChar;
    dest1    := malloc(chromium_base64_encode_len(strlen(source)));
    ST       := TStopwatch.StartNew;
    klomp_avx2_base64_encode(source, strlen(source), dest1, @codedlen);
    writeLn('klomp_avx2_base64_encode --> Time (ms): ', ST.ElapsedMilliseconds);

    //assert(strncmp(dest1, coded, codedlen) == 0);
    writeLn('decoded: '); writeLn(dest1);
    writeLn('real   : '); writeLn(coded);

    var dest2: PAnsiChar;
    dest2    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    klomp_avx2_base64_decode(coded, codedlen, dest2, @len);
    writeLn('klomp_avx2_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest2, source, strlen(source)) == 0);

    var dest3: PAnsiChar;
    dest3    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    klomp_avx2_base64_decode(dest1, codedlen, dest3, @len);
    writeLn('klomp_avx2_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest3, source, strlen(source)) == 0);

    free(dest1);
    free(dest2);
    free(dest3);
end;


Procedure fast_avx2_checkExample(const source: PAnsiChar; const coded: PAnsiChar);
begin
    writeLn;
    writeLn('fast_avx2 codec check.');
    var len     : Integer;
    var codedlen: Integer;

    var dest1: PAnsiChar;
    dest1    := malloc(chromium_base64_encode_len(Strlen(source)));
    ST       := TStopwatch.StartNew;
    codedlen := fast_avx2_base64_encode(dest1, source, Strlen(source));
    writeLn('fast_avx2_base64_encode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(strncmp(dest1, coded, codedlen) = 0);
    writeLn('decoded: '); writeLn(dest1);
    writeLn('real   : '); writeLn(coded);


    var dest2: PAnsiChar;
    dest2    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    len      := fast_avx2_base64_decode(dest2, coded, codedlen);
    writeLn('fast_avx2_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest2, source, strlen(source)) == 0);

    var dest3: PAnsiChar;
    dest3    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    len      := fast_avx2_base64_decode(dest3, dest1, codedlen);
    writeLn('fast_avx2_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest3, source, strlen(source)) == 0);

    free(dest1);
    free(dest2);
    free(dest3);
end;


Procedure scalar_checkExample(const source: PAnsiChar; const coded: PAnsiChar);
begin
    writeLn;
    writeln('scalar codec check.');
    var len     : Integer;
    var codedlen: Integer;

    var dest1: PAnsiChar;
    dest1    := malloc(chromium_base64_encode_len(strlen(source)));
    ST       := TStopwatch.StartNew;
    scalar_base64_encode(source, strlen(source), dest1, @codedlen);
    writeLn('scalar_base64_encode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(strncmp(dest1, coded, codedlen) == 0);
    writeLn('decoded: '); writeLn(dest1);
    writeLn('real   : '); writeLn(coded);

    var dest2: PAnsiChar;
    dest2    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    scalar_base64_decode(coded, codedlen, dest2, @len);
    writeLn('scalar_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest2, source, strlen(source)) = 0);

    var dest3: PAnsiChar;
    dest3    := malloc(chromium_base64_decode_len(codedlen));
    ST       := TStopwatch.StartNew;
    scalar_base64_decode(dest1, codedlen, dest3, @len);
    writeLn('scalar_base64_decode --> Time (ms): ', ST.ElapsedMilliseconds);
    //assert(len == strlen(source));
    //assert(strncmp(dest3, source, strlen(source)) == 0);

    free(dest1);
    free(dest2);
    free(dest3);
end;


Function Base64EncodeTxtKindFile( const FileName: String; out EncodedLen: Integer ): PAnsiChar;
var
 sts     : TMemoryStream;
 source  : PAnsiChar;
 //srcLen  : Integer;

begin
 Result := Nil;
 try
  try
   sts          := TMemoryStream.Create;
   sts.LoadFromFile(FileName);
   sts.Position := 0;
   source       := PAnsiChar(sts.Memory);
   //srcLen     := StrLen(source);
   Result       := malloc(chromium_base64_encode_len(sts.Size));
   klomp_avx2_base64_encode(PAnsiChar(source), sts.size, Result, @EncodedLen);
  except
   Result := Nil;
   Exit;
  end;
 finally
  FreeAndNil(sts);
 end;

end;

Function Base64DecodeTxtKindFile( const EncodedData: PAnsiChar; const DataLen: Integer;
                                  out DecodedLen: Integer;
                                  const saveToFile: Boolean=False;
                                  const SavingFileName: String = 'encodedTxtKindFile.txt' ): String;
var
 dest2: PAnsiChar;
 sts  : TMemoryStream;

begin
 try
  Result := '';
  dest2  := malloc( chromium_base64_decode_len(DataLen) );
  klomp_avx2_base64_decode( EncodedData, DataLen, dest2, @DecodedLen );
  Result := String(dest2);

  if saveToFile then begin
    sts  := TMemoryStream.Create;
    sts.Clear;
    sts.WriteData( dest2, DecodedLen );
    sts.Position := 0;
    sts.SaveToFile(SavingFileName);
    FreeAndNil(sts);
  end;

 finally
  Free(dest2);
  dest2 := Nil;
 end;
end;



end.
