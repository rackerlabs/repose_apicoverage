require 'rest_client'
require 'nokogiri'

module Repose
  class CoverageApp < Sinatra::Base

    get '/' do
       puts "#{settings.views}/index.html"
      send_file "#{settings.views}/index.html"
    end

    get '/api/results' do 
    	# get results from jolokia
    	content_type :json
    	# TODO: url and port needs to be configurable
    	body RestClient.get 'http://localhost:8778/jolokia/read/%22com.rackspace.com.papi.components.checker.handler%22:type=%22InstrumentedHandler%22,scope=*,name=*'

    end

    get '/api/roles' do
    	content_type :json
    	#TODO: needs to be configurable
    	directory = "/Users/dimi5963/projects/repose/repose-aggregator/functional-tests/spock-functional-test/target/repose_home/configs"
    	validator = "#{directory}/validator.cfg.xml"

    	validatorDoc = Nokogiri::XML.parse(File.open(validator))
    	roles = validatorDoc.xpath("//v:validator/@role",'v' => 'http://openrepose.org/repose/validator/v1.0')
    	puts roles.inspect
    	outputs = validatorDoc.xpath("//v:validator/@dot-output", 'v' => 'http://openrepose.org/repose/validator/v1.0')
    	puts outputs.inspect
    	# get all .dot outputs
    	role_list = []
    	roles.each_with_index do | role, index|
    		puts role, outputs[index]
			role_list << {
    			"role" => role,
    			"file" => File.basename(outputs[index])
    		}
    	end

    	body role_list.to_json

    end

    get '/api/roles/file' do
    	#get all the .dot outputs from /etc/repose [may be configurable]
    	file = params[:file]
    	status 200
    	#config directory where the outputs go (needs to be configurable) TODO
    	directory = "/Users/dimi5963/projects/repose/repose-aggregator/functional-tests/spock-functional-test/target/repose_home/configs"
    	body IO.read("#{directory}/#{file}")
    end

  end
end
