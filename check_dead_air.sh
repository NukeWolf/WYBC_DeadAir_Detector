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


#Global Variables
SLEEP_TIMEOUT=15
DEAD_AIR_TRIGGER=200
#White noise is around 60

#Download Audio Stream
curl -o stream ${STREAM_LINK} & 
(
   # Get the process ID and kill it since it is a stream and will run infinite
   curlpid=$! && 
   sleep ${SLEEP_TIMEOUT} && 
   kill ${curlpid} && 

   #Gets the max amplitude
   MAX_AMPLITUDE=$(./aacgain -o stream | awk -F '\t' '{print $4}' | head -2 | tail -n 1)
   #Checks if the amplitude is bigger than some treshhold
   if [[ 1 -eq $(echo "${DEAD_AIR_TRIGGER} > ${MAX_AMPLITUDE}" | bc) ]]
   then
    date >> log
    echo ${MAX_AMPLITUDE} >> log
    #Send API Request to project in server
    curl ${GOOGLE_SCRIPTS_API_LINK}
   fi
   rm stream
)
