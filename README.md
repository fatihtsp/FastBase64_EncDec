                                            Ultrafast base64 encode/decode Library                

# FastBase64 Encoder / Decocder for Delphi.

This repository includes a Delphi port of AVX2 based FastBase64 Encoder and Decoder and some tests.
                                                                              

                                                                              
Orginal project: https://github.com/aklomp/base64                            
This is an implementation of a base64 stream encoding/decoding library in C99 with SIMD (AVX2, NEON, AArch64/NEON, SSSE3, SSE4.1, SSE4.2, AVX) and OpenMP acceleration. It also contains wrapper functions to encode/decode simple length-delimited strings.                                                    

The actual proje motivating is at https://github.com/lemire/fastbase64     
SIMD-accelerated base64 codecs.                                              
                                                                            
This is a Delphi port to Lemire's project from C code. This project is still in-development stage, but first test are very promising.
                                                                          
Copyright (c) 2022 Fatih Taşpınar, fatihtsp@gmail.com                     
All rights reserved.                                                      
                                                                          
Date: 10.03.2022                                                          
                                                                          
Notes:                                                                    
fast_avx2_base64_encode and fast_avx2_base64_decode routines does not work. All the other routines works well and really fast, but the fastest one is klomp's base64 encode and decode routines.

The unit file FastBase64U.pas includes these encode/decode functions:

Errornous fast_avx2 functions due to AVX2 that should be originated from and compilation settings in gcc
//Procedure fast_avx2_checkError();

Procedure chromium_checkExample(const source: PAnsiChar; const coded: PAnsichar);

Fastest base64 encode and decode in my tests klomp's functions, please consider to look at orginal C code using the link given above.
Procedure klomp_avx2_checkExample(const source: PAnsiChar; const coded: PAnsiChar);

Errornous  fast_avx2 encode/decode
//Procedure fast_avx2_checkExample(const source: PAnsiChar; const coded: PAnsiChar);

Procedure scalar_checkExample(const source: PAnsiChar; const coded: PAnsiChar);

Some inline routines from original code:

//#define chromium_base64_encode_len(A) ((A+2)/3 * 4 + 1)

Function chromium_base64_encode_len(Alen: Integer): Integer; 

//#define chromium_base64_decode_len(A) (A / 4 * 3 + 2)

Function chromium_base64_decode_len(Alen: Integer): Integer; 



Use klomp_avx2_base64_encode routine to encode bytes in Filename file. Returns the encoded data as PAnsichar and its length with EncodedLen.

Function Base64EncodeTxtKindFile( const FileName: String; out EncodedLen: Integer ): PAnsiChar;

Use klomp_avx2_base64_decode routine to decode bytes in EncodedData which is PAnsiChar. Returns the result as String and its length with DataLen. Also, one can save the decoded data to file with appropriate Saving options.

Function Base64DecodeTxtKindFile( const EncodedData: PAnsiChar; const DataLen: Integer;
                                  out DecodedLen: Integer;
                                  const saveToFile: Boolean=False;
                                  const SavingFileName: String = 'encodedTxtKindFile.txt' ): String;


Test Results from command windows:


Ultrafast base64 encode/decode library
https://github.com/fatihtsp/FastBase64_EncDec
-------------------------------------------------------------------
chromium codec check.
chromium_base64_encode --> Time (ms): 0
decoded:
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
real   :
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
chromium_base64_decode --> Time (ms): 0
chromium_base64_decode --> Time (ms): 0
chromium codec check.
chromium_base64_encode --> Time (ms): 0
decoded:
YWJjMTIzIT8kKiYoKSctPUB+
real   :
YWJjMTIzIT8kKiYoKSctPUB+
chromium_base64_decode --> Time (ms): 0
chromium_base64_decode --> Time (ms): 0
chromium codec check.
chromium_base64_encode --> Time (ms): 0
decoded:
VHV0b3JpYWxzUG9pbnQ/amF2YTg=
real   :
VHV0b3JpYWxzUG9pbnQ/amF2YTg=
chromium_base64_decode --> Time (ms): 0
chromium_base64_decode --> Time (ms): 0
klomp avx2 codec check.
klomp_avx2_base64_encode --> Time (ms): 0
decoded:
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
real   :
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
klomp_avx2_base64_decode --> Time (ms): 0
klomp_avx2_base64_decode --> Time (ms): 0
klomp avx2 codec check.
klomp_avx2_base64_encode --> Time (ms): 0
decoded:
YWJjMTIzIT8kKiYoKSctPUB+
real   :
YWJjMTIzIT8kKiYoKSctPUB+
klomp_avx2_base64_decode --> Time (ms): 0
klomp_avx2_base64_decode --> Time (ms): 0
klomp avx2 codec check.
klomp_avx2_base64_encode --> Time (ms): 0
decoded:
VHV0b3JpYWxzUG9pbnQ/amF2YTg=
real   :
VHV0b3JpYWxzUG9pbnQ/amF2YTg=
klomp_avx2_base64_decode --> Time (ms): 0
klomp_avx2_base64_decode --> Time (ms): 0

scalar codec check.
scalar_base64_encode --> Time (ms): 0
decoded:
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
real   :
TWFuIGlzIGRpc3Rpbmd1aXNoZWQsIG5vdCBvbmx5IGJ5IGhpcyByZWFzb24sIGJ1dCBieSB0aGlzIHNpbmd1bGFyIHBhc3Npb24gZnJvbSBvdGhlciBhbmltYWxzLCB3aGljaCBpcyBhIGx1c3Qgb2YgdGhlIG1pbmQsIHRoYXQgYnkgYSBwZXJzZXZlcmFuY2Ugb2YgZGVsaWdodCBpbiB0aGUgY29udGludWVkIGFuZCBpbmRlZmF0aWdhYmxlIGdlbmVyYXRpb24gb2Yga25vd2xlZGdlLCBleGNlZWRzIHRoZSBzaG9ydCB2ZWhlbWVuY2Ugb2YgYW55IGNhcm5hbCBwbGVhc3VyZS4=
scalar_base64_decode --> Time (ms): 0
scalar_base64_decode --> Time (ms): 0

scalar codec check.
scalar_base64_encode --> Time (ms): 0
decoded:
YWJjMTIzIT8kKiYoKSctPUB+
real   :
YWJjMTIzIT8kKiYoKSctPUB+
scalar_base64_decode --> Time (ms): 0
scalar_base64_decode --> Time (ms): 0

scalar codec check.
scalar_base64_encode --> Time (ms): 0
decoded:
VHV0b3JpYWxzUG9pbnQ/amF2YTg=
real   :
VHV0b3JpYWxzUG9pbnQ/amF2YTg=
scalar_base64_decode --> Time (ms): 0
scalar_base64_decode --> Time (ms): 0

Encode File: VeryBigFile.txt  klomp_avx2_base64_encode...
VeryBigFile.txt file size (bytes): 28600157
VeryBigFile.txt file encoded length (bytes)   : 38133544
klomp_avx2_base64_encode --> Time (ms): 20
VeryBigFile.txtfile is decoding...
klomp_avx2_base64_decode --> Time (ms): 24
VeryBigFile.txt file decoded length (bytes): 28600157
System.NetEncoding.TNetEncoding.Base64String.Encode --> Time (ms): 323
VeryBigFile.txt file decoded length (bytes): 38215124
VeryBigFile.txtfile is decoding...
System.NetEncoding.TNetEncoding.Base64String.Decode --> Time (ms): 289
VeryBigFile.txt file decoded length (bytes): 28600157

Program finished... Press any key to quit.

