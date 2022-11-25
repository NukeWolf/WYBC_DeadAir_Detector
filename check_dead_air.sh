source ./env

# Download AACGAIN tool if needed
if [ ! -f ./aacgain ]
then
    echo "Downloading AACGAIN"
    curl -o aacgain.zip http://projects.sappharad.com/mp3gain/aacgain_20_mac_cmdline.zip
    unzip aacgain.zip
    rm aacgain.zip
    chmod +x ./aacgain
fi

# Don't Repeat Notifications once every 6 hours.
MIN_TIME_BETWEEN_ALERTS=21600
PREV_DATE=$(tail -n 1 < log)+${MIN_TIME_BETWEEN_ALERTS}

if [[ ${PREV_DATE} -gt $(date +%s) ]]
then
exit
fi




#Global Variables
SLEEP_TIMEOUT=15
DEAD_AIR_TRIGGER=500
#White noise is around 60
#Music should get abouve 10,000 in 15 seconds.

#Download Audio Stream
curl -o stream ${STREAM_LINK} & 
(
   # Get the process ID and kill it since it is a stream and will run infinite
   curlpid=$! && 
   sleep ${SLEEP_TIMEOUT} && 
   kill ${curlpid} && 

   #Gets the max amplitude
   MAX_AMPLITUDE=$(./aacgain -o stream | awk -F '\t' '{print $4}' | head -2 | tail -n 1)
   echo ${MAX_AMPLITUDE}
   #Checks if the amplitude is bigger than some treshhold
   if [[ 1 -eq $(echo "${DEAD_AIR_TRIGGER} > ${MAX_AMPLITUDE}" | bc) ]]
   then
    date >> log
    echo ${MAX_AMPLITUDE} >> log
    date +%s >> log
    #Send API Request to project in server
    curl ${GOOGLE_SCRIPTS_API_LINK}
   fi
   rm stream
)
