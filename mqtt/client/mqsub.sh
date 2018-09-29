#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}
source $BIN_PATH/client/led.cfg

# initially set the LED. If configured it can be switched along with the relay later
if [ -n "$afterboot" ];
then
  echo $afterboot > /proc/led/status
fi

log "MQTT listening..."
$BIN_PATH/mosquitto_sub -I $clientID -h $mqtthost $auth -v -t $topic/+/+/set | while read line; do
    rxtopic=`echo $line| cut -d" " -f1`
    inputVal=`echo $line| cut -d" " -f2`
    
    port=`echo $rxtopic | sed 's|.*/port\([1-8]\)/[a-z]*/set$|\1|'`
    property=`echo $rxtopic | sed 's|.*/port[1-8]/\([a-z]*\)/set$|\1|'`
    
    if [ "$property" == "lock" ] || [ "$property" == "relay" ]
    then
    
        if [ "$inputVal" == "1" ]
        then
            val=1
            if [ -n "$relay_on" ];
            then
              echo $relay_on > /proc/led/status
            fi
        elif [ "$inputVal" == "0" ]
        then
            val=0
            if [ -n "$relay_off" ];
            then
              echo $relay_off > /proc/led/status
            fi
        else
            continue
        fi
        log "MQTT request received. $property control for port" $port "with value" $inputVal
        `echo $val > /proc/power/$property$port`
        echo 5 > $tmpfile
    fi        
done