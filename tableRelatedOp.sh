#!/bin/bash
select tableOperation in "Create table" "List tables" "Delete table"
do
case $tableOperation in
"Create table")
    clear
    echo "Enter table name:"
    read tableName
    if [ -z $tableName ]  # Check if string is empty using -z
    then
        echo "Table name can't be empty, please enter a table name"
    else
        touch $tableName.tbeng
        echo "Table $tableName created at `pwd` on `date`"	
    fi
    ;;

"List tables")
        #Check if the directory contains no tables
        countTables=$(ls | egrep '\.tbeng$' | wc -l) #Count how many .tbeng files currently exist
		if [ $countTables -eq 0 ]
        then 
            DBname=$(basename $(pwd)) #basename returns the last / directory from the pwd command (in our case the DB name)
            echo "$DBname doesn't contain any tables, create a table first"
        else
            find . -type f -name "*.tbeng" -printf "%f\n" | cut -f1 -d.
        fi
;;
"Delete table")
    echo -e "*CAUTION ADVISED: This operation can't be undone\nChoose a table to remove:\n"
    unset options i
    while IFS= read -r -d $'\0' f; do
        options[i++]="$f"
    done < <(find . -maxdepth 1 -type f -name "*.tbeng" -print0 )
    select tableNames in "${options[@]}" "Back"
    do
    case $tableNames in 
        *.tbeng)
            rm $options;
            echo "Table $options deleted";
            break;
            clear;
        ;;
        "Back")
            exit
        ;;
    esac
    done
;;
*)
echo "Enter a valid input"
esac
done
