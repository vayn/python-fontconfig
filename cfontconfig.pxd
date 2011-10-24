# file: cfontconfig.pxd
# -*- coding: utf-8; -*-

cdef extern from "fontconfig/fontconfig.h":

  cdef char* FC_CHARSET 'FC_CHARSET'

  ctypedef unsigned char FcChar8
  ctypedef unsigned char FcChar32
  ctypedef bint FcBool

  ctypedef enum FcResult '_FcResult':
    FcResultMatch
    FcResultNoMatch
    FcResultTypeMismatch
    FcResultNoId
    FcResultOutOfMemory

  ctypedef struct FcConfig:
    pass
  ctypedef struct FcCharSet:
    pass

  ctypedef struct FcBlanks:
    pass
  ctypedef struct FcPattern:
    pass

  FcPattern* FcPatternCreate()
  FcPattern* FcFreeTypeQuery(FcChar8 *, int, FcBlanks *, int *)

  FcBool FcCharSetHasChar(FcCharSet *, FcChar32)
  FcResult FcPatternGetCharSet(FcPattern *, char *, int, FcCharSet **)
  FcBlanks* FcConfigGetBlanks(FcConfig *)
  int FcGetVersion()
  int FcUtf8ToUcs4(FcChar8 *, FcChar32 *, int)
  void FcPatternDestroy(FcPattern *)
