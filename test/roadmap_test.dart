import 'package:coffee_beans/data/bean_photos.dart';
import 'package:coffee_beans/data/recommendations.dart';
import 'package:coffee_beans/data/sample_data.dart';
import 'package:coffee_beans/models/coffee_bean.dart';
import 'package:coffee_beans/models/tried_coffee.dart';
import 'package:coffee_beans/screens/discover_screen.dart';
import 'package:coffee_beans/screens/information_screen.dart';
import 'package:coffee_beans/screens/shops_screen.dart';
import 'package:coffee_beans/state/app_state.dart';
import 'package:coffee_beans/theme/app_theme.dart';
import 'package:coffee_beans/widgets/profile_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

CoffeeBean _bean({
  required String id,
  required String origin,
  required String roast,
  List<String> notes = const [],
  bool local = false,
  bool decaf = false,
}) =>
    CoffeeBean(
      id: id,
      name: id,
      origin: origin,
      roastLevel: roast,
      tastingNotes: notes,
      local: local,
      decaf: decaf,
    );

TriedCoffee _tasting({
  required String beanId,
  required double rating,
  required bool liked,
  DateTime? date,
}) =>
    TriedCoffee(
      id: 't-$beanId',
      beanId: beanId,
      brewMethod: 'V60',
      rating: rating,
      liked: liked,
      date: date ?? DateTime.now(),
    );

