#! /bin/bash

# Make a copy of file "4_<ame>.ip.requests.unique" from output of tcpdump_mulitple_reports.sh on the server instance
# (usually a name server) and place it in local.

usage="\nusage: $0 4_<name>.requests.unique\n
example: $0 4_tcpdump-ns04-12-12-26T1225-22h.requests.unique"

file_to_merge=$1
master_list_name="4_master_list.requests.unique"

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ "$1" = "help" ]; then
    echo -e "$usage\n"
    exit 0
fi

# Gracefull fail on invalid argument
if [[  $file_to_merge != 4_* ]]; then
    echo -e "\nExpected first argument to be a filename beginning with \"4_\"\n$usage"
    exit 1
fi

if [ ! -f "$master_list_name" ]; then
    touch $master_list_name
fi

echo "backing up master list"
cp $master_list_name ${master_list_name}.backup

echo "copying master list to temp"
cp $master_list_name temp

echo "adding $file_to_merge to temp"
cat $file_to_merge >> temp

echo "sorting and uniquing temp back to master list"
sort temp | uniq  > $master_list_name

echo "removing temp file"
rm temp

echo -e "done\n"

echo "diff $master_list_name ${master_list_name}.backup"
diff $master_list_name ${master_list_name}.backup 

exit 0
