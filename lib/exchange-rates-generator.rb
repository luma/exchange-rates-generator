$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))

require 'patron'
require 'nokogiri'
require 'extlib'
require 'logger'

module ExchangeRatesGenerator
  VERSION = '0.0.6'
  
  def self.log_to=(l)
    @log_to = l
  end

  def self.log_to
    @log_to ||= STDOUT
  end
  
  def self.logger=(logger)
    @logger = logger
  end
  
  def self.logger
    @logger ||= begin
      log = Logger.new(log_to)
      log.level = Logger::INFO
      log
    end
  end
end

require 'exchange-rates-generator/errors'

require 'exchange-rates-generator/formatters/base'
require 'exchange-rates-generator/formatters/ruby'
require 'exchange-rates-generator/formatters/javascript'

require 'exchange-rates-generator/sources/base'
require 'exchange-rates-generator/sources/ecb'