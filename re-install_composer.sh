#!/bin/bash

#uninstall all
declare -a fabcomposer=("composer-cli" "composer-rest-server" "generator-hyperledger-composer" "composer-playground")
declare -a fabcomposernext=("composer-cli@next" "composer-rest-server@next" "generator-hyperledger-composer@next" "composer-playground@next")

## loop through fabcomposer array to uninstall all composer node modules
function uninstallComposer(){
  for i in "${fabcomposer[@]}"
  do
    npm ls -g $i
    echo "Uninstalling $i ..."
    npm uninstall -g $i 2>&1
  done
  for i in "${fabcomposernext[@]}"
  do
    npm ls -g $i
    echo "Uninstalling $i ..."
    npm uninstall -g $i 2>&1
  done
}

## now loop through the above fabcomposer array to uninstall
function installComposer(){
  for i in "${fabcomposernext[@]}"
  do
    echo "Installing $i ..."
    npm install -g $i 2>&1
  done
}

function composerVersions(){
  for i in "${fabcomposer[@]}"
  do
    npm ls -g $i 2>&1
  done
}

uninstallComposer
installComposer
composerVersions
