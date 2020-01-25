#!/bin/bash
id=0;
select tableOperation in "Create table" "List tables" "Delete table" "Modify table"
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
        echo -e "Enter column names [Separate each column name with a space]\n"
        #Primary key handling
        #resource used ==> https://stackoverflow.com/questions/9904980/variable-in-bash-script-that-keeps-it-value-from-the-last-time-running
        if [ ! -f "~/id.var" ]; then #if the id file isn't present
            id=1;
        else 
            id=`cat ~/id.var` #assign the id variable the value found in the id.var file
        fi

        read columnInput;
        columnInputArray=($columnInput) #convert the input into array to iterate over the spaces
        for column in "${columnInputArray[@]}"
        do echo -e "$column:\c" >> $tableName.tbeng # \c for continuous text concatination (changing the default echo \n behavior)
        done
        echo -e "$id" >> $tableName.tbeng  #append the id to the .tbeng file
        id=`expr ${id} + 1` #increment the id
        echo "${id}" > ~/id.var #replace the id value with the incremented value.
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
"Modify table")
    echo "select the table by typing its name: "
    #List ops
    echo -e "1-Insert\n";
    echo "Enter data type followed by column name: ";

;;

*)
echo "Enter a valid input"
esac
done
