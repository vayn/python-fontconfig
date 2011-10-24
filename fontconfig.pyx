# file: fontconfig.pyx
# -*- coding: utf-8; -*-

from libc.stdio cimport stderr, fprintf
from cfontconfig cimport *

__license__ = 'GPL3'
__version__ = '0.1.0'


cdef class FontConfig:
  '''Python binding for fontconfig'''
  cdef FcPattern* _c_pat

  def __cinit__(self):
    self._c_pat = FcPatternCreate()

  def __dealloc__(self):
    if self._c_pat is not NULL:
      FcPatternDestroy(self._c_pat)

  cpdef bint support_ch(self, unsigned char* font):
    '''Testing the given font supports Chinese or not'''
    cdef:
      int ret = 0
      FcChar8* file = <FcChar8*>font
      FcCharSet* cs
      FcBlanks* blank
      FcChar32 ch
      int count

    blanks = FcConfigGetBlanks(NULL)
    self._c_pat = FcFreeTypeQuery(<FcChar8*>file, 0, blanks, &count)

    if FcPatternGetCharSet(self._c_pat, FC_CHARSET, 0, &cs) != FcResultMatch:
      fprintf(stderr, "no match\n")
      return ret

    FcUtf8ToUcs4(<FcChar8*>(<unsigned char*>"永"), &ch, 3)
    if FcCharSetHasChar(cs, ch):
      ret = 1
    return ret
