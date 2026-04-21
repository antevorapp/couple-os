import 'dart:convert';
import 'package:http/http.dart' as http;

class AiCommentService {
  static const _apiUrl = 'https://api.anthropic.com/v1/messages';

  final String apiKey;

  AiCommentService({required this.apiKey});

  Future<String?> generateComment(List<String> recentMessages) async {
    if (apiKey.isEmpty) return null;

    final context = recentMessages.take(10).join('\n');
    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': 'claude-haiku-4-5-20251001',
        'max_tokens': 150,
        'messages': [
          {
            'role': 'user',
            'content':
                'Sen bir çift danışmanısın. Aşağıdaki mesajları oku ve çift için kısa, sevecen, Türkçe bir yorum yaz (max 2 cümle):\n\n$context',
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String?;
    }
    return null;
  }
}
