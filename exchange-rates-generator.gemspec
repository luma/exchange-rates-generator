# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "exchange-rates-generator/version"

Gem::Specification.new do |s|
  s.name        = "exchange-rates-generator"
  s.version     = Exchange::Rates::Generator::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Rolly Fordham"]
  s.email       = ["rolly@luma.co.nz"]
  s.homepage    = ""
  s.summary     = %q{Generates a classes (or class like things) that can translate currency values in a specific currency to a number of other currencies.}
  s.description = %q{Generates a classes (or class like things) that can translate currency values in a specific currency to a number of other currencies. Other currency sources and new formats can be added.}

  s.rubyforge_project = "exchange-rates-generator"

  s.files               = `git ls-files`.split("\n")
  s.test_files          = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.default_executable  = 'bin/generate_exchange_rates'
  s.executables         = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths       = ["lib"]
  
  s.add_dependency 'patron', '~> 0.4.10'
  s.add_dependency 'nokogiri', '~> 1.4.4'
  s.add_dependency 'money', '~> 3.1.5'
  s.add_dependency 'i18n', '~> 0.4.2' # Required for activesupport
  s.add_dependency 'activesupport', '~> 3.0.3'

  s.add_development_dependency "bundler", ">= 1.0.7"
  s.add_development_dependency "rake"
  s.add_development_dependency "rspec", "2.1.0"
  s.add_development_dependency "yard"
  s.add_development_dependency "rcov"
end