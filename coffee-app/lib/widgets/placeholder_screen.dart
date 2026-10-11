import 'package:flutter/material.dart';

/// Shared "coming soon" placeholder used by the tab screens during scaffolding.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.note = 'Coming soon — this screen is being designed.',
  });

  final String title;
  final IconData icon;
  final String note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 72, color: theme.colorScheme.primary),
              const SizedBox(height: 24),
              Text(title, style: theme.textTheme.headlineSmall),
              const SizedBox(height: 12),
              Text(
                note,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
