# Cookbook: dynect-dns
# Resource: gslb
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

#actions :delete, :create, :update, :replace
actions :get, :update_ttl


attribute :username, :kind_of => String
attribute :password, :kind_of => String
attribute :customer, :kind_of => String
attribute :zone, :kind_of => String
attribute :fqdn, :kind_of => String

attribute :ttl, :kind_of => String

# attrs for a monitor
# TODO: regex these for better control
attribute :protocol, :kind_of => String, :required => true
attribute :interval, :kind_of => Integer, :required => true

