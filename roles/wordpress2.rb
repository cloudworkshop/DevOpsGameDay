name "wordpress2"
description "Second wordpress server"
run_list(
  "role[base]",
  "recipe[mysql::client]",
  "recipe[wordpress]"
)
default_attributes(
  "dyntini" => {
    "domain" => "reserve.dyntini.com",
    "seq" => "02"
  },
  "database_master" => {
    "read" => false,
    "write" => true
  },
  "database_slave" => {
    "read" => true,
    "write" => false
  }
)
