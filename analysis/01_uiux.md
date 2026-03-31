# UI/UX & Design Analiz Raporu
> flutter_feedback_kit | Sonnet 4.6 | 2026-03-30

---

## Mevcut Durum

### Güçlü Yanlar

- **Temiz API yüzeyi:** `FeedbackButton` ve `FeedbackWidget` ayrımı yerinde; embed veya FAB olarak kullanılabiliyor.
- **Pluggable backend:** `FeedbackBackend` soyutlaması iyi tasarlanmış; kullanıcı kendi backend'ini getirebiliyor.
- **BottomSheet entegrasyonu:** `isScrollControlled: true` ve `viewInsets` kullanımı klavye yönetimini doğru çözüyor.
- **Loading state:** Submit sırasında `CircularProgressIndicator` ile buton devre dışı bırakılıyor; çift gönderim engelleniyor.
- **Error/Success feedback:** `ScaffoldMessenger.showSnackBar` ile kullanıcıya geri bildirim veriliyor.
- **Screenshot ekleme:** base64 encode / decode + `_ScreenshotRow` bileşeni mantıklı bölünmüş.
- **Minimal bağımlılık:** Sadece `http` ve `image_picker`; paket ağırlığı düşük.
- **`submitLabel` / `successMessage` parametreleri:** Temel metin özelleştirmesi mevcut.

### Puan: 4.5/10

---

## Kritik Eksikler

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **Tema desteği yok** — tüm dekorasyon `const InputDecoration(...)` ve `OutlinedButton` hard-code; `Theme.of(context)` kullanılmıyor | High | `FeedbackThemeData` veya builder callback ekle; mevcut decoration'ları tema renklerine bağla | M |
| 2 | **`FeedbackButton` özelleştirilemez** — FAB tipi ve etiketi sabit; `child` widget kabul ediyor ama icon, FAB boyutu, konumu, şekli değiştirilemiyor | High | `iconWidget`, `fabType` (normal/small/large), `label` override veya tam custom builder ekle | M |
| 3 | **Error mesajı kullanıcıya ham gösteriliyor** — `'Failed to send feedback: $e'` string'i son kullanıcıya teknik hata içeriği sızdırıyor | High | `errorMessage` parametresi ekle; varsayılan lokalize mesaj kullan; `$e` sadece `onError` callback'ine git | S |
| 4 | **Lokalizasyon desteği yok** — tüm label'lar (`'Category'`, `'Message'`, `'Send Feedback'`, `'Bug'`, vb.) hard-code İngilizce; i18n imkansız | High | `FeedbackLocalizations` sınıfı veya `labels` map parametresi; `FeedbackCategory.label` getter'ı override edilebilmeli | M |
| 5 | **Maksimum ekran görüntüsü sayısı sabit kodlanmış** — `screenshots.length < 3` satır 201'de hard-code; API'de expose edilmiyor | Med | `maxScreenshots` parametresi `FeedbackWidget`'a eklensin | S |
| 6 | **`FeedbackButton` widget'a customization props geçirilmiyor** — `FeedbackWidget`'ın `categories`, `maxMessageLength`, `submitLabel`, `successMessage` parametreleri `FeedbackButton` üzerinden erişilemiyor | High | `FeedbackButton`'a aynı parametreler eklenmeli ya da `feedbackWidgetBuilder` callback'i verilmeli | S |

---

