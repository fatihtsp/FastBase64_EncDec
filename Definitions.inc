//Definitions.inc


{$define HAVE_AVX2}
{.$define HAVE_AVX512BW}   //{$ifdef fast_AVX512BW routines fails...!! Commented

{.$define GCCCompiler}
{$define VCCompiler}

{$ifdef GCCCompiler}
{$undef VCCompiler}
{$endif}

{$if not (Defined(GCCCompiler) and Defined(VCCompiler))}
{$define VCCompiler}
{$endif}


