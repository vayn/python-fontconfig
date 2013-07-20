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

