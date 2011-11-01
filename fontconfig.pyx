# -*- coding: utf-8
'''
  Python-fontconfig
  ~~~~~~~~~~~~~~~~~

  Python binding for Fontconfig library.

  .. _Python-fontconfig source code:
    http://github.com/Vayn/python-fontconfig

  :author: Vayn a.k.a VT <vayn@vayn.de>
  :license: GPLv3+, see LICENSE for details.
'''
__version__ = '0.4.0'
__docformat__ = 'restructuredtext'


#------------------------------------------------
# Imports
#------------------------------------------------

from cpython.version cimport PY_MAJOR_VERSION
from cfontconfig cimport *

include 'fontconfig.pxi'
include 'factory.pxi'


#------------------------------------------------
# Code
#------------------------------------------------

# Factory Function
query = query

#

cdef class FcFont:
  '''
  FcF is a class of Fontconfig

  This class provides all infomation about font.
  '''
  # Fontconfig library version
  __version__ = fc_version()

  cdef:
    FcPattern *_pat
    FcBlanks *_blanks
    FcCharSet *_cs
    bytes file
    dict _buf

  def __cinit__(self, file):
    '''
    :param file: The absolute path of the font
    '''
    self.file = file.encode('utf8')
    self.init()

  cdef init(self):
    cdef char *file = self.file
    cdef int count
    self._blanks = FcConfigGetBlanks(NULL)
    self._pat = FcFreeTypeQuery(<FcChar8*>file, 0, self._blanks, &count)
    self._buf = {}

  def __dealloc__(self):
    if self._pat is not NULL:
      FcPatternDestroy(self._pat)
    self._pat = NULL

  def __repr__(self):
    try:
      if PY_MAJOR_VERSION < 3:
        # To avoid `UnicodeEncodeError` in Python 2
        family = self.family[0][0].encode('utf8')
      else:
        family = self.family[0][0]
      value = '<%s: %s>' % (
        self.__class__.__name__,
        family
      )
    except:
      value = self.__class__
    return value

  property file:
    def __get__(self):
      return self.file.decode('utf8')
    def __set__(self, file):
      self.file = file.encode('utf8')
      self.init()

  def _getattr(self, *args):
    cdef:
      int ivar
      FcBool bvar
      FcChar8 *cvar
    obj = args[0]
    bobj = obj.encode('utf8')
    type = args[1]

    if type == 'str' and self._buf.get(obj) is None:
      if FcPatternGetString(self._pat, bobj, 0, &cvar) == Match:
        ret = FcChar8_to_unicode(cvar)
        self._buf[obj] = ret
    if type == 'int' and self._buf.get(obj) is None:
      if FcPatternGetInteger(self._pat, bobj, 0, &ivar) == Match:
        self._buf[obj] = ivar
    if type == 'bool' and self._buf.get(obj) is None:
      if FcPatternGetBool(self._pat, bobj, 0, &bvar) == Match:
        self._buf[obj] = bvar
    try:
      return self._buf[obj]
    except KeyError:
      self._buf[obj] = None
      return None

  property fontformat:
    def __get__(self):
      return self._getattr('fontformat', 'str')
  property foundry:
    def __get__(self):
      return self._getattr('foundry', 'str')
  property capability:
    def __get__(self):
      return self._getattr('capability', 'str')

  property slant:
    def __get__(self):
      return self._getattr('slant', 'int')
  property index:
    def __get__(self):
      return self._getattr('index', 'int')
  property weight:
    def __get__(self):
      return self._getattr('weight', 'int')
  property width:
    def __get__(self):
      return self._getattr('width', 'int')
  property spacing:
    def __get__(self):
      return self._getattr('decorative', 'int')

  property scalable:
    def __get__(self):
      return self._getattr('scalable', 'bool')
  property outline:
    def __get__(self):
      return self._getattr('outline', 'bool')
  property decorative:
    def __get__(self):
      return self._getattr('decorative', 'bool')

  cdef list _langen(self, arg):
    '''
    Fragile code generator

    Used by family, style and fullname to avoid repeated code
    '''
    cdef:
      int id
      FcChar8 *cvar
      bytes obj
      bytes lobj
      list got
      list ret
    ret = self._buf.get(arg)
    if ret is None:
      id = 0
      obj = arg.encode('utf8')
      lobj = obj+b'lang'
      got = []
      ret = []
      while 1:
        if FcPatternGetString(self._pat, obj, id, &cvar) == Match:
          got.append(FcChar8_to_unicode(cvar))
          FcPatternGetString(self._pat, lobj, id, &cvar)
          got.append(FcChar8_to_unicode(cvar))
          ret.append(tuple(got))
          got = []
          id += 1
        else:
          self._buf[arg] = ret
          return ret
    else:
      return ret

  property family:
    def __get__(self):
      obj = 'family'
      return self._langen(obj)

  property style:
    def __get__(self):
      obj = 'style'
      return self._langen(obj)

  property fullname:
    def __get__(self):
      obj = 'fullname'
      return self._langen(obj)

  def print_lang(self):
    '''Print all languages the font supports'''
    cdef FcValue var
    if FcPatternGet(self._pat, FC_LANG, 0, &var) == Match:
      FcValuePrint(var)

  def print_pattern(self):
    '''Print all infomation of the font in the wild'''
    FcPatternPrint(self._pat)

  cpdef bint has_char(self, ch):
    '''
    Check whether the font supports the given character

    :param ch: The character you want to check
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

  def count_chars(self):
    '''
    Count the amount of characters in font
    '''
    cdef FcChar32 count = 0
    if FcPatternGetCharSet(self._pat, FC_CHARSET, 0, &self._cs) == Match:
      count = FcCharSetCount(self._cs)
    return count
