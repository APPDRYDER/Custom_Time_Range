#!/bin/bash
#
# Maintainer: David Ryder, David.Ryder@AppDynamics.com
#
# Records start time, end time and duration between start and end times
# Posts a Custom Time Range to the AppDynamics Controller using start and end times
#
# Arguments: <command> [<label>] [<description][<instance>]
# Commands:
#   start
#   end
#   duration
#   post <label>
#
cmd=${1:-"<cmd>"}
rangeLabel=${2:-"TEST"}
rangeDescription=${3:-"Auto Generated"}
instance=${4:-"appd1"}

# Authentication and Access. Required environment variables
ERROR="0"
[ -z "$APPD_USER_NAME" ]        && { echo "Environment variable not set: APPD_USER_NAME"; ERROR=1; }
[ -z "$APPD_ACCOUNT" ]          && { echo "Environment variable not set: APPD_ACCOUNT"; ERROR=1; }
[ -z "$APPD_PWD" ]              && { echo "Environment variable not set: APPD_PWD"; ERROR=1; }
[ -z "$APPD_CONTROLLER_HOST" ]  && { echo "Environment variable not set: APPD_CONTROLLER_HOST"; ERROR=1; }
[ -z "$APPD_CONTROLLER_PORT" ]  && { echo "Environment variable not set: APPD_CONTROLLER_PORT"; ERROR=1; }
[ "$ERROR" == "1" ] && { echo "Exiting"; exit 0; }

APPD_FULL_USER=$APPD_USER_NAME@$APPD_ACCOUNT:$APPD_PWD
B64AUTH=`echo $APPD_FULL_USER | base64`

# Temp files
startTimeFile=/tmp/$instance-starttime.txt
endTimeFile=/tmp/$instance-endtime.txt
testCounterFile="/tmp/test-cntr.txt"

#VERBOSE="--verbose"
VERBOSE=""

#####################################
# Start
if [ $cmd == "start" ]; then
  startTime=$(date +%s)
  echo $startTime > $startTimeFile
  echo "Start Time " $startTime

######################################
# End
elif [ $cmd == "end" ]; then
  endTime=$(date +%s)
  echo $endTime > $endTimeFile
  echo "End Time " $endTime

#####################################
# Duration
elif [ $cmd == "duration" ]; then
  startTime=`cat $startTimeFile`
  endTime=`cat $endTimeFile`
  durationTime=$(($endTime - $startTime))
  echo "Duration " $startTime $endTime $durationTime

#####################################
# Authenticate to Controller
elif [ $cmd == "authenticate" ]; then
  # Required authentication to Controller
  #VERBOSE="--verbose"
  rm /tmp/session.dat
  curl $VERBOSE -s -c /tmp/session.dat \
       --user "$APPD_FULL_USER" \
       -X GET http://$APPD_CONTROLLER_HOST:$APPD_CONTROLLER_PORT/controller/auth?action=login
  cat /tmp/session.dat

#####################################
# Post Custom Time Range
# Expects start and end commands to have been executed
elif [ $cmd == "post" ]; then
  # Timing Seconds
  startTime=`cat $startTimeFile`
  endTime=`cat $endTimeFile`
  durationTime=$(($endTime - $startTime))

  # Timing milli-seconds
  startTimeMs=$(($startTime * 1000))
  endTimeMs=$(($endTime * 1000))
  durationTimeMs=$(($endTimeMs - $startTimeMs))

  echo "Timing SEC" $startTime $endTime $durationTime
  echo "Timing MS " $startTimeMs $endTimeMs $durationTimeMs

  # Iteration Counter to ensure unique custom ranges
  testCntr=`cat $testCounterFile` || testCntr=0; testCntr=`expr $testCntr + 1`; echo $testCntr > $testCounterFile

  # Required authentication to Controller
  rm /tmp/session.dat
  curl $VERBOSE -s -c /tmp/session.dat \
       --user "$APPD_FULL_USER" \
       -X GET http://$APPD_CONTROLLER_HOST:$APPD_CONTROLLER_PORT/controller/auth?action=login
  #cat /tmp/session.dat

  # Parameters to post
  NAME=$rangeLabel"-"`date +'%m%d%y-%H%M'`"-"$testCntr
  PARAMS="{\"name\":\"${NAME}\",\
           \"description\":\"${rangeDescription}\",\
           \"shared\":true,\
           \"timeRange\":{\"type\":\"BETWEEN_TIMES\",\
                          \"durationInMinutes\":0,\
                          \"startTime\":${startTimeMs},\
                          \"endTime\":${endTimeMs}}}"
  echo "Posting: "$NAME

  # Post
  curl $VERBOSE -s -b /tmp/session.dat \
       --header "Authorization: Basic $B64AUTH" \
       --header "Content-Type: application/json;charset=utf-8" \
       --header "Accept-Encoding: text" \
       --header "Accept: application/json, text/plain" \
       --data "${PARAMS}" \
       -X POST http://$APPD_CONTROLLER_HOST:$APPD_CONTROLLER_PORT/controller/restui/user/createCustomRange
else
  echo "Unrecognized command:" $cmd
fi

exit 0
