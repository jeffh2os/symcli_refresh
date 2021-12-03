#!/bin/bash
#Created 2021/11/19
#Updated 2021/12/03
#Symmetrix Powermax Storage Group Refresh with Link, Copy, Monitor, Unlink and Terminate functions.
#If any part is not wanted comment it out.
#Variables set to allow easy use for any storage group and options
#Choice Y/N options added for sanity checks to verify everything is ready

#Variables Set Here
date=$(date +"%Y_%m_%d_%H.%M")
#Symm ID (or sid)
symm=####
#Command Path
cpath=/opt/emc/SYMCLI/bin/
#Source Child Storage Group
src=source_storage_group_csg
#Number of Dev in Storage Group
num=xx
#Linked Storage Group
link=link_storage_group_csg
#Snapshot Name
snap=xxxxxxxxx_refresh_snap
#Log File Name
log=/tmp/refresh
#Email Recipients & Hostname
emailrecipients="someone@myplace.com"
host="echo $HOSTNAME"

#Functions
function checkprogress () {
        $cpath/symsnapvx list -sg $src -snapshot_name  $snap -linked -detail -sid $symm -output xml |grep "<percent>" |sed 's/<percent>//g' |sed s'|</percent>||g' > $log
}


#Warnings and Alerts
echo
echo
echo "Add Your Own Warnings Here"
echo
echo
echo "###############################################################"
echo
echo
echo "$source will need to be frozen and thawed for the snapshot!"
echo
echo
echo "###############################################################"
echo
echo
echo "This will snapshot $source data volume group,"
echo "link the snapshot to $link volume group,"
echo "and sync the data, overwriting the $ink volumes."
echo
echo
echo "###############################################################"
echo
echo
echo "Pausing for 10 seconds.... (CTRL '+' '<C>' out if you need to stop this now!)"
echo
echo
echo "###############################################################"
sleep 10s



#Verify and run snapshot, link, define
while true
do
    read -r -p 'Do you want to continue? Be Very Sure : ' choice
    case "$choice" in
      n|N) echo"Exiting Script!";break;;
      y|Y) echo 'Starting Snapshot, Link and Copy...';$cpath/symsnapvx -sid $symm -sg $source establish -name  $snap && sleep 1m; $capth/symsnapvx -sid $symm -sg $source -lnsg $link  link -copy -snapshot_name $snap -nop;break;;
      *) echo 'Please Respond with Y or N';;
    esac
done

echo
echo

#Monitor Define Process
echo "Monitoring define progress, depending on the size and number of devices this may take some time"
checkprogress
echo "Checking Progress.."
sleep 5s

echo

#Loop to check for 100% progress on the define for all of the devices
while :; do
if  [[ $(cat $log |grep 100 |wc -l) -eq $num ]]; then

    mailx -s "$snap Refresh is complete!" $emailrecipients $host < /dev/null;echo "!!! Define is Complete on $snap !!!";break
else
    echo "Not complete, will check shortly";sleep 5s;checkprogress
 fi
 done

echo
echo

#Unlink and Terminate Snapshot
while true
do
    read -r -p 'Unlinking the snapshot and terminate it, this can not be undone, Be Very Sure : ' choice
    case "$choice" in
      n|N) echo "Exiting Script";break;;
      y|Y) echo 'Starting Unlink and Terminate Snapshot...';$cpath/symsnapvx -sid $symm unlink -sg $src -lnsg $link -snapshot_name $snap -nop&& sleep 5s; $cpath/symsnapvx -sid $symm terminate -sg $src -snapshot_name $snap -nop;break;;
      *) echo 'Please Respond with Y or N';;
    esac
done



# End of Script, Enjoy!

