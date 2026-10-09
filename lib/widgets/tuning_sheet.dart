import 'package:flutter/material.dart';

import '../state/app_state.dart';
import '../theme/app_theme.dart';

/// Bottom sheet for tuning recommendations: preferred roast,
/// surprise-me slider, decaf-only switch.
void showTuningSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) {
      final live = AppState.of(sheetContext);
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.line,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Tune recommendations',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 20),
              Text('PREFERRED ROAST', style: theme.textTheme.labelSmall),
              const SizedBox(height: 10),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'Light', label: Text('Light')),
                  ButtonSegment(value: 'Medium', label: Text('Medium')),
                  ButtonSegment(value: 'Dark', label: Text('Dark')),
                ],
                selected: {live.roastPreference},
                showSelectedIcon: false,
                onSelectionChanged: (selection) =>
                    live.updateTuning(roast: selection.first),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Surprise me', style: theme.textTheme.titleSmall),
                  Text(
                    live.surpriseMe < 0.34
                        ? 'Play it safe'
                        : live.surpriseMe < 0.67
                            ? 'Balanced'
                            : 'Adventurous',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
              Slider(
                value: live.surpriseMe,
                onChanged: (value) => live.updateTuning(surprise: value),
              ),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Decaf only',
                  style: theme.textTheme.titleSmall,
                ),
                value: live.decafOnly,
                activeThumbColor: AppColors.ink,
                onChanged: (value) => live.updateTuning(decaf: value),
              ),
            ],
          ),
        ),
      );
    },
  );
}
