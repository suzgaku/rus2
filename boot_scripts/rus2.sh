#!/bin/sh

echo "RUS2 auto setting..."

shut_flag=0

# USBメモリ(/storage)が見つかるまで待ち。ない場合は終了。
echo "Detecting USB-memory..."
for i in `seq 1 20`
do
    out=`ls /storage `
    if [ "$out" = "/storage" ]; then
        echo "Success."
        break
    fi
    echo "wait"
    sleep 1
done
if [ "${i}" = 20 ]; then
    echo "Not detect."
    exit 0
fi

echo "storage detected."

# オリジナルのWIFI設定ファイルを保存
out=`ls /etc/wpa_supplicant/org_wpa_supplicant.conf `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" != "/" ]; then
    echo "Copying original WIFI file."
    cp /etc/wpa_supplicant/wpa_supplicant.conf /etc/wpa_supplicant/org_wpa_supplicant.conf
fi

# USBメモリに rus_wifi.txt がある場合は、wifi設定をする
out=`ls /storage/rus_wifi.txt `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" = "/" ]; then
    echo "Setting WIFI file from storage."
    \cp -f /etc/wpa_supplicant/org_wpa_supplicant.conf /etc/wpa_supplicant/wpa_supplicant.conf
    cat /storage/rus_wifi.txt >> /etc/wpa_supplicant/wpa_supplicant.conf
    mv /storage/rus_wifi.txt /storage/_rus_wifi.txt
    shut_flag=1
fi

# USBメモリに rus_hostname.txt がある場合は、host名を変更する
out=`ls /storage/rus_hostname.txt `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" = "/" ]; then
    echo "Setting Hostname from USB-memory."
    out=`head -n 1 /storage/rus_hostname.txt `
    if [ "${#out}" -gt 3 ]; then
        raspi-config nonint do_hostname ${out}
        mv /storage/rus_hostname.txt /storage/_rus_hostname.txt
        shut_flag=1
    fi
fi
# USBメモリに rus_resize.txt がある場合は、sd-cardの容量を拡張する
out=`ls /storage/rus_resize.txt `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" = "/" ]; then
    echo "Expand area of SD-Card."
    raspi-config nonint do_expand_rootfs > /storage/_rus_resize.txt
    rm  /storage/rus_resize.txt
    shut_flag=1
fi

# USBメモリに rus_ifconfig.txt がある場合は、ifconfigの結果を格納する
out=`ls /storage/rus_ifconfig.txt `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" = "/" ]; then
    echo "Writing ifconfig to USB-memory."
    ifconfig > /storage/rus_ifconfig.txt
    mv /storage/rus_ifconfig.txt /storage/_rus_ifconfig.txt
    shut_flag=1
fi

# USBメモリに rus_update.txt がある場合は、アップデートを行う
out=`ls /storage/rus_update.txt `
out_cut=`echo ${out} | cut -c 1-1 `
if [ "$out_cut" = "/" ]; then
    echo "Update RUS2 software."
    cd /tmp
    rm main.zip
    wget https://github.com/suzgaku/rus2/archive/main.zip
    unzip -o main.zip
    \cp -f rus2-main/boot_scripts/rus2_update.sh /usr/local/bin/
    mv /storage/rus_update.txt /storage/_rus_update.txt
fi

if [ "$shut_flag" = 1 ]; then
    echo "shutdown after 20seconds."
    sync
    sleep 20
    shutdown -h now 
    exit 1
fi

echo "Finished RUS2 auto setting."
exit 0
