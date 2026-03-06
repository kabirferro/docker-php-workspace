#!/bin/bash
set -e

# Generate virtual hosts automatically
/usr/local/bin/generate-vhosts.sh

# Start Apache
exec "$@"
