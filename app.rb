require 'rubygems'
require 'sinatra/base'
require 'json'

module Repose
  class CoverageApp < Sinatra::Base
    results = nil

    error ArgumentError do
      request.env['sinatra.error'].message
    end

  end
end

Dir["#{File.dirname(__FILE__)}/lib/app/bootstrap/*.rb"].each do |bootstrap|
  require bootstrap
end

#Dir["#{File.dirname(__FILE__)}/lib/app/helpers/*.rb"].each do |helper|
#  require helper
#end

Dir["#{File.dirname(__FILE__)}/lib/app/routes/*.rb"].each do |route|
  require route
end
