# -*- coding: utf-8
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: fontconfig.pxi
# @Date: 2011年 10月 30日 星期日 07:14:47

# Short for FcResultMatch
cdef FcResult Match = FcResultMatch

cdef unicode FcChar8_to_unicode(FcChar8 *str):
  '''Convert FcChar8 to unicode'''
  cdef unicode ret
  ret = (<char*>str).decode('utf8', 'strict')
  return ret

cdef int fc_version():
  '''Return version of Fontconfig'''
  return FcGetVersion()

cdef class FcList(list):
  '''
  FcList will return a FcFont object when you get an item
  in the list.
  '''
  def __getitem__(self, arg):
    if isinstance(arg, slice):
      return FcList(list.__getitem__(self, arg))
    else:
      return FcFont(list.__getitem__(self, arg))

  def __delitem(self, arg):
    FcList(list.__delitem__(self, arg))
