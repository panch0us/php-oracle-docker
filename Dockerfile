FROM php:7.4-fpm

# --- зависимости ---
RUN apt-get update && apt-get install -y \
    unzip libaio1 libssl-dev libcurl4-openssl-dev libicu-dev build-essential wget && \
    rm -rf /var/lib/apt/lists/*

# --- Oracle Instant Client ---
COPY instantclient-basic-linux.x64-11.2.0.4.0.zip /tmp/
COPY instantclient-sdk-linux.x64-11.2.0.4.0.zip /tmp/

RUN mkdir -p /opt/oracle && cd /opt/oracle && \
    unzip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
    mv instantclient_* instantclient && \
    ln -s /opt/oracle/instantclient/libclntsh.so.11.1 /opt/oracle/instantclient/libclntsh.so && \
    echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# --- OCI8 ---
RUN echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8-2.2.0 && \
    docker-php-ext-enable oci8

# --- Oracle env ---
ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
ENV TNS_ADMIN=/opt/oracle/network/admin
ENV NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251

WORKDIR /var/www

CMD ["php-fpm"]

