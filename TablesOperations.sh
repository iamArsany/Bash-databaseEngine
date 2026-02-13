#!/bin/bash

source "./TableFunctions.sh"

TableOptions=("Create Table" "List Tables" "Drop Table" "Insert into Table" "Select From Table" "Delete From Table" "Update Table" "quit")

doDBOperation(){
  clear
  while true; do
  select option in "${TableOptions[@]}"
  do
  clear
  case $REPLY in
    1)
      CreateTable
      ;;
    2)
      ListTables
      ;;
    3)
      DropTable
      ;;
    4)
      InsertIntoTable 
      ;;
    5)
      SelectFromTable
      ;;
    6)
      DeleteFromTable
      ;;
    7)
      UpdateTable
      ;;
    8)
      cd ..
      PS3="$MainLoopMsg"
      return
      ;;
    "exit")
      exit 0
      ;;
    *)
      echo "Try again from the Menu options"
      ;;
  esac
done
  done
}

