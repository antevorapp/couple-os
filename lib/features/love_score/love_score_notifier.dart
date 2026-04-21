import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../shared/models/love_score.dart';
import 'love_score_repository.dart';

final loveScoreRepoProvider = Provider<LoveScoreRepository>((ref) {
  return LoveScoreRepository(Supabase.instance.client);
});

class LoveScoreState {
  final List<LoveScore> scores;
  final Map<String, int> totals;
  final bool isLoading;
  final String? error;

  const LoveScoreState({
    this.scores = const [],
    this.totals = const {},
    this.isLoading = false,
    this.error,
  });

  LoveScoreState copyWith({
    List<LoveScore>? scores,
    Map<String, int>? totals,
    bool? isLoading,
    String? error,
  }) {
    return LoveScoreState(
      scores: scores ?? this.scores,
      totals: totals ?? this.totals,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LoveScoreNotifier extends StateNotifier<LoveScoreState> {
  final LoveScoreRepository _repo;
  final String coupleId;

  LoveScoreNotifier(this._repo, this.coupleId) : super(const LoveScoreState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);
    try {
      final scores = await _repo.fetchScores(coupleId);
      final totals = await _repo.getTotals(coupleId);
      state = state.copyWith(scores: scores, totals: totals, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addScore(int score, {String? note}) async {
    await _repo.addScore(coupleId: coupleId, score: score, note: note);
    await load();
  }
}

final coupleIdProvider = Provider<String>((ref) {
  final user = Supabase.instance.client.auth.currentUser;
  return user?.userMetadata?['couple_id'] as String? ?? 'default_couple';
});

final loveScoreNotifierProvider =
    StateNotifierProvider<LoveScoreNotifier, LoveScoreState>((ref) {
  final repo = ref.watch(loveScoreRepoProvider);
  final coupleId = ref.watch(coupleIdProvider);
  return LoveScoreNotifier(repo, coupleId);
});
