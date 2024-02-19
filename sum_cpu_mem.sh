#!/bin/bash
grep Average *.txt | egrep -v '[0-9]{4}' | sed 's/:Average//' > sum_cpu.txt
grep Average *.txt | egrep '[0-9]{4}' | sed 's/:Average//' > sum_mem.txt

awk '{print $1"  "$3"  "$5"  "$6"  "$8}' sum_cpu.txt | sed 's/ \{1,\}/,/g' > sum_cpu.csv
#sed 's/ \{1,\}/,/g' sum_cpu.txt > sum_cpu.csv
sed 's/ \{1,\}/,/g' sum_mem.txt > sum_mem.csv
