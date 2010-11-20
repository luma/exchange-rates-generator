require "bundler"
Bundler.setup

require "rspec"

$:.unshift(File.dirname(__FILE__) + '/../lib')
require 'exchange-rates-generator'

RSpec.configure do |config|
end