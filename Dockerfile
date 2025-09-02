FROM php:7.4-cli

# --- Зависимости ---
RUN apt-get update && apt-get install -y \
    unzip libaio1 libssl-dev libcurl4-openssl-dev libicu-dev build-essential wget && \
    rm -rf /var/lib/apt/lists/*

# --- Oracle Instant Client 64-bit ---
COPY instantclient-basic-linux.x64-11.2.0.4.0.zip /tmp/
COPY instantclient-sdk-linux.x64-11.2.0.4.0.zip /tmp/

RUN mkdir -p /opt/oracle && cd /opt/oracle && \
    unzip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
    mv instantclient_* instantclient && \
    ln -s /opt/oracle/instantclient/libclntsh.so.11.1 /opt/oracle/instantclient/libclntsh.so && \
    echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf && ldconfig

# --- Устанавливаем OCI8 через pecl (PEAR уже внутри образа) ---
RUN echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8-2.2.0 && \
    docker-php-ext-enable oci8

# --- Переменные окружения Oracle ---
ENV ORACLE_HOME=/opt/oracle/instantclient
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
ENV TNS_ADMIN=/opt/oracle/network/admin

WORKDIR /var/www

CMD ["php", "-a"]

