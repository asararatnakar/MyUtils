#!/bin/bash

# ------------------------------------------------------------------
#
# TITLE : To verify blockcahin height
#
# AUTHOR: Ratnakar Asara
#
# VERSION: 0.1
#
# DESCRIPTION:
#          The purpose of this script is to get the height of the Blockchain
# on a 4 peer network also validates whether all peers are in Sync or not
#
# DEPENDENCY:
#	Download and Install JQ: https://goo.gl/DsDskg
#
# USAGE:
#	CheckHeight.sh [OPTIONS]
#
# OPTIONS:
#       -http://172.17.0.3:5000 - Provide the format http://IP:HOST
#
# SAMPLE 1 :
#	./ChainHeight.sh
#
#       No IP provided hence defaults to IP http://127.0.0.1:5000 and get
# height of a single peer (Generally used outside vagrant, when peers are 
# running inside vagrant)
#
# SAMPLE 2 :
#	./ChainHeight.sh http://172.17.0.3:5000
#
#       I assume, this IP is used when script is running inside Vagrant env.
# Checks heights of 4 peers and compare their block heights to check if they in
# sync
#
# SAMPLE 3 :
#	./ChainHeight.sh https://e405f46f-dfaf-abcd-8995-6dd4a6e2d915_vp0-api.
#                                                     zone.blockchain.ibm.com/
#
#       I assume this is a 4 peer network and gets you the heights of the peers
# and compare their block heights to check if they in sync or not
#
# -----------------------------------------------------------------------------

#TODO: Make sure you have the right ports

: ${IP_PORT:="http://127.0.0.1:5000"}

: ${DOCKER_IP1:="http://172.17.0.3:5000"}
: ${DOCKER_IP2:="http://172.17.0.4:5000"}
: ${DOCKER_IP3:="http://172.17.0.5:5000"}
: ${DOCKER_IP4:="http://172.17.0.6:5000"}

if [ "$#" -eq 1 ]; then
  IP_PORT=$1
fi

CHAIN_HEIGHT=$(curl -ks $IP_PORT/chain | jq '.height')

if test -z "$CHAIN_HEIGHT" ; then
	echo
	echo "Looks like IP and/or PORT are Invalid or May be Network is bad ??"
	echo
	echo "##### Sorry can't help, Please check your network and come back #####"
	echo
	exit 1
fi

if test "$CHAIN_HEIGHT" -le 1 ; then
	echo
	echo "... All you have got is a genesis block, no transactions available yet ..."
	echo
	echo "################### Exiting ###################"
	echo
	exit 1
fi

IS_MATCHED=$(echo "$IP_PORT" | awk '{print match($0, "127.0.0.1")}')

if test "$IS_MATCHED" -eq 8 ; then
	echo ""
        echo "Are you are executing outside Vagrant ? I cannot access all peers"
        echo ""
        echo "Chain height on $IP_PORT is $CHAIN_HEIGHT"
	echo ""
	exit 1
fi

IS_MATCHED=$(echo "$IP_PORT" | awk '{print match($0, "172.17.0.")}')
if test "$IS_MATCHED" -gt 0 ; then
        echo "Looks like you are executing script from inside Vagrant"
        echo ""
	## TODO: This is really really dirty way , change it ASAP
	CHAIN_HEIGHT1=$(curl -ks $DOCKER_IP1/chain | jq '.height')
        echo "Chain height on $DOCKER_IP1 is $CHAIN_HEIGHT1"
	CHAIN_HEIGHT2=$(curl -ks $DOCKER_IP2/chain | jq '.height')
        echo "Chain height on $DOCKER_IP2 is $CHAIN_HEIGHT2"
	CHAIN_HEIGHT3=$(curl -ks $DOCKER_IP3/chain | jq '.height')
        echo "Chain height on $DOCKER_IP3 is $CHAIN_HEIGHT3"
	CHAIN_HEIGHT4=$(curl -ks $DOCKER_IP4/chain | jq '.height')
        echo "Chain height on $DOCKER_IP4 is $CHAIN_HEIGHT4"
	echo ""
	if test "$CHAIN_HEIGHT1" = "$CHAIN_HEIGHT2" -a "$CHAIN_HEIGHT2" = "$CHAIN_HEIGHT3" -a "$CHAIN_HEIGHT3" = "$CHAIN_HEIGHT4"; then 
		echo "Perfect all the peers are in Sync"
	else
		echo "All peers are not in Sync"
	fi
	echo ""
	exit 1
fi

echo ""
for (( i=0;i<4;i++)) ; do
	URL=$(echo $IP_PORT | sed "s/vp[[:digit:]]/vp$i/")
	CHAIN_HEIGHT=$(curl -ks $URL/chain | jq '.height')
        echo "Chain height on $URL is $CHAIN_HEIGHT"
	HEIGHT_ARRAY[$i]=$CHAIN_HEIGHT
done
echo ""
if test "${HEIGHT_ARRAY[0]}" = "${HEIGHT_ARRAY[1]}" -a "${HEIGHT_ARRAY[1]}" = "${HEIGHT_ARRAY[2]}" -a "${HEIGHT_ARRAY[2]}" = "${HEIGHT_ARRAY[3]}" ; then 
	echo "Perfect all the peers are in Sync"
else
	echo "Peers are not in Sync"
fi
echo ""
echo ""
