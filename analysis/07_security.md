# Security & Infrastructure Analiz Raporu
> flutter_feedback_kit | Sonnet 4.6 | 2026-03-30

---

## Mevcut Durum

### Güçlü Yanlar

- **HTTPS zorunluluğu yok ama tasarım gereği HTTP kullanılıyor:** `WebhookBackend`, `http` paketi üzerinden çalışır; güvenli URL geçirmek geliştiricinin sorumluluğundadır — düşük seviyeli bir sorumluluk dağılımı olsa da makul.
- **Timeout koruması mevcuttur:** `WebhookBackend` varsayılan olarak 15 saniyelik timeout uygular; DoS/takılma riskini sınırlar.
- **HTTP error handling yapılmış:** Non-2xx durumlarda `WebhookException` fırlatılır; sessiz hata yutma yoktur.
- **maxMessageLength parametresi var:** `FeedbackWidget`, `maxMessageLength` (varsayılan 2000) ile TextFormField'a karakter sınırı koyar — temel kötüye kullanım önlemi.
- **Dependency injection ile test edilebilir backend:** `http.Client` dışarıdan enjekte edilebildiğinden test yüzeyinde ağ izolasyonu mümkündür.
- **Bağımlılık sayısı az:** Yalnızca `http: ^1.2.2` ve `image_picker: ^1.1.2` — saldırı yüzeyi sınırlı.
- **`List.unmodifiable` kullanımı:** `FeedbackEntry` oluşturulurken screenshot listesi immutable yapılır; veri bütünlüğü korunur.

### Puan: 4/10

Paket yeni ve minimal olmasına karşın; webhook URL doğrulaması, veri sanitizasyon, screenshot boyut/içerik sınırı, hata mesajı sızıntısı ve HTTPS zorlama gibi temel güvenlik kontrolleri eksiktir.

---

