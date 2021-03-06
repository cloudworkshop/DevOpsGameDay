#
# Cookbook Name:: dynect
# Recipe:: add_a_record
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

include_recipe 'dynect'

dynect_rr node[:hostname] do
  customer node[:dynect][:customer]
  username node[:dynect][:username]
  password node[:dynect][:password]
  zone     node[:dynect][:zone]

  record_type "A"

  rdata({ "address" => node[:ec2][:public_ipv4] })
  ttl 30
  fqdn node[:dynect][:fqdn]
  action :create
end
