#!/bin/bash

# Log dosyası yolu
LOG_FILE="/opt/meta/metalog.log"

# Son bilinen log boyutunu saklamak için geçici dosya
LAST_LOG_SIZE_FILE="/opt/meta/.last_log_size"

# Makineyi yeniden başlatma fonksiyonu
restart_machine() {
    echo "Yeni log kaydı bulunamadı. Makine yeniden başlatılıyor..."
    sudo reboot
}

# Log dosyasının mevcut boyutunu al
current_log_size=$(stat -c%s "$LOG_FILE")

# Son log boyutu dosyası mevcut değilse, oluştur
if [ ! -f "$LAST_LOG_SIZE_FILE" ]; then
    echo "$current_log_size" > "$LAST_LOG_SIZE_FILE"
    exit 0
fi

# Log dosyasının son bilinen boyutunu al
last_log_size=$(cat "$LAST_LOG_SIZE_FILE")

# Mevcut log boyutunu son bilinen boyutla karşılaştır 
if [ "$current_log_size" -eq "$last_log_size" ]; 
then restart_machine fi

# Log dosyasının son bilinen boyutunu güncelle
echo "$current_log_size" > "$LAST_LOG_SIZE_FILE"
