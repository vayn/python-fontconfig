# file: fontconfig.pyx
# -*- coding: utf-8; -*-

import sys
from cfontconfig cimport *

__license__ = 'GPLv3'
__version__ = '0.1.0'


cdef class FontConfig:
  '''Python binding for fontconfig'''
  cdef FcPattern* _c_pat
  cdef FcBlanks* _c_blanks
  cdef FcObjectSet* _c_os
  cdef FcFontSet* _c_fs
  cdef FcCharSet* _c_cs

  def __cinit__(self):
    self._c_pat = FcPatternCreate()
    self._c_blanks = FcBlanksCreate()
    self._c_os = FcObjectSetCreate()
    self._c_fs = FcFontSetCreate()

    if self._c_pat is NULL:
      raise MemoryError()
    if self._c_blanks is NULL:
      raise MemoryError()
    if self._c_os is NULL:
      raise MemoryError()
    if self._c_fs is NULL:
      raise MemoryError()

  def __dealloc__(self):
    if self._c_pat is not NULL:
      FcPatternDestroy(self._c_pat)
    if self._c_blanks is not NULL:
      FcBlanksDestroy(self._c_blanks)
    if self._c_os is not NULL:
      FcObjectSetDestroy(self._c_os)
    if self._c_fs is not NULL:
      FcFontSetDestroy(self._c_fs)

  cpdef object families(self):
    '''Return font-families of which support Chinese'''
    cdef:
      FcChar8* strpat = <FcChar8*>(<unsigned char*>":lang=zh")
      FcChar8 *family
      FcChar8 *file
      FcChar32 ch
      object families = []

    self._c_pat = FcNameParse(strpat)
    self._c_os = FcObjectSetBuild(FC_FAMILY, FC_CHARSET, FC_FILE, <char*>0)
    self._c_fs = FcFontList(<FcConfig*>0, self._c_pat, self._c_os)

    if (self._c_fs is NULL) or (self._c_fs.nfont <= 0):
      return families

    FcUtf8ToUcs4(<FcChar8*>(<unsigned char*>"永"), &ch, 3)
    cdef int i
    for i in range(self._c_fs.nfont):
      if FcPatternGetCharSet(self._c_fs.fonts[i], FC_CHARSET, 0, &self._c_cs)\
         != FcResultMatch:
        continue
      if FcPatternGetString(self._c_fs.fonts[i], FC_FAMILY, 1, &family)\
         != FcResultMatch:
        if FcPatternGetString(self._c_fs.fonts[i], FC_FAMILY, 0, &family)\
           != FcResultMatch:
          continue
      if FcPatternGetString(self._c_fs.fonts[i], FC_FILE, 0, &file)\
         != FcResultMatch:
        continue
      if FcCharSetHasChar(self._c_cs, ch):
        families.append((<char*>family, <char*>file))
    return families

  cpdef bint support(self, unsigned char* font):
    '''Testing the given font supports Chinese or not'''
    cdef:
      int ret = 0
      int count
      FcChar8* file = <FcChar8*>font
      FcChar32 ch

    self._c_blanks = FcConfigGetBlanks(NULL)
    self._c_pat = FcFreeTypeQuery(file, 0, self._c_blanks, &count)

    if FcPatternGetCharSet(self._c_pat, FC_CHARSET, 0, &self._c_cs)\
       != FcResultMatch:
      return ret

    FcUtf8ToUcs4(<FcChar8*>(<unsigned char*>"永"), &ch, 3)
    if FcCharSetHasChar(self._c_cs, ch):
      ret = 1
    return ret
