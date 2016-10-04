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
#
# OPTIONS:
#	-h/? - Print a usage message
#	-i   - IP and HOST
#       -s   - Starting Block number
#       -e   - End Block number
#       -l   - Enable Block info logging to file
#
# SAMPLE :
#	./TransactionsCalci.sh -i http://127.0.0.1:7050 -s 2 e 10 -l
#
#       Transaction infomration is calculated between starting block 2 and
# ending block 10, blockinfo will be saved to blocks.txt
# ------------------------------------------------------------------

function usage(){
	## Enhance this section
        echo "USAGE : TransactionsCalci.sh -i http://IP:PORT -s <START_BLOCK_NUM> -e <END_BLOCK_NUM> -l"
	echo "ex: ./TransactionsCalci.sh -i http://127.0.0.1:7050 -b 2 -l"
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

: ${IP_PORT:="http://127.0.0.1:7050"} #Default IP set to 127.0.0.1 and Port to 7050
: ${START_BLOCK_NUM:=1} #Defaults to DeployTx or any First block
: ${ENABLE_LOG:="N"} #Default logging disabled
: ${START_TIME:="0"} #Default Start time stamp
: ${END_TIME:="0"} #Default End time stamp

#Set default values to 0
DEPLOY_TX_COUNTER=0
ERR_TX_COUNTER=0
TX_COUNTER=0
TOTAL_TRXNS=$(curl -ks $IP_PORT/chain | jq '.height')

echo

##TODO: recheck if there is any better approach
function getStartTimeStamp(){
	if test $START_BLOCK_NUM -le $END_BLOCK_NUM ; then
		if test "$START_BLOCK_NUM" = "2" -o "$START_TIME" = "null"; then
			START_BLOCK_NUM=` expr $START_BLOCK_NUM + 1 `
			#Calculate starting block
			curl -ks $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
			START_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')
			if test "$START_TIME" = "null" ; then
				getStartTimeStamp
			fi
		fi
	fi
}

if test -z $TOTAL_TRXNS ; then
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

if test -z $END_BLOCK_NUM ; then
        #comeup with a better approach?
	END_BLOCK_NUM=$TOTAL_TRXNS
else
	echo #echo "End Block number is $END_BLOCK_NUM"
fi
if test $START_BLOCK_NUM -lt 1 -o $START_BLOCK_NUM -gt $TOTAL_TRXNS ; then
	echo "Start block (-s) argument is Invalid changing it to default value 1 "
	echo
	START_BLOCK_NUM=1
fi
if test $END_BLOCK_NUM -le 0 -o $END_BLOCK_NUM -gt $TOTAL_TRXNS ; then
	echo "End block (-e) argument is Invalid changing it to chain height $TOTAL_TRXNS "
	echo
	END_BLOCK_NUM=$TOTAL_TRXNS
fi

echo "--- Total Blocks to be processed ` expr $END_BLOCK_NUM - $START_BLOCK_NUM ` (Ignore Firt Block Genesis)  ---"

if test "$ENABLE_LOG" == "Y" ; then
	echo "############ Begin Writing blocks ############" > blocks.txt
fi

#Calculate starting block
curl -ks $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json

START_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')



for (( i=$START_BLOCK_NUM; $i<$END_BLOCK_NUM; i++ ))
do
	#This check is required
	curl -ks $IP_PORT/chain/blocks/$i | jq '.' > data.json

	#Write logs to blocks.txt if block logging enabled
	if test "$ENABLE_LOG" == "Y" ; then
		echo "---------------- Block-$i ----------------" >> blocks.txt
		cat data.json >> blocks.txt
		echo "---------------- Block-$i ----------------"  >> blocks.txt
		echo "" >> blocks.txt
	fi

	#Calculate Deploy transactions
	COUNTER=$(cat data.json | grep "ChaincodeDeploymentSpec" | wc -l)
	DEPLOY_TX_COUNTER=` expr $DEPLOY_TX_COUNTER + $COUNTER `

	#Calculate Error transactions
	#COUNTER=$(cat data.json | jq '.["transactions"]' | grep errorCode | wc -l)

	#Calculate overall transactions
	COUNTER=$(cat data.json | jq '.["transactions"]' | grep txid | wc -l)
        ###TODO: Can we do better here ? How do we get the failed trxns
	if [ "$COUNTER" -eq "0" ]; then
	        COUNTER=$(cat data.json | jq '.["nonHashData"]' | grep "{}" | wc -l)
		ERR_TX_COUNTER=` expr $ERR_TX_COUNTER + $COUNTER `
	else
                BLOCK_TXN=$(cat data.json | jq '.["nonHashData"]' | grep "{}" | wc -l)
		if [ "$COUNTER" -ne "$BLOCK_TXN" ]; then
                        FAILED_TXN=` expr $BLOCK_TXN - $COUNTER`
		        ERR_TX_COUNTER=` expr $ERR_TX_COUNTER + $FAILED_TXN `
			TX_COUNTER=` expr $TX_COUNTER + $COUNTER `
		fi

	fi
done

#Calculate end block
if test "$ENABLE_LOG" == "Y" ; then
	echo "############ End Writing blocks ############" >> blocks.txt
fi

getStartTimeStamp

#Calculate starting block
curl -ks $IP_PORT/chain/blocks/` expr $END_BLOCK_NUM - 1 ` | jq '.' > timeCal.json


END_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')

##TODO: recheck if there is any better approach
if test "$START_TIME" = "null" -o "$END_TIME" = "null" ; then
	echo "############ looks like, No Invoke transactions, Exiting ... ##############"
	echo
	exit 1;
fi

#Temporary files cleanup
if test -f ./data.json ; then
    rm ./data.json
fi

if test -f ./timeCal.json ; then
    rm ./timeCal.json
fi

TOTAL_TRXNS=` expr $DEPLOY_TX_COUNTER + $TX_COUNTER + $ERR_TX_COUNTER `
echo
echo "----------- Chaincode Deployment Transactions: $DEPLOY_TX_COUNTER"
echo "----------- Failed Transactions: $ERR_TX_COUNTER"
#TODO: This is still not right way to do ?
echo "----------- Successful Transactions (Exclude Deploy TX_COUNTER if any) : " ` expr $TOTAL_TRXNS - $ERR_TX_COUNTER`
echo
echo
echo "************ Total Transactions : " ` expr $DEPLOY_TX_COUNTER + $TX_COUNTER + $ERR_TX_COUNTER ` " **********"
echo
if test -n "$START_TIME" -a -n "$END_TIME" ; then
	echo "------------ Total execution time ` expr $END_TIME - $START_TIME ` secs"
fi
echo

echo "############ Thatz all I have for now, Letz catchup some other time  ###############"
echo
