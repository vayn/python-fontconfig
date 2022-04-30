# -*- coding: utf-8
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: factory.pxi

cpdef query(family='', lang='', with_index=False):
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
  if with_index:
    os = FcObjectSetBuild(FC_CHARSET, FC_FILE, FC_INDEX, NULL)
  else:
    os = FcObjectSetBuild(FC_CHARSET, FC_FILE, NULL)
  fs = FcFontList(<FcConfig*>0, pat, os)
  if fs is NULL or fs.nfont < 1:
    return lst

  cdef:
    int i
    FcChar8 *file
    FcCharSet *cs
    int index
  for i in range(fs.nfont):
    if FcPatternGetCharSet(fs.fonts[i], FC_CHARSET, 0, &cs) != Match:
      continue
    if FcPatternGetString(fs.fonts[i], FC_FILE, 0, &file) == Match:
      if with_index:
        if FcPatternGetInteger(fs.fonts[i], FC_INDEX, 0, &index) != Match:
          continue
        lst.append(((<char*>file).decode('utf8'), index))
      else:
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
  names = query(name, with_index=True)
  if names:
    return FcFont(*names[0])
  else:
    return
