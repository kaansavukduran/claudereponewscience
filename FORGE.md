# Human OS: son doğrulanmış devir

- Forge: U022 tamamlandı (9 Kasım 2026).
- Depo: https://github.com/kaansavukduran/human-os
- Dal: `codex/forge-u022-accessibility`; uygulama kaynak commit'i: `5ef84d30079876c7c7f9f823bac1594000fb71e1`.
- Açılış: uygulamadaki Ayarlar → Görünüm ve erişilebilirlik → Arayüz ölçeği. %80–%200, kaydırıcı, kesin yüzde, hazır seçenekler ve yalnız ölçeği sıfırlama.
- Bugün ekranındaki isteğe bağlı Human OS keşfi yalnızca açılmış araçları birer kez sayar; Ayarlar'dan kapatılabilir. Sağlık kayıtlarını değiştirmez.
- Doğrulama: 637 Flutter testi geçti, 1 mevcut test atlandı; analiz, biçimlendirme, web derleme, 24 görünüm tarayıcı kontrolü, normal uygulama tarayıcı akışı, sözleşmeler ve TypeScript testleri geçti. Makine kayıtları `evidence/`, ekran görüntüleri `reports/runtime/u022-final/` içinde.
- İmzalı beş platform kurulumu ve iki gerçek paketle güncelleyici doğrulaması tamamlanmadı. Web ayarları mevcut politikaya göre oturumluk. Yeni Release yayımlanmadı.
- GitHub Actions kaynak gönderildikten sonra platform derlemelerini doğrular; canlı PR/Actions sonucunu yeniden kontrol et.
- Drive: kaynak/Git yedeği hazırlanacak. Özel hedefin altındaki human-os klasörü doğrulandı; otomatik onay incelemesi yüklemeyi reddetti, açık aktarım onayı bekliyor.
- Sıradaki tek Forge: R007, G007 UniProt güvenlik/dil ve gerçek TSV başlığı incelemesi.

Ayrıntılı ve kanonik durum: `project_state/CURRENT_STATE.json`, `project_state/FORGE_LOG.md`. Kullanıcı tercihleri: `AGENTS.md`.
