require 'rubygems'
require 'sinatra/base'
require 'json'

module Repose
  class CoverageApp < Sinatra::Base
    results = nil

    # In your main application file
    configure do
      set :views, "#{File.dirname(__FILE__)}/../../../views"
      set :public_folder, "#{File.dirname(__FILE__)}/../../../public"
      enable :static
      enable :sessions
      enable :show_exceptions if development?
    end

    configure :development do
      set :show_exceptions, :after_handler
      enable :logging
    end
  end
end