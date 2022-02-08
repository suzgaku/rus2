#!/bin/sh
out=`ls /tmp/rus2-main/install.sh `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" = "/" ]; then
    echo "RUS2 update..."
    cd /tmp/rus2-main
    ./install.sh
    cd ..
    rm -rf rus2-main
    rm -rf main.zip
    echo "shutdown after 20seconds....."
    sync
    sleep 20
    shutdown -h now 
fi
