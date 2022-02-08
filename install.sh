#!/bin/sh

echo "installing files for RUS2..."

\cp -f boot_scripts/rus2.sh /usr/local/bin/
\cp -f boot_scripts/rus2_update.sh /usr/local/bin/
\cp -rf html /var/www/

echo "finished."
