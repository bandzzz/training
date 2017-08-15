#!/usr/bin/env bash
echo 'worker.list=lb' >> /etc/httpd/conf/workers.properties
echo 'worker.lb.type=lb' >> /etc/httpd/conf/workers.properties
echo 'worker.lb.balance_workers=tomcat1,tomcat2' >> /etc/httpd/conf/workers.properties
echo 'worker.tomcat1.host=172.20.20.2' >> /etc/httpd/conf/workers.properties
echo 'worker.tomcat1.port=8009' >> /etc/httpd/conf/workers.properties
echo 'worker.tomcat1.type=ajp13' >> /etc/httpd/conf/workers.properties
echo 'worker.tomcat2.host=172.20.20.3' >> /etc/httpd/conf/workers.properties
echo 'worker.tomcat2.port=8009' >> /etc/httpd/conf/workers.properties
echo 'worker.tomcat2.type=ajp13' >> /etc/httpd/conf/workers.properties
echo 'LoadModule jk_module modules/mod_jk.so' >> /etc/httpd/conf/httpd.conf
echo 'JkWorkersFile conf/workers.properties' >> /etc/httpd/conf/httpd.conf
echo 'JkShmFile /tmp/shm' >> /etc/httpd/conf/httpd.conf
echo 'JkLogFile logs/mod_jk.log' >> /etc/httpd/conf/httpd.conf
echo 'JkLogLevel info' >> /etc/httpd/conf/httpd.conf
echo 'JkMount /test* lb' >> /etc/httpd/conf/httpd.conf
systemctl restart httpd