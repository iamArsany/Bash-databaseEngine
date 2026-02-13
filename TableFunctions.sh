#!/bin/bash

function CreateTable() {
  read -p "Enter Table Name > " newTable
  
  if [[ -z "$newTable" ]]; then
    echo " Table name cannot be empty!"
    return
  fi

  if [[ -f "${newTable}.csv" ]]; then
    echo " Table '${newTable}' already exists!"
    return
  fi

  read -p "Enter Number of Columns > " colNum
  if [[ ! "$colNum" =~ ^[0-9]+$ ]]; then
    echo " Please enter a valid number."
    return
  fi

  colNames=()
  colTypes=()

  for (( i=1; i<=$colNum; i++ ))
  do

    while true; do
      if ((i==1));then
        read -p "Enter Name for Column $i (primary key) > " cName
      else
        read -p "Enter Name for Column $i > " cName
      fi
      
      if [[ -z "$cName" ]]; then
        echo "Column name cannot be empty."
      elif [[ " ${colNames[*]} " =~ " ${cName} " ]]; then
        echo " Column name '${cName}' already exists in this table!"
      else
        colNames+=("$cName")
        break
      fi
    done


    while true; do
      read -p "Enter Type for $cName (int/str) > " cType
      if [[ "$cType" == "int" || "$cType" == "str" ]]; then
        colTypes+=("$cType")
        break
      else
        echo "Invalid type! Please enter 'int' or 'str'."
      fi
    done
  done

  touch "${newTable}.csv"

  echo $(IFS=,; echo "${colNames[*]}") >> "${newTable}.csv"
  echo $(IFS=,; echo "${colTypes[*]}") >> "${newTable}.csv"

  echo "Table '${newTable}' created successfully with $colNum columns."
}

function ListTables(){
  find . | cut -c 3- | sed 's/\.[^.]*$//'
  echo ""
}

function DropTable(){
 clear
 ListTables
 read -p "Drop Table Name> " dropTableName
 if [[ -f "${dropTableName}.csv" ]]; then
   read -p "Write it again to Confirm (This is Irreversible action)> " confirmdropTableName
    if [[ "${dropTableName}" == "${confirmdropTableName}" ]]; then
      rm "${dropTableName}.csv"
    else
      echo "${confirmdropTableName} Dosn't Match ${dropTableName}"
    fi
  else
    echo "${dropTableName} Dosn't Exist"
  fi
  return 0;
}

