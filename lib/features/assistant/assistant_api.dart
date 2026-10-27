import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/config/api_config.dart';

class AssistantReply {
  const AssistantReply({
    required this.answer,
    required this.sources,
    required this.refusal,
  });

  final String answer;
  final List<Map<String, String>> sources;
  final bool refusal;
}

class AssistantApi {
  static String get baseUrl => ApiConfig.baseUrl;

  Future<AssistantReply> ask({
    required String message,
    required String language,
    required String state,
    required String district,
    required String circumstance,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/assistant/chat'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'message': message,
            'language': language,
            'caseData': {
              'state': state,
              'district': district,
              'circumstance': circumstance,
            },
          }),
        )
        .timeout(const Duration(seconds: 30));

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw Exception(data['error'] ?? 'Assistant request failed.');
    }

    final rawSources = data['sources'] as List<dynamic>? ?? [];

    return AssistantReply(
      answer: data['answer'] as String? ?? 'No answer received.',
      refusal: data['refusal'] as bool? ?? false,
      sources: rawSources
          .map(
            (item) => Map<String, String>.from(
              (item as Map).map(
                (key, value) => MapEntry(key.toString(), value.toString()),
              ),
            ),
          )
          .toList(),
    );
  }
}