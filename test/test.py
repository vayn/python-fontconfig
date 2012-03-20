# vim: set fileencoding=utf-8:
# @Author: Vayn a.k.a. VT <vayn@vayn.de>
# @Name: test.py
# @Date: 2011年11月10日 星期四 19时13分01秒
import sys
import unittest
import fontconfig

pyver = sys.version_info[0]
if pyver == 3:
  condition = input('Have you installed FreeMono font already?(y/n): ')
else:
  condition = raw_input('Have you installed FreeMono font already?(y/n): ')
reason = "You don't have the font which tests need"


@unittest.skipIf(condition != 'y', reason)
class FontListTestCase(unittest.TestCase):
  def test_get_list(self):
    """query should give a list for specified font"""
    fonts = fontconfig.query(family='freemono', lang='en')
    self.assertIsInstance(fonts, list)

  def test_get_font_from_list(self):
    """Get FcFont object from list"""
    fonts = fontconfig.query(family='freemono', lang='en')
    font = fonts[0]
    self.assertIsInstance(font, fontconfig.FcFont)

  def test_get_file_path_from_list_element(self):
    """Get font path from an element in font list"""
    fonts = fontconfig.query(family='freemono', lang='en')
    font = fonts[0]
    self.assertIsNotNone(font.file)


@unittest.skipIf(condition != 'y', reason)
class FcFontTestCase(unittest.TestCase):
  fonts = fontconfig.query(family='freemono', lang='en')
  font = fonts[0]

  def test_get_object_from_path(self):
    """Get FcFont instance"""
    fc = fontconfig.FcFont(self.font.file)
    self.assertIsInstance(fc, fontconfig.FcFont)

  def test_char_in_font(self):
    """Test the given character in font charset"""
    fc = fontconfig.FcFont(self.font.file)
    char = 'A' if pyver == 3 else 'A'.decode('utf8')
    self.assertTrue(fc.has_char(char))

  @unittest.expectedFailure
  def test_char_not_in_font(self):
    """Test the given character not in font charset"""
    fc = fontconfig.FcFont(self.font.file)
    char = '永' if pyver == 3 else '永'.decode('utf8')
    self.assertTrue(fc.has_char(char))


if __name__ == '__main__':
  unittest.main()
