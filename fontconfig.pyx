# -*- coding: utf-8
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: fontconfig.pyx
# @Date: 2011年10月28日 星期五 08时22分37秒

#------------------------------------------------
# Imports
#------------------------------------------------

import sys
from cfontconfig cimport *

__author__ = 'Vayn a.k.a VT <vayn@vayn.de>'
__license__ = 'GPLv3'
__version__ = '0.2.0'


#------------------------------------------------
# Code
#------------------------------------------------

class FcInitError(Exception):
  def __init__(self):
    self.value = "Can't init font config library"

  def __str__(self):
    return repr(self.value)


cdef class FontConfig:
  '''Python binding for Fontconfig

  >>> fc = FontConfig(lang=b'zh')
  >>> fc.lang
  b'zh'
  >>> fc.version  # Fontconfig version, 2.8.0
  20800
  >>> font = b'/usr/share/fonts/truetype/freefont/FreeMono.ttf'
  >>> fc.has_char(font, b'永')
  False
  b'forever'
  >>> fc.has_char(font, b'永')
  True
  '''
  cdef FcPattern *__pat
  cdef FcBlanks *__blanks
  cdef FcObjectSet *__os
  cdef FcFontSet *__fs
  cdef FcCharSet *__cs
  cdef bytes _lang

  def __cinit__(self, lang=b'zh'):
    if not FcInit():
      raise FcInitError
    FcFini()
    self._lang = b':lang=' + lang

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

  property lang:
    def __get__(self):
      return self._lang.split(b'=', 1)[1]
    def __set__(self, value):
      self._lang = b':lang=' + value

  cpdef bint has_char(self, char *file, char *ch):
    '''Check if character in the specified font'''
    cdef:
      int ret = 0
      int count
      FcChar32 uscch

    self.__blanks = FcConfigGetBlanks(NULL)
    self.__pat = FcFreeTypeQuery(<FcChar8*>file, 0, self.__blanks, &count)

    if FcPatternGetCharSet(self.__pat, FC_CHARSET, 0, &self.__cs)\
       != FcResultMatch:
      return ret

    FcUtf8ToUcs4(<FcChar8*>ch, &uscch, 3)
    if FcCharSetHasChar(self.__cs, uscch):
      ret = 1
    return ret

  def fc_query(self, char *file):
    '''Get details of the specified font'''
    cdef:
      int id = 0
      int count
      FcChar8 *f = <FcChar8*>file
      FcChar8 *v
      FcChar32 ch
      dict d = {}
      list l = []

    self.__blanks = FcConfigGetBlanks(NULL)
    self.__pat = FcFreeTypeQuery(f, 0, self.__blanks, &count)

    while 1:
      if FcPatternGetString(self.__pat, FC_FAMILY, id, &v) == FcResultMatch:
        l.append(<char*>v)
        id += 1
      else:
        d.update({'family': l})
        break

    id = 0
    l = []
    while 1:
      if FcPatternGetString(self.__pat, FC_STYLE, id, &v) == FcResultMatch:
        l.append(<char*>v)
        id += 1
      else:
        d.update({'style': l})
        break

    id = 0
    l = []
    while 1:
      if FcPatternGetString(self.__pat, FC_FONTFORMAT, id, &v) == FcResultMatch:
        l.append(<char*>v)
        id += 1
      else:
        d.update({'fontformat': l})
        break
    return d

  def fc_list(self):
    '''Return font list of which support specified language'''
    cdef:
      FcChar8 *strpat = <FcChar8*>(<char*>self._lang)
      FcChar8 *family
      FcChar8 *file
      FcChar32 ch
      list lst = []

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
