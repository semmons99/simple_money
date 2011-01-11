require 'simple_money/money'

describe "Money" do

  # Make sure defaults are reset
  after :each do
    Money.default_as = :cents
    Money.default_rounding_method = :bankers
    Money.default_currency = :usd
    Money.reset_overflow
  end

  describe ".default_as" do

    it "should return the default as used to create a new Money" do
      Money.default_as.should == :cents
    end

  end

  describe ".default_as=" do

    it "should set the default as used to create a new Money" do
      Money.default_as = :decimal
      Money.default_as.should == :decimal

      Money.default_as = :cents
      Money.default_as.should == :cents
    end

    it "should raise an ArgumentError unless as is valid" do
      lambda{Money.default_as = :foo}.should raise_error ArgumentError
    end 

  end

  describe ".valid_as?" do

    it "should return true if as is valid" do
      Money.valid_as?(:cents).should   == true
      Money.valid_as?(:decimal).should == true
    end

    it "should return false if as is invalid" do
      Money.valid_as?(:foo).should == false
    end

  end

  describe ".default_rounding_method" do

    it "should return the default rounding method used" do
      Money.default_rounding_method.should == :bankers
    end

  end

  describe ".default_rounding_method=" do

    it "should set the default rounding method" do
      Money.default_rounding_method = :away_from_zero
      Money.default_rounding_method.should == :away_from_zero
    end

    it "should raise an ArgumentError unless rounding method is valid" do
      lambda{
        Money.default_rounding_method = :foo
      }.should raise_error ArgumentError
    end

  end

  describe ".valid_rounding_method?" do

    it "should return true if rounding method is valid" do
      Money.valid_rounding_method?(:away_from_zero).should == true
      Money.valid_rounding_method?(:toward_zero).should    == true
      Money.valid_rounding_method?(:nearest_up).should     == true
      Money.valid_rounding_method?(:nearest_down).should   == true
      Money.valid_rounding_method?(:bankers).should        == true
      Money.valid_rounding_method?(:up).should             == true
      Money.valid_rounding_method?(:down).should           == true
    end

    it "should return false if rounding method is invalid" do
      Money.valid_rounding_method?(:foo).should == false
    end

  end

  describe ".default_currency" do

    it "should return the default currency used" do
      Money.default_currency.should == Currency[:usd]
    end

  end

  describe ".default_currency=" do

    it "should set the default currency used" do
      Money.default_currency.should == Currency[:usd]
      Money.default_currency = :eur
      Money.default_currency.should == Currency[:eur]
    end

    it "should raise and ArgumentError unless the currency is valid" do
      lambda{
        Money.default_currency = :not_a_real_currency
      }.should raise_error ArgumentError
    end

  end

  describe ".overflow" do

    it "should return the sum of all rounded calculations" do
      Money.overflow.should == BigDecimal("0")
      Money.new(1.29)
      Money.overflow.should == BigDecimal("0.29")
    end

  end

  describe ".overflow=" do

    it "should set the overflow to the provided value" do
      Money.overflow.should == BigDecimal("0")
      Money.overflow = 5
      Money.overflow.should == BigDecimal("5")
    end

  end

  describe ".reset_overflow" do

    it "should reset the overflow bucket to 0" do
      Money.overflow.should == BigDecimal("0")
      Money.new(1.29)
      Money.overflow.should == BigDecimal("0.29")
      Money.reset_overflow
      Money.overflow.should == BigDecimal("0")
    end

  end

  describe ".round" do

    context "without rounding method given" do

      it "should round n using the default rounding method" do
        Money.round(1.5).should  == 2
        Money.round(2.5).should  == 2
        Money.round(-1.5).should == -2
        Money.round(-2.5).should == -2
      end

      it "should added rounded fractional cents to the overflow bucket" do
        Money.round(1.5)
        Money.overflow.should == BigDecimal("-0.5")
      end

    end

    context "with rounding method given" do
      
      it "should round n using the given rounding method" do
        Money.round(1.5, :away_from_zero).should == 2
        Money.round(1.5, :toward_zero).should   == 1
        Money.round(1.5, :nearest_up).should     == 2
        Money.round(1.5, :nearest_down).should   == 1
        Money.round(1.5, :bankers).should        == 2
        Money.round(1.5, :up).should             == 2
        Money.round(1.5, :down).should           == 1

        Money.round(2.5, :away_from_zero).should == 3
        Money.round(2.5, :toward_zero).should   == 2
        Money.round(2.5, :nearest_up).should     == 3
        Money.round(2.5, :nearest_down).should   == 2
        Money.round(2.5, :bankers).should        == 2
        Money.round(2.5, :up).should             == 3
        Money.round(2.5, :down).should           == 2

        Money.round(-1.5, :away_from_zero).should == -2
        Money.round(-1.5, :toward_zero).should   == -1
        Money.round(-1.5, :nearest_up).should     == -2
        Money.round(-1.5, :nearest_down).should   == -1
        Money.round(-1.5, :bankers).should        == -2
        Money.round(-1.5, :up).should             == -1
        Money.round(-1.5, :down).should           == -2

        Money.round(-2.5, :away_from_zero).should == -3
        Money.round(-2.5, :toward_zero).should   == -2
        Money.round(-2.5, :nearest_up).should     == -3
        Money.round(-2.5, :nearest_down).should   == -2
        Money.round(-2.5, :bankers).should        == -2
        Money.round(-2.5, :up).should             == -2
        Money.round(-2.5, :down).should           == -3
      end

      it "should added rounded fractional cents to the overflow bucket" do
        Money.round(1.5, :away_from_zero)
        Money.overflow.should == BigDecimal("-0.5")
      end

      it "should raise an ArgumentError unless rounding method is valid" do
        lambda{
          Money.round(1.29, :foo)
        }.should raise_error ArgumentError
      end

    end

  end

  describe "#new" do

    context "without value given" do

      it "should default cents to 0" do
        Money.new.cents.should == 0
      end

    end

    context "with value given" do

      it "should set cents appropriately" do
        (0..100).each do |n|
          Money.new(n).cents.should == n
        end
      end

      it "should added rounded fractional cents to the overflow bucket" do
        Money.new(1.5)
        Money.overflow.should == BigDecimal("-0.5")
      end

    end

    context "with :as => :cents" do

      it "should treat passed value as cents" do
        (0..100).each do |n|
          Money.new(n, :as => :cents).cents.should == n
        end
      end

      it "should added rounded fractional cents to the overflow bucket" do
        Money.new(1.5, :as => :cents)
        Money.overflow.should == BigDecimal("-0.5")
      end

    end

    context "with :as => :decimal" do

      it "should treat passed value as a decimal" do
        ("0.01".."1.00").map(&:to_f).each do |n|
          Money.new(n, :as => :decimal).cents.should == (
            Money.round BigDecimal(n.to_s) * 100
          )
        end
      end

      it "should added rounded fractional cents to the overflow bucket" do
        Money.new(1.555, :as => :decimal)
        Money.overflow.should == BigDecimal("-0.5")
      end

    end

    context "with invalid :as" do

      it "should raise an ArgumentError" do
        lambda{
          Money.new(1_00, :as => :foo)
        }.should raise_error ArgumentError
      end
    end

    it "should use the default :as" do
      Money.default_as = :decimal
      ("0.01".."1.00").map(&:to_f).each do |n|
        Money.new(n).cents.should == (
          Money.round BigDecimal(n.to_s) * 100
        )
      end

      Money.default_as = :cents
      (0..100).each do |n|
        Money.new(n).cents.should == n
      end
    end

    context "with valid :currency" do

      context "with String" do

        it "should use the provided currency to create the object" do
          Money.new(1_00, :currency => "EUR").currency.should == Currency[:eur]
        end

      end

      context "with Symbol" do

        it "should use the provided currency to create the object" do
          Money.new(1_00, :currency => :eur).currency.should == Currency[:eur]
        end

      end

      context "with CurrencyStruct" do

        it "should use the provided currency to create the object" do
          c = Currency[:eur]
          Money.new(1_00, :currency => c).currency.should == Currency[:eur]
        end

      end

    end

    context "with invalid :currency" do

      it "should raise an ArgumentError" do
        lambda{
          Money.new(1_00, :currency => :not_a_real_currency)
        }.should raise_error ArgumentError
      end

    end

    it "should use the default :currency" do
      Money.default_currency = :eur
      Money.new(1_00).currency.should == Currency[:eur]
    end

  end

  describe "#add" do

    it "should add two Money objects together" do
      (0..100).to_a.combination(2).each do |(a,b)|
        (Money.new(a) + Money.new(b)).cents.should == a + b
      end
    end

    it "should raise an error if argument is not a Money" do
      lambda{
        Money.new + 0
      }.should raise_error ArgumentError
    end

  end

  describe "#subtract" do

    it "should subtract two Money objects from each other" do
      (0..100).to_a.combination(2).each do |(a,b)|
        (Money.new(a) - Money.new(b)).cents.should == a - b
      end
    end

    it "should raise an error if argument is not a Money" do
      lambda{Money.new - 0}.should raise_error ArgumentError
    end

  end

  describe "#multiply" do

    it "should multiply a Money object by a Numeric" do
      (0..100).to_a.combination(2).each do |(a,b)|
        (Money.new(a) * b).cents.should == a * b
      end

      ("0.01".."1.00").map(&:to_f).combination(2).each do |(a,b)|
        (Money.new(a, :as => :decimal) * b).cents.should == (
          Money.round BigDecimal(a.to_s) * 100 * BigDecimal(b.to_s)
        )
      end
    end

    it "should added rounded fractional cents to the overflow bucket" do
      Money.new(2) * 2.1
      Money.overflow.should == BigDecimal("0.2")
    end

    it "should raise an error unless argument is a Numeric" do
      lambda{Money.new * Money.new}.should raise_error ArgumentError
    end

  end

  describe "#divide" do

    it "should divide two Money objects" do
      (1..100).to_a.combination(2).each do |(a,b)|
        (Money.new(a) / Money.new(b)).should == (
          BigDecimal(a.to_s) / BigDecimal(b.to_s)
        )
      end
    end

    it "should divide a Money object by a numeric" do
      (1..100).to_a.combination(2).each do |(a,b)|
        (Money.new(a) / b).cents.should == (
          a.divmod(BigDecimal(b.to_s))[0]
        )
        (Money.new(a) / b.to_f).cents.should == (
          a.divmod(BigDecimal(b.to_f.to_s))[0]
        )
      end
    end

    it "should added rounded fractional cents to the overflow bucket" do
      Money.new(5) / 2
      Money.overflow.should == BigDecimal("1")
    end

    it "should raise an error unless argument is a Money or Numeric" do
      lambda{Money.new / :foo}.should raise_error ArgumentError
    end
  end

  describe "#to_s" do

    it "should return cents formatted as a string" do
      Money.new(1_00).to_s.should == "100"
    end

    context "with :as => :cents" do

      it "should return cents formatted as a string" do
        Money.new(1_00).to_s.should == "100"
      end

    end

    context "with :as => :decimal" do

      it "should return cents formatted as a decimal" do
        Money.new(1_00).to_s(:as => :decimal).should == "1.00"
      end

    end

    context "with invalid :as" do

      it "should raise an ArgumentError" do
        lambda{
          Money.new(1_00).to_s(:as => :foo)
        }.should raise_error ArgumentError
      end

    end

  end

end
