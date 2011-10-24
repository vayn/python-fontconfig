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
>>> import fontconfig
>>> fc = fontconfig.FontConfig()
>>> font = b'/usr/share/fonts/truetype/freefont/FreeMono.ttf'
>>> fc.support_ch(font)
False 


License
-----

This program is released under ``GPLv3`` license, see ``LICENSE`` for more detail.
