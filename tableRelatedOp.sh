#!/bin/bash
# exported variables: $scriptDir
DBname=$(basename $(pwd)) #basename returns the last / directory from the pwd command (in our case the DB name)
clear
id=0;
select tableOperation in "Create table" "List tables" "Print table" "Delete table" "Modify table" "Go back to database menu"
do
case $tableOperation in
"Create table")
    clear
    echo "Enter table name:"
    read tableName
    if [ -z "$tableName" ]  # Check if string is empty using -z
    then
        echo "Table name can't be empty, please enter a table name"
    else
        echo "$(pwd)/$tableName"
        if [[ -f "$(pwd)/$tableName.tbeng" ]]; 
        # checks if table is already created
        then
            clear
            echo "This table is already created."
        else
            clear
            touch "$tableName.tbeng"
            echo "Table $tableName created at $(pwd) on $(date)"
            flag=1
            while [ $flag -eq 1 ]
            do
                echo -e "Enter column names [Separate each column name with a space]\n"
                read columnInput;
                echo -e "Enter data type of each column (string | numbers) [Separate each column name with a space]\n"
                read typeInput;
                columnNF=$(echo $columnInput | awk '{print NF}')
                typeNF=$(echo $typeInput | awk '{print NF}')
                if [[ $columnNF -ne $typeNF ]];
                then
                    echo "Number of data types is not equivalent to the number of columns needed, kindly retry."
                    continue
                else
                    ############validating data types#######
                    for ((i = 0 ; i < $typeNF ; i++)); 
                    do
                        field=$(awk -v typeInput="$typeInput" -v i="$i" '{print i " " typeInput}' $selectedTable) ##BUGGED
                        echo field
                    done
                    ############writing data types##########
                    echo -e "id\c" >> $tableName.tbeng #insert id column at start of row
                    typeInputArray=($typeInput) #convert the input into array to iterate over the spaces
                    for column in "${typeInputArray[@]}"
                    do
                        echo -e ":$column\c" >> $tableName.tbeng # \c for continuous text concatination (changing the default echo \n behavior)
                    done
                    echo "" >> $tableName.tbeng #do echo default behaviour of exiting line
                    ############writing column names#########
                    echo -e "id\c" >> $tableName.tbeng #insert id column at start of row
                    columnInputArray=($columnInput) #convert the input into array to iterate over the spaces
                    for column in "${columnInputArray[@]}"
                    do 
                        echo -e ":$column\c" >> $tableName.tbeng # \c for continuous text concatination (changing the default echo \n behavior)
                    done
                    echo "" >> $tableName.tbeng #do echo default behaviour of exiting line


                    flag=0  #change flag to go out of loop, need to be enter the final condition when done
                fi
            done
                 #TODO check each data type entered to be valid
            
        fi
    fi
;;
"List tables")
    #Check if the directory contains no tables
    #Count how many .tbeng files currently exist
    countTables=$(ls | egrep '\.tbeng$' | wc -l) 
    
    if [ $countTables -eq 0 ]
    then 
        echo "$DBname doesn't contain any tables, create a table first"
    else
        find . -type f -name "*.tbeng" -printf "%f\n" | cut -f1 -d.
    fi
;;
"Delete table")
    echo -e "*CAUTION ADVISED: This operation can't be undone\nChoose a table to remove:\n"
    unset options i
    while IFS= read -r -d $'\0' fileName; do
        options[i++]="$fileName"
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

"Modify table")
    echo "select the table by typing its name: "
    #List ops
    echo "Select a table you want to do an operation on from the following:"
    find . -type f -name "*.tbeng" -printf "%f\n"
    unset userInput && read userInput 
    find . -type f -name "$userInput.tbeng" | grep $userInput 1> /dev/null
    if [ ! $? -eq 0 ]
    then echo "Please enter a correct DB name from the list"
    else
        export selectedTable="$userInput.tbeng"
        bash "$scriptDir/tableModification.sh"
    fi
;;

"Go back to database menu")
    exit
;;

*)
echo "Enter a valid input"
esac
done
