#!/bin/bash


function CreateDB ()
{
  clear
  read -p "Database Name> " dbName
  if [[ ! -d "$dbName" ]]; then
    mkdir "$dbName"
  else
    echo "${dbName} is already Exists!"
  fi
  return 0;
}

function ListDB (){
  echo ""
  find . -maxdepth 1 -type d -not -name '.*' | cut -c 3-
  echo ""
}

function ConnectToDB (){
  clear
  echo "List of Available Databases:"
  find . -maxdepth 1 -type d -not -name '.*' | cut -c 3-
  read -p "Database Name> " dbName

  if [[ -d "$dbName" ]]; then
    cd "$dbName"
    usedDB=$(printf '%q\n' "${PWD##*/}")
    PS3="${usedDB} >"
    doDBOperation
  else
    echo "No Database with that Name!"
  fi
}

function DropDB ()
{
 clear
 ListDB
 read -p "Drop Database Name> " dropDBName
 if [[ -d "$dropDBName" ]]; then
   read -p "Write it again to Confirm(This is Irreversible action)> " confirmdropDBName
    if [[ "${dropDBName}" == "${confirmdropDBName}" ]]; then
      rm -r "${dropDBName}"
    else
      echo "${confirmdropDBName} Dosn't Match ${dropDBName}"
    fi
  else
    echo "${dropDBName} Dosn't Exist"
  fi
  return 0;
}

