#!/bin/bash
# exported variables: $scriptDir, $selectedTable

echo "selected table exported : $selectedTable"

select tableModifications in "Print Table" "Insert Data" "Update Row" "Delete Row" "Go back to previous menu"
do
case $tableModifications in
    "Print Table")
        awk 'BEGIN {FS=":";OFS="\t"} NR>1{i=1;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable
        #TODO
        #awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 1){exit}} END{i=1;while(i<=NF){printf $i "  "; i++;}print"\n"}' newtable.tbeng
    ;;
    "Insert Data")
        # TODO -increment id -condition if field is empty -condition if doesn't match types entered
        id=`awk -F : NR>2'END{printf $1}' $selectedTable` #assign id of final row in table
        id=$((id + 1))
        echo -e "Enter fields [Separate each field with a space]\n"
        awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 3){exit} i=2;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable
        read rowInput;
        # TODO conditions to be added here
        echo -e "$id\c" >> $selectedTable
        rowInputArray=($rowInput) #convert the input into array to iterate over the spaces
        for row in "${rowInputArray[@]}"
        do 
            echo -e ":$row\c" >> $selectedTable # \c for continuous text concatination (changing the default echo \n behavior)
        done
        echo "" >> $selectedTable
    ;;
    "Update Row")
    ;;
    "Delete Row")
        echo -e "Please enter the id of the row to be deleted: \c"
        read id
        #sed -e '$(id) d p' $selectedTable
        #sed '5 d p' table.tbeng
        #echo "line $id was deleted successfully"

    ;;
    "Go back to previous menu")
        exit
    ;;
    *)
esac
done