#!/bin/bash
export scriptDir=$(pwd)
source ./tableOuterOperation.sh
function mainMenu() {
    #Display welcome on first time use of the engine.
    if [[ ! -d ~/DBeng ]]
    then whiptail --title "Welcome to the DBeng project" --msgbox "Hello there,\nseems like this is the your first time using this project\nStart by creating a Database" 12 48
    fi
    
    dbOperations=$(whiptail --cancel-button "Exit" --title "DBeng main menu" --fb --menu "Choose an option" 15 60 6 \
        "1" "Create database" \
        "2" "List existing databases" \
        "3" "Delete database" \
        "4" "Do a table operation" \
    3>&1 1>&2 2>&3)
    exitstatus=$?
    [[ "$exitstatus" = 1 ]] && exit;	#test if exit button is pressed
    
    case $dbOperations in
        1) #Create Database
            #Check if the parent directory for Database Engine exists, if not create one.
            if [[ ! -d ~/DBeng ]]
            then
                mkdir ~/DBeng && cd ~/DBeng
            else cd ~/DBeng
            fi
            userInput=$(whiptail --inputbox "Enter the name of your Database:" 15 60 --title "Enter DB name"  3>&1 1>&2 2>&3)
            exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
            if [[ "$exitstatus" = 0 ]]
            then
                inputNF=($(echo $userInput | awk '{print NF}'))
                if [ -z "$userInput" ] #Handle empty input
                then whiptail --ok-button Done --msgbox "Database name cannot be empty, please try again." 15 60 #10 = Height 80 = Width
                elif [ $inputNF -gt 1 ]
                then whiptail --title "Error" --msgbox  "The input can't be more than one, please enter just one continous valid database name." 16 65
                else
                    setDBname="$userInput.beng" #Database name always ends with a .beng
                    if [[ ! -d ~/DBeng/$setDBname ]] #if there is no directory with the same name
                    then
                        mkdir $setDBname
                        whiptail --ok-button Done --msgbox "Database $setDBname created at `pwd` on `date`" 15 60 #10 = Height 80 = Width
                    else
                        whiptail --ok-button Done --msgbox "Database $setDBname already exists." 15 60 #10 = Height 80 = Width
                    fi
                fi
            fi
        ;;
        
        2) #List Databases
            if [[ ! -d ~/DBeng ]] #Check if no databases exist
            then whiptail --title "No database found" --msgbox "Currently no Databases exist, start by creating one" 8 45
                mainMenu #redisplay the menu
                
            else
                cd ~/DBeng
                countDir=$(ls | wc -l) #Count how many databases currently exist
                if [ $countDir -eq 0 ]
                then whiptail --title "No databases exist in ~/DBeng" --msgbox "No databases to list" 8 45
                else
                    whiptail --title "Found $countDir Databases" --scrolltext --msgbox "`find . -type d -name "*.beng" -printf "%f\n" | rev | cut -d"." -f2-  | rev`" 15 60
                    #List all the directories ending with .beng
                    #-printf changes find behavior, instead of outputing
                    #./directoryName this makes it output just directoryName
                fi
            fi
        ;;
        
        3) #Delete Database
            if [[ ! -d ~/DBeng  ]] 		#Check if parent database directory doesn't exist
            then whiptail --title "No ~/DBeng directory found" --msgbox "Currently no Databases exist, start by creating one" 8 45
            else
                cd ~/DBeng
                countDir=$(ls | wc -l) #Count how many databases currently exist
                if [ $countDir -eq 0 ]
                then whiptail --title "No databases exist in ~/DBeng" --msgbox "Create a Database first" 8 45
                else
                    userInput=$(whiptail --scrolltext --inputbox "Enter the name of the Database to be deleted\n*Name is case sensitive\nCurrent available DBs are:\n`find . -type d -name "*.beng" -printf "%f\n"| rev | cut -d"." -f2-  | rev`" 15 60 --title "Delete Database"  3>&1 1>&2 2>&3)
                    exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                    if [[ "$exitstatus" = 0 ]]
                    then
                        #find if the database exist or not, grep is used to give the correct
                        #return code as find always returns 0 "Success" even if the directory doesn't exist
                        # 1> redirection hides the find command ouptput "./$userInput"
                        find . -type d -name "$userInput.beng" | grep $userInput 1> /dev/null
                        if [ ! $? -eq 0 ]
                        then whiptail --title "Database doesn't exist" --msgbox "No database named $userInput found." 8 45
                            
                            #then echo "No database named \"$userInput\" was found!!"
                        else
                            rm -rf "$userInput.beng"
                            if [ $? -eq 0 ]
                            then  whiptail --title "Database Successfully removed" --msgbox "Database $userInput.beng was removed at `date`" 8 45
                                #echo "Database $userInput.beng was removed at `date`"
                            else
                                whiptail --title "Unknown error occured" --msgbox "For some reason we were unable to remove $userInput database" 8 45
                                #echo "An error occured during deletion"
                            fi
                        fi
                    fi
                fi
            fi
        ;;
        
        4) #Do a table operation
            if [[ ! -d ~/DBeng  ]] 		#Check if parent database directory doesn't exist
            then whiptail --title "No ~/DBeng directory found" --msgbox "Currently no Databases exist, start by creating one" 8 45
            else
                cd ~/DBeng
                countDir=$(ls | wc -l) #Count how many databases currently exist
                if [ $countDir -eq 0 ]
                then whiptail --title "No databases exist in ~/DBeng" --msgbox "Create a Database first" 8 45
                else
                    userInput=$(whiptail --scrolltext --inputbox "Enter the name of the Database from the list\n*Name is case sensitive\n`find . -type d -name "*.beng" -printf "%f\n"| rev | cut -d"." -f2-  | rev` " 15 60 --title "Table Operation"  3>&1 1>&2 2>&3)
                    exitstatus=$?	#test if cancel button is pressed	if existstatus == 1 then it is pressed
                    if [[ "$exitstatus" = 0 ]]
                    then
                        if [ -z "$userInput" ] #checks if empty input
                        then
                            whiptail --ok-button Done --msgbox "No input found, please try again." 8 45 #8 = Height 45 = Width
                        else
                            #check if the name of the user input already exist
                            find . -type d -name "$userInput.beng" | grep $userInput 1> /dev/null #throws stdout to null so it don't output
                            if [ ! $? -eq 0 ] #if it doesn't exist, prompt an error
                            then whiptail --title "Database name mismatch" --msgbox "No database named $userInput found." 8 45
                            else cd "$userInput.beng" && tableOuterOperation
                            fi
                        fi
                    fi
                fi
            fi
        ;;
    esac
    mainMenu
    
}

