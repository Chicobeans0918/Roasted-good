import 'package:flutter/material.dart';

import '../models/coffee_bean.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_detail_sheet.dart';

/// Searchable, filterable bean catalogue — 2-column card grid with
/// live search, brief descriptions, and "tried" badges.
class CatalogueScreen extends StatefulWidget {
  const CatalogueScreen({super.key});

  @override
  State<CatalogueScreen> createState() => _CatalogueScreenState();
}

class _CatalogueScreenState extends State<CatalogueScreen> {
  String _query = '';
  String _roastFilter = 'All';
  String _originFilter = 'All origins';

  static const _roasts = ['All', 'Light', 'Medium', 'Dark', 'Medium-Dark'];

  List<String> _origins(List<CoffeeBean> beans) => [
        'All origins',
        ...{for (final b in beans) b.origin},
      ];

  List<CoffeeBean> _filtered(List<CoffeeBean> beans) {
    final q = _query.toLowerCase().trim();
    return beans.where((bean) {
      final matchesQuery = q.isEmpty ||
          bean.name.toLowerCase().contains(q) ||
          bean.origin.toLowerCase().contains(q) ||
          bean.description.toLowerCase().contains(q) ||
          (bean.roaster ?? '').toLowerCase().contains(q) ||
          bean.tastingNotes.any((n) => n.toLowerCase().contains(q));
      final matchesRoast =
          _roastFilter == 'All' || bean.roastLevel == _roastFilter;
      final matchesOrigin =
          _originFilter == 'All origins' || bean.origin == _originFilter;
      return matchesQuery && matchesRoast && matchesOrigin;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    final state = AppState.of(context);
    final beans = _filtered(state.beans);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Search pill.
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search coffee beans...',
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _query = ''),
                        ),
                  filled: true,
                  fillColor: p.surfaceVariant.withValues(alpha: 0.45),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(color: p.line),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide(
                      color: p.ink,
                      width: 1.5,
                    ),
                  ),
                ),
                onChanged: (value) => setState(() => _query = value),
              ),
            ),
            const SizedBox(height: 20),
            _ChipRow(
              options: _roasts,
              selected: _roastFilter,
              onSelected: (value) => setState(() => _roastFilter = value),
            ),
            const SizedBox(height: 12),
            _ChipRow(
              options: _origins(state.beans),
              selected: _originFilter,
              onSelected: (value) =>
                  setState(() => _originFilter = value),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: beans.isEmpty
                  ? Center(
                      child: Text(
                        'No beans match your filters.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: p.muted,
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(24, 8, 24, 64),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 24,
                        mainAxisSpacing: 28,
                        childAspectRatio: 0.56,
                      ),
                      itemCount: beans.length,
                      itemBuilder: (context, index) {
                        final bean = beans[index];
                        return BeanGridCard(
                          bean: bean,
                          onDetails: () =>
                              showBeanDetailSheet(context, bean),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = context.palette;
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final option = options[index];
          final isSelected = option == selected;
          return ChoiceChip(
            label: Text(
              option,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? p.onAccent : p.ink,
              ),
            ),
            selected: isSelected,
            showCheckmark: false,
            onSelected: (_) => onSelected(option),
          );
        },
      ),
    );
  }
}
