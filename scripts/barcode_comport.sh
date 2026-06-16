#!/bin/bash

VENDOR_ID="1a86" # BARCODE cihazının vendor ID'si -- udevadm info -a -n /dev/ttyACM1 | grep '{idVendor}' | head -n1

 sudo chmod 777 /opt/meta/meta.jar;
 sudo chmod 777 /dev/tty*;
 sudo chown -R "meta" /opt/meta/*;
 sudo chown -R "meta" /dev/tty*;
 
# /dev/ttyACM* ve /dev/ttyUSB* cihazları için döngü oluştur
for DEVICE in /dev/ttyUSB*; do
    # Cihazın vendor ID'sini kontrol et
    if udevadm info --query=property --name=$DEVICE | grep -q "ID_VENDOR_ID=$VENDOR_ID"; then
        # Cihazın product ID'sini al
        PRODUCT_ID=$(udevadm info --query=property --name=$DEVICE | grep "ID_MODEL_ID" | cut -d'=' -f2)
        
        if [ ! -z "$PRODUCT_ID" ]; then
            echo "BARCODE device found: $DEVICE with PRODUCT_ID=$PRODUCT_ID"
            
            # Udev kuralını tanımla
            RULE="SUBSYSTEM==\"tty\", ATTRS{idVendor}==\"$VENDOR_ID\", ATTRS{idProduct}==\"$PRODUCT_ID\", TEST==\"power/control\", SYMLINK+=\"msfbarcode\""
            
            # Udev kuralını dosyaya yaz
            echo "$RULE" > /etc/udev/rules.d/msf_barcode_card_setting.rules
            
            # Udev kurallarını yeniden yükle
            echo "Reloading udev rules..."
            udevadm control --reload-rules && udevadm trigger
            
            echo "Udev rule for BARCODE device $DEVICE with PRODUCT_ID=$PRODUCT_ID is created."
            exit 0 # İlk uygun cihaz için kural oluşturulduktan sonra çık
        fi
    fi
done

echo "No BARCODE device with vendor ID $VENDOR_ID found. Exiting."
exit 1