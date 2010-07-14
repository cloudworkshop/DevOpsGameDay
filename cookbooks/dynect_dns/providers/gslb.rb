# Cookbook: dynect-dns
# provider: gslb
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


  dyn_uri_resource = "GSLB/#{@new_resource.zone}/#{@new_resource.fqdn}/"
  @gslb = nil

  begin
	  @gslb = @dyn.get(dyn_uri_resource)
  rescue DynectRest::Exceptions::RequestFailed => e
    Chef::Log.debug("Cannot find resource #{@new_resource} at Dynect")
  end
end

def action_get
  if @gslb
    Chef::Log.info("here is the glsb #{@gslb} in dynect")
  end
end

def action_update_ttl
  if @gslb
	dyn_uri_resource = "GSLB/#{@new_resource.zone}/#{@new_resource.fqdn}/"
    changed = false
    if (@new_resource.ttl && @gslb["ttl"] != @new_resource.ttl)
      @gslb["ttl"] = @new_resource.ttl
      Chef::Log.info("Changing #{@new_resource} ttl to #{@new_resource.ttl}")
      changed = true
    end
    if changed
	  @dyn.put(dyn_uri_resource, @gslb)
      Chef::Log.info("Updated #{@gslb} at dynect")
      @updated = true
    end
  else
	  Chef::Log.debug("No GSLB service found to edit")
  end
end


