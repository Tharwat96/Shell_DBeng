#!/bin/bash
select tableOperation in "Create table" "List existing tables" "Delete table"
do
case $tableOperation in
"Create table")
;;
"List existing tables")
;;
"Delete table")
;;
*)
echo "Enter a valid input"
esac
done
