#!/bin/bash

# This script compares nslookup using more than one resolver IP.

filename=$1

resolver_ips=(
    '10.5.100.101' # examples
    '10.5.100.102'
)

usage="\nusage: $0 4_<name>.requests.unique\n
example: $0 4_master_list.requests.unique"

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
    echo -e "$usage\n"
    exit 0
fi

# Gracefull fail on invalid argument
if [[  $filename != 4_* ]]; then
    echo -e "\nExpected first argument to be a filename beginning with \"4_\"\n$usage"
    exit 1
fi

name=$( echo "$filename" | awk -F '_' '{ print $2 }' | awk -F '.' '{ print $1 }' )
output_file="6_nslookup_compare_${name}"

> $output_file
echo "$(pwd)" 2>&1 | tee -a $output_file
# echo the command and argument to the output file
echo -e "$0 $1\n" 2>&1 | tee -a $output_file

line_count=$(awk "END{print NR}" $filename)
for ((i=1;i<=${line_count};i++)); do
    request_name=$(awk "NR==$i" $filename)
    for resolver_ip in ${resolver_ips[@]}; do
        echo "nslookup $request_name $resolver_ip" 2>&1 | tee -a $output_file
        nslookup $request_name $resolver_ip | grep 'SERVFAIL\|NXDOMAIN\|No answer' 2>&1 | tee -a $output_file
    done
    echo 2>&1 | tee -a $output_file
done

echo "processed $line_count names" 2>&1 | tee -a $output_file

exit 0
