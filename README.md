EMC Symmetrix and Powermax Refresh Script 

Based on SYMCLI this script will snapshot the source, link it
to the target group then monitor for define.

Once define is done it will unlink the snapshot and terminate it.

I have made everything a variable set at the top of the script so 
you can use as needed without re-writing the script itself.

This was made interactive on purpose to force human verification
before taking irreversible actions.

Requires:
SYMCLI | Linux | mailx


