# flutter_feedback_kit — Sprint Plan
> Güncellendi: 2026-03-31 | Sprint 2+3+4+5 tamamlandı | Sprint 6-9 planlandı

Sprint 1→5 tamamlandı. Sprint 6-9 `NEW_FEATURES_RESEARCH.md` araştırmasına dayalı olarak planlandı.

---

## ✅ Sprint 2 — Security & Critical Fixes (P0) — DONE
Web desteği, güvenlik açıkları, WCAG P0 düzeltmeleri (FFK-11→18)

## ✅ Sprint 3 — Architecture & Quality (P1) — DONE
CI, DX iyileştirmeleri, a11y P1 tamamlama (FFK-19→24)

## ✅ Sprint 4 — VocabApp Feature Port (P1) — DONE
VocabApp'ten tüm feedback özelliklerinin Riverpod-free taşınması

| # | Task | Durum |
|---|------|-------|
| 1 | FeedbackCategory → 8 kategori (translation, featureRequest, accessibility) | ✅ |
| 2 | FeedbackEntry.fromJson / encode / decode | ✅ |
| 3 | Input sanitization (HTML injection koruması) | ✅ |
| 4 | FeedbackQueue abstract interface | ✅ |
| 5 | SharedPrefsQueue (offline persistence) | ✅ |
| 6 | ConnectivityService | ✅ |
| 7 | QueuedBackend (offline queue wrapper) | ✅ |
| 8 | SpeechRecognitionService (Riverpod-free STT port) | ✅ |
| 9 | FeedbackWidget: voice input, maxScreenshots=5, capture callback | ✅ |
| 10 | LocalFeedbackBackend + FeedbackDevViewer (emülatör debug tool) | ✅ |

## ✅ Sprint 5 — UX & pub.dev Hazırlık (P2) — DONE
Tema desteği, widget testleri, Dart doc, README, pubspec polish

| # | Task | Durum |
|---|------|-------|
| 1 | FeedbackThemeData + FeedbackTheme InheritedWidget | ✅ |
| 2 | Widget testleri: FeedbackWidget + FeedbackButton + QueuedBackend (32 test) | ✅ |
| 3 | Tüm public API'ye `///` Dart doc comment | ✅ |
| 4 | README güncelle (voice, queue, LocalBackend, theming örnekleri) | ✅ |
| 5 | pubspec: zengin description + topics (form, offline eklendi) | ✅ |

---

## Sprint 6 — Firebase Ekosistemi + Metadata & Events (P2)
**Odak:** İlk backend eklentisi, metadata otomatik toplama, analytics hooks, pub.dev yayını
**Kapasite:** 10 SP
**Kaynak:** NEW_FEATURES_RESEARCH.md F-01, F-12, F-15, F-17 + mevcut plan

| # | Task | Kategori | Efor | Kaynak |
|---|------|----------|------|--------|
| 1 | flutter_feedback_kit_firebase (Firestore + Storage backend paketi) | growth,arch | L=3 | F-01 |
| 2 | FeedbackMetadata — otomatik device/app info zenginleştirme | arch | S=1 | F-12 |
| 3 | FeedbackAnalytics interface (event callback hooks) | analytics,arch | S=1 | F-15 |
| 4 | FeedbackSessionContext — route/user/custom key-value context | arch | S=1 | F-17 |
| 5 | pub.dev yayını (flutter_feedback_kit v0.1.0) | growth | S=1 | PLAN |
| 6 | VocabApp'te flutter_feedback_kit_firebase tam entegrasyonu | growth | M=2 | PLAN |

> **Not F-01 (firebase paketi):** Ayrı pub.dev paketi. `FeedbackBackend` implement eder, `firebase_core` + `cloud_firestore` + `firebase_storage` bağımlılıkları sadece bu pakette.

---

## Sprint 7 — NPS + Smart Trigger + Sentry/Jira Backends (P2)
**Odak:** Ölçüm araçları, akıllı zamanlama, kurumsal backend entegrasyonları
**Kapasite:** 10 SP
**Kaynak:** NEW_FEATURES_RESEARCH.md F-02, F-03, F-06, F-07, F-10

