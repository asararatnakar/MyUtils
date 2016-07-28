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
#	./TransactionsCalci.sh -i http://127.0.0.1:5000 -s 2 e 10 -l
#
#       Transaction infomration is calculated between starting block 2 and
# ending block 10, blockinfo will be saved to blocks.txt
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

##TODO: recheck if there is any better approach
function getStartTimeStamp(){
	if test $START_BLOCK_NUM -le $END_BLOCK_NUM ; then
		if test "$START_BLOCK_NUM" = "2" -o "$START_TIME" = "null"; then
			START_BLOCK_NUM=` expr $START_BLOCK_NUM + 1 `
			#Calculate starting block
			if test "$IS_SECURE" = "https" ; then
				curl -k $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
			else
				curl -s $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
			fi
			START_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')
			if test "$START_TIME" = "null" ; then
				getStartTimeStamp
			fi
		fi
	fi
}

IS_SECURE=${IP_PORT:0: 5}
if test "$IS_SECURE" = "https" ; then
    TOTAL_TRXNS=$(curl -k $IP_PORT/chain | jq '.height')
else
    TOTAL_TRXNS=$(curl -s $IP_PORT/chain | jq '.height')
fi

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
if test "$IS_SECURE" = "https" ; then
	curl -k $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
else
	curl -s $IP_PORT/chain/blocks/$START_BLOCK_NUM | jq '.' > timeCal.json
fi

START_TIME=$(cat timeCal.json | jq '.["nonHashData"]["localLedgerCommitTimestamp"]["seconds"]')



for (( i=$START_BLOCK_NUM; $i<$END_BLOCK_NUM; i++ ))
do
	#This check is required
	if test "$IS_SECURE" = "https" ; then
		curl -k $IP_PORT/chain/blocks/$i | jq '.' > data.json
	else
		curl -s $IP_PORT/chain/blocks/$i | jq '.' > data.json
	fi

	#Write logs to blocks.txt if block logging enabled
	if test "$ENABLE_LOG" == "Y" ; then
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
if test "$ENABLE_LOG" == "Y" ; then
	echo "############ End Writing blocks ############" >> blocks.txt
fi

getStartTimeStamp

#Calculate starting block
if test "$IS_SECURE" = "https" ; then
	curl -k $IP_PORT/chain/blocks/` expr $END_BLOCK_NUM - 1 ` | jq '.' > timeCal.json
else
	curl -s $IP_PORT/chain/blocks/` expr $END_BLOCK_NUM - 1 ` | jq '.' > timeCal.json
fi


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

echo
echo "----------- Chaincode Deployment Transactions: $deployTrxn"
echo "----------- Failed Transactions: $errTrxn"
echo "----------- Successful Transactions (Exclude Deploy Trxn if any) : " ` expr $Trxn - $errTrxn `
echo
echo
echo "************ Total Transactions : " ` expr $deployTrxn + $Trxn + $errTrxn ` " **********"
echo
if test -n "$START_TIME" -a -n "$END_TIME" ; then
	echo "------------ Total execution time ` expr $END_TIME - $START_TIME ` secs"
fi
echo

echo "############ Thatz all I have for now, Letz catchup some other time  ###############"
echo
