#!/usr/bin/ruby
require 'rubygems'
require 'net/https'
require 'uri'
require 'json'
require '/home/zenoss/gameday/script_resources/DynectConfig.rb'

if __FILE__ == $0
  # Set the desired parameters on the command line 
  CUSTOMER_NAME = DynectConfig::DYN_CN
  USER_NAME = DynectConfig::DYN_UN
  PASSWORD = DynectConfig::DYN_PWD
  ZONE = DynectConfig::DYN_ZONE
  FQDN = DynectConfig::DYN_FQDN
  ip_address =ARGV[0]
   
  # Set up our HTTP object with the required host and path
  url = URI.parse('https://api2.dynect.net/REST/Session/')
  headers = { "Content-Type" => 'application/json' }
  http = Net::HTTP.new(url.host, url.port)
  http.use_ssl = true
  
  # Login and get an authentication token that will be used for all subsequent requests.
  session_data = { :customer_name => CUSTOMER_NAME, :user_name => USER_NAME, :password => PASSWORD }
  
  resp, data = http.post(url.path, session_data.to_json, headers)
  result = JSON.parse(data)
  
  if result['status'] == 'success'    
  	auth_token = result['data']['token']
   else
    puts "Command Failed:\n"
    # the messages returned from a failed command are a list
    result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  end
  
  # New headers to use from here on with the auth-token set
  headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
  
  # Get the A recrods for the zone and fqdn
  url = URI.parse("https://api2.dynect.net/REST/ARecord/#{ZONE}/#{FQDN}/")
  resp, data = http.get(url.path, headers)
  get_result = JSON.parse(data)
 
  # Loop through each A record until we find the one that matches the ip address we want to remove then
  # call delete on this record
  found_record = false
  deleted_record = false 
  get_result['data'].each  do |path|
	url = URI.parse("https://api2.dynect.net" + path)
        resp, data = http.get(url.path, headers)
        get_record = JSON.parse(data)
        # Check if the ip address coming in matches the record's ip address 
        if get_record['data']['rdata']['address'] == ip_address
            url = URI.parse("https://api2.dynect.net" + path)
            resp, data = http.delete(url.path, headers)
            # Check that we in fact returned the record correctly 
	    if result['status'] != 'success'
    		puts "Delete Failed:\n"
    		# the messages returned from a failed command are a list
   	 	result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
  	    else
		deleted_record = true
	    end
            found_record = true
	    break 
        end 
  end

  # If the record was not found at all, notify the user
  if found_record == false
	puts "A record was not found in the zone/fqdn supplied"
  else
  	if deleted_record == true
		# Publish the changes if the record was found and deleted
  		url = URI.parse("https://api2.dynect.net/REST/Zone/#{ZONE}/") 
 		publish_data = { "publish" => "true" }
  		resp, data = http.put(url.path, publish_data.to_json, headers)
		if result['status'] != 'success'
                	puts "Publish Zone Failed:\n"
                	# the messages returned from a failed command are a list
                	result['msgs'][0].each{|key, value| print key, " : ", value, "\n"}
            	else
			puts "A Record Removed!"
		end 
        end 
  end
 
  # Logout
  url = URI.parse('https://api2.dynect.net/REST/Session/')
  resp, data = http.delete(url.path, headers)
end
