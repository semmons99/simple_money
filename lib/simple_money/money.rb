require 'bigdecimal'
require 'simple_money/currency'

##
# Used to work with financial calculations. Tries to avoid the pitfalls of
# using Float by storing the value in cents. All calculations are floored.
class Money

  class << self

    ##
    # The valid values for as
    VALID_AS_VALUES = [:cents, :decimal]

    ##
    # The valid rounding methods
    VALID_ROUNDING_METHOD_VALUES = [:away_from_zero, :toward_zero,
      :nearest_up, :nearest_down, :bankers, :up, :down]

    ##
    # Translations from SimpleMoney rounding methods to BigDecimal rounding
    # methods.
    ROUNDING_METHOD_TRANSLATION = {
      :away_from_zero => BigDecimal::ROUND_UP,
      :toward_zero    => BigDecimal::ROUND_DOWN,
      :nearest_up     => BigDecimal::ROUND_HALF_UP,
      :nearest_down   => BigDecimal::ROUND_HALF_DOWN,
      :bankers        => BigDecimal::ROUND_HALF_EVEN,
      :up             => BigDecimal::ROUND_CEILING,
      :down           => BigDecimal::ROUND_FLOOR,
    }

    ##
    # @return [Symbol] The default as used to create a new Money (defaults to
    #  :cents).
    attr_reader :default_as

    ##
    # Set the default as used to create a new Money.
    #
    # @param [Symbol] as The default to use.
    #
    # @return [Symbol]
    #
    # @raise [ArgumentError] Will raise an ArgumentError unless as is valid.
    #
    # @example
    #  Money.default_as = :cents   #=> :cents
    #  Money.default_as = :decimal #=> :decimal
    def default_as=(as)
      raise ArgumentError, "invalid `as`" unless (
        valid_as? as
      )
      @default_as = as
    end

    ##
    # Returns true if argument is a valid value for :as, otherwise false.
    #
    # @param [Symbol] as The value to check.
    #
    # @return [true,false]
    #
    # @example
    #   Money.valid_as? :cents #=> True
    #   Money.valid_as? :foo   #=> False
    def valid_as?(as)
      VALID_AS_VALUES.include? as
    end

    ##
    # @return [Symbol] The default rounding method used when calculations do
    #  not result in an Fixnum (defaults to :bankers).
    attr_reader :default_rounding_method

    ##
    # Set the default rounding method used when calculations do not result in a
    # Fixnum.
    #
    # @param [Symbol] rounding_method The default to use.
    #
    # @return [Symbol]
    #
    # @raise [ArgumentError] Will raise an ArgumentError unless rounding_method
    #  is valid.
    #
    # @example
    #  Money.default_rounding_method = :up   #=> :up
    #  Money.default_rounding_method = :down #=> :down
    def default_rounding_method=(rounding_method)
      raise ArgumentError, "invalid `rounding_method`" unless (
        valid_rounding_method? rounding_method
      )
      @default_rounding_method = rounding_method
    end

    ##
    # Returns true if argument is a valid rounding method, otherwise false.
    #
    # @param [Symbol] rounding_method The value to check.
    #
    # @return [true,false]
    #
    # @example
    #   Money.valid_rounding_method? :up    #=> True
    #   Money.valid_rounding_method? :foo   #=> False
    def valid_rounding_method?(rounding_method)
      VALID_ROUNDING_METHOD_VALUES.include? rounding_method
    end

    ##
    # The default currency used to create a new Money object (default to :usd).
    attr_reader :default_currency

    ##
    # Set the default currency used to create a new Money object.
    #
    # @param [Currency::CurrencyStruct,#to_s] id The CurrencyStruct or id of
    #  the desired default currency.
    #
    # @return [Currency::CurrencyStruct]
    #
    # @example
    #   Money.default_currency = :usd
    #   Money.default_currency #=> #<CurrencyStruct:... id: :usd, ...>
    def default_currency=(id)
      @default_currency = Currency[id]
    end

    ##
    # @return [BigDecimal] The factional cents left over from any transactions
    #  that overflowed.
    attr_reader :overflow

    ##
    # Update the overflow to the specified amount (converted to a BigDecimal
    # object).
    #
    # @param [#to_s] n The value to set the overflow to.
    #
    # @return [BigDecimal]
    #
    # @example
    #   Money.round(1.5)
    #   Money.overflow #=> #<BigDecimal:... '-0.5E0',4(16)>
    #   Money.overflow = 0
    #   Money.overflow #=> #<BigDecimal:... '0.0',4(8)>
    def overflow=(n)
      @overflow = BigDecimal(n.to_s)
    end

    ##
    # Resets the overflow bucket to 0.
    #
    # @return [BigDecimal]
    def reset_overflow
      self.overflow = 0
    end

    ##
    # Returns n rounded to an integer using the given rounding method, or the
    # default rounding method when none is provided. When rounding, the
    # fractional cents are added to the overflow bucket.
    #
    # @param [#to_s] n The value to round.
    # @param [Symbol] rounding_method The rounding method to use.
    #
    # @return [Fixnum]
    #
    # @raise [ArgumentError] Will raise an ArgumentError if an invalid rounding
    #  method is given.
    #
    # @example
    #   Money.round(1.5, :bankers) #=> 2
    def round(n, rounding_method = default_rounding_method)
      raise ArgumentError, "invalid `rounding_method`" unless (
        valid_rounding_method? rounding_method
      )

      original = BigDecimal(n.to_s)
      rounded  = original.round(
        0,
        ROUNDING_METHOD_TRANSLATION[rounding_method]
      )
      @overflow += original - rounded
      rounded.to_i
    end

  end
  @default_as = :cents
  @default_rounding_method = :bankers
  @default_currency = :usd
  @overflow = BigDecimal("0")

  ##
  # @return [Integer] The value of the object in cents.
  attr_reader :cents

  ##
  # @return [Symbol] The rounding method used when calculations result in
  # fractions of a cent.
  attr_reader :rounding_method

  ##
  # @return [Currency::CurrencyStruct] The currency representation the object
  # was created using.
  attr_reader :currency

  ##
  # Creates a new Money object. If as is set to :cents, n will be coerced to a
  # Fixnum. If as is set to :decimal, n will be coerced to a BigDecimal.
  #
  # @param [#to_s] n Value of the new object.
  # @param [Hash] options The options used to build the new object.
  # @option options [Symbol] :as How n is represented (defaults to
  #  self.class.default_as).
  # @option options [Symbol] :rounding_method How any calculations resulting in
  #  fractions of a cent should be rounded.
  # @options options [Currency::CurrencyStruct,#to_s] :currency The currency
  #  representation the object should be created using.
  #
  # @raise [ArgumentError] Will raise an ArgumentError if as is not valid.
  # @raise [ArgumentError] Will raise an ArgumentError if rounding method is
  #  not valid.
  #
  # @example
  #   Money.new                        #=> #<Money:... @cents: 0>
  #   Money.new(1)                     #=> #<Money:... @cents: 1>
  #   Money.new(1_00)                  #=> #<Money:... @cents: 100>
  #   Money.new(1_00, :as => :cents)   #=> #<Money:... @cents: 100>
  #   Money.new(1_00, :as => :decimal) #=> #<Money:... @cents: 10000>
  #   Money.new(1.99, :as => :cents)   #=> #<Money:... @cents: 1>
  #   Money.new(1.99, :as => :decimal) #=> #<Money:... @cents: 199>
  def initialize(n = 0, options = {})
    options = {
      :currency => self.class.default_currency,
      :rounding_method => self.class.default_rounding_method,
      :as => self.class.default_as
    }.merge(options)

    @currency = Currency[options[:currency]]

    raise ArgumentError, "invalid `rounding_method`" unless (
      self.class.valid_rounding_method? options[:rounding_method]
    )
    @rounding_method = options[:rounding_method]

    raise ArgumentError, "invalid `as`" unless (
      self.class.valid_as? options[:as]
    )

    @cents = case options[:as]
             when :cents
               Money.round(
                 BigDecimal(n.to_s), rounding_method
               )
             when :decimal
               case currency.subunit_to_unit
               when 10, 100, 1000
                 Money.round(
                   (
                     BigDecimal(n.to_s) *
                     BigDecimal(currency.subunit_to_unit.to_s)
                   ),
                   rounding_method
                 )
               when 1
                 Money.round(
                   BigDecimal(n.to_s), rounding_method
                 )
               when 5
                 unit = BigDecimal(n.to_s).floor * BigDecimal("5")
                 subunit = (
                   (BigDecimal(n.to_s) % BigDecimal("1")) * BigDecimal("10")
                 )
                 Money.round(unit + subunit)
               else
                 raise Exception, "creation of Money objects with subunit_to_unit = `#{currency.subunit_to_unit}` is not implmented"
               end
             end
  end

  ##
  # Add two Money objects; return the results as a new Money object.
  #
  # @param [Money] n The object to add.
  #
  # @return [Money]
  #
  # @raise [ArgumentError] Will raise an ArgumentError unless n is a Money
  #  object.
  # @raise [ArgumentError] Will raise an ArgumentError if currency of n is
  #  incompatible.
  #
  # @example
  #   Money.new(1) + Money.new(2) #=> #<Money:... @cents: 3>
  def +(n)
    raise ArgumentError, "n must be a Money" unless n.is_a? Money
    raise ArgumentError, "n is an incompatible currency" unless (
      n.currency == currency
    )

    Money.new(
      self.cents + n.cents,
      :as => :cents,
      :rounding_method => rounding_method,
      :currency => currency
    )
  end

  ##
  # Subtract two Money; return the results as a new Money object.
  #
  # @param [Money] n The object to subtract.
  #
  # @return [Money]
  #
  # @raise [ArgumentError] Will raise an ArgumentError unless n is a Money
  #  object.
  # @raise [ArgumentError] Will raise an ArgumentError if currency of n is
  #  incompatible.
  #
  # @example
  #   Money.new(2) - Money.new(1) #=> #<Money:... @cents: 1>
  def -(n)
    raise ArgumentError, "n must be a Money" unless n.is_a? Money
    raise ArgumentError, "n is an incompatible currency" unless (
      n.currency == currency
    )

    Money.new(
      self.cents - n.cents,
      :as => :cents,
      :rounding_method => rounding_method,
      :currency => currency
    )
  end

  ##
  # Multiply Money by a Numeric; return the results as a new Money object.
  #
  # @param [Numeric] n The object to multiply. n will be coerced to a
  #  BigDecimal before any calculations are done.
  #
  # @return [Money]
  #
  # @raise [ArgumentError] Will raise an ArgumentError unless n is a Numeric
  #  object.
  #
  # @example
  #   Money.new(2) * 2 #=> #<Money:... @cents: 4>
  def *(n)
    raise ArgumentError, "n must be a Numeric" unless n.is_a? Numeric

    Money.new(
      BigDecimal(self.cents.to_s) * BigDecimal(n.to_s),
      :as => :cents,
      :rounding_method => rounding_method,
      :currency => currency
    )
  end

  ##
  # Divide self by a Money/Numeric; return the results as a new Numeric/Money.
  #
  # @param [Money,Numeric] n The object to divide. If n is Numeric, it will be
  #  coerced to a BigDecimal before any calculations are done.
  #
  # @return [Numeric,Money]
  #
  # @raise [ArgumentError] Will raise an ArgumentError unless n is a Money
  #  object or Numeric.
  # @raise [ArgumentError] Will raise an ArgumentError if currency of n is
  #  incompatible.
  #
  # @example
  #   Money.new(10) / Money.new(5) #=> 2
  #   Money.new(10) / 5            #=> #<Money:... @cents: 2>
  def /(n)
    case n
    when Money
      raise ArgumentError, "n is an incompatible currency" unless (
        n.currency == currency
      )

      BigDecimal(self.cents.to_s) / BigDecimal(n.cents.to_s)
    when Numeric
      result, overflow = BigDecimal(self.cents.to_s).divmod(BigDecimal(n.to_s))
      self.class.overflow = self.class.overflow + overflow
      Money.new(
        result,
        :as => :cents,
        :rounding_method => rounding_method,
        :currency => currency
      )
    else
      raise ArgumentError, "n must be a Money or Numeric"
    end
  end

  ##
  # Modulo self by a Money/Numeric; return the results as a new Numeric/Money.
  #
  # @param [Money,Numeric] n The object to modulo. If n is Numeric, it will be
  #  coerced to a BigDecimal before any calculations are done.
  #
  # @return [Numeric,Money]
  #
  # @raise [ArgumentError] Will raise an ArgumentError unless n is a Money
  #  object or Numeric.
  # @raise [ArgumentError] Will raise an ArgumentError if n is an incompatible
  #  currency.
  #
  # @example
  #   Money.new(10) % Money.new(5) #=> 2
  #   Money.new(10) % 5            #=> #<Money:... @cents: 2>
  def %(n)
    case n
    when Money
      raise ArgumentError, "n is an incompatible currency" unless (
        n.currency == currency
      )

      BigDecimal(self.cents.to_s) % BigDecimal(n.cents.to_s)
    when Numeric
      Money.new(
        BigDecimal(self.cents.to_s) % BigDecimal(n.to_s),
        :as => :cents,
        :rounding_method => rounding_method,
        :currency => currency
      )
    else
      raise ArgumentError, "n must be a Money or Numeric"
    end
  end

  ##
  # Returns cents formatted as a string, based on any options passed.
  #
  # @param [Hash] options The options used to format the string.
  # @option options [Symbol] :as How cents should be returned (defaults to
  #  self.class.default_as).
  #
  # @return [String]
  #
  # @raise [ArgumentError] Will raise an ArgumentError if as is not valid.
  #
  # @example
  #   n = Money.new(1_00, :as => :cents)
  #   n.to_s                  #=> "100"
  #   n.to_s(:as => :decimal) #=> "1.00"
  def to_s(options = {})
    options = {
      :as => :cents
    }.merge(options)

    raise ArgumentError, "invalid `as`" unless (
      self.class.valid_as? options[:as]
    )

    case options[:as]
    when :cents
      cents.to_s
    when :decimal
      if currency.subunit_to_unit == 1
        return cents.to_s
      end
      unit, subunit = cents.divmod(currency.subunit_to_unit).map(&:to_s)
      subunit = (("0" * currency.decimal_places) + subunit)
      subunit = subunit[
        (-1 * currency.decimal_places),
        currency.decimal_places
      ]
      "#{unit}.#{subunit}"
    end
  end

end
