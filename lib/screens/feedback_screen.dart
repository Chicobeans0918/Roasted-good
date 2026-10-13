import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../theme/app_theme.dart';

/// ============================================================
/// TESTER FEEDBACK RECIPIENT — change this one line to pick
/// where tester feedback goes. Marc-André to confirm.
///
/// Sending is done in-app via the FormSubmit relay (free):
/// the app POSTs the feedback, the relay delivers it to
/// [kFeedbackEmail]. FIRST-RUN ACTIVATION: the relay sends a
/// confirmation link to [kFeedbackEmail] on the first submission —
/// someone with that inbox must click it once, then it works.
/// ============================================================
const kFeedbackEmail = 'Roasted.service@gmail.com';

/// Profile → Information → Send feedback: a simple form (name optional,
/// message required). Sending posts the feedback in-app to [kFeedbackEmail]
/// — no mail app involved — then shows a confirmation.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sent = false;
  bool _sending = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _canSend =>
      _messageController.text.trim().isNotEmpty && !_sending;

  Future<void> _send() async {
    if (!_canSend) return;
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      final name = _nameController.text.trim();
      final message = _messageController.text.trim();
      final response = await http
          .post(
            Uri.parse('https://formsubmit.co/ajax/$kFeedbackEmail'),
            headers: {'Content-Type': 'application/json'},
            body:
                '{"name": ${_json(name)}, "message": ${_json(message)}, "_subject": "Roasted tester feedback"}',
          )
          .timeout(const Duration(seconds: 15));
      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() => _sent = true);
      } else {
        setState(() => _error =
            'Couldn\'t send just now (server said ${response.statusCode}). Check your connection and try again.');
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _error =
          'Couldn\'t send just now. Check your connection and try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  /// Minimal JSON string escaping for the form fields.
  String _json(String value) {
    final escaped = value
        .replaceAll(r'\', r'\\')
        .replaceAll('"', r'\"')
        .replaceAll('\n', r'\n')
        .replaceAll('\r', r'\r')
        .replaceAll('\t', r'\t');
    return '"$escaped"';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Send feedback')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 48),
          children: [
            if (_sent) ...[
              const SizedBox(height: 24),
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: p.ink,
              ),
              const SizedBox(height: 20),
              Text(
                'Thanks for the feedback!',
                textAlign: TextAlign.center,
                style: AppType.serifFor(
                  context,
                  size: 28,
                  weight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'It\'s on its way to the Roasted team — thanks for helping make the app better.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.muted,
                ),
              ),
            ] else ...[
              Text(
                'Tell us what you think',
                style: AppType.serifFor(
                  context,
                  size: 28,
                  weight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What works, what doesn’t, what you wish Roasted did.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.muted,
                ),
              ),
              const SizedBox(height: 32),
              Text('YOUR NAME (OPTIONAL)',
                  style: theme.textTheme.labelSmall),
              const SizedBox(height: 10),
              TextField(
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  hintText: 'Your name',
                ),
              ),
              const SizedBox(height: 28),
              Text('YOUR MESSAGE', style: theme.textTheme.labelSmall),
              const SizedBox(height: 10),
              TextField(
                controller: _messageController,
                maxLines: 6,
                minLines: 4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'I loved… / I wish… / This confused me…',
                ),
              ),
              const SizedBox(height: 32),
              if (_error != null) ...[
                Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSend ? _send : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: _sending
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send feedback'),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
