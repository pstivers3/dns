#! /bin/bash

# Make a copy of file "3_<name>.ip.requests.unique.count" from output of tcpdump_mulitple_reports.sh on the server instance.
# Place the copy in the same dir as this script.

file_to_merge=$1
hours=$2
master_list_name="master_list.txt"

usage="\nusage: $0 3_<name>.ip.requests.unique.count <hours>\n
example: $0 3_tcpdump-server01-2022-11-16T0800-11h.ip.requests.unique.count\n"

# if number of command line arguments not equal to 2, then display ussage
if [ $# -ne 2 ]; then
    echo -e "$usage"
    exit 0
fi

if [ ! -f "$master_list_name" ]; then
    touch $master_list_name
fi

echo "backing up master list"
cp $master_list_name ${master_list_name}.backup

echo "copying master list to temp"
tail -n+2 $master_list_name > temp

echo "awking $file_to_merge to temp"
awk -v h=$hours '{printf "%6.0f     %-6s \n", $1/h, $3}' $file_to_merge >> temp 

echo "sorting and uniquing temp back to master list"
sort -k2 temp > temp.sorted
awk -f merge_to_master_list.awk temp.sorted > $master_list_name 

echo "removing temp files"
rm temp temp.sorted

echo -e "done\n"

echo "diff master_list.txt master_list.txt.backup"
diff master_list.txt master_list.txt.backup

exit 0
