#!/usr/bin/env python3
# vim: set fileencoding=utf-8:
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: setup.py
# @Date: 2011年10月24日 星期一 16时56分48秒
from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext

ext_modules = [
  Extension('fontconfig',
            ['fontconfig.pyx'],
            libraries=["fontconfig"])
]

setup(
  name='Font Config',
  cmdclass={'build_ext': build_ext},
  ext_modules=ext_modules
)
