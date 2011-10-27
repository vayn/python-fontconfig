# file: fontconfig.pyx
# -*- coding: utf-8; -*-
'''Python binding for fontconfig'''

import sys
from cfontconfig cimport *

__license__ = 'GPLv3'
__version__ = '0.1.0'


cdef class FontConfig:
  cdef FcPattern *__pat
  cdef FcBlanks *__blanks
  cdef FcObjectSet *__os
  cdef FcFontSet *__fs
  cdef FcCharSet *__cs

  def __cinit__(self):
    self.__pat = NULL
    self.__blanks = NULL
    self.__os = NULL
    self.__fs = NULL
    self.__cs = NULL

  def __dealloc__(self):
    if self.__pat is not NULL:
      FcPatternDestroy(self.__pat)
    if self.__blanks is not NULL:
      FcBlanksDestroy(self.__blanks)
    if self.__os is not NULL:
      FcObjectSetDestroy(self.__os)
    if self.__fs is not NULL:
      FcFontSetDestroy(self.__fs)

  property version:
    def __get__(self):
      return FcGetVersion()


cdef class FontPattern(FontConfig):
  cdef public bytes ch
  cdef bytes _lang

  def __init__(self, lang=b'zh', ch=b'永'):
    self._lang = b':lang=' + lang
    self.ch = ch

  property lang:
    def __get__(self):
      return self._lang.split(b'=', 1)[1]
    def __set__(self, value):
      self._lang = b':lang=' + value

  def get_info(self, char *file):
    '''Get details of the specified font'''
    cdef:
      int count
      FcChar8 *f = <FcChar8*>file
      FcChar8 *family
      FcChar8 *style
      FcChar8 *stylelang
      FcChar8 *fontformat
      FcChar32 ch
      object info = {}

    self.__blanks = FcConfigGetBlanks(NULL)
    self.__pat = FcFreeTypeQuery(f, 0, self.__blanks, &count)

    if FcPatternGetString(self.__pat, FC_FAMILY, 1, &family)\
       == FcResultMatch:
      info.update({'family': <char*>family})
    elif FcPatternGetString(self.__pat, FC_FAMILY, 0, &family)\
       == FcResultMatch:
      info.update({'family': <char*>family})

    if FcPatternGetString(self.__pat, FC_STYLE, 0, &style)\
       == FcResultMatch:
      info.update({'style': <char*>style})

    if FcPatternGetString(self.__pat, FC_FONTFORMAT, 0, &fontformat)\
       == FcResultMatch:
      info.update({'fontformat': <char*>fontformat})

    return info

  cpdef bint has_char(self, char *file):
    '''Check if self.ch in the specified font'''
    cdef:
      int ret = 0
      int count
      FcChar32 ch
      FcChar8 *f = <FcChar8*>file

    self.__blanks = FcConfigGetBlanks(NULL)
    self.__pat = FcFreeTypeQuery(f, 0, self.__blanks, &count)

    if FcPatternGetCharSet(self.__pat, FC_CHARSET, 0, &self.__cs)\
       != FcResultMatch:
      return ret

    FcUtf8ToUcs4(<FcChar8*>(<char*>self.ch), &ch, 3)
    if FcCharSetHasChar(self.__cs, ch):
      ret = 1
    return ret

  def get_list(self):
    '''Return font list of which support specified language'''
    cdef:
      FcChar8* strpat = <FcChar8*>(<char*>self._lang)
      FcChar8 *family
      FcChar8 *file
      FcChar32 ch
      object lst = []

    self.__pat = FcNameParse(strpat)
    self.__os = FcObjectSetBuild(FC_FAMILY, FC_CHARSET, FC_FILE, NULL)
    self.__fs = FcFontList(<FcConfig*>0, self.__pat, self.__os)

    if (self.__fs is NULL) or (self.__fs.nfont <= 0):
      return lst

    cdef int i
    for i in range(self.__fs.nfont):
      if FcPatternGetCharSet(self.__fs.fonts[i], FC_CHARSET, 0, &self.__cs)\
         != FcResultMatch:
        continue
      if FcPatternGetString(self.__fs.fonts[i], FC_FAMILY, 1, &family)\
         != FcResultMatch:
        if FcPatternGetString(self.__fs.fonts[i], FC_FAMILY, 0, &family)\
           != FcResultMatch:
          continue
      if FcPatternGetString(self.__fs.fonts[i], FC_FILE, 0, &file)\
         != FcResultMatch:
        continue
      lst.append((<char*>family, <char*>file))
    return lst
