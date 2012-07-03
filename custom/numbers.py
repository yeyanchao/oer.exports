"""Various Number-to-string conversions"""
import string

class OutOfRangeError(Exception): pass
class NotIntegerError(Exception): pass
class InvalidFormatError(Exception): pass

#Define digit mapping
romanNumeralMap = (('M',  1000),
				   ('CM', 900),
				   ('D',  500),
				   ('CD', 400),
				   ('C',  100),
				   ('XC', 90),
				   ('L',  50),
				   ('XL', 40),
				   ('X',  10),
				   ('IX', 9),
				   ('V',  5),
				   ('IV', 4),
				   ('I',  1))

def toRoman(n):
	"""convert integer to Roman numeral. From http://www.diveintopython.net/unit_testing/romantest.html """
	if not (0 < n < 5000):
		raise OutOfRangeError, "number out of range (must be 1..4999)"

	result = ""
	for numeral, integer in romanNumeralMap:
		while n >= integer:
			result += numeral
			n -= integer
	return result


def toString(n, format):
  if int(n) <> n:
    raise NotIntegerError, "non-integers can not be converted"
  if format == 'decimal' or not format:
    return str(n)
  if format == 'upper-roman':
    return toRoman(n)
  elif format == 'lower-roman':
    return toRoman(n).lower()
  elif format in ('lower-latin', 'lower-alpha'):
    if n > 25:
      raise OutOfRhangeError, "only numbers up to 25 can be represented"
    return string.ascii_lowercase[n - 1]
  elif format in ('upper-latin', 'upper-alpha'):
    if n > 25:
      raise OutOfRhangeError, "only numbers up to 25 can be represented"
    return string.ascii_uppercase[n - 1]
  else:
    raise InvalidFormatError, "this numbering format is not yes supported: %s" % str(format)