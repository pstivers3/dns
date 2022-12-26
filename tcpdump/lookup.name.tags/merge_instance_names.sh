#! /bin/bash

file_to_merge=$1
master_list_name="instance_name_master_list.txt"

echo -e "\nbacking up master list"
cp $master_list_name ${master_list_name}.backup

echo "copying master list to temp"
tail -n+2 $master_list_name > temp

echo "cat $file_to_merge to temp"
cat $file_to_merge >> temp

# awk to make single space delimited fields, more robust for sort -k
awk '{ print $1, $2, $3 }' temp > temp.awked

echo "sorting and uniquing temp back to master list"
sort -k2 temp.awked > temp.sorted

awk -f merge_instance_names.awk temp.sorted > $master_list_name 

echo "removing temp files"
rm temp*

echo -e "done\n"

echo "diff $master_list_name ${master_list_name}.backup"
diff $master_list_name ${master_list_name}.backup

exit 0
