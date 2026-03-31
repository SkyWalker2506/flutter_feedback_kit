// Domain
export 'src/domain/entities/feedback_category.dart';
export 'src/domain/entities/feedback_entry.dart';
export 'src/domain/entities/feedback_metadata.dart';
export 'src/domain/entities/feedback_session_context.dart';
export 'src/domain/repositories/feedback_analytics.dart';
export 'src/domain/repositories/feedback_backend.dart';
export 'src/domain/repositories/feedback_queue.dart';
export 'src/domain/feedback_middleware.dart';
export 'src/domain/middlewares/logging_middleware.dart';

// Data
export 'src/data/backends/webhook_backend.dart';
export 'src/data/backends/queued_backend.dart';
export 'src/data/queue/shared_prefs_queue.dart';

// Services
export 'src/services/connectivity_service.dart';
export 'src/services/feedback_trigger.dart';
export 'src/services/metadata_collector.dart';
export 'src/services/speech_recognition_service.dart';

// i18n
export 'src/i18n/feedback_localizations.dart';

// Presentation
export 'src/presentation/feedback_annotation_overlay.dart';
export 'src/presentation/feedback_button.dart';
export 'src/presentation/feedback_nps_widget.dart';
export 'src/presentation/feedback_rating_widget.dart';
export 'src/presentation/feedback_theme.dart';
export 'src/presentation/feedback_widget.dart';
