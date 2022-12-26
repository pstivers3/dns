#!/bin/bash

# This script uses AWS CLI to lookup instance name tags for source IP addresses found in TCP dump.
# Make a copy of file "5_<name>.source_ip.unique.count" from output of tcpdump_mulitple_reports.sh 
# Place a copy in the same dir as this script.

usage="usage: $0 5_<name>.source_ip.unique.count <hours>"

filename=$1
hours=$2

# Gracefull fail on bad arguments
if [ ! -f $filename ]; then
    echo -e "$filename does not exist.\n$usage"
    exit 1
fi

if [[  $filename != 5_* ]]; then
    echo -e "Expected a filename beginning with \"5_\" as first argument.\n$usage"
    exit 1
fi

if [ -z $hours ] || ! [ $hours -eq $hours ]; then
    echo -e "Expected the second argument to be a digit in unit hours.\n$usage"
    exit 1
fi

# remove any blank lines. There's often one at the end of the file.
sed -i '/^$/d' $filename

# lookup AWS name tag for each IP address
> temp.instance_name.count
while read line; do
    count=$(echo $line | awk '{ print $1 }')
    ip=$(echo $line | awk '{ print $2 }')
    if [[ $ip == "172.31"* ]]; then
        profile=prod
    else
        profile=dev
    fi
    # exclude certain IP blocks that do not represent server instances
    if [[ $ip != "10.12"* ]]; then
        instance_name=$(aws ec2 describe-instances --profile $profile --region us-east-1 --output text \
            --filter Name=private-ip-address,Values="$ip" \
            --query 'Reservations[].Instances[].[Tags[?Key==`Name`]]' \
            | awk '{ print $2 }' )
        printf "%7d %-16s %-36s\n" "$((count/hours))" "$ip" "$instance_name"
        printf "%7d %-16s %-36s\n" "$((count/hours))" "$ip" "$instance_name" >> temp.instance_name.count
    fi
done < $filename

# Add new ip/names to master list
./merge_instance_names.sh temp.instance_name.count

exit 0
