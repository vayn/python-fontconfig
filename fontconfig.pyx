# -*- coding: utf-8
'''
  Python-fontconfig
  ~~~~~~~~~~~~~~~~~

  Python binding for Fontconfig library.

  .. _Python-fontconfig source code:
    http://github.com/Vayn/python-fontconfig

  :author: Vayn a.k.a VT <vayn@vayn.de>
  :contributor: lilydjwg <lilydjwg@gmail.com>
  :license: GPLv3+, see LICENSE for details.
'''
__version__ = '0.6.0'
__docformat__ = 'restructuredtext'


#------------------------------------------------
# Imports
#------------------------------------------------

from cpython.version cimport PY_MAJOR_VERSION
from cfontconfig cimport *

include 'fontconfig.pxi'
include 'factory.pxi'

import locale

#------------------------------------------------
# Code
#------------------------------------------------

fromName = fromName

cdef class FcFont:
  '''
  FcFont is a class of Fontconfig

  This class provides all infomation about a font file.
  '''
  # Fontconfig library version
  __version__ = fc_version()

  cdef:
    FcPattern *_pat
    FcBlanks *_blanks
    FcCharSet *_cs
    bytes file
    dict _buf
    int count
    int _index

  def __cinit__(self, file, index=0):
    '''
    :param file: The absolute path of the font
    '''
    self.file = file.encode('utf8')
    self._index = index
    self.init()

  cdef init(self):
    cdef char *file = self.file
    self._blanks = FcConfigGetBlanks(NULL)
    self._pat = FcFreeTypeQuery(<FcChar8*>file, self._index, self._blanks, &self.count)
    if self._pat == NULL:
      raise LookupError('FcFreeTypeQuery failed')
    self._buf = {}

  def __dealloc__(self):
    if self._pat is not NULL:
      FcPatternDestroy(self._pat)
    self._pat = NULL

  def __repr__(self):
    family = self.bestname
    value = '<%s: %s>' % (
      self.__class__.__name__,
      family
    )
    return value

  property count:
    def __get__(self):
      return self.count

  property file:
    def __get__(self):
      return self.file.decode('utf8')

  cdef object _getattr(self, bytes name, object type):
    cdef:
      int ivar
      FcBool bvar
      FcChar8 *cvar
      char *obj
    obj = <char*>name
    if type == 'str' and self._buf.get(name) is None:
      if FcPatternGetString(self._pat, obj, 0, &cvar) == Match:
        ret = FcChar8_to_unicode(cvar)
        self._buf[name] = ret
    elif type == 'int' and self._buf.get(name) is None:
      if FcPatternGetInteger(self._pat, obj, 0, &ivar) == Match:
        self._buf[name] = ivar
    elif type == 'bool' and self._buf.get(name) is None:
      if FcPatternGetBool(self._pat, obj, 0, &bvar) == Match:
        self._buf[name] = bvar
    try:
      return self._buf[name]
    except KeyError:
      # If there isn't one property in the font
      self._buf[name] = None

  property fontformat:
    def __get__(self):
      return self._getattr(b'fontformat', 'str')
  property foundry:
    def __get__(self):
      return self._getattr(b'foundry', 'str')
  property capability:
    def __get__(self):
      return self._getattr(b'capability', 'str')

  property slant:
    def __get__(self):
      return self._getattr(b'slant', 'int')
  property index:
    def __get__(self):
      return self._getattr(b'index', 'int')
  property weight:
    def __get__(self):
      return self._getattr(b'weight', 'int')
  property width:
    def __get__(self):
      return self._getattr(b'width', 'int')
  property spacing:
    def __get__(self):
      return self._getattr(b'decorative', 'int')

  property scalable:
    def __get__(self):
      return self._getattr(b'scalable', 'bool')
  property outline:
    def __get__(self):
      return self._getattr(b'outline', 'bool')
  property decorative:
    def __get__(self):
      return self._getattr(b'decorative', 'bool')

  cdef object _langen(self, bytes obj):
    # Used by family, style and fullname
    cdef:
      int id
      FcChar8 *cvar
    ret = self._buf.get(obj)
    if ret is None:
      id = 0
      lang = obj+b'lang'
      ret = []
      while True:
        if FcPatternGetString(self._pat, obj, id, &cvar) == Match:
          val = FcChar8_to_unicode(cvar)
          FcPatternGetString(self._pat, lang, id, &cvar)
          lan = FcChar8_to_unicode(cvar)
          ret.append((lan, val))
          id += 1
        else:
          ret = dict(ret)
          self._buf[obj] = ret
          break
    return ret

  property family:
    def __get__(self):
      return self._langen(b'family')

  property style:
    def __get__(self):
      return self._langen(b'style')

  property fullname:
    def __get__(self):
      return self._langen(b'fullname')

  property bestname:
    def __get__(self):
      ret = self._buf.get(b'bestname')
      if ret:
        return ret

      l = locale.getdefaultlocale()[0].lower().replace('_', '-')
      try:
        family = self.family.get(l, None)
        if family is None:
          l = l.split('-', 1)[0]
          family = [y for x, y in self.family.items() if x.startswith(l)]
          if family:
            family = family[0]
          else:
            family = tuple(self.family.values())[0]
        ret = family
      except IndexError:
        ret = self.file
      self._buf[b'bestname'] = ret
      return ret

  def get_languages(self):
    '''Print all languages the font supports'''
    cdef FcValue var
    cdef FcStrSet* langs
    ret = []
    if FcPatternGet(self._pat, FC_LANG, 0, &var) == Match:
      langs = FcLangSetGetLangs(var.u.l)
      for i in range(langs.num):
        ret.append(FcChar8_to_unicode(langs.strs[i]))
    else:
      ret = None
    return ret

  def print_pattern(self):
    '''Print all infomation of the font in the wild'''
    FcPatternPrint(self._pat)

  def has_char(self, unicode ch):
    '''
    Check whether the font supports the given character

    :param ch: The character you want to check
    '''
    cdef:
      int count
      bytes byte_ch
      FcChar32 ucs4_ch
    if len(ch) != 1:
      raise ValueError('expected a character, but string of length %d found' % len(ch))
    byte_ch = ch.encode('utf8')
    if FcPatternGetCharSet(self._pat, FC_CHARSET, 0, &self._cs) != Match:
      return False
    FcUtf8ToUcs4(<FcChar8*>(<char*>byte_ch), &ucs4_ch, len(byte_ch))
    if FcCharSetHasChar(self._cs, ucs4_ch):
      return True
    else:
      return False

  def count_chars(self):
    '''
    Count the amount of characters in font
    '''
    cdef FcChar32 count = 0
    if FcPatternGetCharSet(self._pat, FC_CHARSET, 0, &self._cs) == Match:
      count = FcCharSetCount(self._cs)
    return count
