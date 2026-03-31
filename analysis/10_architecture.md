# Architecture & Code Quality Analiz Raporu
> flutter_feedback_kit | Sonnet 4.6 | 2026-03-30

---

## Mevcut Durum

### Güçlü Yanlar

- **Katmanlı mimari dogru uygulanmış:** `domain/` (entity + repository arayüzü), `data/` (backend implementasyonları), `presentation/` (widget'lar) ayrımı temiz ve tutarlı.
- **Dependency Inversion prensibi:** `FeedbackWidget` somut backend'e değil `FeedbackBackend` arayüzüne bağlı. Firebase, Slack, Discord gibi herhangi bir backend kolayca eklenebilir.
- **Dependency injection:** `WebhookBackend` test edilebilir `http.Client` injection kabul ediyor; mock'lanması trivial.
- **Immutable entity:** `FeedbackEntry` `const` constructor + `copyWith` pattern'ı ile doğru şekilde tasarlanmış; `operator ==` ve `hashCode` override edilmiş.
- **Test altyapısı mevcut:** `MockClient` kullanarak gerçek HTTP çağrısı yapmadan `WebhookBackend` birim testi yazılmış; `mocktail` devDependency olarak yer alıyor.
- **Barrel export:** Tek `flutter_feedback_kit.dart` ile tüm public API ihraç ediliyor.
- **Örnek uygulama:** `example/` mevcut — pub.dev skorlaması açısından önemli.
- **README kalitesi:** Kurulum, kullanım, özelleştirme ve alan tablosu içeriyor.

### Puan: 5.5/10

Temel mimari sağlam, ancak pub.dev'e yayımlanabilir ve production'da kullanılabilir seviyeye ulaşmak için ciddi eksikler var.

---

## Kritik Eksikler

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **Widget testi yok** — `FeedbackWidget` ve `FeedbackButton` için hiç widget/golden test yazılmamış. UI davranışı (submit, validation, snackbar) test dışı. | High | `flutter_test` ile `testWidgets` ekle; form submit, validation, screenshot row interaksiyon senaryoları. | M |
| 2 | **`dart:io` kullanımı web'i kırdı** — `feedback_widget.dart` içinde `import 'dart:io'` ve `Platform.operatingSystem` direkt çağrılıyor. Bu web platformunu tamamen devre dışı bırakır. | High | `package:flutter/foundation.dart` → `defaultTargetPlatform.name` veya `kIsWeb` guard; web için platform adını `'web'` döndür. | S |
| 3 | **`screenshots` `operator==`/`hashCode`'dan dışarıda** — `FeedbackEntry.operator==` içinde `screenshots` karşılaştırılmıyor; `hashCode` da dahil etmiyor. Bu veri tutarsızlığına yol açar. | High | `listEquals` (Flutter foundation) veya `DeepCollectionEquality` ile `screenshots` listesini karşılaştırmaya ekle. | S |
| 4 | **`analysis_options.yaml` neredeyse boş** — Yalnızca `flutter_lints` include edilmiş, ek lint kuralı yok. Paket için industry standard olan `very_good_analysis` veya en azından ek strict kurallar eksik. | Med | `lints/recommended.yaml` üzerine `prefer_final_fields`, `avoid_print`, `require_trailing_commas`, `unawaited_futures`, `cancel_subscriptions` gibi kurallar ekle. | S |
| 5 | **`FeedbackButton` içinde keyboard insets MediaQuery context hatası** — `MediaQuery.of(context).viewInsets.bottom` `FloatingActionButton` builder'ının dışında alınan context'e dayanıyor; bottom sheet içindeki `_` builder context'i farklı. Keyboard açıldığında görsel bozulma riski var. | Med | Bottom sheet `builder: (sheetContext)` parametresini kullan, `MediaQuery.of(sheetContext)` ile al. | S |
| 6 | **`http.Client` kapatılmıyor** — `WebhookBackend` dışarıdan `httpClient` verilmezse kendi yarattığı `http.Client()`'ı `close()` etmiyor; paket uzun ömürlü kullanımda kaynak sızıntısına yol açar. | Med | `WebhookBackend`'e `dispose()` metodu ekle veya her request için ephemeral client yarat+kapat. | S |

---

## İyileştirme Önerileri

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **`FeedbackEntry.fromJson` factory constructor eksik** — `toJson` var ama `fromJson` yok. Backend'den veri okuma, yerel önbellek, log parsing senaryoları için gerekli. | Med | Simetrik `factory FeedbackEntry.fromJson(Map<String, dynamic> json)` ekle. | S |
| 2 | **`FeedbackWidget` `appVersion` otomatik tespit edebilmeli** — Kullanıcıdan `appVersion: '1.0.0'` string'i zorunlu alması kötü DX. `package_info_plus` isteğe bağlı bağımlılık olabilir veya builder pattern sunulabilir. | Med | `appVersion` optional yap, null ise `package_info_plus` ile otomatik doldur. | M |
| 3 | **Theming / customization eksik** — Widget renkleri, padding, radius hardcoded. Paket kullanan geliştiriciler markalarına uygun görünüm elde edemiyor. `FeedbackThemeData` veya `ThemeExtension` desteği eklenebilir. | Med | `FeedbackThemeData` value object; `FeedbackWidget` constructor'a opsiyonel `theme` parametresi. | M |
| 4 | **Screenshot boyut limiti yok** — Base64 encode edilen görseller için bayt sınırı yok. Kullanıcı büyük fotoğraf seçerse payload onlarca MB olabilir; webhook'lar genellikle 1–10 MB limiti uygular. | Med | `maxScreenshotSizeBytes` parametresi ekle; `image` paketi ile resize/compress seçeneği sun. | M |
| 5 | **`FeedbackCategory` genişletilebilir değil** — `enum` sabit; paket kullanıcısı özel kategori ekleyemiyor. Uygulamaya özgü "payment", "login" gibi kategoriler tanımlanamıyor. | Med | `FeedbackCategory` yerine sealed class/abstract class veya `String` tabanlı value object; mevcut enum'ı `BuiltinFeedbackCategory` olarak tut. | L |
| 6 | **CI/CD pipeline yok** — `.github/workflows/` boş. pub.dev pub points'ten puan düşülüyor; paket güvenilirliği sorgulanıyor. | Med | `flutter analyze && flutter test` çalıştıran GitHub Actions workflow ekle. | S |
| 7 | **`CHANGELOG.md` format** — `Keep a Changelog` standardına (`### Added`, `### Fixed`, `### Changed`) uymayan düz metin. pub.dev bunu parse eder. | Low | CHANGELOG'u `## [0.1.0] - 2026-03-30` + alt başlıklar formatına çevir. | S |
| 8 | **Localisation (l10n) desteği yok** — Tüm string'ler (`'Send Feedback'`, `'Message is required'`, `'Thank you...'`) hardcoded İngilizce. Çok dilli uygulama kullananlar tüm metinleri kendisi override etmek zorunda. | Low | Mevcut `submitLabel`, `successMessage` gibi parametreleri genişlet; `FeedbackLocalizations` delegate seçeneği ekle. | L |
| 9 | **`FeedbackButton` FAB'a kilitli** — `FeedbackButton` her zaman `FloatingActionButton.extended` render ediyor; menu item, settings sayfası satırı, listTile gibi farklı entry point'lerde kullanılamıyor. | Low | `FeedbackButton` yerine `openFeedbackSheet(context, ...)` utility fonksiyonu + `FeedbackButton` onu çağıran bir wrapper olsun. | M |
| 10 | **`dart doc` / API dokümantasyonu minimal** — Hiçbir public class/method'da `///` doc comment yok. pub.dev documentation skoru düşecek. | Low | Tüm public API'ye `///` Dart doc comment ekle. | M |

---

## Kesin Olmalı (industry standard)

Bunlar pub.dev'de yayımlanacak her pakette beklenen minimum standartlar:

1. **Widget testleri** — `FeedbackWidget` ve `FeedbackButton` için `testWidgets` senaryoları.
2. **CI workflow** — GitHub Actions ile `flutter analyze && flutter test` otomatik çalışmalı.
3. **`dart:io` web uyumluluğu** — `Platform.operatingSystem` yerine web-safe API.
4. **`operator==` / `hashCode` tutarlılığı** — `screenshots` listesi de dahil edilmeli.
5. **`http.Client` lifecycle yönetimi** — `dispose()` ya da ephemeral client.
6. **API dokümantasyonu** — En az her public class ve constructor için `///` doc comment.
7. **`CHANGELOG.md` standart format** — Keep a Changelog uyumu.

---

## Kesin Değişmeli (mevcut sorunlar)

Bunlar bug veya veri tutarsızlığı riski taşıyan aktif sorunlar:

1. **`dart:io` → `defaultTargetPlatform`** — Web build kırık, düzeltilmeli.
2. **`screenshots` equality** — `FeedbackEntry` equality mantığı yanlış, test'ler güvenilmez sonuç üretebilir.
3. **`MediaQuery` context sorunu `FeedbackButton`'da** — Keyboard davranışı bozulabilir.
4. **`http.Client` kapatılmıyor** — Uzun ömürlü kullanımda kaynak sızıntısı.

---

## Nice-to-Have

Paketi diğerlerinden ayıracak, ancak zorunlu olmayan özellikler:

- **`package_info_plus` ile otomatik version detection**
- **`FeedbackThemeData` / `ThemeExtension` ile tema desteği**
- **Screenshot resize/compress desteği**
- **`FeedbackCategory` genişletilebilirlik (sealed class / custom kategoriler)**
- **`openFeedbackSheet` utility fonksiyonu**
- **Localisation desteği (`FeedbackLocalizations`)**
- **`fromJson` factory constructor**
- **Golden testler (pub golden_toolkit / alchemist)**

---

## Özet Puanlama

| Kriter | Puan | Not |
|--------|------|-----|
| Mimari / Katman Ayrımı | 8/10 | Domain-Data-Presentation ayrımı temiz |
| Test Coverage | 4/10 | Unit testler var, widget testi yok |
| API Tasarımı / DX | 5/10 | Temel kullanım kolay, genişletilebilirlik zayıf |
| pub.dev Uyumluluğu | 5/10 | CI yok, doc comment yok, web uyumu kırık |
| Hata Yönetimi | 6/10 | WebhookException iyi, kaynak yönetimi eksik |
| Kod Kalitesi / Linting | 5/10 | flutter_lints yeterli değil |
| **Genel** | **5.5/10** | Sağlam temel, pub.dev'e hazır değil |

---

## Referanslar

- [pub.dev Pub Points Scoring Criteria](https://pub.dev/help/scoring)
- [Things you should know before publishing a package on pub.dev](https://tsinis.medium.com/things-you-should-know-before-publishing-a-package-on-pub-dev-95ab195e216d)
- [Building a Flutter SDK: A Deep Dive Into pub.dev](https://getstream.io/blog/deep-dive-pub-dev/)
- [Improving Code Quality in Flutter With Very Good Analysis](https://onlyflutter.com/improving-code-quality-in-flutter-with-very-good-analysis/)
- [Dart Linter Rules](https://dart.dev/tools/linter-rules)
- [Flutter Widget Testing Best Practices: Golden Tests](https://vibe-studio.ai/insights/flutter-widget-testing-best-practices-golden-tests-and-screenshot-diffs)
- [DCM: Getting Started with Flutter Static Analysis](https://dcm.dev/blog/2025/10/21/getting-started-flutter-static-analytics-lints/)
