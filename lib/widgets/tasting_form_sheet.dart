import 'package:flutter/material.dart';

import '../models/coffee_bean.dart';
import '../models/tried_coffee.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import 'rating_stars.dart';

/// Opens the tasting-log form for [bean]: brew method, 1–5 star rating,
/// liked/disliked verdict, and an optional note.
Future<void> showTastingFormSheet(BuildContext context, CoffeeBean bean) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cream,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => TastingFormSheet(bean: bean),
  );
}

class TastingFormSheet extends StatefulWidget {
  const TastingFormSheet({super.key, required this.bean});

  final CoffeeBean bean;

  @override
  State<TastingFormSheet> createState() => _TastingFormSheetState();
}

class _TastingFormSheetState extends State<TastingFormSheet> {
  String? _brewMethod;
  double _rating = 0;
  bool _liked = true;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  bool get _canSave => _brewMethod != null && _rating > 0;

  void _save() {
    if (!_canSave) return;
    AppState.of(context).logTasting(
      TriedCoffee(
        id: TriedCoffee.newId(),
        beanId: widget.bean.id,
        brewMethod: _brewMethod!,
        rating: _rating,
        liked: _liked,
        note: _noteController.text.trim(),
        date: DateTime.now(),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          12,
          24,
          32 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
            Text('Log a tasting', style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              widget.bean.name,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 24),
            Text('BREWING METHOD', style: theme.textTheme.labelSmall),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final method in TriedCoffee.brewMethods)
                  ChoiceChip(
                    label: Text(method),
                    selected: _brewMethod == method,
                    showCheckmark: false,
                    onSelected: (_) =>
                        setState(() => _brewMethod = method),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Text('YOUR RATING', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            RatingInput(
              value: _rating,
              onChanged: (value) => setState(() => _rating = value),
            ),
            const SizedBox(height: 24),
            Text('DID YOU LIKE IT?', style: theme.textTheme.labelSmall),
            const SizedBox(height: 10),
            SegmentedButton<bool>(
              segments: const [
                ButtonSegment(
                  value: true,
                  icon: Icon(Icons.thumb_up_outlined, size: 18),
                  label: Text('Liked it'),
                ),
                ButtonSegment(
                  value: false,
                  icon: Icon(Icons.thumb_down_outlined, size: 18),
                  label: Text('Not for me'),
                ),
              ],
              selected: {_liked},
              showSelectedIcon: false,
              onSelectionChanged: (selection) =>
                  setState(() => _liked = selection.first),
            ),
            const SizedBox(height: 24),
            Text('NOTE', style: theme.textTheme.labelSmall),
            const SizedBox(height: 10),
            TextField(
              controller: _noteController,
              maxLines: 3,
              minLines: 2,
              decoration: const InputDecoration(
                hintText: 'How was it? Any flavours worth remembering...',
                filled: true,
                fillColor: AppColors.cream,
                contentPadding: EdgeInsets.all(16),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: AppColors.line),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide(color: AppColors.ink, width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canSave ? _save : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Text('Save tasting'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
