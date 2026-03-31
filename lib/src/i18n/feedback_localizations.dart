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
        _ => const EnFeedbackLocalizations(),
      };

  @override
  bool shouldReload(FeedbackLocalizationsDelegate old) => false;
}
