#!/bin/sh

log() {
	logger -s -t "mqtt" "$*"
}

log "MQTT listening..."
$BIN_PATH/mosquitto_sub -I $clientID -h $mqtthost -v -t $topic/+/relay/set | while read line; do
    rxtopic=`echo $line| cut -d" " -f1`
    inputVal=`echo $line| cut -d" " -f2`
    
    port=`echo $rxtopic | sed 's|.*/port\([1-8]\)/relay/set$|\1|'`
    
    if [ "$inputVal" == "1" ]
    then
        val=1
    elif [ "$inputVal" == "0" ]
    then
        val=0
    else
        continue
    fi
    log "MQTT request received. Relay control for port" $port "with value" $inputVal
    `echo $val > /proc/power/relay$port`
    echo 5 > $tmpfile		
done