function InsertIntoTable () {

  ListTables
  read -p "Enter Table Name to insert into > " tableName

  if [[ ! -f "${tableName}.csv" ]]; then
    echo "Error: Table '${tableName}' does not exist."
    return
  fi


  header=$(sed -n '1p' "${tableName}.csv")
  types=$(sed -n '2p' "${tableName}.csv")

  if [[ -z "$header" ]]; then
    echo "Error: Invalid table , delete and create it using the CLI menu!"
    return 
  fi

  colNames=(${header//,/ })
  colTypes=(${types//,/ })

  newRow=()


  for (( i=0; i<${#colNames[@]}; i++ ))
  do
    while true; do
      echo -n "Column (${colNames[$i]}) Type (${colTypes[$i]}) | Input Value > "
      read val

      if [[ -z "$val" ]]; then
        echo "Error: Value cannot be empty."
        continue
      fi

      if [[ "${colTypes[$i]}" == "int" ]]; then
        if [[ ! "$val" =~ ^[0-9]+$ ]]; then
          echo "Invalid Input! Expected an Integer."
          continue
        fi
      fi     
      newRow+=("$val")
      break
    done
  done



  rowString=$(IFS=,; echo "${newRow[*]}")
  echo "$rowString" >> "${tableName}.csv"

  echo "Data inserted successfully into ${tableName}."
}

function SelectFromTable() {
  ListTables
  read -p "Enter Table Name > " tableName
  [[ ! -f "${tableName}.csv" ]] && echo "Table not found!" && return


  header=$(sed -n '1p' "${tableName}.csv")
  types=$(sed -n '2p' "${tableName}.csv")
  

  colNames=(${header//,/ })
  colTypes=(${types//,/ })
  numCols=${#colNames[@]}

  echo "Available Columns (Total $numCols):"
  for i in "${!colNames[@]}"; do echo "$((i+1))) ${colNames[$i]} (${colTypes[$i]})"; done


  read -p "Enter columns to show (* for all, or space-separated numbers like 1 3 2) > " colInput
  
  selectedIndices=()
  if [[ "$colInput" == "*" ]]; then
    for ((i=0; i<numCols; i++)); do selectedIndices+=($i); done
  else

    for choice in $colInput; do
      if [[ "$choice" -gt 0 && "$choice" -le "$numCols" ]]; then
        selectedIndices+=($((choice-1)))
      else
        echo "Warning: Column $choice ignored (Out of range)."
      fi
    done
  fi
  [[ ${#selectedIndices[@]} -eq 0 ]] && echo "No valid columns selected." && return


  echo "Filter condition (Format: 'colNum value', e.g., '1 string' or '2 234'). Leave empty for no filter."
  read -p "Where > " filterCol filterVal


  echo "------------------------------------------"
  headerRow=""
  for idx in "${selectedIndices[@]}"; do
    headerRow+="${colNames[$idx]}  "
  done
  echo "$headerRow" 
  echo "------------------------------------------"



  sed '1,2d' "${tableName}.csv" | while read -r row; do
    rowData=(${row//,/ })

    if [[ -n "$filterCol" ]]; then
      fIdx=$((filterCol-1))
      
      if [[ $fIdx -lt 0 || $fIdx -ge $numCols ]]; then
        echo "Error: Filter column $filterCol is invalid."
        return
      fi


      if [[ "${colTypes[$fIdx]}" == "int" && ! "$filterVal" =~ ^[0-9]+$ ]]; then
        continue 
      fi


      if [[ "${rowData[$fIdx]}" != "$filterVal" ]]; then
        continue
      fi
    fi


    outputRow=""
    for idx in "${selectedIndices[@]}"; do
      outputRow+="${rowData[$idx]}  "
    done
    echo "$outputRow"
  done
  echo "------------------------------------------"
}

function DeleteFromTable() {
  ListTables
  read -p "Enter Table Name > " tableName

  if [[ ! -f "${tableName}.csv" ]]; then
    echo "Error: Table doesn't exist."
    return
  fi

  header=$(sed -n '1p' "${tableName}.csv")
  colNames=(${header//,/ })
  numCols=${#colNames[@]}

  echo "Available Columns:"
  for i in "${!colNames[@]}"; do echo "$((i+1))) ${colNames[$i]}"; done
  
  read -p "Enter Column Number > " delColNum
  read -p "Enter Value to delete > " delVal

  if [[ "$delColNum" -le 0 || "$delColNum" -gt "$numCols" ]]; then
    echo "Invalid column number."
    return
  fi

  targetLines=$(awk -F, -v col="$delColNum" -v val="$delVal" 'NR > 2 && $col == val {print NR}' "${tableName}.csv")

  if [[ -z "$targetLines" ]]; then
    echo "No such Row found."
    return
  fi

  sortedLines=$(echo "$targetLines" | sort -rn)

  for lineNum in $sortedLines; do
    sed -i "${lineNum}d" "${tableName}.csv"
  done

  echo "Deleted successfully."
}


function UpdateTable() {
  ListTables
  read -p "Enter Table Name > " tableName
  [[ ! -f "${tableName}.csv" ]] && echo "Table not found!" && return

  header=$(sed -n '1p' "${tableName}.csv")
  types=$(sed -n '2p' "${tableName}.csv")
  colNames=(${header//,/ })
  colTypes=(${types//,/ })
  numCols=${#colNames[@]}

  echo "Columns: "
  for i in "${!colNames[@]}"; do echo "$((i+1))) ${colNames[$i]} (${colTypes[$i]})"; done

  echo "Enter updates (Format: 'colNum value colNum value'):"
  read -p "> " -a updateInput
  
  echo "Enter WHERE condition (Format: 'colNum value'):"
  read -p "> " whereCol whereVal

  
  # validation step
  declare -A updatesToMake
  for ((i=0; i<${#updateInput[@]}; i+=2)); do
    idx=$((updateInput[i]-1))
    val=${updateInput[i+1]}
    
    if [[ "${colTypes[$idx]}" == "int" && ! "$val" =~ ^[0-9]+$ ]]; then
      echo "Error: Column ${updateInput[i]} requires an integer!" && return
    fi
    updatesToMake[$idx]=$val
  done

  if [[ -n "${updatesToMake[0]}" ]]; then
    newPK=${updatesToMake[0]}
    if grep -q "^$newPK," "${tableName}.csv"; then
      echo "Error: Primary Key '$newPK' already exists! Aborting." && return
    fi
  fi

  
  # execute and actually replace
  found=false
  tempFile="${tableName}.tmp"
  sed -n '1,2p' "${tableName}.csv" > "$tempFile"

  sed '1,2d' "${tableName}.csv" | while read -r row; do
    rowData=(${row//,/ })
    wIdx=$((whereCol-1))

    if [[ "${rowData[$wIdx]}" == "$whereVal" ]]; then
      found=true
      for idx in "${!updatesToMake[@]}"; do
        rowData[$idx]=${updatesToMake[$idx]}
      done
      updatedRow=$(IFS=,; echo "${rowData[*]}")
      echo "$updatedRow" >> "$tempFile"
      echo "Updated Row: $updatedRow"
    else
      echo "$row" >> "$tempFile"
    fi
  done

  mv "$tempFile" "${tableName}.csv"
  
  if [[ "$found" == "true" ]]; then
    echo "Update completed successfully."
  else
    echo "No rows matched the WHERE condition."
  fi
}


