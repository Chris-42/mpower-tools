#!/bin/sh
# homie spec (incomplete)
$PUBBIN -h $mqtthost -t $topic/\$homie -m "3.0.0" -r
$PUBBIN -h $mqtthost -t $topic/\$state -m "init" -r
$PUBBIN -h $mqtthost -t $topic/\$name -m "$devicename" -r
$PUBBIN -h $mqtthost -t $topic/\$implementation -m "shell" -r
$PUBBIN -h $mqtthost -t $topic/\$fw/version -m "$version" -r

$PUBBIN -h $mqtthost -t $topic/\$fw/name -m "mPower MQTT" -r

IPADDR=`ifconfig eth1 | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }'`
$PUBBIN -h $mqtthost -t $topic/\$localip -m "$IPADDR" -r

MACADDR=`ifconfig eth1 | grep 'HWaddr' | awk '{print $NF}'`                     
$PUBBIN -h $mqtthost -t $topic/\$mac -m "$MACADDR" -r 

NODES=`seq $PORTS | sed 's/\([0-9]\)/port\1/' |  tr '\n' , | sed 's/.$//'`
$PUBBIN -h $mqtthost -t $topic/\$nodes -m "$NODES" -r

UPTIME=`awk '{print $1}' /proc/uptime`
$PUBBIN -h $mqtthost -t $topic/\$stats/uptime -m "$UPTIME" -r

properties=relay

if [ $energy -eq 1 ]
then
    properties=$properties,energy
fi

if [ $power -eq 1 ]
then
    properties=$properties,power
fi

if [ $voltage -eq 1 ]
then
    properties=$properties,voltage
fi

if [ $lock -eq 1 ]
then
    properties=$properties,lock
fi
# node infos
for i in $(seq $PORTS)
do
    NAME="Port $i"                
    if [ -f /etc/persistent/cfg/config_file ]; then
        N=`grep "^port.$((i-1)).label=" /etc/persistent/cfg/config_file | cut -d '=' -f 2`
        [ -n "$N" ] && NAME=$N                                                            
    fi                                                                                    
    $PUBBIN -h $mqtthost -t $topic/port$i/\$name -m "$NAME" -r
    $PUBBIN -h $mqtthost -t $topic/port$i/\$type -m "power switch" -r
    $PUBBIN -h $mqtthost -t $topic/port$i/\$properties -m "$properties" -r
    $PUBBIN -h $mqtthost -t $topic/port$i/relay/\$settable -m "true" -r
    $PUBBIN -h $mqtthost -t $topic/port$i/relay/\$datatype -m "boolean" -r
    $PUBBIN -h $mqtthost -t $topic/port$i/relay/\$name -m "${NAME} relay" -r
    if [ $power -eq 1 ]
    then
      $PUBBIN -h $mqtthost -t $topic/port$i/power/\$datatype -m "float" -r
      $PUBBIN -h $mqtthost -t $topic/port$i/power/\$name -m "${NAME} power" -r
    fi
    if [ $voltage -eq 1 ]
    then
      $PUBBIN -h $mqtthost -t $topic/port$i/voltage/\$datatype -m "float" -r
      $PUBBIN -h $mqtthost -t $topic/port$i/voltage/\$name -m "${NAME} voltage" -r
    fi
done

if [ $lock -eq 1 ]
then
    for i in $(seq $PORTS)
    do
        $PUBBIN -h $mqtthost -t $topic/port$i/lock/\$settable -m "true" -r
    done
fi
$PUBBIN -h $mqtthost -t $topic/\$state -m "ready" -r