void main() {
  group('theme toggle', () {
    test('defaults to following the system', () {
      expect(AppState().themeMode, ThemeMode.system);
    });

    test('setThemeMode updates and notifies listeners', () {
      final state = AppState();
      var notified = 0;
      state.addListener(() => notified++);
      state.setThemeMode(ThemeMode.dark);
      expect(state.themeMode, ThemeMode.dark);
      expect(notified, 1);
      // Setting the same mode again is a no-op.
      state.setThemeMode(ThemeMode.dark);
      expect(notified, 1);
    });
  });

  group('bean photo mapping', () {
    test('known beans map to roast-appropriate photos', () {
      expect(
        beanPhotoAsset(_bean(id: 'yirgacheffe-dawn', origin: 'Ethiopia', roast: 'Light')),
        'assets/beans/light_roast_beans.jpg',
      );
      expect(
        beanPhotoAsset(_bean(id: 'sumatra-night', origin: 'Sumatra', roast: 'Dark')),
        'assets/beans/dark_roast_beans.jpg',
      );
      expect(
        beanPhotoAsset(_bean(id: 'brown-bag-espresso-blend', origin: 'Blend', roast: 'Medium-Dark')),
        'assets/beans/medium_dark_beans.jpg',
      );
    });

    test('unknown bean ids fall back by roast level', () {
      expect(
        beanPhotoAsset(_bean(id: 'future-bean', origin: 'Peru', roast: 'Light')),
        'assets/beans/light_roast_beans.jpg',
      );
      expect(
        beanPhotoAsset(_bean(id: 'future-bean', origin: 'Peru', roast: 'Dark')),
        'assets/beans/dark_roast_beans.jpg',
      );
      expect(
        beanPhotoAsset(_bean(id: 'future-bean', origin: 'Peru', roast: 'Medium')),
        'assets/beans/medium_roast_beans.jpg',
      );
    });

    test('no two adjacent catalogue beans share a photo', () {
      final beans = SampleData.beans;
      for (var i = 0; i < beans.length - 1; i++) {
        expect(
          beanPhotoAsset(beans[i]),
          isNot(beanPhotoAsset(beans[i + 1])),
          reason: '${beans[i].id} and ${beans[i + 1].id} share a photo',
        );
      }
    });

    test('every sample bean has a mapped photo', () {
      for (final bean in SampleData.beans) {
        expect(beanPhotoAsset(bean), startsWith('assets/beans/'));
        expect(beanPhotoAsset(bean), endsWith('.jpg'));
      }
    });
  });

  group('minimal map tiles', () {
    test('CARTO light/dark URLs are exact', () {
      expect(
        cartoTileUrl(dark: false),
        'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
      );
      expect(
        cartoTileUrl(dark: true),
        'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
      );
    });
  });

  group('recommendations', () {
    final ethiopiaA = _bean(
      id: 'eth-a',
      origin: 'Ethiopia',
      roast: 'Light',
      notes: const ['fruity', 'floral'],
    );
    final ethiopiaB = _bean(
      id: 'eth-b',
      origin: 'Ethiopia',
      roast: 'Light',
      notes: const ['fruity', 'berry'],
    );
    final brazilC = _bean(
      id: 'bra-c',
      origin: 'Brazil',
      roast: 'Dark',
      notes: const ['chocolate'],
    );
    final beans = [ethiopiaA, ethiopiaB, brazilC];
    final beanById = {for (final b in beans) b.id: b};

    List<ScoredRecommendation> recommend(List<TriedCoffee> tried) =>
        recommendBeans(
          beans: beans,
          tried: tried,
          beanById: beanById,
          roastPreference: 'Medium',
          surpriseMe: 0,
          decafOnly: false,
          limit: 8,
        );

    test('a loved fruity Ethiopian boosts similar untried beans', () {
      final recs = recommend([
        _tasting(beanId: 'eth-a', rating: 5, liked: true),
      ]);
      // The tried bean itself is excluded.
      expect(recs.map((r) => r.bean.id), isNot(contains('eth-a')));
      expect(recs.first.bean.id, 'eth-b');
      expect(recs.first.reason, contains('fruity'));
      expect(recs.first.score, greaterThan(recs.last.score));
    });

    test('4-star floor: low-rated tastings do not drive picks', () {
      final recs = recommend([
        _tasting(beanId: 'eth-a', rating: 2, liked: false),
      ]);
      final ethB = recs.firstWhere((r) => r.bean.id == 'eth-b');
      expect(ethB.score, 0);
    });

    test('explanations stay short and human', () {
      final recs = recommend([
        _tasting(beanId: 'eth-a', rating: 5, liked: true),
      ]);
      for (final rec in recs) {
        expect(rec.reason, isNotEmpty);
        expect(rec.reason.length, lessThan(80));
      }
    });

    test('decaf-only filter still applies', () {
      final decafBeans = [
        ...beans,
        _bean(id: 'dec-d', origin: 'Colombia', roast: 'Medium', decaf: true),
      ];
      final recs = recommendBeans(
        beans: decafBeans,
        tried: [_tasting(beanId: 'eth-a', rating: 5, liked: true)],
        beanById: {for (final b in decafBeans) b.id: b},
        roastPreference: 'Medium',
        surpriseMe: 0,
        decafOnly: true,
        limit: 8,
      );
      expect(recs.map((r) => r.bean.id), ['dec-d']);
    });
  });

  group('taste identity line', () {
    test('summarizes the dominant roast and origin', () {
      final tried = [
        _tasting(beanId: 'yirgacheffe-dawn', rating: 5, liked: true),
        _tasting(beanId: 'kenya-aa', rating: 4, liked: true),
      ];
      CoffeeBean? beanFor(String id) =>
          SampleData.beans.where((b) => b.id == id).firstOrNull;
      final line = tasteIdentityLine(tried, beanFor);
      expect(line, contains('light-roast lover'));
    });

    test('empty tastings get the blank-slate line', () {
      expect(
        tasteIdentityLine([], (_) => null),
        'Your palate is a blank slate — for now',
      );
    });
  });

  group('shops seed', () {
    test('the two new shops are present with exact coordinates', () {
      final byId = {for (final s in SampleData.shops) s.id: s};
      expect(byId.length, 9);
      final uji = byId['uji-cafe']!;
      expect(uji.name, 'Uji Café');
      expect(uji.address, '215 Rideau St, Ottawa');
      expect(uji.latitude, 45.4278363);
      expect(uji.longitude, -75.6883043);
      final kafia = byId['kafia-coffee']!;
      expect(kafia.name, 'International Kafia Coffee');
      expect(kafia.address, '842 Boyd Ave, Ottawa');
      expect(kafia.latitude, 45.376811);
      expect(kafia.longitude, -75.751322);
    });
  });

  group('dark theme', () {
    testWidgets('discover screen renders under the dark theme',
        (tester) async {
      await tester.pumpWidget(
        AppStateScope(
          state: AppState(),
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const DiscoverScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Discoveries'), findsOneWidget);
      // The palette resolves in dark mode.
      final context = tester.element(find.text('Discoveries'));
      expect(
        context.palette.background,
        const Color(0xFF1C130C),
      );
    });

    testWidgets('information screen shows the theme toggle',
        (tester) async {
      await tester.pumpWidget(
        AppStateScope(
          state: AppState(),
          child: MaterialApp(
            theme: AppTheme.dark(),
            home: const InformationScreen(),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Light'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);
      expect(find.text('System'), findsOneWidget);

      // Tapping Dark pins the theme mode.
      final state = AppState();
      await tester.pumpWidget(
        AppStateScope(
          state: state,
          child: MaterialApp(
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: state.themeMode,
            home: const InformationScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.tap(find.text('Dark'));
      await tester.pump();
      expect(state.themeMode, ThemeMode.dark);
    });
  });
}
