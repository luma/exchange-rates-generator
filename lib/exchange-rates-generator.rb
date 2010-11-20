# -*- encoding : utf-8 -*-

require 'patron'
require 'nokogiri'
require 'logger'

require 'active_support/core_ext/object/blank'
require 'active_support/inflector'

module ExchangeRatesGenerator
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

dir = File.join(File.expand_path(File.dirname(__FILE__)), 'exchange-rates-generator')
require dir + '/errors'

require dir + '/currency'
require dir + '/currencies'

require dir + '/formatters/base'
require dir + '/formatters/ruby'
require dir + '/formatters/javascript'

require dir + '/sources/base'
require dir + '/sources/ecb'