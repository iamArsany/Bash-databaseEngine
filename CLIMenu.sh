#!/bin/bash

MainLoopMsg="Enter from (1-5)>"


# sourcing necessary files 
source ./databaseFunctions.sh
source ./TablesOperations.sh

let -a MenuOptionsList
MenuOptionsList=("Create Database" "List Databases" "Connect To Databases" "Drop Database" "Quit")

PS3="$MainLoopMsg"
echo ""
select option in "${MenuOptionsList[@]}"
do
PS3="$MainLoopMsg"
  case $REPLY in
    1)
      CreateDB
      ;;
    2)
      ListDB
      ;;
    3)
      ConnectToDB
      ;;
    4)
      DropDB
      ;;
    5)
      exit 0
      ;;
  esac
done



