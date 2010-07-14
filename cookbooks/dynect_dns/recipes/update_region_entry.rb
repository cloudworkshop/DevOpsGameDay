# Cookbook Name:: dynect-dns
# Recipe:: update_region_pool.rb
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

include_recipe 'dynect_dns'

dynect_dns_gslb_region_pool node[:hostname] do
	customer node[:dynect][:customer]
	username node[:dynect][:username]
	password node[:dynect][:password]
	zone     node[:dynect][:zone]
	fqdn "gslb.#{node[:dynect][:domain]}"
	
	region_code 'US West'
	address '165.250.13.13'
	weight '6'
	new_address '172.165.1.1'

	action :update_pool_entry

end
