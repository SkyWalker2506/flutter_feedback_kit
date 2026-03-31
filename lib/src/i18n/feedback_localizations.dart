import 'package:flutter/material.dart';

/// Localisation strings for flutter_feedback_kit widgets.
///
/// To add a language, extend [FeedbackLocalizations] and register the delegate:
///
/// ```dart
/// MaterialApp(
///   localizationsDelegates: [
///     FeedbackLocalizationsDelegate.delegate,
///     GlobalMaterialLocalizations.delegate,
///     GlobalWidgetsLocalizations.delegate,
///   ],
///   supportedLocales: FeedbackLocalizationsDelegate.supportedLocales,
/// )
/// ```
///
/// Or pass a custom instance directly to [FeedbackWidget.localizations].
abstract class FeedbackLocalizations {
  const FeedbackLocalizations();

  /// Resolves from the widget tree, falling back to English.
  static FeedbackLocalizations of(BuildContext context) {
    return Localizations.of<FeedbackLocalizations>(
          context, FeedbackLocalizations) ??
        const EnFeedbackLocalizations();
  }

  String get categoryLabel;
  String get messageLabel;
  String get messagePlaceholder;
  String get messageRequired;
  String get submitLabel;
  String get successMessage;
  String get queuedMessage;
  String get microphoneNotAvailable;
  String get screenshotLabel;
  String get captureScreenLabel;
  String get chooseFromGalleryLabel;
  String get stopListeningTooltip;
  String get voiceInputTooltip;
  String get sendingLabel;
  String get ratingLabel;
  String get npsQuestion;
  String get annotationSaveLabel;
  String get annotationDiscardLabel;
  String get annotationUndoTooltip;
  String get feedbackSendError;
  String get removeScreenshot;
  String get npsNotLikely;
  String get npsVeryLikely;
}

// ─── English ──────────────────────────────────────────────────────────────────

/// Default English strings.
class EnFeedbackLocalizations extends FeedbackLocalizations {
  const EnFeedbackLocalizations();

  @override String get categoryLabel => 'Category';
  @override String get messageLabel => 'Message';
  @override String get messagePlaceholder => 'Describe your feedback…';
  @override String get messageRequired => 'Message is required';
  @override String get submitLabel => 'Send Feedback';
  @override String get successMessage => 'Thank you for your feedback!';
  @override String get queuedMessage =>
      'Saved offline. Will send when connected.';
  @override String get microphoneNotAvailable => 'Microphone not available';
  @override String get screenshotLabel => 'Screenshot';
  @override String get captureScreenLabel => 'Capture screen';
  @override String get chooseFromGalleryLabel => 'Choose from gallery';
  @override String get stopListeningTooltip => 'Stop listening';
  @override String get voiceInputTooltip => 'Voice input';
  @override String get sendingLabel => 'Sending feedback, please wait';
  @override String get ratingLabel => 'How do you feel?';
  @override String get npsQuestion =>
      'How likely are you to recommend this app to a friend?';
  @override String get annotationSaveLabel => 'Save';
  @override String get annotationDiscardLabel => 'Discard';
  @override String get annotationUndoTooltip => 'Undo';
  @override String get feedbackSendError =>
      'Failed to send feedback. Please try again.';
  @override String get removeScreenshot => 'Remove screenshot';
  @override String get npsNotLikely => 'Not likely';
  @override String get npsVeryLikely => 'Very likely';
}

// ─── Turkish ──────────────────────────────────────────────────────────────────

/// Turkish strings.
class TrFeedbackLocalizations extends FeedbackLocalizations {
  const TrFeedbackLocalizations();

