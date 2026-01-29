#!/bin/bash
set -e

# Warte auf MySQL
echo "Waiting for database connection..."
until mysql -h"$TYPO3_DB_HOST" -u"$TYPO3_DB_USERNAME" -p"$TYPO3_DB_PASSWORD" -e "SELECT 1" &> /dev/null; do
    echo "Database not ready yet, waiting..."
    sleep 2
done
echo "Database is ready!"

# TYPO3 Setup nur beim ersten Start
if [ ! -f /var/www/html/var/.installed ]; then
    echo "Running TYPO3 setup..."
    
    cd /var/www/html
    
    ./vendor/bin/typo3 setup \
        --no-interaction \
        --server-type=apache \
        --driver=pdoMysql \
        --host="$TYPO3_DB_HOST" \
        --port="${TYPO3_DB_PORT:-3306}" \
        --dbname="$TYPO3_DB_NAME" \
        --username="$TYPO3_DB_USERNAME" \
        --password="$TYPO3_DB_PASSWORD" \
        --admin-username="${TYPO3_ADMIN_USERNAME:-admin}" \
        --admin-email="${TYPO3_ADMIN_EMAIL:-admin@example.com}" \
        --admin-user-password="${TYPO3_ADMIN_PASSWORD:-Admin123!}" \
        --project-name="${TYPO3_PROJECT_NAME:-TYPO3 Camino Demo}"

    # Site Configuration mit Camino erstellen
    mkdir -p /var/www/html/config/sites/main
    cat > /var/www/html/config/sites/main/config.yaml << EOF
base: '${TYPO3_BASE_URL:-/}'
rootPageId: 1
dependencies:
  - typo3/theme-camino
languages:
  -
    title: English
    enabled: true
    languageId: 0
    base: /
    locale: en_US.UTF-8
    navigationTitle: English
    flag: us
errorHandling: []
EOF

    # Set root page as site root (required for site configuration to work)
    echo "Setting page 1 as site root..."
    mysql -h"$TYPO3_DB_HOST" -u"$TYPO3_DB_USERNAME" -p"$TYPO3_DB_PASSWORD" "$TYPO3_DB_NAME" \
        -e "UPDATE pages SET is_siteroot=1 WHERE uid=1;"

    # Reverse Proxy Konfiguration (für SSL-terminierende Proxies wie nginx)
    if [ -n "${TYPO3_REVERSE_PROXY_IP:-}" ]; then
        echo "Configuring reverse proxy IP: $TYPO3_REVERSE_PROXY_IP"
        php -r '
            $settings = include "/var/www/html/config/system/settings.php";
            $settings["SYS"]["reverseProxyIP"] = getenv("TYPO3_REVERSE_PROXY_IP");
            file_put_contents(
                "/var/www/html/config/system/settings.php",
                "<?php\nreturn " . var_export($settings, true) . ";\n"
            );
        '
    fi

    # Permissions setzen
    chown -R www-data:www-data /var/www/html/config
    chown -R www-data:www-data /var/www/html/var
    chown -R www-data:www-data /var/www/html/public/fileadmin

    touch /var/www/html/var/.installed
    echo "============================================"
    echo "TYPO3 setup complete!"
    echo "Frontend: ${TYPO3_BASE_URL:-http://localhost}"
    echo "Backend:  ${TYPO3_BASE_URL:-http://localhost}/typo3"
    echo "Username: ${TYPO3_ADMIN_USERNAME:-admin}"
    echo "Password: ${TYPO3_ADMIN_PASSWORD:-Admin123!}"
    echo "============================================"
else
    echo "TYPO3 already installed, skipping setup."
fi

exec "$@"
