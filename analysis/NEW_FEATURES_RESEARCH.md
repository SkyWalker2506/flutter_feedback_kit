# flutter_feedback_kit — New Features Research
> Sonnet 4.6 | 2026-03-31 | Sprint 6+ için özellik araştırması

---

## Araştırma Özeti

Sprint 1-4 tamamlandı. Sprint 5 (pub.dev hazırlık) devam ediyor. Bu belge Sprint 6 ve sonrası için araştırılmış, önceliklendirilmiş 18 yeni özellik/fikri içeriyor.

**Araştırma kaynakları:**
- pub.dev: `feedback`, `wiredash`, `rate_my_app`, `feedback_sentry`, `feedback_github`, `flutter_emoji_feedback`, `suggest_a_feature`, `research_package`
- Flutter Gems feedback kategorisi
- Instabug / Shake SDK özellik seti
- Wiredash 2.x feature roadmap
- Mevcut `analysis/12_competitive.md` ve `MASTER_ANALYSIS.md`

---

## Rakip Durum Özeti (Güncelleme)

| Paket | Güçlü Yanı | Bizim Avantajımız |
|-------|-----------|-------------------|
| **feedback** (1.6K likes) | Screenshot annotation, Flutter Favorite, `feedback_sentry`/`feedback_github` eklenti ekosistemi | Backend agnostik — eklentisi yok, altyapıyı kendin getir |
| **wiredash** (300 likes) | NPS/promoter score, GDPR uyumlu EU cloud, event tracking, tüm platformlar | SaaS bağımlılığı yok; kendi altyapını kullan |
| **rate_my_app** | Koşullu prompt (kaç açılış, kaç gün), app store yönlendirme | Feedback → backend pipeline; rating sadece bir adım |
| **in_app_review** (2.4K) | Native OS dialog, sıfır UX friksiyon | Yapılandırılmış kategori + zengin metadata |
| **flutter_emoji_feedback** | Emoji tabanlı mood/CSAT widget | Kategori sistemi + backend pipeline |
| **suggest_a_feature** | Feature request UI out-of-box | Genel amaçlı, pluggable |

**Pazar boşluğu:** Offline queue + voice input + backend agnostik mimarinin kombinasyonu hiçbir pakette yok. Bu üçü bizim Sprint 4'te tamamlanan temel diferansiasyon.

---

## Yeni Özellik Listesi (18 Özellik)

### Değerlendirme Kriterleri
- **Efor:** S = ~1 gün, M = 2-3 gün, L = 1 hafta, XL = 2+ hafta
- **Impact:** High = pub.dev traction + diferansiasyon, Med = DX iyileştirme, Low = niş katkı
- **Kategori:** `ui` UI/UX, `arch` mimari/backend, `growth` ekosistem büyütme, `analytics` veri/ölçüm

---

### GRUP A — Ekosistem Backends (arch / growth)

#### F-01: flutter_feedback_kit_firebase
**Başlık:** Firebase Firestore + Storage backend paketi

**Açıklama:** `FeedbackBackend` interface'ini implement eden ayrı bir pub.dev paketi. Firestore'a `FeedbackEntry` yazar, screenshot'ları Firebase Storage'a yükler. Kullanıcı sadece `firebase_core` + config ekleyip paketi bağlar. `feedback_sentry` / `feedback_github` modelini taklit eder ama BYOB mimarisi üzerinde çalışır.

**Efor:** L | **Impact:** High | **Kategori:** arch, growth

**Neden:** Flutter geliştiricilerinin %60+'ı Firebase kullanıyor. "Firebase zaten varsa bir satırla entegre" mesajı traction'ı çarpan etkisiyle büyütür. `feedback_sentry`'nin (Sentry ekosistemi içinde) yaptığı işi biz Firebase için yaparız.

---

#### F-02: flutter_feedback_kit_sentry
**Başlık:** Sentry UserFeedback backend paketi

**Açıklama:** Sentry'nin User Feedback API'sine `FeedbackEntry` gönderen backend paketi. Sentry event ID ile ilişkilendirme opsiyonel — crash anında otomatik feedback toplanabilir. `sentry_flutter` ile koordineli çalışır.

