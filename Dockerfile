FROM php:8.3-apache

# System-Dependencies
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    libxml2-dev \
    unzip \
    git \
    default-mysql-client \
    && rm -rf /var/lib/apt/lists/*

# PHP Extensions für TYPO3
RUN docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) \
    intl \
    pdo_mysql \
    zip \
    gd \
    opcache \
    fileinfo

# Apache mod_rewrite
RUN a2enmod rewrite

# Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Apache DocumentRoot auf public setzen
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# AllowOverride für .htaccess
RUN sed -i '/<Directory \/var\/www\/>/,/<\/Directory>/ s/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

WORKDIR /var/www/html

# TYPO3 v14 mit Camino installieren
RUN composer create-project "typo3/cms-base-distribution:^14" . --no-interaction \
    && composer require typo3/theme-camino:^14 \
    && composer clear-cache

# Copy local packages
COPY packages/ /var/www/html/packages/

# Add local packages repository and install enhancely extension
RUN composer config repositories.local path './packages/*' \
    && composer require enhancely/enhancely:@dev \
    && composer clear-cache

# Create var directory and set permissions
RUN mkdir -p /var/www/html/var \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 /var/www/html/var \
    && chmod -R 775 /var/www/html/public

# Entrypoint für Setup beim ersten Start
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]
