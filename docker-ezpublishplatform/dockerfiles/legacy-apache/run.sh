#!/bin/bash
set -xe

# Default variables
source /usr/local/share/postfix-variables.sh

# Start confd
confd -onetime -backend env

# Start supervisord for email sending
/usr/bin/supervisord -c /etc/supervisor/supervisord.conf &

# Run Apache
exec /var/www/external/ezp-toolkit/docker-ezpublishplatform/dockerfiles/legacy-apache/apache/run.sh
