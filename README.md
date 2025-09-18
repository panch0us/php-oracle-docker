# php-oracle-docker

Подключаем PHP7.4 к Oracle 11.2.0.4 через Docker

- docker build -t php74-oracle-64bit .
- docker run -it -v /root/downloads/test-oracle.php:/var/www/test-oracle.php -v /u01/app/oracle/product/11.2.0/db_1/network/admin/:/opt/oracle/network/admin:ro php74-oracle-64bit php /var/www/test-oracle.php

Пример для меня:
- docker build -t php-fpm-oracle .


- docker run -d --name php-fpm-oracle --restart unless-stopped -p 9000:9000 \
  -v /var/www/statist:/var/www/statist \
  -v /u01/app/oracle/product/11.2.0/db_1/network/admin/:/opt/oracle/network/admin:ro \
  php74-oracle-fpm