**Efor:** M | **Impact:** High | **Kategori:** arch, growth

**Neden:** `feedback_sentry` paketi `feedback` paketine bağımlı; bizim için boş bir niş. Sentry kullanıcıları (kurumsal segment) için anında değer.

---

#### F-03: flutter_feedback_kit_jira
**Başlık:** Jira Cloud issue oluşturan backend paketi

**Açıklama:** `FeedbackEntry`'den Jira issue oluşturan backend. API token tabanlı auth, proje/issuetype konfigürasyonu. Screenshot'lar Jira attachment olarak eklenir. Kurumsal/B2B Flutter uygulamaları için kritik.

**Efor:** M | **Impact:** High | **Kategori:** arch, growth

**Neden:** Hiçbir Flutter feedback paketinde yerleşik Jira desteği yok. Kurumsal segment için güçlü differentiator.

---

#### F-04: flutter_feedback_kit_github
**Başlık:** GitHub Issues backend paketi

**Açıklama:** `FeedbackEntry`'den GitHub issue oluşturur. Personal Access Token veya GitHub App auth. Label mapping (FeedbackCategory → GitHub label). `feedback_github` paketi Firebase Storage bağımlılığı getiriyor; bizim implementasyonumuz daha hafif.

**Efor:** M | **Impact:** Med | **Kategori:** arch, growth

**Neden:** Open source projelerde beta tester feedback'i doğrudan Issues'a aktar. `feedback_github`'ın Firebase bağımlılığı olmayan alternatifi.

---

### GRUP B — Kullanıcı Deneyimi & UI (ui)

#### F-05: Screenshot Annotation Overlay
**Başlık:** Basit çizim + işaretleme katmanı

**Açıklama:** Screenshot üzerine kalem, dikdörtgen ve ok araçlarıyla işaretleme yapılabilen overlay widget. `feedback` paketinin temel özelliği. Renk seçici, geri al/ileri al, blur (gizlilik için). Annotation sonucu `Uint8List` olarak `FeedbackEntry.screenshots`'a eklenir.

**Efor:** XL | **Impact:** High | **Kategori:** ui

**Neden:** `feedback` paketinin 1.6K beğenisinin büyük kısmı bu özellikten. Bizim en büyük rekabet açığı. Sprint 6'da planlandı; bu araştırma ile öncelik teyit edildi.

---

#### F-06: NPS / Promoter Score Widget
**Başlık:** Net Promoter Score anket modülü

**Açıklama:** 0-10 sayısal skala + "Neden bu puanı verdiniz?" opsiyonel metin alanı. `FeedbackEntry`'e `npsScore: int?` field'ı eklenir. Wiredash'ın en ayırt edici özelliği — SaaS olmadan aynısını sun. Conditional trigger ile (X oturumdan sonra göster) `SmartTrigger` modülüyle birleşir.

**Efor:** M | **Impact:** High | **Kategori:** ui, analytics

**Neden:** Wiredash'ın 300 beğeniyle ayrıştığı tek özellik. Biz bunu ücretsiz, SaaS olmadan sunarız.

---

#### F-07: Emoji / CSAT Rating Widget
**Başlık:** 5 seviyeli emoji duygu skoru

**Açıklama:** `flutter_emoji_feedback` paketinin sunduğu mood-based rating. 😡😞😐😊😍 veya 1-5 yıldız. `FeedbackEntry`'e `rating: int?` (1-5) eklenir. `FeedbackWidget`'a opsiyonel `showRating: true` parametresi.

**Efor:** S | **Impact:** Med | **Kategori:** ui

**Neden:** Hızlı CSAT toplama için en yaygın UX pattern. S efor, Med+ impact — sprint'e erken dahil edilebilir.

---

#### F-08: Automatic Screen Capture
**Başlık:** Feedback açılınca otomatik ekran görüntüsü

