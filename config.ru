require 'rubygems'
require 'bundler'

Bundler.require

require Dir.pwd + '/app.rb'

set :environment, :production
set :sessions, true
set :session_secret, 'SDglk3Sdkh3SD3#@d'

run Rack::URLMap.new("/" => Repose::CoverageApp.new)
