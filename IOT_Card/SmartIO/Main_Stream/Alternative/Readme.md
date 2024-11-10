Bu versiyonlar deneme amaçlı üretilmiştir.

* Tüm alternatif çözümlerde ortak adımlar 
 * 300ms den -> 500ms de bir veri basmaya çevrildi.
 * Girişlere göre anlık veri basma özelliği kaldırıldı, panel boğulmasın diye. Duruma göre 1 ms de bir arası veri bastığı oluyordu.
 * Başlangıçta bir kere verilerin setlenmesi yeterlidir, kart resetlenene kadar 0xFF talebi beklemez. Main stream ürününde 
    en geç 20 saniyede bir 0xff talebi bekliyordu eğer panelden gelmezse kendisine reset atıyordu, bu özellik olası hatalı kullanıma karşı kapatıldı.
    Reset ihtimallerine iyileştirmeler yapıldı.

-VERSIYON 1
* SmartIO_Stream_Regular.bin ;  82 byte olarak çalışır.


-VERSIYON 2
* SmartIO_Stream_Small.bin   ;  38 byte olarak çalışır.

   Eski protocol gibi rölelerden sonra mesaj sonu karakteri ile bitirilir.
  msg[0]=MESSAGE_HEAD;
  
	msg[1] = (HSC0_TOTAL & 0xff000000) >> 24;
	msg[2] = (HSC0_TOTAL & 0x00ff0000) >> 16;
	msg[3] = (HSC0_TOTAL & 0x0000ff00) >> 8;
	msg[4] = (HSC0_TOTAL & 0x000000ff);

	msg[5] = (HSC1_TOTAL & 0xff000000) >> 24;
	msg[6] = (HSC1_TOTAL & 0x00ff0000) >> 16;
	msg[7] = (HSC1_TOTAL & 0x0000ff00) >> 8;
	msg[8] = (HSC1_TOTAL & 0x000000ff);

	msg[9] = (HSC2_TOTAL & 0xff000000) >> 24;
	msg[10] = (HSC2_TOTAL & 0x00ff0000) >> 16;
	msg[11] = (HSC2_TOTAL & 0x0000ff00) >> 8;
	msg[12] = (HSC2_TOTAL & 0x000000ff);

	msg[13] = (HSC3_TOTAL & 0xff000000) >> 24;
	msg[14] = (HSC3_TOTAL & 0x00ff0000) >> 16;
	msg[15] = (HSC3_TOTAL & 0x0000ff00) >> 8;
	msg[16] = (HSC3_TOTAL & 0x000000ff);

	msg[17] = (HSC4_TOTAL & 0xff000000) >> 24;
	msg[18] = (HSC4_TOTAL & 0x00ff0000) >> 16;
	msg[19] = (HSC4_TOTAL & 0x0000ff00) >> 8;
	msg[20] = (HSC4_TOTAL & 0x000000ff);

	msg[21] = (HSC5_TOTAL & 0xff000000) >> 24;
	msg[22] = (HSC5_TOTAL & 0x00ff0000) >> 16;
	msg[23] = (HSC5_TOTAL & 0x0000ff00) >> 8;
	msg[24] = (HSC5_TOTAL & 0x000000ff);

	msg[25] = (HSC6_TOTAL & 0xff000000) >> 24;
	msg[26] = (HSC6_TOTAL & 0x00ff0000) >> 16;
	msg[27] = (HSC6_TOTAL & 0x0000ff00) >> 8;
	msg[28] = (HSC6_TOTAL & 0x000000ff);

	msg[29] = (HSC7_TOTAL & 0xff000000) >> 24;
	msg[30] = (HSC7_TOTAL & 0x00ff0000) >> 16;
	msg[31] = (HSC7_TOTAL & 0x0000ff00) >> 8;
	msg[32] = (HSC7_TOTAL & 0x000000ff);
  
	msg[33]=((retValHSC0) | (retValHSC1 << 1) | (retValHSC2 << 2) | (retValHSC3 << 3) | (retValHSC4  << 4) | (retValHSC5 << 5) | (retValHSC6 << 6) | (retValHSC7 << 7)) ; // HSC girişler
	
	msg[34]=((retValI0) | (retValI1 << 1) | (retValI2 << 2) | (retValI3 << 3) | (retValI4  << 4) | (retValI5 << 5) | (retValI6 << 6) | (retValI7 << 7)) ;
	
	msg[35]=digitalOutputs;
	
     msg[36]=((retValR1) | (retValR2 << 1)); // roleler
 
	msg[37]=MESSAGE_TAIL;
	
	
