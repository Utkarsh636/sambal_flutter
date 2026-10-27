import 'package:flutter/material.dart';
import '../case/case_controller.dart';
import 'assistant_api.dart';

class ChatMessage {
  const ChatMessage({
    required this.user,
    required this.text,
    this.sources = const [],
    this.refusal = false,
  });

  final bool user;
  final String text;
  final List<Map<String, String>> sources;
  final bool refusal;
}

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final textController = TextEditingController();
  final scrollController = ScrollController();
  final api = AssistantApi();

  final messages = <ChatMessage>[];
  bool typing = false;

  @override
  void dispose() {
    textController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = SambalScope.of(context);
    final hindi = controller.isHindi;
    String t(String hi, String en) => hindi ? hi : en;

    final suggestions = [
      t('मुझे कौन से कागज़ चाहिए?', 'What documents do I need?'),
      t('कितना शुल्क लगेगा?', 'What fee will I pay?'),
      t('मुझे कहाँ जाना है?', 'Where do I need to go?'),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(t('सहायक', 'Assistant'))),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.fromLTRB(16, 10, 16, 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      t(
                        'मैं प्रक्रिया की जानकारी देता हूँ, कानूनी सलाह नहीं।',
                        'I provide process information, not legal advice.',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: messages.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          t(
                            'नमस्ते। कागज़, शुल्क या कार्यालय के बारे में पूछिए।',
                            'Hello. Ask about documents, fees, or offices.',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: messages.length + (typing ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (typing && index == messages.length) {
                          return _typingBubble(t);
                        }
                        return _messageBubble(messages[index], hindi);
                      },
                    ),
            ),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: suggestions
                    .map(
                      (suggestion) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(suggestion),
                          onPressed: typing
                              ? null
                              : () => ask(suggestion, hindi),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: textController,
                      minLines: 1,
                      maxLines: 4,
                      onSubmitted: (_) => ask(textController.text, hindi),
                      decoration: InputDecoration(
                        hintText: t('अपना सवाल लिखें…', 'Type your question…'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(54, 54),
                      padding: EdgeInsets.zero,
                    ),
                    onPressed: typing
                        ? null
                        : () => ask(textController.text, hindi),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> ask(String question, bool hindi) async {
    final value = question.trim();
    if (value.isEmpty || typing) return;

    final data = SambalScope.of(context).data;

    setState(() {
      messages.add(ChatMessage(user: true, text: value));
      textController.clear();
      typing = true;
    });

    scrollToBottom();

    try {
      final reply = await api.ask(
        message: value,
        language: hindi ? 'hi' : 'en',
        state: data.state,
        district: data.district,
        circumstance: data.circumstance,
      );

      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            user: false,
            text: reply.answer,
            sources: reply.sources,
            refusal: reply.refusal,
          ),
        );
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        messages.add(
          ChatMessage(
            user: false,
            refusal: true,
            text: hindi
                ? 'सहायक से अभी संपर्क नहीं हो सका। कृपया इंटरनेट और सर्वर की जाँच करें।'
                : 'The assistant could not be reached. Check your internet and server.',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() => typing = false);
        scrollToBottom();
      }
    }
  }

  Widget _messageBubble(ChatMessage message, bool hindi) {
    final colors = Theme.of(context).colorScheme;
    final background = message.user
        ? colors.primary
        : colors.surfaceContainerHighest;

    final foreground = message.user ? colors.onPrimary : colors.onSurface;

    return Align(
      alignment: message.user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 330),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.refusal)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  hindi ? 'सत्यापित उत्तर नहीं' : 'No verified answer',
                  style: TextStyle(
                    color: message.user ? colors.onPrimary : colors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            Text(message.text, style: TextStyle(color: foreground)),
            ...message.sources.map(
              (source) => Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  '${hindi ? 'स्रोत' : 'Source'}: ${source['source']}\n'
                  '${hindi ? 'सत्यापित' : 'Verified'}: ${source['verified']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: message.user
                        ? colors.onPrimary.withValues(alpha: 0.7)
                        : colors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _typingBubble(String Function(String, String) t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(t('सहायक लिख रहा है…', 'Assistant is typing…')),
      ),
    );
  }

  void scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 150), () {
      if (!scrollController.hasClients) return;
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }
}