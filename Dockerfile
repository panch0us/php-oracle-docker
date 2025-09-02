FROM php:7.4-cli

# Добавляем архитектуру i386 и устанавливаем 32-битные инструменты
RUN dpkg --add-architecture i386 && \
    apt-get update && \
    apt-get install -y \
    libaio1:i386 \
    unzip \
    libstdc++6:i386 \
    libgcc1:i386 \
    gcc-multilib \
    g++-multilib \
    && rm -rf /var/lib/apt/lists/*

# Копируем локальные файлы Oracle (32-битные)
COPY instantclient-basiclite-linux-11.2.0.4.0.zip /tmp/
COPY instantclient-sdk-linux-11.2.0.4.0.zip /tmp/

# Распаковываем Oracle клиент
RUN cd /tmp && \
    unzip -q instantclient-basiclite-linux-11.2.0.4.0.zip -d /usr/local/ && \
    unzip -q instantclient-sdk-linux-11.2.0.4.0.zip -d /usr/local/ && \
    rm -f /tmp/*.zip

# Проверяем архитектуру библиотек
RUN echo "Архитектура библиотек:" && \
    file /usr/local/instantclient_11_2/libclntsh.so.11.1

# Настраиваем ссылки и библиотеки
RUN ln -s /usr/local/instantclient_11_2/libclntsh.so.11.1 /usr/local/instantclient_11_2/libclntsh.so && \
    echo '/usr/local/instantclient_11_2' > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    ldconfig

# Копируем заголовочные файлы из SDK
RUN cp -r /usr/local/instantclient_11_2/sdk/include/* /usr/local/instantclient_11_2/ 2>/dev/null || true

# Устанавливаем OCI8 расширение с явным указанием 32-битных флагов
RUN export CFLAGS="-m32" && \
    export LDFLAGS="-L/usr/local/instantclient_11_2 -m32" && \
    docker-php-ext-configure oci8 --with-oci8=instantclient,/usr/local/instantclient_11_2 && \
    docker-php-ext-install oci8

# Переменные окружения
ENV LD_LIBRARY_PATH=/usr/local/instantclient_11_2
ENV ORACLE_HOME=/usr/local/instantclient_11_2
ENV TNS_ADMIN=/usr/local/instantclient_11_2/network/admin
