#!/bin/bash

function usage(){
	## Enhance comments section
        echo "USAGE : trxCalci.sh -i http://IP:PORT -b <BLOCK_NUMBER_FROM> -e"
	echo "ex: ./trxCalci.sh -i http://127.0.0.1:5000 -b 2 -e"
}

while getopts "\?hei:b:" opt; do
  case $opt in
     i)   IP_PORT="$OPTARG"
	;;
     e)   ENABLE_LOG="Y"
	;;
     b)   BLOCK_NUM="$OPTARG"
	;;
   \?|h)  usage
          exit 1
        ;;
  esac
done
echo 
echo "##################### 1 .. 2... 3 Letz have fun  #######################"
# Wrong way of cheking ??
TEMP=$IP_PORT

: ${IP_PORT:="http://127.0.0.1:5000"}
: ${BLOCK_NUM:=2}
: {ENABLE_LOG:="N"}

if [ -z "$TEMP" ]; then 
	echo "IP / PORT not provided, Defaulting to $IP_PORT"
else 
	echo "IP / PORT $IP_PORT"
fi

echo "Consider blocks from $BLOCK_NUM"
GRAND_COUNT=0
echo 
TOTAL_TRXNS=$(curl -s $IP_PORT/chain | jq '.height')
#TOTAL_TRXNS=`expr $TOTAL_TRXNS - 2` ## remove GenesisBlock + Deploy 

#awk '/]/{ print NR; exit }' 
echo "--- Total Blocks to be processed ` expr $TOTAL_TRXNS - 2 ` (Ignore Genesis and Deploy Blocks) ---"

for (( i=$BLOCK_NUM; $i<$TOTAL_TRXNS; i++ ))
do
#echo $i
curl -s $IP_PORT/chain/blocks/$i | jq '.' > data.json
#cat data.json
TRX_LENGTH=$(cat data.json | jq '.["transactions"]' | wc -l)
#Remove the '[' and ']' barckets
TRX_LENGTH=`expr $TRX_LENGTH - 2` ## remove GenesisBlock + Deploy 
GRAND_COUNT=`expr $GRAND_COUNT + $TRX_LENGTH / 16 `
if [ "$ENABLE_LOG" == "Y" ] ; then
	echo "Transaction field length : $TRX_LENGTH"
fi
done
echo 
echo "----------- Total Transactions executed are $GRAND_COUNT"
echo
echo "############ Thatz all I have for now, Letz catchup some other time  ###############"
echo
