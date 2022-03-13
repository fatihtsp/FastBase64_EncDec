# FastBase64 Encoder / Decocder for Delphi.

This repository includes a Delphi port of AVX2 based FastBase64 Encoder and Decoder and some tests.

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
{                                                                              }
{ Date: 10.03.2022                                                             }
{                                                                              }
{ Notes:                                                                       }
{ fast_avx2_base64_encode and fast_avx2_base64_decode routines does not work   }
{ All the other routines works well and really fast, but the fastest one is    }
{ fast_avx2_base64_encode and fast_avx2_base64_decode                          }
{                                                                              }
{******************************************************************************}
