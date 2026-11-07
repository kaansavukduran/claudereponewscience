HUMAN OS - yerel deneme paketi / local try-out package
=======================================================

TURKCE
1. Bu klasoru bir yere cikar (ZIP'i "Tumunu ayikla").
2. Windows: "Human-OS-baslat.bat" dosyasina cift tikla.
   (Windows "bilinmeyen yayimci" derse: "Ek bilgi" > "Yine de calistir".
   Betik yalnizca senin bilgisayarinda, localhost uzerinde calisir.)
   Linux/macOS: terminalde  ./Human-OS-baslat.sh  (python3 gerekir).
3. Tarayicin acilir: http://localhost:8765/
4. Kapatmak icin acilan siyah/mavi pencereyi kapat.

Bilmen gerekenler
- Bu bir GELISTIRME surumudur: "klinik karar icin degil" seridi gorursun.
- Girdigin veriler yalnizca bu tarayicida, bu bilgisayarda saklanir ve
  SIFRELI DEGILDIR. Ayni tarayiciyi ve ayni adresi (8765) kullan; baska
  tarayicida ya da baska portta verilerini gormezsin.
- Verileri silmek: tarayici ayarlarindan "localhost icin site verilerini temizle".
- Hicbir sey internete gonderilmez.
- "Yedek olustur" dugmesi yedegi indirir; onu sakla.

ENGLISH
1. Extract this folder somewhere.
2. Windows: double-click "Human-OS-baslat.bat". Linux/macOS: ./Human-OS-baslat.sh
   (needs python3).
3. Your browser opens http://localhost:8765/ . Close the console window to stop.

Good to know
- This is a DEVELOPMENT build ("not for clinical decisions" strip).
- Your entries stay in this browser on this computer and are NOT encrypted.
  Use the same browser and the same address (port 8765) to see them again.
- To delete them, clear the site data for localhost in your browser.
- Nothing is sent over the network. "Create backup" downloads a file: keep it.
