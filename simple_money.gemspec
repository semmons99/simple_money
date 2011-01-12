Gem::Specification.new do |s|
  s.name        = "simple_money"
  s.version     = "0.2.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Shane Emmons"]
  s.email       = "semmons99@gmail.com"
  s.homepage    = "http://github.com/semmons99/simple_money"
  s.summary     = "Library to work with money/currency."
  s.description = "This gem is intended for working with financial calculations (money/currency) where you need highly accurate results."

  s.required_ruby_version     = ">= 1.8.7"
  s.required_rubygems_version = ">= 1.3.7"
  
  s.add_development_dependency "rspec", ">= 2.0.0"
  s.add_development_dependency "yard"

  s.files        = Dir.glob("lib/**/*") + %w(CHANGELOG.md LICENSE README.md)
  s.require_path = "lib"
end

