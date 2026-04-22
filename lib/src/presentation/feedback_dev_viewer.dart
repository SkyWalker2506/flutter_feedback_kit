import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'feedback_dev_viewer_io.dart'
    if (dart.library.html) 'feedback_dev_viewer_web.dart' as impl;

/// In-app viewer for feedback saved by [LocalFeedbackBackend].
/// Add this screen to your debug-only navigation.
///
/// **Not supported on web.** On web platforms this widget shows an
/// informational placeholder. Use [WebhookBackend] + a server-side viewer
/// instead.
///
/// ```dart
/// FeedbackDevViewer(directoryPath: feedbackDir.path)
/// ```
class FeedbackDevViewer extends StatefulWidget {
  const FeedbackDevViewer({super.key, required this.directoryPath});

  /// Absolute path to the directory written by [LocalFeedbackBackend].
  final String directoryPath;

  @override
  State<FeedbackDevViewer> createState() => _FeedbackDevViewerState();
}

class _FeedbackDevViewerState extends State<FeedbackDevViewer> {
  List<_LocalEntry> _entries = [];
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (kIsWeb) {
      if (mounted) setState(() => _loaded = true);
      return;
    }
    final raw = await impl.loadEntries(widget.directoryPath);
    if (mounted) {
      setState(() {
        _entries = raw.map(_LocalEntry.fromMap).toList();
        _loaded = true;
      });
    }
  }

  Future<void> _deleteEntry(_LocalEntry e) async {
    await impl.deleteEntry(widget.directoryPath, e.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        appBar: AppBar(title: const Text('Feedback Log')),
        body: const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.web, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                'FeedbackDevViewer is not available on web.',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 4),
              Text(
                'Use WebhookBackend + a server-side viewer instead.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Feedback Log (${_entries.length})'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: _load,
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.inbox_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 8),
                      Text(
                        'No feedback yet',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: ( context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) => _EntryTile(
                    entry: _entries[i],
                    directoryPath: widget.directoryPath,
                    onDelete: () => _deleteEntry(_entries[i]),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => _EntryDetailScreen(
                          entry: _entries[i],
                          directoryPath: widget.directoryPath,
                        ),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ─── Entry model ─────────────────────────────────────────────────────────────

class _LocalEntry {
  _LocalEntry.fromMap(Map<String, dynamic> map)
      : id = map['_id'] as String? ?? '',
        category = map['category'] as String? ?? '',
        message = map['message'] as String? ?? '',
        createdAt = map['createdAt'] as String? ?? '',
        platform = map['platform'] as String? ?? '',
        appVersion = map['appVersion'] as String? ?? '',
        screenshotNames =
            (map['screenshots'] as List? ?? []).cast<String>();

  final String id;
  final String category;
  final String message;
  final String createdAt;
  final String platform;
  final String appVersion;
  final List<String> screenshotNames;

  DateTime? get dateTime => DateTime.tryParse(createdAt);

  String get dateLabel {
    final dt = dateTime;
    if (dt == null) return createdAt;
    return '${dt.year}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.day.toString().padLeft(2, '0')}  '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }
}

// ─── List tile ───────────────────────────────────────────────────────────────

class _EntryTile extends StatelessWidget {
  const _EntryTile({
    required this.entry,
    required this.directoryPath,
    required this.onDelete,
    required this.onTap,
  });

  final _LocalEntry entry;
  final String directoryPath;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: entry.screenshotNames.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: impl.buildThumbnail(
                    directoryPath, entry.screenshotNames.first),
              )
            : const Icon(
                Icons.feedback_outlined,
                size: 32,
                color: Colors.grey,
              ),
      ),
      title: Row(
        children: [
          _CategoryBadge(category: entry.category),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              entry.dateLabel,
              style: Theme.of(context).textTheme.bodySmall,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (entry.screenshotNames.length > 1)
            Text(
              '${entry.screenshotNames.length} imgs',
              style: Theme.of(context).textTheme.bodySmall,
            ),
        ],
      ),
      subtitle: Text(
        entry.message,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete_outline, size: 18, color: Colors.grey),
        tooltip: 'Delete',
        onPressed: onDelete,
      ),
      onTap: onTap,
    );
  }
}

// ─── Detail screen ───────────────────────────────────────────────────────────

class _EntryDetailScreen extends StatelessWidget {
  const _EntryDetailScreen({
    required this.entry,
    required this.directoryPath,
  });

  final _LocalEntry entry;
  final String directoryPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: _CategoryBadge(category: entry.category),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.dateLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              'v${entry.appVersion}  ·  ${entry.platform}',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.outline),
            ),
            const SizedBox(height: 16),
            Text(entry.message, style: theme.textTheme.bodyMedium),
            if (entry.screenshotNames.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Screenshots (${entry.screenshotNames.length})',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final name in entry.screenshotNames)
                    impl.buildScreenshotPreview(
                      context,
                      directoryPath,
                      name,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Category badge ───────────────────────────────────────────────────────────

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.category});
  final String category;

  Color get _color => switch (category) {
        'bug' => Colors.red,
        'suggestion' => Colors.blue,
        'ui' => Colors.purple,
        'performance' => Colors.orange,
        _ => Colors.grey,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _color.withAlpha(30),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _color.withAlpha(100)),
      ),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 11,
          color: _color,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