**Açıklama:** `FeedbackButton` veya `FeedbackWidget` açılmadan önce arka planda mevcut ekranı yakalar (`RepaintBoundary` ile). Kullanıcı "ekran görüntüsü al" butonuna basmak zorunda kalmaz. Opt-in (`autoCapture: true`), GDPR uyumu için kullanıcıya toggle gösterilebilir.

**Efor:** M | **Impact:** High | **Kategori:** ui

**Neden:** Instabug'ın varsayılan davranışı bu. Kullanıcı friction'ını kaldırır; feedback kalitesini ciddi artırır.

---

#### F-09: Localization / i18n Desteği
**Başlık:** Çok dil desteği (ARB tabanlı)

**Açıklama:** `FeedbackLocalizations` soyut sınıfı + `DefaultFeedbackLocalizations` (EN). TR, DE, FR, ES, JA hazır çeviriler. `feedback` paketi bu yaklaşımı `GlobalFeedbackLocalizationsDelegate` ile kullanıyor. Kullanıcı kendi `FeedbackLocalizations` implementasyonunu geçirebilir.

**Efor:** M | **Impact:** High | **Kategori:** ui, growth

**Neden:** pub.dev international traction için zorunlu. `feedback` paketinin varken bizim yokken pub.dev puanı düşük kalır.

---

#### F-10: Smart Trigger / Conditional Prompt
**Başlık:** Koşullu feedback tetikleyici

**Açıklama:** `FeedbackTrigger` sınıfı — `minAppLaunches`, `minDaysInstalled`, `minScreenVisits`, `oncePerVersion` gibi koşullar. `rate_my_app`'ın kondisyon sistemini feedback için uyarla. `SharedPreferences` tabanlı durum takibi. Kullanıcı "sonra sor" / "gösterme" seçenekleri.

**Efor:** L | **Impact:** High | **Kategori:** arch, ui

**Neden:** `rate_my_app`'ın en değerli özelliği. Geri bildirim isteğini doğru zamanda göstermek conversion'ı 3-5x artırır. Hiçbir feedback paketi bunu bizim offline queue mimarimizle birleştirmiyor.

---

### GRUP C — Backend Altyapı & Mimari (arch)

#### F-11: FeedbackMiddleware (Pipeline)
**Başlık:** Ara katman / pipeline mimarisi

**Açıklama:** `FeedbackMiddleware` interface'i — backend'e göndermeden önce `FeedbackEntry`'yi transform eden zincir. Örnek middleware'ler: `MetadataEnricher` (otomatik device info ekle), `PiiSanitizer` (email/telefon maskeleme), `SentimentAnalyzer` (basit keyword-based skoring). Builder pattern: `QueuedBackend(middleware: [MetadataEnricher(), PiiSanitizer()])`.

**Efor:** L | **Impact:** High | **Kategori:** arch

**Neden:** Mevcut mimarinin doğal uzantısı. Kurumsal kullanıcılar GDPR compliance için PII sanitization istiyor. Middleware konsepti backend ekosistemini daha güçlü kılar.

---

#### F-12: FeedbackMetadata Otomatik Zenginleştirme
**Başlık:** Cihaz/uygulama bilgisi otomatik toplama

**Açıklama:** `device_info_plus` + `package_info_plus` ile otomatik metadata: OS, OS version, device model, app version, build number, locale, screen size, connection type. `FeedbackEntry.metadata`'ya eklenir. `FeedbackWidget`'ta "Cihaz bilgisi gönder" toggle (GDPR).

**Efor:** S | **Impact:** High | **Kategori:** arch

**Neden:** `flutter_app_feedback` paketinin bu özelliği vardı ama bakımsız. Geliştiriciler bug report'larda "hangi cihaz?" sorusunu sormak istemiyor. S efor, yüksek değer.

---

#### F-13: Web + Desktop Platform Desteği
**Başlık:** flutter web / macOS / Windows / Linux desteği

**Açıklama:** `dart:io` → `defaultTargetPlatform` / `kIsWeb` migration (P0 düzeltmesi zaten yapıldı). `image_picker_web` entegrasyonu. `SpeechRecognitionService` web shim (Web Speech API). `SharedPrefsQueue` → `universal_io` + `shared_preferences_web` uyumlu hale getir.

