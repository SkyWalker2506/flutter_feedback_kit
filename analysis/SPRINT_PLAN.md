# flutter_feedback_kit — Sprint Plan
> Güncellendi: 2026-03-31 | Sprint 2+3+4+5+6+7+8 tamamlandı

Sprint 1→8 tamamlandı.

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

## ✅ Sprint 6 — Firebase Ekosistemi + Metadata & Events (P2) — DONE

| # | Task | Durum |
|---|------|-------|
| 1 | flutter_feedback_kit_firebase (Firestore + Storage backend paketi) | ✅ |
| 2 | FeedbackMetadata + FeedbackMetadataCollector | ✅ |
| 3 | FeedbackAnalytics interface (event callback hooks) | ✅ |
| 4 | FeedbackSessionContext (userId, currentRoute, extra KVs) | ✅ |
| 5 | QueuedBackend.onQueued callback + lastSubmitWasQueued flag | ✅ |
| 6 | FeedbackWidget: onQueued, analytics, metadataCollector, sessionContextBuilder | ✅ |

---

## ✅ Sprint 7 — NPS + Smart Trigger + Sentry/Jira Backends (P2) — DONE

| # | Task | Durum |
|---|------|-------|
| 1 | FeedbackNpsWidget (0–10 NPS scale) | ✅ |
| 2 | FeedbackRatingWidget (emoji CSAT 1–5) | ✅ |
| 3 | flutter_feedback_kit_sentry (Sentry UserFeedback backend) | ✅ |
| 4 | flutter_feedback_kit_jira (Jira Cloud issue backend) | ✅ |
| 5 | FeedbackTrigger (minLaunches, minDays, repeatAfterDays, oncePerVersion) | ✅ |
| 6 | FeedbackEntry.rating + npsScore fields | ✅ |
| 7 | FeedbackButton.trigger param | ✅ |

---

## ✅ Sprint 8 — Screenshot Annotation + i18n (P3) — DONE

| # | Task | Durum |
|---|------|-------|
| 1 | FeedbackAnnotationOverlay (CustomPainter, colour palette, undo, stroke width) | ✅ |
| 2 | FeedbackLocalizations + 5 dil (EN, TR, DE, FR, ES) + delegate | ✅ |
| 3 | autoCapture param (FeedbackWidget + FeedbackButton) | ✅ |
| 4 | FeedbackWidget: i18n entegrasyonu (tüm string'ler localizations'dan) | ✅ |

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
