name "base"
description "base role for all nodes"
run_list(
  "recipe[chef::bootstrap_client]",
  "recipe[dynect_dns]"
)
default_attributes(
  "database_east" => {
    "master_ip" => "10.241.26.81",
    "slave_ip" => "10.249.70.95"
  },
  "database_west" => {
    "master_ip" => "10.162.155.133",
    "slave_ip" => "10.162.154.165"
  },
  "dynect" => {
    "customer" => "XXXXXXXXXXXXXXXXXXXXX",
    "username" => "XXXXXXXXXXXXXXXXXXXXX",
    "password" => "XXXXXXXXXXXXXXXXXXXXX",
    "zone" => "dyntini.com",
    "domain" => "dyntini.com"
  }
)
