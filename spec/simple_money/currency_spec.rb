require 'simple_money/currency'

describe "Currency" do

  describe "#[]" do

    it "should return a Hash pertaining to the requested currency id" do
      Currency[:usd].should == {
        :priority            => 1,
        :iso_code            => "USD",
        :name                => "United States Dollar",
        :symbol              => "$",
        :subunit             => "Cent",
        :subunit_to_unit     => 100,
        :decimal_places      => 2,
        :symbol_first        => true,
        :html_entity         => "$",
        :decimal_mark        => ".",
        :thousands_separator => ","
      }
    end

    it "should work with and uppercase string" do
      Currency["USD"].should == {
        :priority            => 1,
        :iso_code            => "USD",
        :name                => "United States Dollar",
        :symbol              => "$",
        :subunit             => "Cent",
        :subunit_to_unit     => 100,
        :decimal_places      => 2,
        :symbol_first        => true,
        :html_entity         => "$",
        :decimal_mark        => ".",
        :thousands_separator => ","
      }
    end

    it "should work with a lowercase string" do
      Currency["usd"].should == {
        :priority            => 1,
        :iso_code            => "USD",
        :name                => "United States Dollar",
        :symbol              => "$",
        :subunit             => "Cent",
        :subunit_to_unit     => 100,
        :decimal_places      => 2,
        :symbol_first        => true,
        :html_entity         => "$",
        :decimal_mark        => ".",
        :thousands_separator => ","
      }
    end

    it "should work with a uppercase symbol" do
      Currency[:USD].should == {
        :priority            => 1,
        :iso_code            => "USD",
        :name                => "United States Dollar",
        :symbol              => "$",
        :subunit             => "Cent",
        :subunit_to_unit     => 100,
        :decimal_places      => 2,
        :symbol_first        => true,
        :html_entity         => "$",
        :decimal_mark        => ".",
        :thousands_separator => ","
      }
    end

    it "should work with a lowercase symbol" do
      Currency[:usd].should == {
        :priority            => 1,
        :iso_code            => "USD",
        :name                => "United States Dollar",
        :symbol              => "$",
        :subunit             => "Cent",
        :subunit_to_unit     => 100,
        :decimal_places      => 2,
        :symbol_first        => true,
        :html_entity         => "$",
        :decimal_mark        => ".",
        :thousands_separator => ","
      }
    end

  end

end
