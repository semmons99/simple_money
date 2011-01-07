SimpleMoney
===========

This gem is intended for working with financial calculations where you need
highly accurate results. When performing calculations where fractional cents
are introduced, these fractional cents are stored in an overflow bucket for the
user to examine as needed.

Usage:
    require 'simple_money'

    a = Money.new(1_00, :as => :cents)
    a.cents                 #=> 100
    b = a * 1.555
    b.cents                 #=> 156
    Money.overflow          #=> #<BigDecimal:... '-0.5E0',4(16)>
    b.to_s                  #=> "100"
    b.to_s(:as => :decimal) #=> "1.00"

Version History
---------------

See {file:CHANGELOG.md} for details.

Copyright
---------

Copyright (c) 2011 Shane Emmons. See {file:LICENSE} for details.
