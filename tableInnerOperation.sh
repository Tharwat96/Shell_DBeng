function tableInnerOperation() {
    id=0;
    
    innerOperation=$(whiptail --cancel-button "Exit" --title "Inner table operation menu" --fb --menu "Choose an option" 15 60 6 \
        "1" "Display records" \
        "2" "Display specific record" \
        "3" "Insert record" \
        "4" "Update record" \
        "5" "Delete record" \
    "6" "Go back to previous menu" 3>&1 1>&2 2>&3)
    exitstatus=$?
    [[ "$exitstatus" = 1 ]] && exit;	#test if exit button is pressed
    
    
    case $innerOperation in
        1) #Display records
            whiptail --title "Records for $selectedTable" --scrolltext --msgbox  "`awk 'BEGIN {FS=":";OFS="\t"} NR>1{i=1;while(i<=NF){printf $i "  "; i++;} printf"\n"}' $selectedTable`" 16 65
        ;;
        
        2) #Display specific record
            id=$(whiptail --inputbox "Please enter the ID of the row that you want to display. " 20 80 --title "Display record"  3>&1 1>&2 2>&3)
            exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
            if [[ "$exitstatus" = 0 ]]
            then
                #STILL NEEDS TO CHECK IF MULTIPLE INSERTIONS
                if [ -z "$id" ]
                then whiptail --title "Error" --msgbox  "The input can't be left empty, please enter a valid ID." 16 65
                else
                    ids=($(awk 'BEGIN {FS=":"} NR>2{print $1}' $selectedTable))
                    if [[ " ${ids[@]} " =~ " ${id} " ]]; then
                        row=$(awk -F : -v id=$id 'BEGIN {OFS=" "} {$1=$1;if($1==id){print $0}}' "$selectedTable")
                        #CHECK IF PREV COMMAND WAS SUCCESSFUL THEN DISPLAY THIS
                        whiptail --title "Success" --msgbox "$row" 16 65
                        echo -e ":$type\c" >> $userInput.tbeng #\c for continuous text concatenation (changing the default echo \n behavior)
                    else
                        whiptail --title "Error" --msgbox  "id was not found in the table." 16 65
                    fi
                fi
            fi
        ;;
    
    
    3) #Insert record
        flag=1
        rowInput=$(whiptail --inputbox "Enter fields for this record:\n`awk 'BEGIN {FS=":";OFS="\t"} {if(NR == 3){exit} i=2;while(i<=NF){printf $i "\t"; i++;} printf"\n"}' $selectedTable`" 20 80 --title "Insert Record"  3>&1 1>&2 2>&3)
        exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
        if [[ "$exitstatus" = 0 ]]
        then
            if [ -z "$rowInput" ]  # Check if string is empty using -z
            then whiptail --title "Input is empty" --scrolltext --msgbox  "Row can't be empty, please enter row data to continue" 16 65
            else
                #count number of fields entered
                tableNF=$(awk -F : '{if(NR==1){exit}} END{print NF-1}' "$selectedTable")
                inputNF=$(echo $rowInput | awk '{print NF}')
                if [[ $inputNF -ne $tableNF ]]; #if number of fields enetered don't match.
                then
                    whiptail --title "Number of fields don't match!" --msgbox "Number of columns entered doesn't match with the number of data types." 10 55
                    flag=0
                else
                    oldId=$(awk -F : 'END{printf $1}' $selectedTable) #assign id of final row in table
                    id=$((oldId+1))
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
        fi
    ;;
    
    4) #Update record
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
                    #count number of fields entered and check if they match with table header
                    tableNF=$(awk -F : '{if(NR==1){exit}} END{print NF-1}' "$selectedTable")
                    inputNF=$(echo $updatedRow | awk '{print NF}')
                    if [[ $inputNF -ne $tableNF ]]; #if number of fields enetered don't match.
                    then
                        whiptail --title "Number of fields don't match!" --msgbox "Number of fields entered doesn't match with the number of table columns." 10 55
                        flag=0
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
                                    whiptail --title "Validation failed" --msgbox "$field is not a number" 8 45
                                    flag=0
                                fi
                            fi
                            tmp=$(echo -e ":$field\c") # \c for continuous text concatenation (changing the default echo \n behavior)
                            i=$((i+1))
                        done
                        if [ $flag -eq 1 ] # flag=1 => everything is ok, flag=0 => something is not right
                        then
                            awk -F : -v rowNum=$NR -v input=$updatedRow '{if(NR==rowNum){$0=$1":"input}print}' $selectedTable > tmpfile && mv tmpfile $selectedTable #replace the old record with the new one
                            whiptail --title "Record updated" --msgbox  "The record was updated successfully" 16 65
                        fi
                    fi
                fi
            fi
        fi
    ;;
    
    5) #Delete record
        id=$(whiptail --inputbox "Please enter the ID of the row that you want to delete. " 20 80 --title "Delete Record"  3>&1 1>&2 2>&3)
        exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
        if [[ "$exitstatus" = 0 ]]
        then
            idNF=($(echo $id | awk '{print NF}'))
            if [ -z "$id" ]
            then whiptail --title "Error" --msgbox  "The input can't be left empty, please enter a valid ID." 16 65
            elif [ $idNF -gt 1 ]
            then whiptail --title "Error" --msgbox  "The input can't be more than one, please enter just one valid ID." 16 65
            else
                ids=($(awk 'BEGIN {FS=":"} NR>2{print $1}' $selectedTable))
                if [[ " ${ids[@]} " =~ " ${id} " ]]; then
                    awk -F : -v id=$id '{if($1==id){next}print}' $selectedTable > tmpfile && mv tmpfile $selectedTable
                    #CHECK IF PREV COMMAND WAS SUCCESSFUL THEN DISPLAY THIS
                    whiptail --title "Success" --msgbox  "Record was deleted successfully" 16 65
                    echo -e ":$type\c" >> $userInput.tbeng #\c for continuous text concatenation (changing the default echo \n behavior)
                else
                    whiptail --title "Error" --msgbox  "id was not found in the table." 16 65
                fi
            fi
        fi
    ;;
    
    6) #Go back to previous Menu
        tableOuterOperation
    ;;
    
    esac
    tableInnerOperation
}