#!/bin/bash

GRAND_COUNT=0
echo "##################### 1 .. 2... 3 Letz have fun  #######################"
#TODO: Process IP and PORT as argument
DEFAULT_IP=http://127.0.0.1:5000
echo "No Args supplied defaulting to $DEFAULT_IP"
echo 
TOTAL_TRXNS=$(curl -s $DEFAULT_IP/chain | jq '.height')
#TOTAL_TRXNS=`expr $TOTAL_TRXNS - 2` ## remove GenesisBlock + Deploy 

#awk '/]/{ print NR; exit }' 
echo "--- Total Blocks to be processed ` expr $TOTAL_TRXNS - 2 ` (Ignore Genesis and Deploy Blocks) ---"

for (( i=2; $i<$TOTAL_TRXNS; i++ ))
do
#echo $i
curl -s $DEFAULT_IP/chain/blocks/$i | jq '.' > data.json
#cat data.json
TRX_LENGTH=$(cat data.json | jq '.["transactions"]' | wc -l)
#Remove the '[' and ']' barckets
TRX_LENGTH=`expr $TRX_LENGTH - 2` ## remove GenesisBlock + Deploy 
GRAND_COUNT=`expr $GRAND_COUNT + $TRX_LENGTH / 16 `
echo "Transaction field length : $TRX_LENGTH"
echo
done
echo "TOTAL TRXS Executed are $GRAND_COUNT"
echo
echo "##################### EXECUTION DONE #######################"

