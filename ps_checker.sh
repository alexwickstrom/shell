#!/bin/sh
if [ ! -d "/home/root/crashlogs" ]
then
    mkdir /home/root/crashlogs
fi
min_running_wis=5 # 3 wisbtctl2 + 1 c_test + 1 grep = 5
echo $min_running_wis

counter=0
while [[ $(ps -ef | grep -cE "wisbtctl2|c_test") < $min_running_wis ]]; do
    sleep 5
    let "counter++"
    if [[ $counter > 1 ]]
    then    
        break
    fi  
done

LOW_MEM=400

while true; do
    # count the number of wis processes running
    
    free_mb=$(free -m  | grep ^Mem | tr -s ' ' | cut -d ' ' -f 4)
    num_wis_pid=$(ps -ef | grep -cE "wisbtctl2|c_test")
    # get the list of remaining processes
    remaining_processes=$(ps -ef | grep -E "wisbtctl2|c_test")
    
    if [[ $num_wis_pid -lt $min_running_wis ]]
    then
        echo "hi"
        free_mem=$(free -h)
        disk_use=$(df -h)
        crash_str="a wis process must have crashed"
        echo $crash_str
        # save to file with datetime in filename
        fname_to_save="/home/root/crashlogs/crash$(date +"%Y_%m_%d_%I_%M_%p").log"
        touch $fname_to_save
        echo $crash_str > $fname_to_save
        # now write the remaining processes to file
        echo " " >> $fname_to_save
        echo "Remaining Processes:" >> $fname_to_save
        echo "$remaining_processes" >> $fname_to_save
        echo " " >> $fname_to_save
        echo -e "Free Memory: \n$free_mem" >> $fname_to_save
        echo " " >> $fname_to_save
        echo -e "Disk Use:\n$disk_use" >> $fname_to_save
        echo "hci status:" >> $fname_to_save
        hciconfig >> $fname_to_save
        tar c -z -f /home/root/crashlogs/driver_logs$(date +"%Y_%m_%d_%I_%M_%p").tar /log_*
        reboot -f  
    fi  
    sleep 1m
done