**Efor:** L | **Impact:** High | **Kategori:** arch

**Neden:** `feedback` ve `wiredash` tüm platformları destekliyor; biz mobile-only kalırsak pub.dev platform desteği puanı düşük kalır.

---

#### F-14: EmailBackend (SMTP / SendGrid)
**Başlık:** E-posta backend implementasyonu

**Açıklama:** `FeedbackBackend` implementasyonu — SendGrid veya SMTP üzerinden `FeedbackEntry`'yi email olarak gönderir. `in_app_feedback` paketinin yaptığı ama bakımsız. Şablonlanabilir HTML email body, attachment desteği (screenshot base64).

**Efor:** M | **Impact:** Med | **Kategori:** arch, growth

**Neden:** Startup/indie segment için backend gerektirmeyen sıfır-kurulum seçeneği. SendGrid free tier ile dakikada aktif.

---

### GRUP D — Analitik & Akıllı Özellikler (analytics)

#### F-15: FeedbackAnalytics Event Tracking
**Başlık:** Lightweight feedback event tracker

**Açıklama:** `FeedbackAnalytics` interface — `onFeedbackShown`, `onFeedbackSubmitted`, `onFeedbackDismissed`, `onVoiceInputUsed`, `onScreenshotAdded` event'leri. Backend-agnostik: kullanıcı kendi analytics provider'ını (Firebase Analytics, Amplitude, Mixpanel, Posthog) implement eder. `flutter_feedback_kit`'te sıfır analitik bağımlılığı — sadece event callback'ler.

**Efor:** S | **Impact:** Med | **Kategori:** analytics, arch

**Neden:** Geliştiriciler feedback widget'ının kullanımını kendi analytics stack'lerine göndermek istiyor. S efor, doğal mimari uzantı.

---

#### F-16: AI-Powered Category Detection
**Başlık:** Otomatik kategori tahmini (on-device veya API)

**Açıklama:** Kullanıcı metin yazarken `FeedbackCategory`'yi otomatik tahmin et. İki mod: (a) basit keyword-based (on-device, sıfır bağımlılık) — "crash", "slow", "UI" gibi anahtar kelimeler, (b) LLM API mode (opsiyonel `AiCategoryDetector` implementasyonu — kullanıcı kendi API key'ini getirir). `FeedbackWidget`'ta öneri göster, kullanıcı override edebilir.

**Efor:** M | **Impact:** Med | **Kategori:** analytics, ui

**Neden:** Instabug'ın premium özelliği. Keyword-based versiyon S eforla uygulanabilir; LLM versiyon backend-agnostik kalır (kullanıcı API key getirir). Kategorileme kalitesini artırır.

---

#### F-17: Session Context Capture
**Başlık:** Geri bildirim anındaki oturum bağlamı

**Açıklama:** `FeedbackSessionContext` — opsiyonel callback: kullanıcı adı/ID, aktif ekran/route, son N navigasyon adımı, özel key-value pairs. `FeedbackWidget(sessionContext: () => FeedbackSessionContext(...))`. Backend'e `FeedbackEntry.sessionContext` olarak gönderilir. Instabug'ın "repro steps" özelliğinin hafif versiyonu.

**Efor:** S | **Impact:** Med | **Kategori:** arch, analytics

**Neden:** "Nerede olduğunu bilmeden bug fix etmek zor." En sık istenen kurumsal özellik. S efor — sadece callback interface ve metadata field.

---

#### F-18: pub.dev Plugin Ecosystem CLI / Generator
**Başlık:** `flutter_feedback_kit_new_backend` Mason brick'i

**Açıklama:** `mason` brick ile yeni backend paketi iskelet oluşturma: `mason make feedback_kit_backend --name firebase` → hazır `pubspec.yaml`, `FeedbackBackend` implement eden sınıf, README şablonu, test dosyası. `feedback` paketinin `feedback_sentry` / `feedback_github` ekosistemini hızla büyütmesini sağlayan pattern.

**Efor:** S | **Impact:** Med | **Kategori:** growth

