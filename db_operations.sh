#!/bin/bash
select DBoperation in "Create Database" "List Databases" "Delete Database" "Use Database for table operations"
do
case $DBoperation in
"Create Database") 
	#Check if the parent directory for Database Engine exists, if not create one.
	if [[ ! -d ~/DBeng ]]
	then
		mkdir ~/DBeng && cd ~/DBeng 
	else 
		cd ~/DBeng
	fi
	echo "Enter the Database name:"
	read userInput
	setDBname="$userInput.beng" #Database name always ends with a .beng 
	mkdir $setDBname 
	echo "Database $setDBname created at `pwd` on `date`"	
	;;
	
"List Databases") 
	#Check if no databases exist
	if [[ ! -d ~/DBeng ]]
	then 
		echo "Start by creating a Database first"
	else 
		cd ~/DBeng 
		countDir=$(ls | wc -l) #Count how many databases currently exist
		if [ $countDir -eq 0 ]
		then echo "Currently no databases exist, create a Database first"
		else 
			echo "Available Databases: $countDir"
			#List all the directories ending with .beng
			#-printf changes find behavior, instead of outputing
			#./directoryName this makes it output just directoryName
			find . -type d -name "*.beng" -printf "%f\n"
		fi
	fi
	;;
"Delete Database") 
	#Check if no databases exist
	if [[ ! -d ~/DBeng  ]]
	then echo "Start by creating a Database first"
	else 
		cd ~/DBeng 
		countDir=$(ls | wc -l) #Count how many databases currently exist
		if [ $countDir -eq 0 ]
		then echo "Currently no databases exist, create a Database first"
		else
			echo "Enter the name of the Database to be deleted:"
			read userInput
			#find if the database exist or not, grep is used to give the correct
			#return code as find always returns 0 "Success" even if the directory doesn't exist
			# 1> redirection hides the find command ouptput "./$userInput"
			find . -type d -name "$userInput.beng" | grep $userInput 1> /dev/null
			if [ ! $? -eq 0 ]
			then echo "No database named \"$userInput\" was found!!"
			else 
				rm -rf "$userInput.beng" 
				if [ $? -eq 0 ]
				then echo "Database $userInput.beng was removed at `date`"
				else
					echo "An error occured during deletion"
				fi
			fi
		fi
	fi
	;;
"Use Database for table operations")
	#Check if no databases exist
	if [[ ! -d ~/DBeng ]]
	then echo "Start by creating a Database first"
	else 
		cd ~/DBeng 
		countDir=$(ls | wc -l) #Count how many databases currently exist
		if [ $countDir -eq 0 ]
		then echo "Currently no databases exist, create a Database first"
		else
			echo "Select the database you want to do the operation on from the following:"
			find . -type d -name "*.beng" -printf "%f\n"
			read userInput 
			export userInput
			find . -type d -name "$userInput.beng" | grep $userInput 1> /dev/null
			if [ ! $? -eq 0 ]
			then echo "Please enter a correct DB name from the list"
			else
				# cd "$userInput.beng"
				bash tableRelatedOp.sh
			fi
			
		
		
		fi
	
	fi
;;
*) echo "Enter a valid choice from the list"
esac 
done
