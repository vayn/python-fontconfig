--------------------------
Fontconfig Python binding
--------------------------

**Note**: This is a proof of concept at present.

Requirement
-----

Cython_, Fontconfig_

.. _Cython: http://cython.org/
.. _Fontconfig: http://www.freedesktop.org/wiki/Software/fontconfig


Compilation
-----

>>> python setup.py build_ext -i 


Usage
-----

>>> python
Python 3.2.2 (default, Sep  5 2011, 04:52:19) 
[GCC 4.6.1 20110819 (prerelease)] on linux2
Type "help", "copyright", "credits" or "license" for more information.
>>> from fontconfig import FontPattern
>>> fc = FontPattern(lang=b'zh', flag=bytes('永', 'utf8'))
>>> fc.flag.decode('utf8')
永
>>> fc.lang
b'zh'
>>> fc.version  # Fontconfig version, 2.8.0
20800
>>> font = b'/usr/share/fonts/truetype/freefont/FreeMono.ttf'
>>> fc.has_char(font)
False
>>> font = b'/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc'
>>> fc.has_char(font)
True
>>> fc.flag = b'forever'
>>> fc.flag
b'forever'
>>> font = b'/usr/share/fonts/truetype/freefont/FreeMono.ttf'
>>> fc.has_char(font)
True
>>> fc.get_info(font)
{'family': b'FreeMono', 'fontformat': b'TrueType', 'style': b'Normal'}
>>> fc.get_list()[:3]
[(b'unifont', b'/usr/share/fonts/misc/unifont.bdf'),
 (b'AR PL UKai TW', b'/usr/share/fonts/truetype/arphic/ukai.ttc'),
 (b'WenQuanYi Bitmap Song',
  b'/usr/share/fonts/wqy-bitmapfont/wenquanyi_9ptb.pcf')]


License
-----

This program is released under ``GPLv3`` license, see ``LICENSE`` for more detail.
