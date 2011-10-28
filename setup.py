# vim: set fileencoding=utf-8:
import sys
from distutils.core import setup
from distutils.extension import Extension

ext_modules = [
  Extension('fontconfig',
            ['fontconfig.c'],
            libraries=["fontconfig"])
]

args = dict(
  name='Font Config',
  version='0.2.0',
  author='Vayn a.k.a. VT',
  author_email='vayn@vayn.de',
  description='Python bindings for Fontconfig library',
  url='https://github.com/Vayn/python-fontconfig',
  ext_modules=ext_modules
)


if __name__ == '__main__':
  if sys.argv[1] == 'build_ext':
    from Cython.Distutils import build_ext
    setup(**args)
  else:
    setup(**args)
