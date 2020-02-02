function tableInnerOperation() {
    id=0;
    
    innerOperation=$(whiptail --cancel-button "Exit" --title "Inner table operation main Menu" --fb --menu "Choose an option" 15 60 6 \
        "1" "Display Records" \
        "2" "Insert Record" \
        "3" "Update Record" \
        "4" "Delete Record" \
    "5" "Go back to previous menu" 3>&1 1>&2 2>&3)
    exitstatus=$?
    [[ "$exitstatus" = 1 ]] && exit;	#test if exit button is pressed
    
    
    case $innerOperation in
        1) #Display Records
            whiptail --title "Records for $selectedTable" --scrolltext --msgbox  "`awk 'BEGIN {FS=":";OFS="\t"} NR>1{i=1;while(i<=NF){printf $i "  "; i++;} printf"\n"}' $selectedTable`" 16 65
        ;;
        
        2) #Insert Record
            flag=1
            rowInput=$(whiptail --inputbox "Enter fields for this record:\n`awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 3){exit} i=2;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable`" 20 80 --title "Insert Record"  3>&1 1>&2 2>&3)
            exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
            if [[ "$exitstatus" = 0 ]]
            then
                if [ -z "$rowInput" ]  # Check if string is empty using -z
                then whiptail --title "Input is empty" --scrolltext --msgbox  "Row can't be empty, please enter row data to continue" 16 65
                else
                    oldId=$(awk -F : 'END{printf $1}' $selectedTable) #assign id of final row in table
                    id=$((oldId+1))
                    echo "id:$id oldId:$oldId"
                    newRow=$(echo -e "$id\c")
                    rowInputArray=($rowInput) #convert the input into array to iterate over the spaces
                    i=1
                    for field in "${rowInputArray[@]}"
                    do
                        currentDataType=$(awk -F : -v i=$((i + 1)) '{if(NR==1){exit}} END{print $i}' "$selectedTable")
                        if [[ $currentDataType == "numbers" ]]
                        then
                            numRegex='^[0-9]+$'
                            if ! [[ $field =~ $numRegex ]] ; then
                                whiptail --title "Validation failed" --msgbox "$field is not a number" 8 45
                                flag=0
                            fi
                        fi
                        tmp=$(echo -e ":$field\c") # \c for continuous text concatination (changing the default echo \n behavior)
                        i=$((i+1))
                    done
                    #Need to check if record was inserted successfully before displaying the message but echo alwasy returns a zero!
                    tmp=$(echo "")
                    newRow="$newRow$tmp"
                    if [ $flag -eq 1 ]
                    then
                        echo -e $newRow >> $selectedTable # \c for continuous text concatination (changing the default echo \n behavior)
                        whiptail --title "Record inserted" --msgbox  "The record was added to table $selectedTable successfully" 16 65
                    fi
                fi
            fi
        ;;
        
        3) #Update Record
            id=$(whiptail --inputbox "Please insert the ID of the row that you want to update. " 20 80 --title "Update Record"  3>&1 1>&2 2>&3)
            exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
            if [[ "$exitstatus" = 0 ]]
            then
                #$1=$1 is to force rebuilding the entire record using current OFS
                #reference: https://stackoverflow.com/questions/13704947/print-all-fields-with-awk-separated-by-ofs
                row=$(awk -F : -v id=$id -v OFS=" " '{$1=$1;if($1==id){for(i=2; i<=NF; i++){printf $i " "}}}' $selectedTable)
                NR=$(awk -F : -v id=$id '{if($1==id){print NR}}' $selectedTable) #get row number of the record to be edited
                updatedRow=$(whiptail --inputbox "" 20 80 --title "Update Record" "$row"  3>&1 1>&2 2>&3) #display the record in the input line
                exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                if [[ "$exitstatus" = 0 ]]
                then
                    if [ -z "$updatedRow" ] #Handle empty input
                    then whiptail --title "Error" --msgbox  "The input can't be left empty, please enter a valid input or use the delete option if you want to delete" 16 65
                    else
                        rowInputArray=($updatedRow) #convert the input into array to iterate over the spaces
                        updatedRow=$(echo $updatedRow | awk -v OFS=":" '{$1=$1; print}')
                        flag=1
                        i=1
                        for field in "${rowInputArray[@]}"
                        do
                            currentDataType=$(awk -F : -v i=$((i + 1)) '{if(NR==1){exit}} END{print $i}' "$selectedTable")
                            if [[ $currentDataType == "numbers" ]]
                            then
                                numRegex='^[0-9]+$'
                                if ! [[ $field =~ $numRegex ]] ; then
                                    flag=0
                                fi
                            fi
                            tmp=$(echo -e ":$field\c") # \c for continuous text concatenation (changing the default echo \n behavior)
                            i=$((i+1))
                        done
                        if [ $flag -eq 1 ] # flag=1 => if everything is ok, flag=0 => something is not right
                        then
                            awk -F : -v rowNum=$NR -v input=$updatedRow '{if(NR==rowNum){$0=$1":"input}print}' $selectedTable > tmpfile && mv tmpfile $selectedTable #replace the old record with the new one
                            whiptail --title "Record updated" --msgbox  "The record was updated successfully" 16 65
                        else
                            whiptail --title "Validation failed" --msgbox "$field is not a number" 8 45
                        fi
                    fi
                fi
            fi
        ;;
        
        4) #Delete Record
            id=$(whiptail --inputbox "Please enter the ID of the row that you want to delete. " 20 80 --title "Delete Record"  3>&1 1>&2 2>&3)
            exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
            if [[ "$exitstatus" = 0 ]]
            then
                if [ -z "$id" ]
                then whiptail --title "Error" --msgbox  "The input can't be left empty, please enter a valid ID." 16 65
                else
                    
                    #####FIX###########
                    #NEED HANDLING / WHAT ABOUT THE INPUT WAS FALSE ID ?
                    awk -F : -v id=$id '{if($1==id){next}print}' $selectedTable > tmpfile && mv tmpfile $selectedTable
                    #CHECK IF PREV COMMAND WAS SUCCESSFUL THEN DISPLAY THIS
                    whiptail --title "Success" --msgbox  "Record was deleted successfully" 16 65
                fi
            fi
        ;;
        
        5) #Go back to previous Menu
            tableOuterOperation
        ;;
        
    esac
    tableInnerOperation
}