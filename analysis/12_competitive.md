# Competitive Analysis Raporu (Hızlı Tarama)
> flutter_feedback_kit | Sonnet 4.6 | 2026-03-30

---

## Mevcut Durumumuz

**flutter_feedback_kit v0.1.0** — Pluggable backend mimarisiyle in-app feedback toplama paketi.

Mevcut özellikler:
- `FeedbackButton` (FAB) ve `FeedbackWidget` (form) bileşenleri
- Kategori seçimi: Bug, Suggestion, UI/UX, Performance, Other
- Opsiyonel ekran görüntüsü ekleme (max 3 adet)
- `FeedbackBackend` interface — kendi backend'ini getir (BYOB)
- Yerleşik `WebhookBackend` (Slack, Discord, herhangi bir HTTP endpoint)
- Bağımlılıklar: `http`, `image_picker`

---

## Rakip Paketler

| Paket | Beğeni | Pub Puanı | Haftalık İndirme | Versiyon | Son Güncelleme | Temel Özellikler |
|-------|--------|-----------|-----------------|----------|----------------|-----------------|
| **feedback** | 1.640 | 150 | 24.900 | 3.2.0 | 2025 Temmuz | Screenshot annotation, çizim araçları, GitLab/Sentry plugin, Flutter Favorite |
| **wiredash** | 300 | 70 | 11.100 | 2.6.0 | 2025 | NPS anketi, gerçek zamanlı analitik, GDPR uyumlu, dashboard |
| **rate_my_app** | 626 | 140 | 24.400 | 2.3.2 | 2025 | App store yönlendirme, koşullu soru, yıldız diyaloğu |
| **in_app_review** | 2.400 | - | 629.500 | - | 2025 Ağustos | Native iOS/Android/macOS sistem yorum diyaloğu |
| **flutter_app_feedback** | 3 | 140 | 36 | 0.0.4 | 4 yıl önce | Firebase backend, ekran görüntüsü, cihaz bilgisi |
| **in_app_feedback** | 3 | 150 | 7 | 0.0.1+5 | 2 yıl önce | GitHub issue, SendGrid email, bottom sheet |
| **flutter_usabilla** | 26 | 150 | 41.000 | 2.5.0 | Aktif | Usabilla SDK wrapper, kurumsal |

---

## Feature Gap Analizi

| Özellik | flutter_feedback_kit | feedback | wiredash | rate_my_app | in_app_review |
|---------|---------------------|----------|----------|-------------|---------------|
| Screenshot annotation/çizim | Yok | **Var** | Var (etiket) | Yok | Yok |
| Pluggable backend | **Var** | Kısmi (plugin ile) | Yok (SaaS) | Yok | Yok |
| Webhook (Slack/Discord) | **Var** | Yok (DIY) | Yok | Yok | Yok |
| Firebase entegrasyonu | Yok | Yok (DIY) | Yok | Yok | Yok |
| NPS/Anket | Yok | Yok | **Var** | Kısmi | Yok |
| App store yönlendirme | Yok | Yok | Yok | **Var** | **Var** |
| Kategori seçimi | **Var** | Yok | Yok | Yok | Yok |
| Analitik dashboard | Yok | Yok | **Var** | Yok | Yok |
| GDPR uyumluluk | Bilinmiyor | Yok | **Var** | Yok | Yok |
| Ücretsiz | **Evet** | **Evet** | Kısmi (freemium) | **Evet** | **Evet** |
| Kurumsal (backend agnostik) | **Var** | Yok | Yok | Yok | Yok |
| Cihaz/platform bilgisi | Var (platform) | Yok | Var | Yok | Yok |
| Flutter Favorite | Yok | **Var** | Yok | Yok | Yok |
| Tüm platformlar | Yok (mobile-first) | **Var** | **Var** | Mobile | Mobile/macOS |

---

## Güçlü Yanlarımız

1. **Backend agnostik mimari:** Hiçbir rakip "kendi backend'ini getir" felsefesiyle tasarlanmamış. `feedback` eklentilerle geçici çözüm sunar; `wiredash` SaaS bağımlıdır.
2. **Webhook yerleşik:** Slack/Discord entegrasyonu kutudan çıkar. Rakipler bunu manuel olarak yapmak zorunda.
3. **Kategori sistemi:** Standart kategori ayrımı (Bug, UI/UX, Performance vb.) hiçbir doğrudan rakipte yok.
4. **Sıfır SaaS bağımlılığı:** `wiredash` veya `flutter_usabilla` gibi harici servis gerektirmez; self-hosted/kendi altyapın.
5. **Hafif bağımlılık:** Sadece `http` + `image_picker` — rakiplere göre minimal.

---

## Zayıf Yanlarımız

1. **Screenshot annotation yok:** `feedback` paketinin en güçlü özelliği bu; görsel geri bildirim çok daha değerli.
2. **Sıfır topluluk / pub puanı:** v0.1.0, henüz pub.dev'de yok; rakipler binlerce beğeniyle kurulu.
3. **Analitik yok:** Feedback verilerini görselleştirme/izleme mekanizması yok.
4. **NPS yok:** `wiredash`'ın en çekici özelliği olan Net Promoter Score anket sistemi eksik.
5. **Sadece mobile:** Web/Desktop desteği henüz yok; `feedback` ve `wiredash` tüm platformlarda çalışıyor.
6. **Firebase, Sentry, Jira backend yok:** Yerleşik popüler backend entegrasyonları eksik.

