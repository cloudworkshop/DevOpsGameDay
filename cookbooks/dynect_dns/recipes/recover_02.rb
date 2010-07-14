# Cookbook Name:: dynect-dns
# Recipe:: recover_02
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
#
# SITUATIONAL RECIPE:
# Pulls IP2 from WEST region, replace with IP5 from EAST REGION

include_recipe 'dynect_dns'

dynect_dns_gslb_region_pool node[:hostname] do
	customer node[:dynect][:customer]
	username node[:dynect][:username]
	password node[:dynect][:password]
	zone     node[:dynect][:zone]
	fqdn "reserve.#{node[:dynect][:domain]}"
	
	region_code 'US West'
	new_address '184.72.54.44'
	address '184.72.248.73'
	label 'www-02-west' # update label to this
	action :update_pool_entry

end
