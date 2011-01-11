require 'simple_money/currency'

describe "Currency" do

  USD = Currency::CurrencyStruct.new(
    1, "USD", "United States Dollar", "$", "Cent", 100, 2, true, "$", ".", ","
  )

  describe "#[]" do

    it "should return a Hash pertaining to the requested currency id" do
      Currency[:usd].should == USD
    end

    it "should work with and uppercase string" do
      Currency["USD"].should == USD
    end

    it "should work with a lowercase string" do
      Currency["usd"].should == USD
    end

    it "should work with a uppercase symbol" do
      Currency[:USD].should == USD
    end

    it "should work with a lowercase symbol" do
      Currency[:usd].should == USD
    end

    it "should raise an ArgumentError if an invalid currency is requested" do
      lambda{
        Currency[:not_a_real_currency]
      }.should raise_error ArgumentError
    end

    it "should return the argument if it is already a CurrencyStruct" do
      Currency[USD].should == USD
    end

  end

end
