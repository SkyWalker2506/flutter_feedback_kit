# flutter_feedback_kit — Sprint Plan
> Güncellendi: 2026-03-31 | Sprint 2+3+4 tamamlandı

Sprint 1→4 tamamlandı. Aşağıdaki planlar mevcut durumu yansıtmaktadır.

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

---

## Sprint 5 — UX & pub.dev Hazırlık (P2)
**Odak:** Tema desteği, widget testleri, Dart doc, pub.dev yayın hazırlığı
**Kapasite:** 9 SP

| # | Task | Kategori | Efor | Öncelik |
|---|------|----------|------|---------|
| 1 | FeedbackThemeData — Theme.of(context) entegrasyonu | ui | M=2 | P2 |
| 2 | Widget testleri: FeedbackWidget + FeedbackButton + QueuedBackend | arch | M=2 | P2 |
| 3 | Tüm public API'ye `///` Dart doc comment | arch | M=2 | P2 |
| 4 | README güncelle (voice, queue, LocalBackend örnekleri) | arch | S=1 | P2 |
| 5 | pubspec topics + description polish | arch | S=1 | P2 |
| 6 | VocabApp entegrasyon testi (flutter_feedback_kit path dep) | arch | S=1 | P2 |

---

## Sprint 6 — Firebase Backend & Ecosystem (P3)
**Odak:** flutter_feedback_kit_firebase paketi, screenshot annotation, pub.dev yayını
**Kapasite:** 9 SP

| # | Task | Kategori | Efor | Öncelik |
|---|------|----------|------|---------|
| 1 | flutter_feedback_kit_firebase (Firebase Firestore + Storage backend) | growth | L=3 | P3 |
| 2 | VocabApp'te flutter_feedback_kit_firebase ile tam entegrasyon | growth | M=2 | P3 |
| 3 | Screenshot annotation overlay (çizim katmanı) | ui,growth | XL=5 | P3 |
| 4 | Publish to pub.dev | growth | S=1 | P3 |
