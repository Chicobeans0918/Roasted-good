// Generates assets/seed/beans.json and assets/seed/shops.json from the
// bundled Dart seed data, so the JSON always mirrors the app fallback.
// Run: dart run tool/gen_seed_json.dart
import 'dart:convert';
import 'dart:io';

import 'package:coffee_beans/data/sample_data.dart';

Future<void> main() async {
  final beans = [
    for (final b in SampleData.beans) {'id': b.id, ...b.toMap()},
  ];
  final shops = [
    for (final s in SampleData.shops) {'id': s.id, ...s.toMap()},
  ];

  const encoder = JsonEncoder.withIndent('  ');
  await File('assets/seed/beans.json')
      .writeAsString('${encoder.convert(beans)}\n');
  await File('assets/seed/shops.json')
      .writeAsString('${encoder.convert(shops)}\n');

  // ignore: avoid_print
  print('Wrote ${beans.length} beans, ${shops.length} shops.');
}
