require 'rest_client'
require 'nokogiri'
require 'yaml'
require 'set'

module Repose
  class CoverageApp < Sinatra::Base

    get '/' do
       puts "#{settings.views}/index.html"
      send_file "#{settings.views}/index.html"
    end

    get '/api/results' do 
    	# get results from jolokia
    	content_type :json
        config = YAML.load_file(File.expand_path("config.yaml", Dir.pwd))
        host = config['host']
        port = config['port']

    	body RestClient.get "http://#{host}:#{port}/jolokia/read/%22com.rackspace.com.papi.components.checker.handler%22:type=%22InstrumentedHandler%22,scope=*,name=*"
    end

    get '/api/steps' do
        # get steps from jolokia
        scopes = params[:scopes]
        content_type :json
        config = YAML.load_file(File.expand_path("config.yaml", Dir.pwd))
        host = config['host']
        port = config['port']
        scopes = []
        #get all results with success and fail paths and all nodes
        results = {
            :success_paths => {},
            :fail_paths => {},
            :nodes => {}
        }

        result = JSON.parse(RestClient.get "http://#{host}:#{port}/jolokia/read/%22com.rackspace.com.papi.components.checker.handler%22:type=%22InstrumentedHandler%22,scope=*,name=*")
        result['value'].each do |key, _|
            scopes << key.scan(/scope=\"(\w+)\"/)[0][0]
        end

        scopes.uniq!

        puts scopes.inspect

        scopes.each do |scope|
            results[:success_paths][scope.split('_')[0]] = []
            results[:fail_paths][scope.split('_')[0]] = []
            results[:nodes][scope.split('_')[0]] = []
            # get xml from scope
            response =  JSON.parse(RestClient.get "http://#{host}:#{port}/jolokia/exec/%22com.rackspace.com.papi.components.checker%22:type=%22Validator%22,scope=%22#{scope}%22,name=%22checker%22/checkerXML")
            responseDoc = Nokogiri::XML.parse(response['value'])
            #get output and get the paths
            steps = responseDoc.xpath("//v:step",'v' => 'http://www.rackspace.com/repose/wadl/checker')
            # have to iterate twice :(
            steps.each do |step|
                # save a node for a specific scope (role)
                results[:nodes][scope.split('_')[0]] << {
                    "id" => step['id'],
                    "type" => step['type']
                }
            end
            puts results.inspect
            steps.each do |step|
                # check if there are next steps
                if step['next'] then
                    # for each next step, add it to fail or success path
                    step['next'].split(' ').each do | next_step|
                        if results[:nodes][scope.split('_')[0]].find {|node| node["id"] == next_step && ["METHOD_FAIL", "REQ_TYPE_FAIL", "URL_FAIL"].include?(node["type"])} then
                            results[:fail_paths][scope.split('_')[0]] << "#{step['id']}->#{next_step}"
                        else
                            results[:success_paths][scope.split('_')[0]] << "#{step['id']}->#{next_step}"
                        end
                    end
                end
            end
        end

        body results.to_json

    end

    get '/api/roles' do
    	content_type :json
    	#TODO: needs to be configurable
        config = YAML.load_file(File.expand_path("config.yaml", Dir.pwd))
    	directory = config['config_directory']
    	validator = "#{directory}/validator.cfg.xml"

    	validatorDoc = Nokogiri::XML.parse(File.open(validator))
    	roles = validatorDoc.xpath("//v:validator/@role",'v' => 'http://openrepose.org/repose/validator/v1.0')
    	outputs = validatorDoc.xpath("//v:validator/@dot-output", 'v' => 'http://openrepose.org/repose/validator/v1.0')
    	# get all .dot outputs
    	role_list = []
    	roles.each_with_index do | role, index|
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
        config = YAML.load_file(File.expand_path("config.yaml", Dir.pwd))
        directory = config['output_directory']
    	body IO.read("#{directory}/#{file}")
    end

  end
end