  @override String get categoryLabel => 'Kategori';
  @override String get messageLabel => 'Mesaj';
  @override String get messagePlaceholder => 'Geri bildiriminizi açıklayın…';
  @override String get messageRequired => 'Mesaj gereklidir';
  @override String get submitLabel => 'Geri Bildirim Gönder';
  @override String get successMessage => 'Geri bildiriminiz için teşekkürler!';
  @override String get queuedMessage =>
      'Çevrimdışı kaydedildi. Bağlantı sağlandığında gönderilecek.';
  @override String get microphoneNotAvailable => 'Mikrofon kullanılamıyor';
  @override String get screenshotLabel => 'Ekran Görüntüsü';
  @override String get captureScreenLabel => 'Ekranı yakala';
  @override String get chooseFromGalleryLabel => 'Galeriden seç';
  @override String get stopListeningTooltip => 'Dinlemeyi durdur';
  @override String get voiceInputTooltip => 'Sesli giriş';
  @override String get sendingLabel => 'Gönderiliyor, lütfen bekleyin';
  @override String get ratingLabel => 'Nasıl hissediyorsunuz?';
  @override String get npsQuestion =>
      'Bu uygulamayı bir arkadaşınıza önerme olasılığınız nedir?';
  @override String get annotationSaveLabel => 'Kaydet';
  @override String get annotationDiscardLabel => 'Vazgeç';
  @override String get annotationUndoTooltip => 'Geri al';
  @override String get feedbackSendError =>
      'Geri bildirim gönderilemedi. Lütfen tekrar deneyin.';
  @override String get removeScreenshot => 'Ekran görüntüsünü kaldır';
  @override String get npsNotLikely => 'Pek olası değil';
  @override String get npsVeryLikely => 'Çok olası';
}

// ─── German ───────────────────────────────────────────────────────────────────

/// German strings.
class DeFeedbackLocalizations extends FeedbackLocalizations {
  const DeFeedbackLocalizations();

  @override String get categoryLabel => 'Kategorie';
  @override String get messageLabel => 'Nachricht';
  @override String get messagePlaceholder => 'Beschreiben Sie Ihr Feedback…';
  @override String get messageRequired => 'Nachricht ist erforderlich';
  @override String get submitLabel => 'Feedback senden';
  @override String get successMessage => 'Vielen Dank für Ihr Feedback!';
  @override String get queuedMessage =>
      'Offline gespeichert. Wird gesendet, sobald Sie verbunden sind.';
  @override String get microphoneNotAvailable => 'Mikrofon nicht verfügbar';
  @override String get screenshotLabel => 'Screenshot';
  @override String get captureScreenLabel => 'Bildschirm aufnehmen';
  @override String get chooseFromGalleryLabel => 'Aus Galerie wählen';
  @override String get stopListeningTooltip => 'Zuhören stoppen';
  @override String get voiceInputTooltip => 'Spracheingabe';
  @override String get sendingLabel => 'Wird gesendet, bitte warten';
  @override String get ratingLabel => 'Wie fühlen Sie sich?';
  @override String get npsQuestion =>
      'Wie wahrscheinlich empfehlen Sie diese App einem Freund?';
  @override String get annotationSaveLabel => 'Speichern';
  @override String get annotationDiscardLabel => 'Verwerfen';
  @override String get annotationUndoTooltip => 'Rückgängig';
  @override String get feedbackSendError =>
      'Feedback konnte nicht gesendet werden. Bitte versuchen Sie es erneut.';
  @override String get removeScreenshot => 'Screenshot entfernen';
  @override String get npsNotLikely => 'Unwahrscheinlich';
  @override String get npsVeryLikely => 'Sehr wahrscheinlich';
}

// ─── French ───────────────────────────────────────────────────────────────────

/// French strings.
class FrFeedbackLocalizations extends FeedbackLocalizations {
  const FrFeedbackLocalizations();

  @override String get categoryLabel => 'Catégorie';
  @override String get messageLabel => 'Message';
  @override String get messagePlaceholder => 'Décrivez votre retour…';
  @override String get messageRequired => 'Le message est requis';
  @override String get submitLabel => 'Envoyer le retour';
  @override String get successMessage => 'Merci pour votre retour !';
  @override String get queuedMessage =>
      'Sauvegardé hors ligne. Sera envoyé une fois connecté.';
  @override String get microphoneNotAvailable => 'Microphone non disponible';
  @override String get screenshotLabel => 'Capture';
  @override String get captureScreenLabel => 'Capturer l\'écran';
  @override String get chooseFromGalleryLabel => 'Choisir dans la galerie';
  @override String get stopListeningTooltip => 'Arrêter d\'écouter';
  @override String get voiceInputTooltip => 'Saisie vocale';
  @override String get sendingLabel => 'Envoi en cours, veuillez patienter';
  @override String get ratingLabel => 'Comment vous sentez-vous ?';
  @override String get npsQuestion =>
      'Quelle est la probabilité que vous recommandiez cette app ?';
  @override String get annotationSaveLabel => 'Enregistrer';
  @override String get annotationDiscardLabel => 'Annuler';
  @override String get annotationUndoTooltip => 'Annuler';
  @override String get feedbackSendError =>
      'Échec de l\'envoi du retour. Veuillez réessayer.';
  @override String get removeScreenshot => 'Supprimer la capture';
  @override String get npsNotLikely => 'Peu probable';
  @override String get npsVeryLikely => 'Très probable';
}

