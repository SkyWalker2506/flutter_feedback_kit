import '../entities/feedback_entry.dart';

abstract class FeedbackBackend {
  Future<void> submit(FeedbackEntry entry);

  void dispose() {}
}
