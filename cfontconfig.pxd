# -*- coding: utf-8
# @Author: Vincent Tsai <vayn@vayn.de>
# @Name: cfontconfig.pxd
# @Date: 2011年 10月 28日 星期五 08:23:02 CST

#-----------------------------------------------
# Code
#-----------------------------------------------

cdef extern from "fontconfig/fontconfig.h":

  cdef char *FC_FAMILY 'FC_FAMILY'
  cdef char *FC_FAMILYLANG 'FC_FAMILYLANG'
  cdef char *FC_FILE 'FC_FILE'
  cdef char *FC_CHARSET 'FC_CHARSET'
  cdef char *FC_FOUNDRY 'FC_FOUNDRY'
  cdef char *FC_SLANT 'FC_SLANT'
  cdef char *FC_STYLE 'FC_STYLE'
  cdef char *FC_LANG 'FC_LANG'
  cdef char *FC_STYLELANG 'FC_STYLELANG'
  cdef char *FC_FULLNAME 'FC_FULLNAME'
  cdef char *FC_FULLNAMELANG 'FC_FULLNAMELANG'
  cdef char *FC_FONTFORMAT 'FC_FONTFORMAT'
  cdef char *FC_INDEX 'FC_INDEX'
  cdef char *FC_WEIGHT 'FC_WEIGHT'
  cdef char *FC_WIDTH 'FC_WIDTH'
  cdef char *FC_SPACING 'FC_SPACING'
  cdef char *FC_CAPABILITY 'FC_CAPABILITY'
  cdef char *FC_SCALABLE 'FC_SCALABLE'
  cdef char *FC_OUTLINE 'FC_OUTLINE'
  cdef char *FC_DECORATIVE 'FC_DECORATIVE'
  ctypedef unsigned char FcChar8
  ctypedef unsigned int FcChar32
  ctypedef bint FcBool

  ctypedef enum FcResult 'FcResult':
    FcResultMatch
    FcResultNoMatch
    FcResultTypeMismatch
    FcResultNoId
    FcResultOutOfMemory

  ctypedef struct FcType:
    pass
  ctypedef struct FcBlanks:
    pass
  ctypedef struct FcMatrix:
    pass
  ctypedef struct FcConfig:
    pass
  ctypedef struct FcCharSet:
    pass
  ctypedef struct FcLangSet:
    pass
  ctypedef struct FcFontSet:
    int nfont
    int sfont
    FcPattern **fonts
  ctypedef union FcValue_union:
    FcChar8 *s
    int i
    FcBool b
    double d
    FcMatrix *m
    FcCharSet *c
    void *f
    FcLangSet *l
  ctypedef struct FcValue:
    FcType type
    FcValue_union u
  ctypedef struct FcObjectSet:
    pass
  ctypedef struct FcPattern:
    pass

  FcPattern * FcPatternCreate()
  FcPattern * FcFreeTypeQuery(FcChar8 *, int, FcBlanks *, int *)
  FcPattern * FcNameParse(FcChar8 *)
  void FcPatternPrint(FcPattern *)
  void FcPatternDestroy(FcPattern *)

  FcBlanks * FcBlanksCreate()
  FcBlanks * FcConfigGetBlanks(FcConfig *)
  void FcBlanksDestroy(FcBlanks *)

  FcObjectSet * FcObjectSetCreate()
  FcObjectSet * FcObjectSetBuild(char *, ...)
  void FcObjectSetDestroy(FcObjectSet *)

  FcFontSet * FcFontSetCreate()
  FcFontSet * FcFontList(FcConfig *, FcPattern *, FcObjectSet *)
  void FcFontSetDestroy(FcFontSet *)

  FcCharSet * FcCharSetCreate()
  FcChar32 FcCharSetCount(FcCharSet *)
  void FcCharSetDestroy(FcCharSet *)

  FcBool FcCharSetHasChar(FcCharSet *, FcChar32)
  FcResult FcPatternGet(FcPattern *, char *, int, FcValue *)
  FcResult FcPatternGetCharSet(FcPattern *, char *, int, FcCharSet **)
  FcResult FcPatternGetString(FcPattern *, char *, int, FcChar8 **)
  FcResult FcPatternGetInteger(FcPattern *, char *, int, int *)
  FcResult FcPatternGetBool(FcPattern *, char *, int, FcBool *)

  FcStrSet * FcLangSetGetLangs(FcLangSet *ls)

  void FcValuePrint(FcValue)
  int FcGetVersion()
  int FcUtf8ToUcs4(FcChar8 *, FcChar32 *, int)

cdef extern from "fcmore.h":
  ctypedef struct FcStrSet:
    int ref
    int num
    int size
    FcChar8 **strs

