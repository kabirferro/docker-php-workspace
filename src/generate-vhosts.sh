#!/bin/bash

VHOSTS_DIR="/usr/local/apache2/conf/extra/vhosts"
PROJECTS_DIR="/var/www/html"

# Default PHP backend (php82)
FPM_HOST="php82"
FPM_PORT="9000"

# Scan each project directory
for PROJECT_DIR in "$PROJECTS_DIR"/*; do
    if [ -d "$PROJECT_DIR" ]; then
        PROJECT_NAME=$(basename "$PROJECT_DIR")
        VHOST_NAME="${PROJECT_NAME}.test"
        VHOST_PROJECT_DIR="$VHOSTS_DIR/$VHOST_NAME"
        VHOST_CONF="$VHOST_PROJECT_DIR/vhost.conf"
        
        # Create directory for the domain
        mkdir -p "$VHOST_PROJECT_DIR"
        
        # Detect document root (public, public_html or project root)
        if [ -d "$PROJECT_DIR/public" ]; then
            DOC_ROOT="/var/www/html/$PROJECT_NAME/public"
        elif [ -d "$PROJECT_DIR/public_html" ]; then
            DOC_ROOT="/var/www/html/$PROJECT_NAME/public_html"
        else
            DOC_ROOT="/var/www/html/$PROJECT_NAME"
        fi
        
        # SSL certificate paths inside the domain directory
        SSL_CERT="$VHOST_PROJECT_DIR/cert.crt"
        SSL_KEY="$VHOST_PROJECT_DIR/cert.key"
        
        # Generate self-signed certificate if not present
        if [ ! -f "$SSL_CERT" ] || [ ! -f "$SSL_KEY" ]; then
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                -keyout "$SSL_KEY" \
                -out "$SSL_CERT" \
                -subj "/C=IT/ST=Italy/L=Local/O=Dev/CN=${VHOST_NAME}" \
                -addext "subjectAltName=DNS:${VHOST_NAME},DNS:www.${VHOST_NAME}" \
                2>/dev/null
        fi
        
        # Generate vhost only if it does not exist yet (preserves manual edits)
        if [ ! -f "$VHOST_CONF" ]; then
            cat > "$VHOST_CONF" <<EOF
<VirtualHost *:80>
    ServerName $VHOST_NAME
    DocumentRoot $DOC_ROOT

    <Directory $DOC_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    # Proxy PHP requests to PHP
    <FilesMatch \.(php|inc)$>
        SetHandler "proxy:fcgi://$FPM_HOST:$FPM_PORT"
    </FilesMatch>

    ErrorLog /usr/local/apache2/conf/extra/vhosts/$VHOST_NAME/error.log
    CustomLog /usr/local/apache2/conf/extra/vhosts/$VHOST_NAME/access.log combined
</VirtualHost>

# SSL Virtual Host
<VirtualHost *:443>
    ServerName $VHOST_NAME
    DocumentRoot $DOC_ROOT

    SSLEngine on
    SSLCertificateFile /usr/local/apache2/conf/extra/vhosts/$VHOST_NAME/cert.crt
    SSLCertificateKeyFile /usr/local/apache2/conf/extra/vhosts/$VHOST_NAME/cert.key

    <Directory $DOC_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    <FilesMatch \.(php|inc)$>
        SetHandler "proxy:fcgi://$FPM_HOST:$FPM_PORT"
    </FilesMatch>

    ErrorLog /usr/local/apache2/conf/extra/vhosts/$VHOST_NAME/ssl_error.log
    CustomLog /usr/local/apache2/conf/extra/vhosts/$VHOST_NAME/ssl_access.log combined
</VirtualHost>
EOF
            echo "✓ Generated vhost for $VHOST_NAME (PHP 8.2 default)"
        else
            echo "○ Skipped $VHOST_NAME - vhost.conf already exists (manual config preserved)"
        fi
    fi
done

echo "Virtual hosts generation completed!"
