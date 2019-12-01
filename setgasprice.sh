#!/bin/bash
MINIMUMGAS=10000000000
CHAINLINKDIR=/home/chainlayer/.chainlink-mainnet

## No need to change below this line
MAIL=`cat $CHAINLINKDIR/.api|head -1`
PW=`cat $CHAINLINKDIR/.api|tail -1`
AVGGAS=`curl -k -s https://ethgasstation.info/json/ethgasAPI.json|jq -r '.fastest'`
echo -n "Fast gas is : ${AVGGAS}00000000"
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
  COOKIE="clsession=`cat cookiefile |grep clsession|cut -f 7`"
  curl -k -s -b cookiefile -c cookiefile -X PATCH -H 'Content-Type: application/json' -d '{"ethGasPriceDefault":"'$GAS'"}' https://localhost:6689/v2/config|jq '{"Old": .data.attributes.ethGasPriceDefault.old, "New" : .data.attributes.ethGasPriceDefault.new} '
  rm cookiefile
else
  echo "`date` Not logged in, this is probable not the active node"
fi