## Kritik Eksikler

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **URL doğrulaması yok** — `WebhookBackend(url: ...)` string olarak alınır; `http://` (plaintext), `file://`, `javascript://` veya boş string geçilebilir; MITM ve veri sızıntısına açık kapı | High | Constructor'da `Uri.parse` + `scheme` kontrolü (`https` zorunlu, ya da en az bir uyarı mekanizması); geçersiz URL'de erken exception | S |
| 2 | **Hata mesajında sunucu yanıtı sızdırılıyor** — `WebhookException('Webhook failed ... ${response.body}')` ifadesi, sunucudan dönen stack trace / dahili bilgiyi kullanıcıya veya loglara yansıtır; information disclosure riski | High | `response.body`'yi exception mesajına dahil etme; yalnızca status code logla; body'yi ayrı bir debug-only alanda tut | S |
| 3 | **Screenshot içeriğine hiçbir kontrol yok** — Kullanıcı galeriden herhangi bir dosyayı seçebilir; boyut sınırı, MIME türü kontrolü veya resim doğrulaması yoktur; büyük dosyalar (10+ MB base64) ağ yükü ve potansiyel bellek tüketimi yaratır | High | Maksimum resim boyutu (örn. 1 MB), maksimum screenshot sayısı kontrolü (UI'da 3 ile sınırlı ancak programatik `copyWith` ile aşılabilir), MIME type doğrulaması | M |
| 4 | **Mesaj alanında sanitizasyon eksik** — `message` alanı yalnızca "boş mu?" kontrolünden geçer; XSS payload veya özel karakterler (`<script>`, `\n`, kontrol karakterleri) backend'e ham olarak iletilir | Medium | Webhook backend'e gitmeden önce mesajda kontrol karakterleri ve potansiyel injection karakterleri için sanitizasyon veya beyaz liste doğrulaması | M |
| 5 | **HTTPS zorlama mekanizması yok** — Paket, `http://` ile çağrılmasına izin verir; özellikle mobil ağlarda MITM saldırısına karşı savunmasız; kullanıcı geri bildirimi (kişisel not + platform bilgisi) dinlenebilir | Medium | Scheme kontrolü: `https` değilse `AssertionError` veya açık bir `ArgumentError` fırlat; en azından `kDebugMode`'da uyarı göster | S |

---

## İyileştirme Önerileri

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **Rate limiting / debounce** — Kullanıcı kısa sürede defalarca submit yapabilir; webhook endpoint'i spam/flood riski altında | Medium | Submit sonrası cooldown süresi (örn. 30 saniye) veya double-submit koruması; `_isSubmitting` bayrağı tek request koruması sağlıyor ancak UI sıfırlandıktan sonra hemen tekrar gönderilebilir | S |
| 2 | **`appVersion` parametresi doğrulanmıyor** — Dışarıdan string olarak alınır; `'../../../etc'` gibi path traversal veya çok uzun string gönderilebilir | Low | Basit regex doğrulaması (semver formatı beklentisi) veya maksimum uzunluk sınırı | S |
| 3 | **`platform` değeri kullanıcı tarafından override edilebilir** — `FeedbackEntry.copyWith(platform: 'attacker-string')` ile değiştirilebilir; server-side'ı yanıltma riski mevcut | Low | `platform` alanını `FeedbackEntry` constructor'ında `Platform.operatingSystem` ile sabit olarak doldur; dışarıdan override edilemez hale getir | S |
| 4 | **Certificate pinning desteği yok** — Özellikle hassas feedback (kurumsal kullanım) için MITM koruması sertifika sabitleme gerektirir | Medium | `SecurityContext` veya `HttpOverrides` üzerinden pinning desteği eklenebilir; `httpClient` injection zaten mevcut olduğundan dışarıdan desteklenebilir; bir örnek veya dokümantasyon yeterli | M |
| 5 | **Custom header'larda hassas veri kontrolü yok** — `WebhookBackend(headers: {'Authorization': 'Bearer token123'})` kullanımı örneğin loglara veya hata mesajlarına sızabilir | Medium | Header'lar `toString` veya exception mesajlarında asla gösterilmemeli; `WebhookException` içinde header'ları loglamaktan kaçın | S |
| 6 | **Screenshot base64 payload boyutu sınırsız** — 3 adet 5 MB resim = ~20 MB base64 JSON; mobilde bellek baskısı ve sunucu tarafında büyük payload saldırısı riski | Medium | `_pickScreenshot` içinde `ImagePicker.pickImage` üzerinde `maxWidth`, `maxHeight` ve `imageQuality` parametreleri kullanılarak resim sıkıştırılabilir; mevcut API buna izin veriyor | S |
| 7 | **Bağımlılık versiyonları sabitlenmemiş** — `http: ^1.2.2` ve `image_picker: ^1.1.2` küçük sürüm güncellemelerini otomatik alır; supply chain riski mevcut | Medium | `pubspec.lock` commit'lenmeli (zaten yapılıyor); CI'da `pub audit` / `dart pub deps` çalıştırarak bilinen CVE taraması yapılmalı | S |
| 8 | **`onError` callback'i ham exception objesini sızdırıyor** — `widget.onError?.call(e)` ile dışarıya geçen exception, paket kullanıcısının yanlışlıkla UI'da göstermesine neden olabilir; özellikle `WebhookException.message` içindeki `response.body` | Low | `WebhookException`'a `userMessage` (güvenli) ve `debugMessage` (hassas) alanları ekle; `onError`'a yalnızca `userMessage` geç | M |

---

## Kesin Olmalı

1. **URL scheme zorunluluğu (`https`)** — Plaintext HTTP ile webhook URL kabul etme; constructor'da `ArgumentError` fırlat.
2. **`response.body` exception mesajından çıkarılmalı** — Sunucu yanıtını hata mesajına dahil etme; bilgi sızıntısı önlenir.
3. **Screenshot boyut sınırı** — `pickImage` çağrısında `maxWidth: 1024, maxHeight: 1024, imageQuality: 80` gibi değerler ile büyük payload riski önlenmeli.
4. **Mesaj sanitizasyonu** — En azından null byte ve kontrol karakterleri (`\x00`–`\x1f`) filtrelenmeli.

---

## Kesin Değişmeli

1. **Hata mesajı mimarisi** — `WebhookException`'da `userMessage` / `debugMessage` ayrımı yapılmalı; `onError` callback'i kullanıcıya güvenli mesaj iletmeli.
2. **Rate limiting / double-submit koruması** — Submit sonrası cooldown; `_isSubmitting` sıfırlandıktan sonraki anlık yeniden gönderim kapatılmalı.
3. **`appVersion` format doğrulaması** — Maksimum uzunluk ve kabul edilebilir karakter seti tanımlanmalı.

---

## Nice-to-Have

1. **Certificate pinning dokümantasyonu** — `httpClient` injection ile nasıl pinning yapılacağına dair README örneği.
2. **`platform` alanını readonly yap** — Kullanıcı tarafından `copyWith` ile değiştirilemez hale getirilmesi; örneğin `late final` veya factory constructor ile hesaplanan alan.
3. **`dart pub audit` CI entegrasyonu** — GitHub Actions workflow'una bağımlılık güvenlik taraması eklenmesi.
4. **Feedback gönderim öncesi kullanıcı onayı** — "Bu feedback platform bilgisi ve ekran görüntüsü içerir, göndermek istiyor musunuz?" gibi bir onay adımı; GDPR/KVKK uyumluluğu açısından değerli.
5. **`SecurityContext` / TLS minimum version** — Custom `httpClient` için TLS 1.2+ zorunluluğu örneği.

---

## Referanslar

- [Flutter Security — Official Docs](https://docs.flutter.dev/security)
- [OWASP Mobile Top 10 — 2025](https://owasp.org/www-project-mobile-top-10/)
- [OWASP Top 10 For Flutter — M1: Credential Security](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m1-mastering-credential-security-in-flutter)
- [OWASP Top 10 For Flutter — M2: Supply Chain](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m2-inadequate-supply-chain-security-in-flutter)
- [OWASP Top 10 For Flutter — M6: Privacy Controls](https://docs.talsec.app/appsec-articles/articles/owasp-top-10-for-flutter-m6-inadequate-privacy-controls-in-flutter-and-dart)
- [Flutter Security Best Practices — HackerNoon 2025](https://hackernoon.com/10-best-practices-for-securing-your-flutter-mobile-app-in-2025)
- [Flutter App Security Vulnerabilities — Touchlane](https://touchlane.com/5-overlooked-flutter-security-vulnerabilities-and-how-to-address-them/)
- [Securing Flutter Apps: OWASP Mobile Top 10 — 8kSec](https://8ksec.io/securing-flutter-applications/)
