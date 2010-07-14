name "wordpress1"
description "First wordpress server"
run_list(
  "role[base]",
  "recipe[mysql::client]",
  "recipe[wordpress]"
)
default_attributes(
  "dyntini" => {
    "domain" => "reserve.dyntini.com",
    "seq" => "01"
  },
  "database_master" => {
    "read" => true,
    "write" => true
  }
)
