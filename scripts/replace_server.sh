#!/bin/bash

# create a scratch directory for our temp files
mkdir ~/gameday_temp

# use our template file to create a json file with the correct ip address in it
IPTODELETE=$1

# first lets get this IP out of the list of DNS A Records so users won't see a bad server
ruby ~/gameday/script_resources/ruby_delete_a_record.rb $IPTODELETE

# remove the bad server from zenoss's monitoring
wget -T 5 -t 1 --quiet --auth-no-challenge --http-user=gameday --http-password=zenossgd "http://devops.zenoss.com:8080/zport/dmd/Devices/Server/SSH/Linux/devices/$1/deleteDevice"

# call out to chef to remove the old ec2 instance
knife ec2 server delete $2 -y

# bring up the new ec2 cloud server 
knife ec2 server create -G default -S dynect-ops-integration -I ~/gameday/script_resources/dynect-ops-integration.pem -Z us-east-1c --flavor m1.small -i ami-a6c62ecf -x ubuntu -s https://api.opscode.com/organizations/cloudworkshop 'role[base]' 'recipe[dynect::default]' 'role[wordpress1]' 'recipe[dynect::add_a_record]' 2>&1 | tee ~/gameday_temp/server_create_output.txt

# parse through the output of the knife create to get the newly created instance id 
cat ~/gameday_temp/server_create_output.txt | grep -m 1 'Instance ID' > ~/gameday_temp/instance_id.txt
INSTANCEID=`cat ~/gameday_temp/instance_id.txt | grep -o 'i-[0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z][0-9a-zA-Z]'`

# parse through the output of the knife create to get the newly created ip address
cat ~/gameday_temp/server_create_output.txt | grep -m 1 'Public IP Address' > ~/gameday_temp/public_ip_line.txt
PUBLIC_IP=`cat ~/gameday_temp/public_ip_line.txt | grep -o '[0-9]*[0-9]*[0-9][.][0-9]*[0-9]*[0-9][.][0-9]*[0-9]*[0-9][.][0-9]*[0-9]*[0-9]'`

# add new server to zenoss to monitor again
wget -T 5 -t 1 --quiet --auth-no-challenge --http-user=gameday --http-password=zenossgd "http://devops.zenoss.com:8080/zport/dmd/DeviceLoader/loadDevice?deviceName=$PUBLIC_IP&devicePath=/Server/SSH/Linux&tag=$INSTANCEID"

# now let's cleanup our temp work
rm -r ~/gameday_temp

