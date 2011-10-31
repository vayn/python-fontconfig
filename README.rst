-----------------
Python-fontconfig
-----------------

Python bindings for Fontconfig_ library


Requirement
==========

- Fontconfig_ **Required**
- Cython_ (if you want to regenerate C source)

.. _Cython: http://cython.org/
.. _Fontconfig: http://www.freedesktop.org/wiki/Software/fontconfig

Tested on
_________

- ``Python 2.7.2`` (64-bit)
- ``Python 3.2.2`` (64-bit)


Installation
============

>>> git clone git://github.com/Vayn/python-fontconfig.git
>>> cd python-fontconfig/
>>> python setup.py install


Building C source
=================

>>> python setup.py build_ext -i 


TODO
====

- Usage doc


License
=======

This program is released under ``GPLv3`` license, see ``LICENSE`` for more detail.
