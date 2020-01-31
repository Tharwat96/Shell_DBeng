#!/bin/bash
# exported variables: $scriptDir, $selectedTable

echo "secelcted table exported : $selectedTable"

select tableModifications in "Print Data" "Insert Data" "Update Data" "Delete Data" "Go back to previous menu"
do
case $tableModifications in
    "Print Data")
        awk 'BEGIN {FS=":";OFS="\t"} NR>1{i=1;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable
        #TODO
        #awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 1){exit}} END{i=1;while(i<=NF){printf $i "  "; i++;}print"\n"}' newtable.tbeng
    ;;
    "Insert Data")
        echo -e "Enter fields [Separate each field with a space]\n"
        awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 3){exit} i=1;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable
        read rowInput;
        rowInputArray=($rowInput) #convert the input into array to iterate over the spaces
        for row in "${rowInputArray[@]}"
        do 
            echo -e ":$row\c" >> $selectedTable # \c for continuous text concatination (changing the default echo \n behavior)
        done
        echo "" >> $selectedTable
    ;;
    "Update Data")
    ;;
    "Delete Data")
    ;;
    "Go back to previous menu")
        exit
    ;;
    *)
esac
done