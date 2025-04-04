# rhel-hdd-sizing-fix
A quick fix for storage issues with the MBR and FS size in RHEL.

This shell script for Linux automatically verifies problems with the partition table or disk structures, then it can correct additional space not recognized by the FS by discovering and adding any available physical device space missing and adding it to the hdd volume and logical device the user chooses.
