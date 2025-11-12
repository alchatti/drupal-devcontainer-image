#!/usr/bin/env bash
set -euo pipefail

echo "📌 Entrypoint running as: $(whoami)"

echo "🔧 Applying runtime configuration..."

# -----------------------------
# PHP Configuration
# -----------------------------
# Write runtime INI to the per-user PHP conf.d (set up in Dockerfile)
RUNTIME_PHP_INI="$PHP_INI_DIR/conf.d/zz-x-docker-dev-php.ini"

cat > "$RUNTIME_PHP_INI" <<EOF
; # PHP Configurations - Static
; file_uploads = On
max_input_vars = 6000
max_multipart_body_parts = 12000
max_input_nesting_level = 1200
display_errors = on
; session.cookie_secure = 0

; # Xdebug
; vscode default xdebug port
xdebug.client_port =${XDEBUG_CLIENT_PORT:-9003}

; # PHP Configurations - From Environment Variables (with defaults)
memory_limit=${PHP_MEMORY_LIMIT:--1}
upload_max_filesize=${PHP_UPLOAD_MAX_FILESIZE:-100M}
post_max_size=${PHP_POST_MAX_SIZE:-100M}
max_execution_time=${PHP_MAX_EXECUTION_TIME:-300}

[opcache]
opcache.enable=1
opcache.memory_consumption=${OPCACHE_MEMORY_CONSUMPTION:-256}
opcache.max_accelerated_files=${OPCACHE_MAX_ACCELERATED_FILES:-10000}
opcache.validate_timestamps=${OPCACHE_VALIDATE_TIMESTAMPS:-1}
EOF

echo "✅ PHP configured (memory_limit=${PHP_MEMORY_LIMIT}), written to ${RUNTIME_PHP_INI}"
# -----------------------------
# Verify Redis & Imagick
# -----------------------------
echo "🧩 Verifying extensions..."
php -m | grep -E 'redis|imagick' || echo "⚠️  Redis/Imagick not detected"

# -----------------------------
# Setting Apache
# -----------------------------
echo "⚙️  Setting Apache..."
# Ensure defaults (allow APACHE_DOCUMENT_ROOT to be empty)
: "${WORKSPACE_ROOT:=${WORKSPACE_ROOT}}"
: "${APACHE_DOCUMENT_ROOT:=}"
: "${APACHE_SERVER_NAME:=localhost}"

# Compute effective DocumentRoot (if APACHE_DOCUMENT_ROOT empty -> use WORKSPACE_ROOT)
if [ -n "${APACHE_DOCUMENT_ROOT}" ]; then
	DOCROOT="${WORKSPACE_ROOT%/}/${APACHE_DOCUMENT_ROOT#'/'}"
else
	DOCROOT="${WORKSPACE_ROOT%/}"
fi

# Create a minimal 000-default.conf into sites-enabled so Apache will use it
VHOST_FILE="/etc/apache2/sites-enabled/000-default.conf"
cat > "$VHOST_FILE" <<EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost

		DocumentRoot ${DOCROOT}

		<Directory "${DOCROOT}">
				Options Indexes FollowSymLinks
				AllowOverride All
				Require all granted
		</Directory>

        ErrorLog /var/log/apache2/error.log
		CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

echo "ℹ️  Runtime DocumentRoot=${DOCROOT}"

# -----------------------------
# Start Apache
# -----------------------------
echo "🚀 Starting Apache..."
# Start Apache in the background and forward logs to Docker stdout/stderr
if command -v apachectl >/dev/null 2>&1; then
	echo "🔁 Starting Apache in background..."
	apachectl -k start || { echo "❌ Failed to start Apache"; exit 1; }
else
	echo "⚠️ apachectl not found; attempting apache2ctl"
	apache2ctl -k start || { echo "❌ Failed to start Apache via apache2ctl"; exit 1; }
fi

# Back to Shell
echo "👤 Dropping privileges to user: vscode"
exec gosu vscode "$@"
