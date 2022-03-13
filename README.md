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
