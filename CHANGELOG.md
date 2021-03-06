SimpleMoney 0.3.0
=================

Features
--------
- Updates to work with gem-testers.org

SimpleMoney 0.2.1
=================

Features
--------
- Added #%, #<=>, #==, #abs and #divmod
- Cleanup/Enhanced documentation

Bug fixes
---------
- Update all calculations to respect options set on object (rounding method,
  currency, etc) when return a new object as a result of the calculation

SimpleMoney 0.2.0
=================

Features
--------
- Money is now Currency aware
- All existing methods respect currency

SimpleMoney 0.1.1
=================

Features
--------
 - Ensure all calculations are done using BigDecimal
 - Implemented Money#to_s
 - Cleaned up documentation
 - Reorganize lib/spec for compatibility with autotest
 - Implemented Money.overflow=

Bug fixes
---------
 - Fixed error where overflow wasn't properly updated after calling Money#/

SimpleMoney 0.1.0
=================

Features
--------
 - Initial release.
