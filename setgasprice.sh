#!/bin/bash
#
# This script sets the gas to the highest value of three gas oracles +1 GWEI
#
MINIMUMGAS=10000000000
CHAINLINKDIR=/home/chainlayer/.chainlink-mainnet/

## No need to change below this line
## Make sure you have your email address and password one on top of the other 
## In a .api file
MAIL=`cat $CHAINLINKDIR/.api|head -1`
PW=`cat $CHAINLINKDIR/.api|tail -1`

# Query Oracles
AVGGAS1=`curl -k -s https://ethgasstation.info/json/ethgasAPI.json| tac | tac |jq -r '.fastest' 2>/dev/null`
AVGGAS2=`curl -k -s https://gasprice.poa.network/| tac | tac |jq -r '.fast' 2>/dev/null`0
AVGGAS3=`curl -k -s https://api.anyblock.tools/latest-minimum-gasprice| tac | tac |jq -r '.fast' 2>/dev/null`0

# Check for numbers
re='^[0-9]+$'
if ! [[ $AVGGAS1 =~ $re ]] ; then
   echo "Oracle 1 error, set to 0"
   AVGGAS1=0
fi

if ! [[ $AVGGAS2 =~ $re ]] ; then
   echo "Oracle 2 error, set to 0"
   AVGGAS2=0
fi

if ! [[ $AVGGAS3 =~ $re ]] ; then
   echo "Oracle 3 error, set to 0"
   AVGGAS3=0
fi


if [ $AVGGAS1 -gt $AVGGAS2 ]
then
  AVGGAS=$AVGGAS1
else
  AVGGAS=$AVGGAS2
fi

if [ $AVGGAS -lt $AVGGAS3 ]
then
  AVGGAS=$AVGGAS3
fi

echo "Gassprices: $AVGGAS1 $AVGGAS2 $AVGGAS3"
echo -n "Fastest gas is : ${AVGGAS}00000000"

GAS=$(($AVGGAS+10))00000000
echo -n " New gas is : $GAS"
if [ $GAS -lt $MINIMUMGAS ]
then
  GAS=$MINIMUMGAS
fi
echo " Final gas is : $GAS"
echo "Logged in: `curl -k -s -c cookiefile -X POST   -H 'Content-Type: application/json'   -d '{"email":"'$MAIL'", "password":"'$PW'"}' https://localhost:6689/sessions|jq '.data.attributes.authenticated'`"
if [ -f cookiefile ]
then
  curl -k -s -b cookiefile -c cookiefile -X PATCH -H 'Content-Type: application/json' -d '{"ethGasPriceDefault":"'$GAS'"}' https://localhost:6689/v2/config|jq '{"Old": .data.attributes.ethGasPriceDefault.old, "New" : .data.attributes.ethGasPriceDefault.new} '
  rm cookiefile
else
  echo "`date` Not logged in, this is probable not the active node"
fi