**Neden:** 3. parti geliştiricilerin kendi backend paketlerini yazmasını kolaylaştırır. Ekosistem ağ etkisini tetikler.

---

## Öncelik Matrisi

| # | Özellik | Efor | Impact | Kategori | Sprint Önerisi |
|---|---------|------|--------|----------|----------------|
| F-01 | firebase backend paketi | L | High | arch,growth | Sprint 6 |
| F-05 | screenshot annotation | XL | High | ui | Sprint 6 |
| F-09 | localization / i18n | M | High | ui,growth | Sprint 6 |
| F-12 | metadata otomatik zenginleştirme | S | High | arch | Sprint 6 |
| F-08 | otomatik screen capture | M | High | ui | Sprint 6 |
| F-02 | sentry backend paketi | M | High | arch,growth | Sprint 7 |
| F-03 | jira backend paketi | M | High | arch,growth | Sprint 7 |
| F-06 | NPS widget | M | High | ui,analytics | Sprint 7 |
| F-10 | smart trigger / koşullu prompt | L | High | arch,ui | Sprint 7 |
| F-13 | web + desktop desteği | L | High | arch | Sprint 7 |
| F-11 | middleware pipeline | L | High | arch | Sprint 8 |
| F-15 | analytics event tracking | S | Med | analytics,arch | Sprint 6 |
| F-17 | session context capture | S | Med | arch,analytics | Sprint 6 |
| F-07 | emoji CSAT rating | S | Med | ui | Sprint 7 |
| F-16 | AI kategori tespiti | M | Med | analytics,ui | Sprint 8 |
| F-04 | github backend paketi | M | Med | arch,growth | Sprint 8 |
| F-14 | email (SendGrid) backend | M | Med | arch,growth | Sprint 8 |
| F-18 | mason brick generator | S | Med | growth | Sprint 9 |

---

## Sprint 6 Taslağı (Bu Araştırmadan)

**Tema:** Firebase Ekosistemi + pub.dev Kalite

| # | Görev | Efor | Kaynak |
|---|-------|------|--------|
| 1 | flutter_feedback_kit_firebase paketi | L=3 | F-01 |
| 2 | Screenshot annotation overlay | XL=5 | F-05 |
| 3 | FeedbackMetadata otomatik zenginleştirme | S=1 | F-12 |
| 4 | Analytics event tracking interface | S=1 | F-15 |
| 5 | Session context capture | S=1 | F-17 |
| 6 | pub.dev yayını | S=1 | SPRINT_PLAN.md Sprint 6 |

> Toplam: 12 SP — büyük görev (annotation XL=5) nedeniyle sıkışık. F-05 ayrı sprint'e taşınabilir; F-01+F-12+F-15+F-17 kendi başına değerli bir Sprint 6 oluşturur.

## Sprint 7 Taslağı

**Tema:** NPS + Sentry/Jira Backends + Smart Trigger

| # | Görev | Efor |
|---|-------|------|
| 1 | NPS/Promoter Score widget | M=2 |
| 2 | Emoji CSAT rating | S=1 |
| 3 | flutter_feedback_kit_sentry | M=2 |
| 4 | flutter_feedback_kit_jira | M=2 |
| 5 | Smart trigger / conditional prompt | L=3 |

> Toplam: 10 SP

---

## Kaynaklar

- [feedback — pub.dev](https://pub.dev/packages/feedback)
- [feedback_sentry — pub.dev](https://pub.dev/packages/feedback_sentry)
- [feedback_github — pub.dev](https://pub.dev/packages/feedback_github)
- [wiredash — pub.dev](https://pub.dev/packages/wiredash)
- [flutter_emoji_feedback — pub.dev](https://pub.dev/packages/flutter_emoji_feedback)
- [suggest_a_feature — pub.dev](https://pub.dev/packages/suggest_a_feature)
- [Flutter Gems — Feedback](https://fluttergems.dev/feedback/)
- [Instabug Android SDK](https://github.com/Instabug/Instabug-Android)
- [Wiredash Docs](https://docs.wiredash.com/)
