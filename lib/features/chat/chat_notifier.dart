import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/message.dart';
import '../love_score/love_score_notifier.dart';
import 'ai_comment_service.dart';
import 'chat_repository.dart';

final chatRepoProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(Supabase.instance.client);
});

final aiCommentServiceProvider = Provider<AiCommentService>((ref) {
  return AiCommentService(apiKey: '');
});

final messagesStreamProvider = StreamProvider<List<Message>>((ref) {
  final repo = ref.watch(chatRepoProvider);
  final coupleId = ref.watch(coupleIdProvider);
  return repo.messagesStream(coupleId);
});

class ChatNotifier extends StateNotifier<AsyncValue<void>> {
  final ChatRepository _repo;
  final AiCommentService _aiService;
  final String coupleId;
  int _messageCount = 0;

  ChatNotifier(this._repo, this._aiService, this.coupleId)
      : super(const AsyncValue.data(null));

  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;
    state = const AsyncValue.loading();
    try {
      await _repo.sendMessage(coupleId: coupleId, content: content);
      _messageCount++;
      state = const AsyncValue.data(null);

      if (_messageCount % 5 == 0) {
        await _triggerAiComment();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> _triggerAiComment() async {
    final messages = await _repo.fetchRecent(coupleId, limit: 10);
    final texts = messages.map((m) => m.content).toList();
    final comment = await _aiService.generateComment(texts);
    if (comment != null) {
      await _repo.sendMessage(
        coupleId: coupleId,
        content: comment,
        isAiComment: true,
      );
    }
  }
}

final chatNotifierProvider =
    StateNotifierProvider<ChatNotifier, AsyncValue<void>>((ref) {
  final repo = ref.watch(chatRepoProvider);
  final ai = ref.watch(aiCommentServiceProvider);
  final coupleId = ref.watch(coupleIdProvider);
  return ChatNotifier(repo, ai, coupleId);
});
