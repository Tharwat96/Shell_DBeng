#!/bin/bash
userInput=test.beng
cd ~/DBeng/$userInput
select tableOperation in "Create table" "List existing tables" "Delete table"
do
case $tableOperation in
"Create table")
    echo "Enter table name:"
    read tableName
    if [ -z $tableName ]
    then 
        echo "Please enter a table name"
    else
        touch $tableName.tbeng
    fi
;;
"List existing tables")
    find . -type f -name "*.tbeng" -printf "%f\n" | cut -f1 -d.
;;
"Delete table")
    echo "*CAUTION ADVISED: This operation can't be undone*\nChoose a table to remove: \n"
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
            break
        ;;
    esac
    done
;;
*)
echo "Enter a valid input"
esac
done