## İyileştirme Önerileri

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **`FeedbackThemeData` sınıfı ekle** — Wiredash/BetterFeedback gibi paket-özel tema nesnesi; renk, border radius, buton stili, input decoration tanımlanabilsin | High | `FeedbackThemeData` + `FeedbackTheme` inherited widget; `FeedbackWidget` build'de tema okusu | M |
| 2 | **Başarı durumunda SnackBar yerine widget içi feedback** — BottomSheet kapanıyor, SnackBar anlık görünüyor ve kaybolabiliyor; daha iyi UX için inline success state | Med | `_FeedbackPhase` enum (form / submitting / success) ile widget içi "Teşekkürler" ekranı | M |
| 3 | **Ekran görüntüsü önizlemesi yetersiz** — 64x64 thumbnail çok küçük; silme için `GestureDetector` + `CircleAvatar` tıklama hedefi 20px (min. 48x48 olmalı) | Med | Thumbnail boyutunu 80x80'e çıkar; silme butonu için `IconButton` veya `InkWell` ile 48x48 hit area | S |
| 4 | **`FeedbackButton` her zaman FAB** — Paketi kullanan geliştirici AppBar action, Drawer item veya inline buton olarak kullanmak isteyebilir | Med | `FeedbackButton` → `FeedbackLauncher` olarak yeniden adlandır ve `builder` callback sun; FAB örneği README'de göster | M |
| 5 | **Otomatik ekran görüntüsü alma desteği** — `my_feedback` ve `BetterFeedback` gibi mevcut ekranın screenshot'ını otomatik ekleme; kullanıcı deneyimini dramatik artırır | High | `captureCurrentScreen: bool` parametresi; `RenderRepaintBoundary` ile current screen yakala | L |
| 6 | **Rating / NPS widget** — Yıldız puanlama veya NPS (0-10) alanı; Wiredash'in en güçlü özelliklerinden biri; paketin değerini artırır | High | `FeedbackWidget`'a `showRating: bool` ve `ratingWidget` builder ekle | L |
| 7 | **Web desteği teyidi** — `dart:io`'nun `Platform.operatingSystem` kullanımı web'de `Unsupported operation: Platform._operatingSystem` hatasına yol açar | High | `kIsWeb` kontrolü ekle; platform tespiti için `universal_io` veya conditional import kullan | S |
| 8 | **`TextFormField` character counter görsel iyileştirme** — `maxLength` ile otomatik gelen counter doğru ama stilize edilemiyor; renk ve stil tema'ya bağlanmalı | Low | `CounterStyle` decoration parametresi ile tema entegrasyonu | S |
| 9 | **Accessibility (erişilebilirlik)** — Screenshot ekleme butonunda ve thumbnail silme butonunda `Semantics` / `tooltip` yok; screen reader desteği eksik | Med | `Semantics` wrapper + `Tooltip` ekle; silme butonuna `semanticLabel: 'Screenshot sil'` | S |
| 10 | **`FeedbackCategory` dışarıdan genişletilemiyor** — `enum` olduğu için özel kategoriler eklenemiyor; kullanıcılar sadece 5 sabit kategoriyle sınırlı | Med | `FeedbackCategory` abstract class veya `interface` yap; ya da `FeedbackCategoryItem(label, value)` sınıfı tanımla | M |

---

## Kesin Olmalı

1. **`FeedbackThemeData` / tema entegrasyonu** — Paketi yayınlamadan önce tüm hard-coded renk ve stil'lerin tema üzerinden gelmesi gerekir; aksi hâlde dark mode kırık görünür.
2. **Web platformu uyumluluğu** — `dart:io Platform` çağrısı web'i çökertiyor; Flutter paketleri için web desteği zorunlu referans alınmalı.
3. **`FeedbackButton` → widget customization props geçişi** — En temel kullanım senaryosu FAB + BottomSheet olduğu için, `FeedbackButton`'un altındaki `FeedbackWidget`'ı özelleştiremezseniz paket pratikte kullanışsız.
4. **Hata mesajlarında teknik detay sızdırılmaması** — `$e` içeren ham hata string'i UX güvenlik zaafiyeti; kesinlikle kaldırılmalı.

---

## Kesin Değişmeli

1. **`FeedbackCategory` enum → genişletilebilir yapı** — Enum olması üçüncü parti kullanıcıların özel kategori eklemesini imkânsız kılıyor; bu bir paket sınırlaması olarak kabul edilemez.
2. **Screenshot silme hit area** — 20px `CircleAvatar` üzerine `GestureDetector` WCAG standartlarını karşılamıyor (min 48dp); mutlaka büyütülmeli.
3. **`maxScreenshots` parametresi** — `3` sabit kodlanmış; paket kullanıcısı farklı limit isteyebilir.

---

## Nice-to-Have

1. **Otomatik ekran görüntüsü yakalama** (`captureCurrentScreen: true`)
2. **NPS / yıldız rating alanı** seçimli olarak gösterilebilir
3. **`FeedbackWidget` için animasyon** — Form → loading → success geçişinde `AnimatedSwitcher`
4. **Lokaliz edilmiş `FeedbackCategory` label'ları** için ARB/intl entegrasyonu
5. **Drag-to-dismiss** davranışı için `showModalBottomSheet` `enableDrag: true` (zaten default, ama `DraggableScrollableSheet` ile min height kontrolü)
6. **`FeedbackButton` konumu** — `floatingActionButtonLocation` hook'u veya alternatif yerleştirme örnekleri
7. **Şablon geri bildirim metinleri** — Bug raporlama için placeholder hint text özelleştirmesi

---

## Referanslar

- [feedback (BetterFeedback) — pub.dev](https://pub.dev/packages/feedback) — `FeedbackThemeData`, screenshot annotation, localizations referans mimarisi
- [wiredash — pub.dev](https://pub.dev/packages/wiredash) — `WiredashThemeData`, NPS, multi-step flow; sektör standardı
- [my_feedback — pub.dev](https://pub.dev/packages/my_feedback) — Screen recording, screenshot annotation
- [Flutter Gems — Feedback kategori listesi](https://fluttergems.dev/feedback/) — Alandaki tüm paketlerin karşılaştırması
- [Flutter adaptive design best practices](https://docs.flutter.dev/ui/adaptive-responsive/best-practices) — Widget parçalama ve tema uyumu
