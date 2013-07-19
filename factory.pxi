# -*- coding: utf-8
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: factory.pxi

cpdef query(family='', lang=''):
  '''
  Produce font object list for the queried language
  '''
  cdef:
    FcChar8 *strpat
    FcPattern *pat = NULL
    FcFontSet *fs = NULL
    FcObjectSet *os = NULL
    list lst = []

  if lang:
    l_lang = ('%s:lang=%s' % (family, lang))
  else:
    l_lang = family
  l_lang = l_lang.encode('utf-8')
  strpat = <FcChar8*>(<char*>l_lang)
  pat = FcNameParse(strpat)
  os = FcObjectSetBuild(FC_CHARSET, FC_FILE, NULL)
  fs = FcFontList(<FcConfig*>0, pat, os)
  if fs is NULL or fs.nfont < 1:
    return lst

  cdef:
    int i
    FcChar8 *file
    FcCharSet *cs
  for i in range(fs.nfont):
    if FcPatternGetCharSet(fs.fonts[i], FC_CHARSET, 0, &cs) != Match:
      continue
    if FcPatternGetString(fs.fonts[i], FC_FILE, 0, &file) == Match:
      lst.append((<char*>file).decode('utf8'))

  FcPatternDestroy(pat)
  pat = NULL
  FcObjectSetDestroy(os)
  os = NULL
  FcCharSetDestroy(cs)
  cs = NULL
  FcFontSetDestroy(fs)
  fs = NULL
  return lst

def fromName(name):
  cdef:
    list names
  names = query(name)
  if names:
    return FcFont(names[0])
  else:
    return
