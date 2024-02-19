#!/bin/bash
date > du_log.txt
echo "### du -sh /u1/ ###" >> du_log.txt
du -sh /u1/* >> du_log.txt
echo "### du -sh /u1/PROD/ ###" >> du_log.txt
du -sh /u1/PROD/* >> du_log.txt
echo "### du -sh /u1/PROD/db/ ###" >> du_log.txt
du -sh /u1/PROD/db/* >> du_log.txt
echo "### du -sh /u1/PROD/db/apps_st/ ###" >> du_log.txt
du -sh /u1/PROD/db/apps_st/* >> du_log.txt
echo "### du -sh /u1/PROD/inst/ ###" >> du_log.txt
du -sh /u1/PROD/inst/* >> du_log.txt
echo "### du -sh /u1/PROD/inst/apps/ ###" >> du_log.txt
du -sh /u1/PROD/inst/apps/* >> du_log.txt
echo "### du -sh /u1/PROD/inst/apps/PROD_ggs11/logs/appl/conc/ ###" >> du_log.txt
du -sh /u1/PROD/inst/apps/PROD_ggs11/logs/appl/conc/* >> du_log.txt
echo "### du -sh /u1/PROD/inst/apps/PROD_ggs11/ ###" >> du_log.txt
du -sh /u1/PROD/inst/apps/PROD_ggs11/* >> du_log.txt
echo "### du -sh /u1/PROD/inst/apps/PROD_ggs11/logs/ ###" >> du_log.txt
du -sh /u1/PROD/inst/apps/PROD_ggs11/logs/* >> du_log.txt
