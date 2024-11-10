Linux ortamında Cutecom programı kullanılarak Xmodem protokolü ile .bin dosyası güncellenecek.(requires the sz tools, install)

1.apt-get install lrzsz
2.sudo apt-get install cutecom lrzsz

*supervisorctl stop meta ile jar kapatılır
*Cutecom ekranı açılır, 
*Porta 115200 baudrate ile bağlanılır
*Protokol xmodem olarak secılır
*input kısmından bootloadera dallanmak için windows daki gibi herhangi bir tuşa basılır (HEX seçili ise 0-ff arası, none seçili ise herhangi karakter ile durdurulur.)
*send ile denemeAPP.bin seçilip atılır.
*Firware updated ve jumping çıktıları görülür.
*cutecom kapatılır ve meta.jar baslatılır.