// ─── Spanish ──────────────────────────────────────────────────────────────────

/// Spanish strings.
class EsFeedbackLocalizations extends FeedbackLocalizations {
  const EsFeedbackLocalizations();

  @override String get categoryLabel => 'Categoría';
  @override String get messageLabel => 'Mensaje';
  @override String get messagePlaceholder => 'Describe tu opinión…';
  @override String get messageRequired => 'El mensaje es obligatorio';
  @override String get submitLabel => 'Enviar opinión';
  @override String get successMessage => '¡Gracias por tu opinión!';
  @override String get queuedMessage =>
      'Guardado sin conexión. Se enviará cuando te conectes.';
  @override String get microphoneNotAvailable => 'Micrófono no disponible';
  @override String get screenshotLabel => 'Captura';
  @override String get captureScreenLabel => 'Capturar pantalla';
  @override String get chooseFromGalleryLabel => 'Elegir de la galería';
  @override String get stopListeningTooltip => 'Dejar de escuchar';
  @override String get voiceInputTooltip => 'Entrada de voz';
  @override String get sendingLabel => 'Enviando, por favor espera';
  @override String get ratingLabel => '¿Cómo te sientes?';
  @override String get npsQuestion =>
      '¿Con qué probabilidad recomendarías esta app?';
  @override String get annotationSaveLabel => 'Guardar';
  @override String get annotationDiscardLabel => 'Descartar';
  @override String get annotationUndoTooltip => 'Deshacer';
  @override String get feedbackSendError =>
      'Error al enviar la opinión. Por favor, inténtalo de nuevo.';
  @override String get removeScreenshot => 'Eliminar captura';
  @override String get npsNotLikely => 'Poco probable';
  @override String get npsVeryLikely => 'Muy probable';
}

// ─── Arabic ───────────────────────────────────────────────────────────────────

/// Arabic strings.
class ArFeedbackLocalizations extends FeedbackLocalizations {
  const ArFeedbackLocalizations();

  @override String get categoryLabel => 'الفئة';
  @override String get messageLabel => 'الرسالة';
  @override String get messagePlaceholder => 'صف ملاحظاتك…';
  @override String get messageRequired => 'الرسالة مطلوبة';
  @override String get submitLabel => 'إرسال الملاحظات';
  @override String get successMessage => 'شكراً على ملاحظاتك!';
  @override String get queuedMessage =>
      'تم الحفظ بدون اتصال. سيتم الإرسال عند الاتصال.';
  @override String get microphoneNotAvailable => 'الميكروفون غير متاح';
  @override String get screenshotLabel => 'لقطة الشاشة';
  @override String get captureScreenLabel => 'التقاط الشاشة';
  @override String get chooseFromGalleryLabel => 'اختر من المعرض';
  @override String get stopListeningTooltip => 'إيقاف الاستماع';
  @override String get voiceInputTooltip => 'الإدخال الصوتي';
  @override String get sendingLabel => 'جارٍ الإرسال، يرجى الانتظار';
  @override String get ratingLabel => 'كيف تشعر؟';
  @override String get npsQuestion =>
      'ما مدى احتمال توصيتك بهذا التطبيق لصديق؟';
  @override String get annotationSaveLabel => 'حفظ';
  @override String get annotationDiscardLabel => 'تجاهل';
  @override String get annotationUndoTooltip => 'تراجع';
  @override String get feedbackSendError =>
      'فشل إرسال الملاحظات. يرجى المحاولة مرة أخرى.';
  @override String get removeScreenshot => 'إزالة لقطة الشاشة';
  @override String get npsNotLikely => 'غير محتمل';
  @override String get npsVeryLikely => 'محتمل جداً';
}

// ─── Japanese ─────────────────────────────────────────────────────────────────

/// Japanese strings.
class JaFeedbackLocalizations extends FeedbackLocalizations {
  const JaFeedbackLocalizations();

