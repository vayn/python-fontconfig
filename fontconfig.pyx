# -*- coding: utf-8
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: fontconfig.pyx
# @Date: 2011年10月28日 星期五 08时22分37秒
'''
  Python-fontconfig
  ~~~~~~~~~~~~~~~~~

  Python binding for Fontconfig library.

  .. _Python-fontconfig source code:
    http://github.com/Vayn/python-fontconfig

  :author: Vayn a.k.a VT <vayn@vayn.de>
  :license: GPLv3+, see LICENSE for details.
'''
__version__ = '0.2.0'
__docformat__ = 'restructuredtext'

#------------------------------------------------
# Imports
#------------------------------------------------

from cfontconfig cimport *

include 'fontconfig.pxi'

#------------------------------------------------
# Code
#------------------------------------------------

class FcInitError(Exception):
  pass

cdef class FontFactory:
  '''
  Font Factory

  There is no reason to instantiate it.
  '''

  # Fontconfig library version
  __version__ = fc_version()

  def __init__(self):
    raise FcInitError("Can't init Factory")

cdef class FcFont(FontFactory):
  '''
  FcF is a Class of FontConfig
  
  This class provides all infomation about font.
  TODO: Reduce the whole class
  '''
  cdef:
    FcPattern *_pat
    FcBlanks *_blanks
    FcCharSet *_cs
    bytes _file

  def __cinit__(self):
    if not FcInit():
      raise FcInitError("Can't init font config library")
    FcFini()

  def __init__(self, file):
    '''
    :param file: The absolute path of the font
    '''
    l_file = file.encode('utf8')
    self.init(l_file)

  cdef init(self, bytes l_file):
    self._file = l_file
    cdef char *file = self._file
    cdef int count
    self._blanks = FcConfigGetBlanks(NULL)
    self._pat = FcFreeTypeQuery(<FcChar8*>file, 0, self._blanks, &count)

  def __repr__(self):
    try:
      value = '<%s: %s>' % (
        self.__class__.__name__,
        self.family[0][0],
      )
    except:
      value = self.__class__.__name__
    return value

  property file:
    def __get__(self):
      cdef FcChar8 *var
      if FcPatternGetString(self._pat, FC_FONTFORMAT, 0, &var) == Match:
        return FcChar8_to_unicode(var)
    def __set__(self, file):
      l_file = file.encode('utf8')
      self.init(l_file)

  cdef list _langen(self, obj, obj1):
    '''Fragile code generator

    Used by family, style and fullname to avoid repeated code
    '''
    cdef:
      int id = 0
      FcChar8 *var
      list got = []
      list ret = []
    while 1:
      if FcPatternGetString(self._pat, obj, id, &var) == Match:
        got.append(FcChar8_to_unicode(var))
        FcPatternGetString(self._pat, obj1, id, &var)
        got.append(FcChar8_to_unicode(var))
        ret.append(tuple(got))
        got = []
        id += 1
      else:
        return ret

  property family:
    def __get__(self):
      return self._langen(FC_FAMILY, FC_FAMILYLANG)

  property style:
    def __get__(self):
      return self._langen(FC_STYLE, FC_STYLELANG)

  property fullname:
    def __get__(self):
      return self._langen(FC_FULLNAME, FC_FULLNAMELANG)

  property format:
    def __get__(self):
      cdef FcChar8 *var
      if FcPatternGetString(self._pat, FC_FONTFORMAT, 0, &var) == Match:
        return FcChar8_to_unicode(var)

  property foundry:
    def __get__(self):
      cdef FcChar8 *var
      if FcPatternGetString(self._pat, FC_FOUNDRY, 0, &var) == Match:
        return FcChar8_to_unicode(var)

  property slant:
    def __get__(self):
      cdef int var
      if FcPatternGetInteger(self._pat, FC_SLANT, 0, &var) == Match:
        return var

  property index:
    def __get__(self):
      cdef int var
      if FcPatternGetInteger(self._pat, FC_INDEX, 0, &var) == Match:
        return var

  property weight:
    def __get__(self):
      cdef int var
      if FcPatternGetInteger(self._pat, FC_WEIGHT, 0, &var) == Match:
        return var

  property width:
    def __get__(self):
      cdef int var
      if FcPatternGetInteger(self._pat, FC_WIDTH, 0, &var) == Match:
        return var

  property spacing:
    def __get__(self):
      cdef int var
      if FcPatternGetInteger(self._pat, FC_SPACING, 0, &var) == Match:
        return var

  property capability:
    def __get__(self):
      cdef FcChar8 *var
      if FcPatternGetString(self._pat, FC_CAPABILITY, 0, &var) == Match:
        return FcChar8_to_unicode(var)

  property scalable:
    def __get__(self):
      cdef FcBool var
      if FcPatternGetBool(self._pat, FC_SCALABLE, 0, &var) == Match:
        return var

  property ouline:
    def __get__(self):
      cdef FcBool var
      if FcPatternGetBool(self._pat, FC_OUTLINE, 0, &var) == Match:
        return var

  property decorative:
    def __get__(self):
      cdef FcBool var
      if FcPatternGetBool(self._pat, FC_DECORATIVE, 0, &var) == Match:
        return var

  def lang(self):
    '''Print all languages the font supports'''
    cdef FcValue var
    if FcPatternGet(self._pat, FC_LANG, 0, &var) == Match:
      FcValuePrint(var)

  def raw_info(self):
    '''Print all infomation of the font in the wild'''
    FcPatternPrint(self._pat)

  cpdef bint has_char(self, unicode ch):
    '''
    Check whether the font supports the given character

    :param ch: The character you want to check

    **NOTE:** You should use ``ch = u"..."`` if you are in Python 2
    '''
    cdef:
      int ret = 0
      int count
      bytes byte_ch
      FcChar32 ucs4_ch

    if FcPatternGetCharSet(self._pat, FC_CHARSET, 0, &self._cs) != Match:
      return ret

    byte_ch = ch.encode('utf8')
    FcUtf8ToUcs4(<FcChar8*>(<char*>byte_ch), &ucs4_ch, 3)
    if FcCharSetHasChar(self._cs, ucs4_ch):
      ret = 1
    return ret
