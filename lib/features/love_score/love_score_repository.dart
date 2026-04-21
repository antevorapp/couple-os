import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/love_score.dart';

class LoveScoreRepository {
  final SupabaseClient _client;

  LoveScoreRepository(this._client);

  Future<List<LoveScore>> fetchScores(String coupleId) async {
    final data = await _client
        .from('love_scores')
        .select()
        .eq('couple_id', coupleId)
        .order('created_at', ascending: false)
        .limit(50);
    return (data as List).map((e) => LoveScore.fromJson(e)).toList();
  }

  Future<void> addScore({
    required String coupleId,
    required int score,
    String? note,
  }) async {
    final userId = _client.auth.currentUser!.id;
    await _client.from('love_scores').insert({
      'user_id': userId,
      'couple_id': coupleId,
      'score': score,
      'note': note,
    });
  }

  Future<Map<String, int>> getTotals(String coupleId) async {
    final data = await _client
        .from('love_scores')
        .select('user_id, score')
        .eq('couple_id', coupleId);

    final Map<String, int> totals = {};
    for (final row in data as List) {
      final uid = row['user_id'] as String;
      final s = row['score'] as int;
      totals[uid] = (totals[uid] ?? 0) + s;
    }
    return totals;
  }
}
