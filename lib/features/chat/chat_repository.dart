import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/message.dart';

class ChatRepository {
  final SupabaseClient _client;

  ChatRepository(this._client);

  Stream<List<Message>> messagesStream(String coupleId) {
    return _client
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('couple_id', coupleId)
        .order('created_at')
        .map((data) => data.map(Message.fromJson).toList());
  }

  Future<void> sendMessage({
    required String coupleId,
    required String content,
    bool isAiComment = false,
  }) async {
    final userId = isAiComment ? 'ai' : _client.auth.currentUser!.id;
    await _client.from('messages').insert({
      'sender_id': userId,
      'couple_id': coupleId,
      'content': content,
      'is_ai_comment': isAiComment,
    });
  }

  Future<List<Message>> fetchRecent(String coupleId, {int limit = 20}) async {
    final data = await _client
        .from('messages')
        .select()
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false)
        .limit(limit);
    return (data as List<dynamic>)
        .map((e) => Message.fromJson(e as Map<String, dynamic>))
        .toList()
        .reversed
        .toList();
  }
}
