# Cookbook: dynect-dns
# provider: gslb_region_pool
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#


def load_current_resource
  require 'dynect_rest'

  @dyn = DynectRest.new(@new_resource.customer, @new_resource.username, @new_resource.password, @new_resource.zone)

  dyn_uri_resource = "GSLBRegionPoolEntry/#{@new_resource.zone}/#{@new_resource.fqdn}/"
  region_code = @new_resource.region_code
  region_code = region_code.sub(/\s/, '%20')  # poor woman's encoding
  dyn_uri_resource << "#{region_code}/#{new_resource.address}"
  @pool_entry = nil

  begin
	  @pool_entry = @dyn.get(dyn_uri_resource)
  rescue DynectRest::Exceptions::RequestFailed => e
    Chef::Log.debug("Cannot find resource #{@new_resource} at Dynect")
  end
end

def action_get
  if @pool_entry
    Chef::Log.info("here is the glsb #{@pool_entry} in dynect")
  end
end

def action_update_pool_entry
  if @pool_entry
    changed = false
	dyn_uri_resource = "GSLBRegionPoolEntry/#{@new_resource.zone}/#{@new_resource.fqdn}/"
	region_code = @new_resource.region_code
	region_code = region_code.sub(/\s/, '%20')  # poor woman's encoding
	dyn_uri_resource << "#{region_code}/#{new_resource.address}"

    if (@new_resource.new_address && @pool_entry["address"] != @new_resource.new_address)
      @pool_entry["new_address"] = @new_resource.new_address
      Chef::Log.info("Changing #{@new_resource} address to #{@new_resource.new_address}")
      changed = true
    end
	%w{ label weight serve_mode }.each do |arg| 
		if (@new_resource.send(arg.to_sym) && @pool_entry["#{arg}"] != @new_resource.send(arg.to_sym))
			@pool_entry["#{arg}"] = @new_resource.send(arg.to_sym)
			changed = true
			Chef::Log.info("Regional Entry #{arg} value is: #{@pool_entry["#{arg}"]}\n")
		end
	end
    if changed
	  @dyn.put(dyn_uri_resource, @pool_entry)
      Chef::Log.info("Updated #{@pool_entry} at dynect")
      @updated = true
    end
  else
	  Chef::Log.debug("No GSLB Pool entry found to edit, will create it")
	  action_create_pool_entry
  end
end

def action_create_pool_entry
	@new_entry = Hash.new(nil)
	dyn_uri_resource = "GSLBRegionPoolEntry/#{@new_resource.zone}/#{@new_resource.fqdn}/"
	region_code = @new_resource.region_code
	region_code = region_code.sub(/\s/, '%20')  # poor woman's encoding
	dyn_uri_resource << "#{region_code}/"

	%w{ address label weight serve_mode }.each do |arg| 
		puts "new value #{arg} is : ", @new_resource.send(arg.to_sym)
		@new_entry["#{arg}"] = @new_resource.send(arg.to_sym) if @new_resource.send(arg.to_sym)
		Chef::Log.info("Adding Regional Entry #{arg} value is: #{@new_entry["#{arg}"]}\n")
	end

	begin
		@dyn.post(dyn_uri_resource, @new_entry)
		Chef::Log.info("Added #{@new_entry} at dynect")
        @updated = true
    rescue DynectRest::Exceptions::RequestFailed => e
		Chef::Log.debug("Cannot create entry")
	end
end

def action_iterate
  if @pool_entry
	%w{ address label weight serve_mode }.each do |arg| 
		Chef::Log.info("Regional Entry #{arg} value is: #{@pool_entry["#{arg}"]}\n")
	end
  else
	  Chef::Log.debug("No GSLB Pool entry found to edit")
  end
end