-VERSIYON 3
* SmartIO2_Urfa_Misket.bin   ;  86 byte olarak çalışır.

 	 msg[0]=MESSAGE_HEAD;
  
	msg[1] = (HSC0_TOTAL & 0xff000000) >> 24;
	msg[2] = (HSC0_TOTAL & 0x00ff0000) >> 16;
	msg[3] = (HSC0_TOTAL & 0x0000ff00) >> 8;
	msg[4] = (HSC0_TOTAL & 0x000000ff);

	msg[5] = (HSC1_TOTAL & 0xff000000) >> 24;
	msg[6] = (HSC1_TOTAL & 0x00ff0000) >> 16;
	msg[7] = (HSC1_TOTAL & 0x0000ff00) >> 8;
	msg[8] = (HSC1_TOTAL & 0x000000ff);

	msg[9] = (HSC2_TOTAL & 0xff000000) >> 24;
	msg[10] = (HSC2_TOTAL & 0x00ff0000) >> 16;
	msg[11] = (HSC2_TOTAL & 0x0000ff00) >> 8;
	msg[12] = (HSC2_TOTAL & 0x000000ff);

	msg[13] = (HSC3_TOTAL & 0xff000000) >> 24;
	msg[14] = (HSC3_TOTAL & 0x00ff0000) >> 16;
	msg[15] = (HSC3_TOTAL & 0x0000ff00) >> 8;
	msg[16] = (HSC3_TOTAL & 0x000000ff);

	msg[17] = (HSC4_TOTAL & 0xff000000) >> 24;
	msg[18] = (HSC4_TOTAL & 0x00ff0000) >> 16;
	msg[19] = (HSC4_TOTAL & 0x0000ff00) >> 8;
	msg[20] = (HSC4_TOTAL & 0x000000ff);

	msg[21] = (HSC5_TOTAL & 0xff000000) >> 24;
	msg[22] = (HSC5_TOTAL & 0x00ff0000) >> 16;
	msg[23] = (HSC5_TOTAL & 0x0000ff00) >> 8;
	msg[24] = (HSC5_TOTAL & 0x000000ff);

	msg[25] = (HSC6_TOTAL & 0xff000000) >> 24;
	msg[26] = (HSC6_TOTAL & 0x00ff0000) >> 16;
	msg[27] = (HSC6_TOTAL & 0x0000ff00) >> 8;
	msg[28] = (HSC6_TOTAL & 0x000000ff);

	msg[29] = (HSC7_TOTAL & 0xff000000) >> 24;
	msg[30] = (HSC7_TOTAL & 0x00ff0000) >> 16;
	msg[31] = (HSC7_TOTAL & 0x0000ff00) >> 8;
	msg[32] = (HSC7_TOTAL & 0x000000ff);
  
	msg[33]=((retValHSC0) | (retValHSC1 << 1) | (retValHSC2 << 2) | (retValHSC3 << 3) | (retValHSC4  << 4) | (retValHSC5 << 5) | (retValHSC6 << 6) | (retValHSC7 << 7)) ; // HSC girişler
	
	msg[34]=((retValI0) | (retValI1 << 1) | (retValI2 << 2) | (retValI3 << 3) | (retValI4  << 4) | (retValI5 << 5) | (retValI6 << 6) | (retValI7 << 7)) ;
	
	msg[35]=digitalOutputs;
	
        msg[36]=((retValR1) | (retValR2 << 1)); // roleler
	
	
      int msgindex=37;
      for(xz=0; xz < MISKET_TYPE_COUNT ; xz++) (MISKET_TYPE_COUNT 12 adet)
      {
		msg[msgindex++] = (MISKETS_COUNT[xz] & 0xff000000) >> 24;
		msg[msgindex++] = (MISKETS_COUNT[xz] & 0x00ff0000) >> 16;
		msg[msgindex++] = (MISKETS_COUNT[xz] & 0x0000ff00) >> 8;
		msg[msgindex++] = (MISKETS_COUNT[xz] & 0x000000ff);
       }

       msg[85]=MESSAGE_TAIL;
       
       
     
