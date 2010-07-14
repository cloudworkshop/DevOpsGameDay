# Cookbook: dynect-dns
# Resource: gslb_region_pool
#
# Author:: Lisa Hagemann lhagemann@dyn.com
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

actions :get, :update_pool_entry, :create_pool_entry, :iterate

attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :customer, :kind_of => String
attribute :zone, :kind_of => String
attribute :fqdn, :kind_of => String

# attrs for a regional pool entry
attribute :region_code, :kind_of => String
attribute :address, :kind_of => String
attribute :label, :kind_of => String
attribute :weight, :kind_of => String
attribute :serve_mode, :kind_of => String
attribute :new_address, :kind_of => String
