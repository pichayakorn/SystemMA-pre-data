#!/bin/bash
df -h > FilesystemH.txt
df -k > FilesystemK.txt
df -m > FilesystemM.txt

# Use the -p POSIX format for re-format in report
#df -Ph > FilesystemPH.txt

# Using sed to re-format to CSV
df -Ph | sed 's/ \{1,\}/,/g' > FilesystemH.csv
