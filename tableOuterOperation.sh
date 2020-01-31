
function tableOuterOperation() {
 	outerOperation=$(whiptail --cancel-button "Exit" --title "Outer table operation main Menu" --fb --menu "Choose an option" 15 60 6 \
        "1" "Create table" \
        "2" "List tables" \
		"3" "Delete table" \
        "4" "Modify table [Inner operation]" \
		"5" "Go back to DBeng Main menu" 3>&1 1>&2 2>&3)

    case $outerOperation in
	1) #Create Table
	userInput=$(whiptail --inputbox "Enter table name:" 10 80 --title "Create a table"  3>&1 1>&2 2>&3)
	if [ -z "$userInput" ] #if input is empty
	then whiptail --title "Input can't be empty" --msgbox "Please enter a valid table name." 8 45
	elif [ -f "$(pwd)/$userInput.tbeng" ] #check if the table already exists
	then whiptail --title "Table already exist" --msgbox "Currently there's already a table named $userInput.tbeng in this Database." 8 45
	else touch "$userInput.tbeng"
		whiptail --title "Table created successfully" --msgbox "Table $userInput was created at $(pwd) on $(date)" 10 55
		headerInput=$(whiptail --inputbox "Enter column names\nSeparate each column name with a space" 15 80 --title "Define table columns"  3>&1 1>&2 2>&3)

		#Handling empty user input.
		while [ -z "$headerInput"] 
		do whiptail --title "Input can't be empty" --msgbox "Please enter a valid input." 10 55
		headerInput=$(whiptail --inputbox "Enter column names\nSeparate each column name with a space" 15 80 --title "Define table columns"  3>&1 1>&2 2>&3)

		#convert the input into array to iterate over the spaces
		headerInputArray=($columnInput) 
		for column in "${columnInputArray[@]}"
            do echo -e "$column:\c" >> $tableName.tbeng # \c for continuous text concatination (changing the default echo \n behavior)
            done
		done

	fi 
	;;


	2) #List tables
	   #Check if no tables currently exist in the database first.
	   countTables=$(ls | egrep '\.tbeng$' | wc -l) 
	   if [ $countTables -eq 0 ]
	   then whiptail --title "No tables found!" --msgbox "This database currently have no existing tables." 10 55
	   else whiptail --title "Current tables list" --msgbox "Current tables in the database are:\n`find . -type f -name "*.tbeng" -printf "%f\n" | cut -f1 -d .`" 20 55
	   fi
	;;

	3) #Delete Table

	   #check if no tables exist
	   countTables=$(ls | egrep '\.tbeng$' | wc -l) 
	   if [ $countTables -eq 0 ]
	   then whiptail --title "No tables found!" --msgbox "This database currently has no existing tables." 10 55

	   else 
	   		userInput=$(whiptail --inputbox "Enter the name of the Table to be deleted\nCurrent available Tables are:\n `find . -name "*.tbeng" -printf "%f\n"`" 20 80 --title "Delete Table"  3>&1 1>&2 2>&3)
			find . -name "$userInput.tbeng" | grep $userInput 1> /dev/null
			if [ ! $? -eq 0 ]
				then whiptail --title "Table doesn't exist" --msgbox "No Table named $userInput found." 8 45
				else 
					rm -rf "$userInput.tbeng" 
					if [ $? -eq 0 ]
					then  whiptail --title "Table Successfully removed" --msgbox "Table $userInput.tbeng was removed at `date`" 8 45
					#echo "Database $userInput.beng was removed at `date`"
					else
					 	whiptail --title "Unknown error occured" --msgbox "For some reason we were unable to remove $userInput Table" 8 45
					fi
			fi
	   fi
;;

	4) #Modify table [Inner operation]
		#check if no tables exist
	   countTables=$(ls | egrep '\.tbeng$' | wc -l) 
	   if [ $countTables -eq 0 ]
	   then whiptail --title "No tables found!" --msgbox "This database currently has no existing tables." 10 55

	   else 
	   		userInput=$(whiptail --inputbox "Enter the name of the Table to be modified\nCurrent available Tables are:\n `find . -name "*.tbeng" -printf "%f\n"`" 20 80 --title "Modify Table"  3>&1 1>&2 2>&3)
			find . -name "$userInput.tbeng" | grep $userInput 1> /dev/null
			if [ ! $? -eq 0 ]
				then whiptail --title "Table doesn't exist" --msgbox "No Table named $userInput found." 8 45
				else 
					whiptail --title "Modding" --msgbox "Modding" 8 45
			fi
	   fi

	;;
	5) #Go back to DBeng Main menu
	mainMenu
	;;
	esac
	tableOuterOperation
}

