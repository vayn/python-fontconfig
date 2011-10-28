# vim: set fileencoding=utf-8:
import sys
from distutils.core import setup
from distutils.extension import Extension

def ext_modules(build=False):
  if build:
    source = 'fontconfig.pyx'
  else:
    source = 'fontconfig.c'
  ext = [Extension('fontconfig', [source], libraries=["fontconfig"])]
  return ext

args = dict(
  name='Font Config',
  version='0.2.0',
  author='Vayn a.k.a. VT',
  author_email='vayn@vayn.de',
  description='Python bindings for Fontconfig library',
  url='https://github.com/Vayn/python-fontconfig',
)


if __name__ == '__main__':
  if sys.argv[1] == 'build_ext':
    from Cython.Distutils import build_ext

    args.update(cmdclass={'build_ext': build_ext})
    args.update(ext_modules=ext_modules(True))
    setup(**args)
  else:
    args.update(ext_modules=ext_modules())
    setup(**args)