---

## Diferansiasyon Fırsatları

### Yüksek Öncelik (Hızlı Kazanım)

1. **Built-in backend'ler ekle (Firebase, Sentry, Jira)**
   - `flutter_feedback_kit_firebase`, `flutter_feedback_kit_sentry` gibi opsiyonel paketler
   - `feedback` bu modeli plugin ekosistemiyle başarıyla uyguluyor
   - Bizim avantajımız: backend interface zaten var, sadece implementasyon lazım

2. **Screenshot annotation**
   - `feedback`'in temel avantajı bu — basit çizim araçları eklenebilir
   - Mevcut `image_picker` altyapısı genişletilebilir

3. **Metadata zenginleştirme**
   - Otomatik cihaz bilgisi, OS versiyonu, uygulama versiyonu, kullanıcı ID alanları
   - `flutter_app_feedback` bunu yapıyor ama bakımsız

### Orta Öncelik (Ekosistem Büyütme)

4. **Pub.dev yayını + Flutter Favorite yolculuğu**
   - Mevcut paketin en büyük eksiği yayınlanmamış olması
   - İyi README, örnek uygulama, 130+ pub puanı hedefi

5. **Web + Desktop desteği**
   - `image_picker` web'de sınırlı — alternatif yaklaşım gerekli
   - Ancak tüm platform desteği paket kalitesini önemli ölçüde artırır

6. **NPS/CSAT anket modülü**
   - `wiredash`'ın 300 beğeniyle rakipten ayıran tek özellik bu
   - Anket builder + backend entegrasyonuyla güçlü bir fark yaratılabilir

### Uzun Vadeli

7. **Opsiyonel ücretli dashboard (SaaS)**
   - `wiredash` modelini düşün: açık kaynak SDK + opsiyonel cloud dashboard
   - Core paket daima ücretsiz, dashboard gelir modeli

---

## Öneriler

### Kısa Vadeli (v0.2 - v0.3)
- [ ] Paketi pub.dev'e yayınla, pub puanı 130+ hedefle
- [ ] README'yi güçlendir: kurulum GIF'i, tam örnek uygulama
- [ ] `flutter_feedback_kit_firebase` ek paketi yaz
- [ ] Screenshot annotation için basit çizim overlay ekle
- [ ] Web platform desteği ekle

### Orta Vadeli (v0.4 - v1.0)
- [ ] `flutter_feedback_kit_sentry` ve `flutter_feedback_kit_jira` paketleri
- [ ] Metadata otomatik toplama (device info, os version)
- [ ] NPS/CSAT anket modülü
- [ ] Kapsamlı test coverage (%80+)
- [ ] Localization (i18n) desteği

### Pazarlama / Konumlandırma
- **"Zero SaaS, Full Control"** mesajıyla konumlan — `wiredash`'a karşı
- **"feedback package artı pluggable backends"** olarak lanse et
- İlk hedef kitle: kurumsal/startup'lar kendi altyapısını kullananlar
- GitHub örnek repo'ları: Slack bot, Discord entegrasyon, Firebase dashboard

---

## Rakip Özeti

| Paket | Konum | Bizimle Çakışma | Tehdit Seviyesi |
|-------|-------|-----------------|-----------------|
| **feedback** | En popüler, screenshot annotation odaklı | Orta — biz backend'e odaklanıyoruz | Yüksek |
| **wiredash** | SaaS dashboard, NPS | Düşük — farklı segment | Orta |
| **rate_my_app** | App store review odaklı | Düşük — farklı amaç | Düşük |
| **in_app_review** | Native OS dialog | Yok — tamamlayıcı | Yok |
| **flutter_app_feedback** | Firebase-only, bakımsız | Yüksek — ama ölü | Yok |
| **in_app_feedback** | GitHub/email, bakımsız | Yüksek — ama ölü | Yok |

---

## Sonuç

`flutter_feedback_kit`'in **temel diferansiasyon vektörü** backend agnostik mimarisi. Bu niş şu an doldurmamış: `feedback` screenshot'a, `wiredash` SaaS'a, `rate_my_app` app store'a odaklanıyor. Bizim "kendi backend'ini getir + hazır webhook" yaklaşımı kurumsal ve self-hosted segment için gerçek bir boşluğu doldurabilir.

**En kritik eksikler:** Screenshot annotation ve pub.dev yayını. Bu ikisi hızla kapatılırsa, paketin traction kazanma şansı yüksek.

---

## Referanslar

- [feedback — pub.dev](https://pub.dev/packages/feedback)
- [wiredash — pub.dev](https://pub.dev/packages/wiredash)
- [rate_my_app — pub.dev](https://pub.dev/packages/rate_my_app)
- [in_app_review — pub.dev](https://pub.dev/packages/in_app_review)
- [flutter_app_feedback — pub.dev](https://pub.dev/packages/flutter_app_feedback)
- [in_app_feedback — pub.dev](https://pub.dev/packages/in_app_feedback)
- [flutter_usabilla — pub.dev](https://pub.dev/packages/flutter_usabilla)
- [Flutter Gems — Feedback kategori](https://fluttergems.dev/feedback/)
