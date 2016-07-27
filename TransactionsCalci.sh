#!/bin/bash

# ------------------------------------------------------------------
#
# TITLE : Transaction Calculator
#
# AUTHOR: Ratnakar Asara
#
# VERSION: 0.2
#
# DESCRIPTION:
#          The purpose of this script is to calculate number of
# successful transactions taken place on fabric. Script gets the
# chain height and segragates Deploy, Failed and Total transactions
# executed on blockchain, also calculates total time taken to
# execute the transactions
#
# DEPENDENCY:
#	Download and Install JQ: https://goo.gl/DsDskg
#
# USAGE:
#	TransactionsCalci.sh [OPTIONS]
# OPTIONS:
#	-h/? - Print a usage message
#	-i   - IP and HOST
#       -s   - Starting Block number
#       -e   - End Block number
#       -l   - Enable Block info logging to file
#
# SAMPLE :
#	./TransactionsCalci.sh -i http://127.0.0.1:5000 -s 2 -l
#       Transaction infomration is calculated from block 2 and block
# info will be saved to blocks.txt
# ------------------------------------------------------------------

function usage(){
	## Enhance this section
        echo "USAGE : TransactionsCalci.sh -i http://IP:PORT -s <START_BLOCK_NUM> -e <END_BLOCK_NUM> -l"
	echo "ex: ./TransactionsCalci.sh -i http://127.0.0.1:5000 -b 2 -l"
}

while getopts "\?hli:s:e:" opt; do
  case $opt in
     s)   START_BLOCK_NUM="$OPTARG"
        ;;
     e)   END_BLOCK_NUM="$OPTARG"
        ;;
     i)   IP_PORT="$OPTARG"
	;;
     l)   ENABLE_LOG="Y"
	;;
   \?|h)  usage
          exit 1
        ;;
  esac
done

echo
echo "##################### Letz begin the fun  #######################"

: ${IP_PORT:="http://127.0.0.1:5000"} #Default IP set to 127.0.0.1 and Port to 5000
: ${START_BLOCK_NUM:=1} #Defaults to DeployTx or any First block
: ${ENABLE_LOG:="N"} #Default logging disabled
: ${START_TIME:="0"} #Default Start time stamp
: ${END_TIME:="0"} #Default End time stamp

#Set default values to 0
deployTrxn=0
errTrxn=0
Trxn=0

echo
IS_SECURE=${IP_PORT:0: 5}
if [ "$IS_SECURE" = "https" ]; then
    TOTAL_TRXNS=$(curl -k $IP_PORT/chain | jq '.height')
else
    TOTAL_TRXNS=$(curl -s $IP_PORT/chain | jq '.height')
fi

if [ -z $TOTAL_TRXNS ]; then
	echo
	echo "Looks like IP and/or PORT are Invalid or May be Network is bad ??"
	echo
	echo "##### Oops can't help, Please reset your network and come back #####"
	echo
	exit 1
else
	echo "Chain height on $IP_PORT is $TOTAL_TRXNS"
fi

if test "$TOTAL_TRXNS" -le 1 ; then
	echo
	echo "... All you have got is a genesis block, no transactions available yet ..."
	echo
	echo "################### Exiting ###################"
	echo
	exit 1
fi

if [ -z $END_BLOCK_NUM ]; then
        #comeup with a better approach?
	END_BLOCK_NUM=$TOTAL_TRXNS
else
	echo "End Block number is $END_BLOCK_NUM"
fi

echo "--- Total Blocks to be processed ` expr $TOTAL_TRXNS - 1 ` (Ignore Firt Block Genesis) ---"

if [ "$ENABLE_LOG" == "Y" ] ; then
	echo "############ Begin Writing blocks ############" > blocks.txt
fi

#Calculate starting block
if [ "$IS_SECURE" = "https" ]; then
	curl -k $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
else
	curl -s $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
fi

START_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')

for (( i=$START_BLOCK_NUM; $i<$END_BLOCK_NUM; i++ ))
do
	#This check is required
	if [ "$IS_SECURE" = "https" ]; then
		curl -k $IP_PORT/chain/blocks/$i | jq '.' > data.json
	else
		curl -s $IP_PORT/chain/blocks/$i | jq '.' > data.json
	fi

	#Write logs to blocks.txt if block logging enabled
	if [ "$ENABLE_LOG" == "Y" ] ; then
		echo "---------------- Block-$i ----------------" >> blocks.txt
		cat data.json >> blocks.txt
		echo "---------------- Block-$i ----------------"  >> blocks.txt
		echo "" >> blocks.txt
	fi

	#Calculate Deploy transactions
	counter=$(cat data.json | grep "ChaincodeDeploymentSpec" | wc -l)
	deployTrxn=` expr $deployTrxn + $counter `

	#Calculate Error transactions
	counter=$(cat data.json | jq '.["nonHashData"]["transactionResults"]' | grep errorCode | wc -l)
	errTrxn=` expr $errTrxn + $counter `

	#Calculate overall transactions
	counter=$(cat data.json | jq '.["nonHashData"]["transactionResults"]' | grep uuid | wc -l)
	Trxn=` expr $Trxn + $counter `
done

#Calculate end block
if [ "$ENABLE_LOG" == "Y" ] ; then
	echo "############ End Writing blocks ############" >> blocks.txt
fi

#Calculate starting block
if [ "$IS_SECURE" = "https" ]; then
	curl -k $IP_PORT/chain/blocks/` expr $END_BLOCK_NUM - 1 ` | jq '.' > timeCal.json
else
	curl -s $IP_PORT/chain/blocks/` expr $END_BLOCK_NUM - 1 ` | jq '.' > timeCal.json
fi

END_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')

#Temporary files cleanup
if [ -f ./data.json ]; then
    rm ./data.json
fi

if [ -f ./timeCal.json ]; then
    rm ./timeCal.json
fi

if test "$START_TIME" == "null" ; then
	START_TIME=0
fi
if test "$END_TIME" == "null" ; then
	END_TIME=0
fi

echo
echo "----------- Chaincode Deployment Transactions: $deployTrxn"
echo "----------- Failed Transactions: $errTrxn"
echo "----------- Successful Transactions (Exclude Deploy Trxn) : " ` expr $Trxn - $errTrxn`
echo
echo
echo "************ Total Transactions : " ` expr $deployTrxn + $Trxn + $errTrxn` " **********"
echo
if test -n "$START_TIME" -a -n "$END_TIME" ; then
	echo "------------ Total execution time ` expr $END_TIME - $START_TIME ` in ms"
fi
echo

echo "############ Thatz all I have for now, Letz catchup some other time  ###############"
echo
