=================
Python-fontconfig
=================

Python bindings for Fontconfig_ library


Requirement
-----------

- Fontconfig_ **Required**
- Cython_ (if you want to regenerate C source)

.. _Cython: http://cython.org/
.. _Fontconfig: http://www.freedesktop.org/wiki/Software/fontconfig

Tested on
~~~~~~~~~

- ``Python 2.7.2`` (64-bit)
- ``Python 3.2.2`` (64-bit)


Installation
------------

From PyPI::

  >>> pip install Python-fontconfig

  or

  >>> easy_install Python-fontconfig 

From GitHub::

  >>> git clone git://github.com/Vayn/python-fontconfig.git
  >>> cd python-fontconfig/
  >>> python setup.py install


Building C source
-----------------

>>> python setup.py build_ext -i 


Usage
-----

>>> import fontconfig

>>> fonts = fontconfig.query(family='ubuntu', lang='en')

>>> fonts
['/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-BI.ttf',
 '/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-L.ttf',
 '/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-LI.ttf',
 '/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-R.ttf',
 '/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-B.ttf',
 '/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-RI.ttf']

>>> font = fonts[0]

>>> font
<FcFont: Ubuntu>

>>> font.
font.capability     font.fullname       font.slant
font.count_chars    font.get_languages  font.spacing
font.decorative     font.has_char       font.style
font.family         font.index          font.weight
font.file           font.outline        font.width
font.fontformat     font.print_pattern
font.foundry        font.scalable

>>> font.family
[('en', 'Ubuntu')]

>>> font.foundry
'unknown'

>>> font.fontformat
'TrueType'

>>> font.has_char('A')
True

>>> font.file
'/usr/share/fonts/truetype/ubuntu-font-family/Ubuntu-BI.ttf'

>>> font = fontconfig.FcFont(font.file)

>>> font.family
[('en', 'Ubuntu')]

License
-------

This program is released under ``GPLv3`` license, see ``LICENSE`` for more detail.
