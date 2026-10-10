import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';

/// ============================================================
/// TESTER FEEDBACK RECIPIENT — change this one line to pick
/// where tester feedback goes. Marc-André to confirm.
/// ============================================================
const kFeedbackEmail = 'Roasted.service@gmail.com';

/// Profile → Information → Send feedback: a simple form (name optional,
/// message required). Sending opens the device mail app with a prefilled
/// email to [kFeedbackEmail]; if no mail app can handle it, the message is
/// copied to the clipboard instead — then shows a confirmation.
class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _nameController = TextEditingController();
  final _messageController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _nameController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _canSend => _messageController.text.trim().isNotEmpty;

  Future<void> _send() async {
    if (!_canSend) return;
    final name = _nameController.text.trim();
    final message = _messageController.text.trim();
    final body =
        '${name.isEmpty ? '' : 'Name: $name\n\n'}$message';
    final uri = Uri(
      scheme: 'mailto',
      path: kFeedbackEmail,
      queryParameters: {
        'subject': 'Roasted tester feedback',
        'body': body,
      },
    );
    // Prefer the mail app; fall back to clipboard when unavailable.
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      final emailText = 'To: $kFeedbackEmail\n'
          'Subject: Roasted tester feedback\n\n$body';
      await Clipboard.setData(ClipboardData(text: emailText));
    }
    if (!mounted) return;
    setState(() => _sent = true);
  }

  Future<void> _copyEmail() async {
    await Clipboard.setData(const ClipboardData(text: kFeedbackEmail));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email address copied'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
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
                'Your mail app should have opened with the message ready — '
                'if not, send it to:',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: p.muted,
                ),
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _copyEmail,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: p.line),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          kFeedbackEmail,
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.copy_outlined,
                        size: 18,
                        color: p.muted,
                      ),
                    ],
                  ),
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
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSend ? _send : null,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 14),
                    child: Text('Send feedback'),
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
