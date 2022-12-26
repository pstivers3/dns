#!/bin/bash

output_file=$1
hours=$2
seconds=$(echo "$hours*60*60" | bc)
name_server_ip=$(grep -m 1 nameserver /etc/resolv.conf | awk '{print $2}')

usage="\nusage: nohup $0 <output_file_name> <hours> &\n
Exaple: nohup $0 tcpdump-local-2022-12-26T1100-2h 2 &\n
Decimals of an hour are allowed. 0.1 for example will run for 6 minutes.\n
This script will add extensions to the output filenames as appropriate.\n"

# if number of command line arguments not equal to 2, then display ussage
if [ $# -ne 2 ]; then
    echo -e "$usage"
    exit 0
fi

echo "hours=$hours"
echo "start time: $(date)"
echo -e "timeout $seconds tcpdump -n dst port 53\n"
# capture the requests
timeout $seconds tcpdump -n dst port 53 >> 1_${output_file}.raw
# remove any blank lines. There's likely one at the end of the file.
sed -i '/^$/d' 1_${output_file}.raw
# the first line in the awk command is useful if running this script on a name server and wish to filter 
# for specific source IPs. Otherwise comment them out. 
awk '\
    #($3 ~ /^10.10.5.101/ || $3 ~ /^10.10.5.102/ || $3 ~ /^10.10.5.103/ || $3 ~ /^10.10.5.103/) && \ # example 
    ($5 == "${name_server_ip}.53:" || "${name_server_ip}.domain:") \
    {split($3,p,"."); $3=p[1]"."p[2]"."p[3]"."p[4]; print $3, $8}' \
    1_${output_file}.raw > 2_${output_file}.ip.requests
# print the list of unique request IP/names, and the count
sort 2_${output_file}.ip.requests | uniq -c > 3_${output_file}.ip.requests.unique.count
# print the sorted list of unique request names
awk '{print $3}' 3_${output_file}.ip.requests.unique.count | sort | uniq > 4_${output_file}.requests.unique
awk '{print $1}' 2_${output_file}.ip.requests | sort | uniq -c > 5_${output_file}.source_ip.unique.count
exit 0
