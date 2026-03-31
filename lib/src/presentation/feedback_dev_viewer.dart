import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

/// In-app viewer for feedback saved by [LocalFeedbackBackend].
/// Add this screen to your debug-only navigation.
///
/// ```dart
/// FeedbackDevViewer(directory: feedbackDir)
/// ```
class FeedbackDevViewer extends StatefulWidget {
  const FeedbackDevViewer({super.key, required this.directory});

  final Directory directory;

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

  void _load() {
    if (!widget.directory.existsSync()) {
      setState(() {
        _entries = [];
        _loaded = true;
      });
      return;
    }

    final files = widget.directory
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path)); // newest first

    final entries = <_LocalEntry>[];
    for (final file in files) {
      try {
        final map =
            jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
        final ssNames = (map['screenshots'] as List? ?? []).cast<String>();
        final ssFiles = ssNames
            .map((n) => File('${widget.directory.path}/$n'))
            .where((f) => f.existsSync())
            .toList();
        entries.add(_LocalEntry(map: map, screenshots: ssFiles, file: file));
      } catch (_) {}
    }

    setState(() {
      _entries = entries;
      _loaded = true;
    });
  }

  void _deleteEntry(_LocalEntry e) {
    e.file.deleteSync();
    for (final f in e.screenshots) {
      if (f.existsSync()) f.deleteSync();
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
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
                      Text('No feedback yet',
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : ListView.separated(
                  itemCount: _entries.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, indent: 72),
                  itemBuilder: (context, i) => _EntryTile(
                    entry: _entries[i],
                    onDelete: () => _deleteEntry(_entries[i]),
                    onTap: () => Navigator.push<void>(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            _EntryDetailScreen(entry: _entries[i]),
                      ),
                    ),
                  ),
                ),
    );
  }
}

// ─── Entry model ─────────────────────────────────────────────────────────────

class _LocalEntry {
  _LocalEntry({
    required this.map,
    required this.screenshots,
    required this.file,
  });

  final Map<String, dynamic> map;
  final List<File> screenshots;
  final File file;

  String get category => map['category'] as String? ?? '';
  String get message => map['message'] as String? ?? '';
  String get createdAt => map['createdAt'] as String? ?? '';
  String get platform => map['platform'] as String? ?? '';
  String get appVersion => map['appVersion'] as String? ?? '';

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
    required this.onDelete,
    required this.onTap,
  });

  final _LocalEntry entry;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        width: 48,
        height: 48,
        child: entry.screenshots.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.file(
                  entry.screenshots.first,
                  fit: BoxFit.cover,
                  semanticLabel: 'Screenshot thumbnail',
                ),
              )
            : const Icon(Icons.feedback_outlined, size: 32, color: Colors.grey),
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
          if (entry.screenshots.length > 1)
            Text(
              '📎${entry.screenshots.length}',
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
  const _EntryDetailScreen({required this.entry});

  final _LocalEntry entry;

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
            if (entry.screenshots.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              Text(
                'Screenshots (${entry.screenshots.length})',
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in entry.screenshots)
                    GestureDetector(
                      onTap: () => Navigator.push<void>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => _FullScreenImage(file: f),
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          f,
                          width: 140,
                          height: 140,
                          fit: BoxFit.cover,
                          semanticLabel: 'Screenshot',
                        ),
                      ),
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

// ─── Full-screen image ────────────────────────────────────────────────────────

class _FullScreenImage extends StatelessWidget {
  const _FullScreenImage({required this.file});
  final File file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black, foregroundColor: Colors.white),
      body: Center(
        child: InteractiveViewer(
          child: Image.file(file, semanticLabel: 'Full-size screenshot'),
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
