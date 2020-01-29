#!/bin/bash
# exported variables: $scriptDir, $selectedTable

echo $selectedTable

select tableModifications in "Insert Data" "Update Data" "Delete Data" "Go back to previous menu"
do
case $tableModifications in
    "Insert Data")
    set -x
        echo -e "Enter fields [Separate each field with a space]\n"
        awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 1){exit}} END{i=1;while(i<=NF){printf $i "  "; i++;}}' $selectedTable
        read rowInput;
        rowInputArray=($rowInput) #convert the input into array to iterate over the spaces
        for row in "${rowInputArray[@]}"
        do echo -e "$row:\c" >> $selectedTable.tbeng # \c for continuous text concatination (changing the default echo \n behavior)
        done
        echo -e "$id" >> $selectedTable.tbeng  #append the id to the .tbeng file
        id=`expr ${id} + 1` #increment the id
        echo "${id}" > ~/id.var #replace the id value with the incremented value.
    set +x
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