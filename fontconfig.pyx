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
__version__ = '0.3.1'
__docformat__ = 'restructuredtext'


#------------------------------------------------
# Imports
#------------------------------------------------

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

  TODO: Reduce the whole class
  '''
  # Fontconfig library version
  __version__ = fc_version()

  cdef:
    FcPattern *_pat
    FcBlanks *_blanks
    FcCharSet *_cs
    bytes _file
    readonly dict __dict__
    readonly dict attr_dict
    FcChar8 *cvar
    int ivar
    FcBool bvar

  def __cinit__(self, file):
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
    self.init_attrdict()

  cdef init_attrdict(self):
    self.__dict__ = {}
    self.attr_dict = {}
    lst = []
    lst.append(['fontformat', 'foundry', 'capability'])
    lst.append(['slant', 'index', 'weight', 'width', 'spacing'])
    lst.append(['scalable', 'outline', 'decorative'])
    for i in lst[0]:
      self.attr_dict.update({i: 'str'})
    for i in lst[1]:
      self.attr_dict.update({i: 'int'})
    for i in lst[2]:
      self.attr_dict.update({i: 'bool'})

  def __dealloc__(self):
    if self._pat is not NULL:
      FcPatternDestroy(self._pat)
    self._pat = NULL
    if self._cs is not NULL:
      FcCharSetDestroy(self._cs)
    self._cs = NULL

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
      return self._file.decode('utf8')
    def __set__(self, file):
      l_file = file.encode('utf8')
      self.init(l_file)

  def __getattr__(self, arg):
    obj = arg.encode('utf8')
    if self.attr_dict.get(arg) == 'str':
      if self.__dict__.get(arg) is None:
        if FcPatternGetString(self._pat, obj, 0, &self.cvar) == Match:
          ret = FcChar8_to_unicode(self.cvar)
          self.__dict__[arg] = ret
    elif self.attr_dict.get(arg) == 'int':
      if self.__dict__.get(arg) is None:
        if FcPatternGetInteger(self._pat, obj, 0, &self.ivar) == Match:
          self.__dict__[arg] = self.ivar
    elif self.attr_dict.get(arg) == 'bool':
      if self.__dict__.get(arg) is None:
        if FcPatternGetBool(self._pat, obj, 0, &self.bvar) == Match:
          self.__dict__[arg] = self.bvar
    return self.__dict__[arg]

  cdef list _langen(self, obj, obj1):
    '''
    Fragile code generator

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
      if self.__dict__.get('family') is None:
        ret = self._langen(FC_FAMILY, FC_FAMILYLANG)
        self.__dict__['family'] = ret
        return ret
      else:
        return self.__dict__['family']

  property style:
    def __get__(self):
      if self.__dict__.get('style') is None:
        ret = self._langen(FC_STYLE, FC_STYLELANG)
        self.__dict__['style'] = ret
        return ret
      else:
        return self.__dict__['family']

  property fullname:
    def __get__(self):
      if self.__dict__.get('fullname') is None:
        ret = self._langen(FC_FULLNAME, FC_FULLNAMELANG)
        self.__dict__['fullname'] = ret
        return ret
      else:
        return self.__dict__['fullname']

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
