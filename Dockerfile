# Базовый образ: официальный образ PHP 7.4 с FPM (FastCGI Process Manager)
FROM php:7.4-fpm

# --- Установка системных зависимостей ---
# Обновление списка пакетов и установка необходимых библиотек и утилит
RUN apt-get update && apt-get install -y \
    # unzip - для распаковки архивов Oracle Instant Client
    unzip \
    # libaio1 - асинхронный I/O, необходим для работы Oracle Client
    libaio1 \
    # libssl-dev - разработческие файлы OpenSSL, нужны для сборки расширений
    libssl-dev \
    # libcurl4-openssl-dev - разработческие файлы cURL с поддержкой OpenSSL
    libcurl4-openssl-dev \
    # libicu-dev - разработческие файлы International Components for Unicode
    libicu-dev \
    # build-essential - базовые инструменты для компиляции (gcc, make и др.)
    build-essential \
    # wget - утилита для загрузки файлов из интернета
    wget && \
    # Очистка кэша пакетов для уменьшения размера образа
    rm -rf /var/lib/apt/lists/*

# --- Копирование Oracle Instant Client ---
# Копирование ZIP-архивов базового пакета и SDK Oracle Instant Client
# в временную директорию /tmp внутри контейнера
COPY instantclient-basic-linux.x64-11.2.0.4.0.zip /tmp/
COPY instantclient-sdk-linux.x64-11.2.0.4.0.zip /tmp/

# --- Установка и настройка Oracle Instant Client ---
RUN mkdir -p /opt/oracle && cd /opt/oracle && \
    # Распаковка базового пакета Oracle Instant Client
    unzip /tmp/instantclient-basic-linux.x64-11.2.0.4.0.zip && \
    # Распаковка SDK пакета Oracle Instant Client
    unzip /tmp/instantclient-sdk-linux.x64-11.2.0.4.0.zip && \
    # Переименование директории instantclient_* в instantclient для удобства
    mv instantclient_* instantclient && \
    # Создание символической ссылки для совместимости версий
    # libclntsh.so.11.1 -> libclntsh.so (требуется для OCI8)
    ln -s /opt/oracle/instantclient/libclntsh.so.11.1 /opt/oracle/instantclient/libclntsh.so && \
    # Добавление пути к библиотекам Oracle в конфигурацию динамического linker'а
    echo "/opt/oracle/instantclient" > /etc/ld.so.conf.d/oracle-instantclient.conf && \
    # Обновление кэша shared libraries (чтобы система нашла Oracle библиотеки)
    ldconfig

# --- Установка расширения OCI8 для PHP ---
# Установка PECL расширения oci8 с указанием пути к Instant Client
RUN echo 'instantclient,/opt/oracle/instantclient' | pecl install oci8-2.2.0 && \
    # Включение установленного расширения в PHP
    docker-php-ext-enable oci8

# --- Настройка переменных окружения для Oracle ---
# ORACLE_HOME - корневая директория Oracle Client
ENV ORACLE_HOME=/opt/oracle/instantclient
# LD_LIBRARY_PATH - пути для поиска shared libraries
ENV LD_LIBRARY_PATH=/opt/oracle/instantclient
# TNS_ADMIN - директория с конфигурационными файлами Oracle (tnsnames.ora, sqlnet.ora)
ENV TNS_ADMIN=/opt/oracle/network/admin
# NLS_LANG - настройки языковой среды и кодировки для Oracle
# AMERICAN_AMERICA - язык и территория
# CL8MSWIN1251 - кодировка Windows-1251 для кириллицы
ENV NLS_LANG=AMERICAN_AMERICA.CL8MSWIN1251

# --- Установка рабочей директории ---
# Рабочая директория для приложения (тома будут монтироваться сюда)
WORKDIR /var/www

# --- Команда по умолчанию при запуске контейнера ---
# Запуск PHP-FPM процессора в foreground режиме
CMD ["php-fpm"]
