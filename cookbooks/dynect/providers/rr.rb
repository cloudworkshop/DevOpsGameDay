#
# Cookbook Name:: dynect
# Provider:: rr
#
# Copyright:: 2010, Opscode, Inc <legal@opscode.com>
#
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

  @current_resource = Chef::Resource::DynectRr.new(@new_resource.name)
  @current_resource.record_type(@new_resource.record_type)
  @current_resource.customer(@new_resource.customer)
  @current_resource.username(@new_resource.username)
  @current_resource.password(@new_resource.password)
  @current_resource.zone(@new_resource.zone)

  @rr = nil
  @target = nil

  begin
    @rr = DynectRest::Resource.new(@dyn, @new_resource.record_type, @new_resource.zone).get(@new_resource.fqdn)

	if @rr != nil && @rr.kind_of?(Array)
      Chef::Log.debug("Ambiguous response for #{@new_resource} #{@new_resource.rdata.inspect} at Dynect, looking further")
	  
      # fqdn + record_type + rdata == a unique record, hence element 0
      # note: dynect_rest 0.3.0 gem "find" method duplicates rr in
      # return list for each matching key,value pair, "or" logic
      @rr = DynectRest::Resource.new(@dyn, @new_resource.record_type, @new_resource.zone).find(@new_resource.fqdn, @new_resource.rdata)[0]
    end

# at this point @rr sould be empty or a single Resource Record
    if @rr != nil
      Chef::Log.debug("Found resource #{@new_resource} #{@new_resource.rdata.inspect} at Dynect")
	  # is this singular rr our requested target? 
	    @new_resource.rdata.each do |key, value|
			@target = @rr if @rr[key.to_s] == value
		end
	  Chef::Log.debug(" ##### found target") if @target

      @current_resource.fqdn(@rr.fqdn)
      @current_resource.ttl(@rr.ttl)
      @current_resource.zone(@rr.zone)
      @current_resource.rdata(@rr.rdata)
    else 
      Chef::Log.info("Cannot find resource #{@new_resource} #{@new_resource.rdata.inspect} at Dynect")
    end

  rescue DynectRest::Exceptions::RequestFailed => e
    Chef::Log.debug("Cannot find resource #{@new_resource} at Dynect")
  end
end

def action_create
  unless @target 
    rr = DynectRest::Resource.new(@dyn, @new_resource.record_type, @new_resource.zone)
    rr.fqdn(@new_resource.fqdn)
    rr.ttl(@new_resource.ttl) if @new_resource.ttl
    rr.rdata = @new_resource.rdata
    rr.save
    @dyn.publish
    Chef::Log.info("Added #{@new_resource} #{@new_resource.rdata.inspect} to dynect")
    @updated = true
  end
end

def action_update
  if @rr
    changed = false
    if (@new_resource.ttl && @rr.ttl != @new_resource.ttl)
      @rr.ttl(@new_resource.ttl)
      Chef::Log.info("Changing #{@new_resource} ttl from #{@rr.ttl} to #{@new_resource.ttl}")
      changed = true
    end
    if @rr.rdata != @new_resource.rdata
      Chef::Log.info("Changing #{@new_resource} rdata from #{@rr.rdata.inspect} to #{@new_resource.rdata.inspect}")
      @rr.rdata = @new_resource.rdata
      changed = true
    end
    if changed
      @rr.save
      @dyn.publish
      Chef::Log.info("Updated #{@new_resource} at dynect")
      @updated = true
    end
  else
    action_create
  end
end

def action_replace
  rr = DynectRest::Resource.new(@dyn, @new_resource.record_type, @new_resource.zone)
  rr.fqdn(@new_resource.fqdn)
  rr.ttl(@new_resource.ttl) if @new_resource.ttl
  rr.rdata = @new_resource.rdata
  rr.save(true)
  @dyn.publish
  Chef::Log.info("Replaced #{@new_resource} at dynect")
  @updated = true
end

def action_delete
  if @rr
    @rr.delete
    @dyn.publish
    Chef::Log.info("Deleted #{@new_resource} #{@new_resource.rdata.inspect} from dynect")
    @updated = true
  end
end
