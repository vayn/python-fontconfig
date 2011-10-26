# file: cfontconfig.pxd
# -*- coding: utf-8; -*-

cdef extern from "fontconfig/fontconfig.h":

  cdef char* FC_FAMILY 'FC_FAMILY'
  cdef char* FC_FILE 'FC_FILE'
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

  ctypedef struct FcBlanks:
    pass
  ctypedef struct FcConfig:
    pass
  ctypedef struct FcCharSet:
    pass
  ctypedef struct FcFontSet:
    int nfont
    int sfont
    FcPattern **fonts
  ctypedef struct FcObjectSet:
    pass
  ctypedef struct FcPattern:
    pass

  FcPattern* FcPatternCreate()
  FcPattern* FcFreeTypeQuery(FcChar8 *, int, FcBlanks *, int *)
  FcPattern* FcNameParse(FcChar8 *)
  void FcPatternDestroy(FcPattern *)

  FcBlanks* FcBlanksCreate()
  FcBlanks* FcConfigGetBlanks(FcConfig *)
  void FcBlanksDestroy(FcBlanks *)

  FcObjectSet* FcObjectSetCreate()
  FcObjectSet* FcObjectSetBuild(char *, ...)
  void FcObjectSetDestroy(FcObjectSet *)

  FcFontSet* FcFontSetCreate()
  FcFontSet* FcFontList(FcConfig *, FcPattern *, FcObjectSet *)
  void FcFontSetDestroy(FcFontSet *)

  FcCharSet* FcCharSetCreate()
  void FcCharSetDestroy(FcCharSet *)

  int FcGetVersion()
  int FcUtf8ToUcs4(FcChar8 *, FcChar32 *, int)
  void FcPatternPrint(FcPattern *)
  FcBool FcCharSetHasChar(FcCharSet *, FcChar32)
  FcResult FcPatternGetCharSet(FcPattern *, char *, int, FcCharSet **)
  FcResult FcPatternGetString(FcPattern *, char *, int, FcChar8 **)