  @override String get categoryLabel => 'カテゴリ';
  @override String get messageLabel => 'メッセージ';
  @override String get messagePlaceholder => 'フィードバックを入力してください…';
  @override String get messageRequired => 'メッセージは必須です';
  @override String get submitLabel => 'フィードバックを送信';
  @override String get successMessage => 'フィードバックをありがとうございます！';
  @override String get queuedMessage =>
      'オフラインで保存しました。接続時に送信されます。';
  @override String get microphoneNotAvailable => 'マイクが使用できません';
  @override String get screenshotLabel => 'スクリーンショット';
  @override String get captureScreenLabel => '画面をキャプチャ';
  @override String get chooseFromGalleryLabel => 'ギャラリーから選択';
  @override String get stopListeningTooltip => '音声入力を停止';
  @override String get voiceInputTooltip => '音声入力';
  @override String get sendingLabel => '送信中、しばらくお待ちください';
  @override String get ratingLabel => 'どう感じますか？';
  @override String get npsQuestion =>
      'このアプリを友人に勧める可能性はどのくらいですか？';
  @override String get annotationSaveLabel => '保存';
  @override String get annotationDiscardLabel => '破棄';
  @override String get annotationUndoTooltip => '元に戻す';
  @override String get feedbackSendError =>
      'フィードバックの送信に失敗しました。もう一度お試しください。';
  @override String get removeScreenshot => 'スクリーンショットを削除';
  @override String get npsNotLikely => '可能性が低い';
  @override String get npsVeryLikely => '非常に可能性が高い';
}

// ─── Chinese (Simplified) ─────────────────────────────────────────────────────

/// Chinese Simplified strings.
class ZhFeedbackLocalizations extends FeedbackLocalizations {
  const ZhFeedbackLocalizations();

  @override String get categoryLabel => '类别';
  @override String get messageLabel => '消息';
  @override String get messagePlaceholder => '请描述您的反馈…';
  @override String get messageRequired => '消息不能为空';
  @override String get submitLabel => '提交反馈';
  @override String get successMessage => '感谢您的反馈！';
  @override String get queuedMessage => '已离线保存，连接后将自动发送。';
  @override String get microphoneNotAvailable => '麦克风不可用';
  @override String get screenshotLabel => '截图';
  @override String get captureScreenLabel => '截取屏幕';
  @override String get chooseFromGalleryLabel => '从相册选择';
  @override String get stopListeningTooltip => '停止录音';
  @override String get voiceInputTooltip => '语音输入';
  @override String get sendingLabel => '正在发送，请稍候';
  @override String get ratingLabel => '您的感受如何？';
  @override String get npsQuestion => '您向朋友推荐此应用的可能性有多大？';
  @override String get annotationSaveLabel => '保存';
  @override String get annotationDiscardLabel => '丢弃';
  @override String get annotationUndoTooltip => '撤销';
  @override String get feedbackSendError => '发送反馈失败，请重试。';
  @override String get removeScreenshot => '删除截图';
  @override String get npsNotLikely => '不太可能';
  @override String get npsVeryLikely => '非常可能';
}

// ─── Delegate ─────────────────────────────────────────────────────────────────

/// [LocalizationsDelegate] for registering flutter_feedback_kit in
/// [MaterialApp.localizationsDelegates].
class FeedbackLocalizationsDelegate
    extends LocalizationsDelegate<FeedbackLocalizations> {
  const FeedbackLocalizationsDelegate();

  /// Convenience singleton.
  static const delegate = FeedbackLocalizationsDelegate();

  /// Locales supported out of the box.
  static const supportedLocales = [
    Locale('en'),
    Locale('tr'),
    Locale('de'),
    Locale('fr'),
    Locale('es'),
    Locale('ar'),
    Locale('ja'),
    Locale('zh'),
  ];

  @override
  bool isSupported(Locale locale) =>
      supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<FeedbackLocalizations> load(Locale locale) async =>
      switch (locale.languageCode) {
        'tr' => const TrFeedbackLocalizations(),
        'de' => const DeFeedbackLocalizations(),
        'fr' => const FrFeedbackLocalizations(),
        'es' => const EsFeedbackLocalizations(),
        'ar' => const ArFeedbackLocalizations(),
        'ja' => const JaFeedbackLocalizations(),
        'zh' => const ZhFeedbackLocalizations(),
        _ => const EnFeedbackLocalizations(),
      };

  @override
  bool shouldReload(FeedbackLocalizationsDelegate old) => false;
}
