# Performance Analiz Raporu (Hızlı Tarama)
> flutter_feedback_kit | Sonnet 4.6

## Mevcut Durum

### Güçlü Yanlar
- `FeedbackButton` `StatelessWidget` olarak doğru tasarlanmış — gereksiz rebuild yok
- `_ScreenshotRow` ayrı `StatelessWidget`'a çıkarılmış — iyi ayrışma
- `WebhookBackend` constructor injection ile `http.Client` alıyor — test edilebilir, nesne yaşam döngüsü dışarıdan yönetilebilir
- `_messageController.dispose()` implement edilmiş — bellek sızıntısı yok
- `timeout` parametresi var ve varsayılan 15 sn — iyi
- `mounted` check'leri tüm async işlem sonralarında mevcut
- Widget state minimal tutulmuş: sadece `_selectedCategory`, `_screenshots`, `_isSubmitting`

### Puan: 6/10

---

## Kritik Eksikler

| # | Sorun | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **base64Encode ana thread'de senkron** — `_pickScreenshot()`'ta `File.readAsBytes()` sonrası `base64Encode(bytes)` doğrudan UI thread'inde çalışıyor; büyük resimler UI'ı dondurabilir | Yüksek — >1 MB görselde frame drop | `compute()` veya `Isolate.run()` ile arka plana taşı | Orta |
| 2 | **`Image.memory` her rebuild'de base64Decode** — `_ScreenshotRow.build()` içinde `base64Decode(screenshots[i])` her widget rebuild'inde tekrar decode ediliyor | Orta — liste uzadıkça gereksiz CPU | `Uint8List` listesi tut veya `MemoryImage` cache kullan | Orta |
| 3 | **Sınırsız screenshot boyutu** — `maxMessageLength` var ama screenshot başına boyut sınırı yok; 3 × 10 MB = 30 MB base64 payload webhook'a gönderilir | Yüksek — OOM riski + ağ timeout | `maxScreenshotBytes` parametresi ekle, seçimde resize uygula | Orta |
| 4 | **`ImagePicker.pickImage` compress/resize yok** — orijinal çözünürlük dosyadan okunuyor; `imageQuality` ve `maxWidth`/`maxHeight` parametreleri kullanılmıyor | Yüksek — gereksiz bellek ve bant genişliği tüketimi | `picker.pickImage(source: ..., imageQuality: 60, maxWidth: 800)` | Düşük |

---

## İyileştirme Önerileri

| # | Öneri | Etki | Çözüm | Efor |
|---|-------|------|-------|------|
| 1 | **`_categories` her build'de yeniden hesaplanıyor** — `_FeedbackWidgetState.build()` sırasında `widget.categories ?? FeedbackCategory.values` getter'ı çağrılıyor | Düşük — getter basit ama `initState`'e taşımak daha doğru | `late final _categories` olarak `initState`'de hesapla | Düşük |
| 2 | **`DropdownMenuItem` listesi her build'de yeniden oluşturuluyor** — `_categories.map(...).toList()` her `build()` çağrısında yeni liste üretiyor | Düşük — küçük liste ama gereksiz allocation | `initState`'de cache'le | Düşük |
| 3 | **`FeedbackButton` içinde `MediaQuery.of(context)` builder dışı context kullanımı** — `builder: (_)` içinde dış `context`'ten `MediaQuery.of(context).viewInsets` okunuyor; keyboard değişimlerinde rebuild tetiklenmiyor | Orta — klavye açıkken bottom sheet içerik kayması | `builder` parametresine gelen `_` context'i kullan | Düşük |
| 4 | **`http.Client` dispose edilmiyor** — `WebhookBackend` varsayılan `http.Client()` oluşturuyor ama `close()` çağrısı yok; `httpClient` dışarıdan enjekte edilmezse kaynak sızıntısı olabilir | Düşük-Orta — uzun süreli kullanımda soket pool birikimi | `WebhookBackend`'e `dispose()` metodu ekle veya `close_on_done` mantığı | Düşük |
| 5 | **Isolate kullanımı gerekiyor mu?** — Mevcut yük: dosya okuma + base64 encode. Bu işlemler için `compute()` yeterli; tam `Isolate.spawn` overkill olur. | — | `compute(base64Encode, bytes)` ile çöz | Düşük |
| 6 | **`_screenshots` state'i `List<String>` (base64) tutuyor** — Hem encode hem decode maliyetini iki kez öde. `List<Uint8List>` tutup sadece submit anında encode etmek daha verimli | Orta | State'i `List<Uint8List>` yap, submit'te encode et | Orta |

---

## Kesin Olmalı

1. **`ImagePicker.pickImage`'da `imageQuality` ve `maxWidth` parametrelerini kullan** — Tek satır değişiklik, büyük etki. Herhangi bir screenshot boyutu kontrolü olmadan paket production'da sorun yaratır.
2. **`base64Encode` işlemini `compute()` ile arka plana taşı** — UI thread koruması için zorunlu; büyük görüntülerde jank kaçınılmaz.
3. **`WebhookBackend.dispose()` metodu ekle** — HTTP client'ın yaşam döngüsünü kapat; paket kullanıcıları widget dispose ettiğinde client'ı da kapatabilmeli.

---

## Nice-to-Have

- `_ScreenshotRow`'da `Image.memory` yerine `MemoryImage` + `Image` widget kombinasyonu ile decode cache kullan
- `_categories` ve `DropdownMenuItem` listesini `initState`'de cache'le
- `FeedbackButton`'daki `MediaQuery` context sorununu düzelt
- Screenshot'lar için önizleme loading indicator ekle (async decode görünürlüğü)
- `submit()` metoduna retry mekanizması (exponential backoff) eklemeyi düşün
