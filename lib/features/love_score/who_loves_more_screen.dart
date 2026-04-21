import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'dart:typed_data';

import '../../core/theme/app_theme.dart';
import 'love_score_notifier.dart';

class WhoLovesMoreScreen extends ConsumerStatefulWidget {
  const WhoLovesMoreScreen({super.key});

  @override
  ConsumerState<WhoLovesMoreScreen> createState() => _WhoLovesMoreScreenState();
}

class _WhoLovesMoreScreenState extends ConsumerState<WhoLovesMoreScreen> {
  final _screenshotController = ScreenshotController();
  int _selectedScore = 5;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _shareScore() async {
    final Uint8List? image = await _screenshotController.capture();
    if (image == null) return;

    final tempDir = Directory.systemTemp;
    final file = await File('${tempDir.path}/love_score.png').writeAsBytes(image);
    await Share.shareXFiles([XFile(file.path)], text: 'Couple OS - Aşk Skorum!');
  }

  void _showAddScoreDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Bugün ne kadar seviyorsun?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            StatefulBuilder(
              builder: (ctx, setLocalState) => Column(
                children: [
                  Text(
                    '$_selectedScore / 10',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppTheme.primary,
                        ),
                  ),
                  Slider(
                    value: _selectedScore.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    activeColor: AppTheme.primary,
                    inactiveColor: AppTheme.surface,
                    onChanged: (v) {
                      setLocalState(() => _selectedScore = v.round());
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            TextField(
              controller: _noteController,
              decoration: const InputDecoration(
                hintText: 'Bir not ekle (opsiyonel)',
                prefixIcon: Icon(Icons.note_outlined, color: AppTheme.textSecondary),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref
                      .read(loveScoreNotifierProvider.notifier)
                      .addScore(_selectedScore, note: _noteController.text.trim());
                  _noteController.clear();
                },
                child: const Text('Kaydet'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loveScoreNotifierProvider);
    final currentUserId = ref.read(coupleIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kim Daha Çok Seviyor?'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: _shareScore,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddScoreDialog,
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Skor Ekle'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : Screenshot(
              controller: _screenshotController,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildScoreCard(state, currentUserId),
                    const SizedBox(height: 24),
                    _buildHistory(state),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildScoreCard(LoveScoreState state, String coupleId) {
    final totals = state.totals;
    final entries = totals.entries.toList();
    if (entries.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              const Icon(Icons.favorite_border, size: 64, color: AppTheme.textSecondary),
              const SizedBox(height: 16),
              Text(
                'Henüz skor yok!\nİlk skoru sen ekle.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ).animate().fadeIn();
    }

    entries.sort((a, b) => b.value.compareTo(a.value));
    final winner = entries.first;
    final total = totals.values.fold(0, (a, b) => a + b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.favorite, size: 48, color: AppTheme.primary)
                .animate(onPlay: (c) => c.repeat())
                .scale(begin: const Offset(1, 1), end: const Offset(1.2, 1.2), duration: 800.ms)
                .then()
                .scale(begin: const Offset(1.2, 1.2), end: const Offset(1, 1), duration: 800.ms),
            const SizedBox(height: 16),
            Text(
              'Toplam Aşk Skoru',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '$total',
              style: Theme.of(context)
                  .textTheme
                  .displayLarge
                  ?.copyWith(color: AppTheme.primary),
            ),
            const Divider(height: 32, color: AppTheme.surface),
            ...entries.map((e) {
              final isWinner = e.key == winner.key;
              final pct = total > 0 ? (e.value / total * 100).toStringAsFixed(1) : '0';
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        if (isWinner)
                          const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          e.key.substring(0, 8),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                color: isWinner ? AppTheme.primary : AppTheme.textSecondary,
                                fontWeight:
                                    isWinner ? FontWeight.bold : FontWeight.normal,
                              ),
                        ),
                      ],
                    ),
                    Text(
                      '${e.value} ($pct%)',
                      style: TextStyle(
                        color: isWinner ? AppTheme.primary : AppTheme.textSecondary,
                        fontWeight: isWinner ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    ).animate().slideY(begin: 0.2).fadeIn();
  }

  Widget _buildHistory(LoveScoreState state) {
    if (state.scores.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Geçmiş', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...state.scores.take(20).map(
              (s) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppTheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      '${s.score}',
                      style: const TextStyle(
                          color: AppTheme.primary, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    s.userId.substring(0, 8),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  subtitle: s.note != null && s.note!.isNotEmpty
                      ? Text(s.note!, style: Theme.of(context).textTheme.bodyMedium)
                      : null,
                  trailing: Text(
                    _formatDate(s.createdAt),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 12),
                  ),
                ),
              ),
            ),
      ],
    ).animate().fadeIn(delay: 200.ms);
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}.${dt.month}.${dt.year}';
  }
}