| # | Task | Kategori | Efor | Kaynak |
|---|------|----------|------|--------|
| 1 | NPS / Promoter Score widget modülü | ui,analytics | M=2 | F-06 |
| 2 | Emoji CSAT rating widget (5 seviyeli mood skoru) | ui | S=1 | F-07 |
| 3 | flutter_feedback_kit_sentry (Sentry UserFeedback backend) | arch,growth | M=2 | F-02 |
| 4 | flutter_feedback_kit_jira (Jira Cloud issue backend) | arch,growth | M=2 | F-03 |
| 5 | FeedbackTrigger — koşullu prompt sistemi (minLaunches, minDays) | arch,ui | L=3 | F-10 |

> **Not F-10 (SmartTrigger):** `SharedPreferences` tabanlı durum takibi. `rate_my_app` koşul sistemini feedback için uyarlar. "Sonra sor / Gösterme" seçenekleri dahil.

---

## Sprint 8 — Screenshot Annotation + i18n (P3)
**Odak:** En büyük rekabet açığı (annotation), uluslararasılaştırma
**Kapasite:** 9 SP
**Kaynak:** NEW_FEATURES_RESEARCH.md F-05, F-09

| # | Task | Kategori | Efor | Kaynak |
|---|------|----------|------|--------|
| 1 | Screenshot annotation overlay (kalem, dikdörtgen, ok, blur) | ui | XL=5 | F-05 |
| 2 | Localization / i18n desteği (FeedbackLocalizations, EN+TR+DE+FR+ES) | ui,growth | M=2 | F-09 |
| 3 | Otomatik screen capture (`autoCapture: true`, RepaintBoundary) | ui | M=2 | F-08 |

> **Not F-05 (annotation):** `feedback` paketinin 1.6K beğenisinin ana kaynağı. CustomPainter tabanlı; renk seçici, undo/redo, privacy blur. Bu sprint'in odağı.

---

## Sprint 9 — Middleware + AI + Web/Desktop + Mason (P3)
**Odak:** Platform tamamlama, kurumsal pipeline, ekosistem araçları
**Kapasite:** 9 SP
**Kaynak:** NEW_FEATURES_RESEARCH.md F-11, F-13, F-16, F-18

| # | Task | Kategori | Efor | Kaynak |
|---|------|----------|------|--------|
| 1 | FeedbackMiddleware pipeline (MetadataEnricher, PiiSanitizer) | arch | L=3 | F-11 |
| 2 | Web + Desktop platform desteği (macOS, Windows, Linux, Web) | arch | L=3 | F-13 |
| 3 | AI kategori tespiti (keyword-based + opsiyonel LLM) | analytics,ui | M=2 | F-16 |
| 4 | Mason brick generator (feedback_kit_backend iskelet) | growth | S=1 | F-18 |

---

## Backlog (Sprint 10+)

| # | Özellik | Kaynak | Öncelik |
|---|---------|--------|---------|
| B-01 | flutter_feedback_kit_github (GitHub Issues backend) | F-04 | P3 |
| B-02 | EmailBackend (SendGrid / SMTP) | F-14 | P3 |
| B-03 | FeedbackEntry.npsScore + rating fields | F-06 yan etki | P3 |
| B-04 | flutter_feedback_kit_supabase | — | P3 |

---

## Diferansiasyon Özeti (Araştırma Bulgusu)

> **Pazar boşluğu:** Offline queue + voice input + backend-agnostik mimari kombinasyonu **hiçbir rakip pakette yok**.
> Sprint 4 bu üç özelliği tamamladı. Sprint 6-9 bu temeli ekosisteme (backend eklentileri) ve deneyime (NPS, annotation, i18n) dönüştürür.

| Rakip | Güçlü Yanı | Bizim Üstünlüğümüz |
|-------|-----------|---------------------|
| feedback (1.6K ⭐) | Annotation, Flutter Favorite, eklenti ekosistemi | Backend agnostik; offline queue; voice input |
| wiredash (300 ⭐) | NPS, GDPR EU cloud, tüm platformlar | SaaS bağımlılığı yok; kendi altyapını getir |
| rate_my_app | Koşullu prompt, app store yönlendirme | Yapılandırılmış backend pipeline |
| in_app_review (2.4K ⭐) | Native OS dialog, sıfır UX friksiyon | Zengin kategori + metadata + analytics |
