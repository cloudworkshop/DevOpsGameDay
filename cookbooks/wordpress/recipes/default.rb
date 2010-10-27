#
# Cookbook Name:: wordpress
# Recipe:: default
#
# Copyright 2009-2010, Opscode, Inc.
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

include_recipe "apache2"

g = gem_package "mysql" do
  action :nothing
end

g.run_action(:install)
require 'rubygems'
Gem.clear_paths

if node.has_key?("ec2")
  server_fqdn = node.ec2.public_hostname
  region = node.ec2.placement_availability_zone.split("-")[1]
  dyn_hostname = "www-#{node.dyntini.seq}-#{region}.#{node.dyntini.domain}"
else
  server_fqdn = node.fqdn
end

remote_file "#{Chef::Config[:file_cache_path]}/wordpress-#{node[:wordpress][:version]}.tar.gz" do
  checksum node[:wordpress][:checksum]
  source "http://wordpress.org/wordpress-#{node[:wordpress][:version]}.tar.gz"
  mode "0644"
end

directory "#{node[:wordpress][:dir]}" do
  owner "root"
  group "root"
  mode "0755"
  action :create
end

execute "untar-wordpress" do
  cwd node[:wordpress][:dir]
  command "tar --strip-components 1 -xzf #{Chef::Config[:file_cache_path]}/wordpress-#{node[:wordpress][:version]}.tar.gz"
  creates "#{node[:wordpress][:dir]}/wp-settings.php"
end


#ruby_block "config file" do
#  block do
#    run_context = Chef::RunContext.new(node, {})
#    r = Chef::Resource::File.new("#{node[:wordpress][:dir]}/wp-config.php", run_context)
#    r.content(IO.read("#{node[:wordpress][:dir]}/wp-config-sample.php"))
#    r.owner("root")
#    r.group("root")
#    r.mode("0644")
#    r.run_action(:create)
#  end
#end


remote_directory "#{node[:wordpress][:dir]}/wp-content/themes/dyntini" do
  source "dyntini-theme"
  owner "www-data"
  group "www-data"
  mode "0644"
  files_owner "www-data"
  files_group "www-data"
  files_mode "0644"
end

cookbook_file "#{node.wordpress.dir}/wp-content/db.php" do
  source "db.php"
  owner "root"
  group "root"
  mode "0644"
end

dbmw = node.database_master.attribute?(:write) ? 1:0
dbmr = node.database_master.attribute?(:read) ? 1:0
if node.attribute?("database_slave")
  dbsw = node.database_slave.attribute?(:write) ? 1:0
  dbsr = node.database_slave.attribute?(:read) ? 1:0
end

template "#{node.wordpress.dir}/db-config.php" do
  source "db-config.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables(
    :region => region,
    :dbmw => dbmw,
    :dbmr => dbmr,
    :dbsw => dbsw,
    :dbsr => dbsr
  )
end

template "#{node.wordpress.dir}/admin-header.php" do
  source "admin-header.php.erb"
  owner "root"
  group "root"
  mode "0644"
  variables :dyn_hostname => dyn_hostname
end

remote_directory "#{node.wordpress.dir}/wp-content/plugins/twitter-widget-pro" do
  source "twitter-widget-pro"
  owner "root"
  group "root"
  mode "0644"
end

include_recipe %w{php::php5 php::module_mysql}

apache_site "000-default" do
  enable false
end

web_app "wordpress" do
  template "wordpress.conf.erb"
  docroot "#{node[:wordpress][:dir]}"
  server_name server_fqdn
  server_aliases node.fqdn
end

# Lets do dns stuff in this cookbook because its fun
#
ruby_block "edit etc hosts" do
  block do
    rc = Chef::Util::FileEdit.new("/etc/hosts")
    rc.insert_line_after_match(/^127\.0\.0\.1 localhost$/, "#{node.database_east.master_ip} db-master-east.internal")
    rc.insert_line_after_match(/^db-master-east.internal$/, "#{node.database_east.slave_ip} db-slave-east.internal")
    rc.insert_line_after_match(/^db-slave-east.internal$/, "#{node.database_west.master_ip} db-master-west.internal")
    rc.insert_line_after_match(/^db-master-west.internal$/, "#{node.database_west.slave_ip} db-slave-west.internal")
    rc.write_file
  end
end