mainMenu


# select DBoperation in "Create Database" "List Databases" "Delete Database" "Use Database for table operations" "Exit"
# do

# case $DBoperation in
# "Create Database") createDB
# ;;

# "List Databases")
# 	#Check if no databases exist
# 	if [[ ! -d ~/DBeng ]]
# 	then
# 		echo "Start by creating a Database first"
# 	else
# 		cd ~/DBeng
# 		countDir=$(ls | wc -l) #Count how many databases currently exist
# 		if [ $countDir -eq 0 ]
# 		then echo "Currently no databases exist, create a Database first"
# 		else
# 			echo "Available Databases: $countDir"
# 			#List all the directories ending with .beng
# 			#-printf changes find behavior, instead of outputing
# 			#./directoryName this makes it output just directoryName
# 			find . -type d -name "*.beng" -printf "%f\n"
# 		fi
# 	fi
# ;;
# "Delete Database")
# 	#Check if no databases exist
# 	if [[ ! -d ~/DBeng  ]]
# 	then echo "Start by creating a Database first"
# 	else
# 		cd ~/DBeng
# 		countDir=$(ls | wc -l) #Count how many databases currently exist
# 		if [ $countDir -eq 0 ]
# 		then echo "Currently no databases exist, create a Database first"
# 		else
# 			echo "Enter the name of the Database to be deleted:"
# 			read userInput
# 			#find if the database exist or not, grep is used to give the correct
# 			#return code as find always returns 0 "Success" even if the directory doesn't exist
# 			# 1> redirection hides the find command ouptput "./$userInput"
# 			find . -type d -name "$userInput.beng" | grep $userInput 1> /dev/null
# 			if [ ! $? -eq 0 ]
# 			then echo "No database named \"$userInput\" was found!!"
# 			else
# 				rm -rf "$userInput.beng"
# 				if [ $? -eq 0 ]
# 				then echo "Database $userInput.beng was removed at `date`"
# 				else
# 					echo "An error occured during deletion"
# 				fi
# 			fi
# 		fi
# 	fi
# ;;
# "Use Database for table operations")
# 	#Check if no databases exist
# 	if [[ ! -d ~/DBeng ]]
# 	then echo "Start by creating a Database first"
# 	else
# 		cd ~/DBeng
# 		countDir=$(ls | wc -l) #Count how many databases currently exist
# 		if [ $countDir -eq 0 ]
# 		then echo "Currently no databases exist, create a Database first"
# 		else
# 			echo "Select the database you want to do the operation on from the following:"
# 			find . -type d -name "*.beng" -printf "%f\n"
# 			read userInput
# 			find . -type d -name "$userInput.beng" | grep $userInput 1> /dev/null
# 			if [ ! $? -eq 0 ]
# 			then echo "Please enter a correct DB name from the list"
# 			else
# 				cd "$userInput.beng" && bash "$scriptDir/tableRelatedOp.sh"
# 			fi
# 		fi
# 	fi
# ;;
# "Exit")
# 	exit
# ;;
# *) echo "Enter a valid choice from the list"
# esac
# done
