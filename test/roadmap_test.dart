import 'package:coffee_beans/data/bean_photos.dart';
import 'package:coffee_beans/data/recommendations.dart';
import 'package:coffee_beans/data/sample_data.dart';
import 'package:coffee_beans/models/coffee_bean.dart';
import 'package:coffee_beans/models/community_post.dart';
import 'package:coffee_beans/models/post_comment.dart';
import 'package:coffee_beans/models/tried_coffee.dart';
import 'package:coffee_beans/services/community_service.dart';
import 'package:coffee_beans/screens/discover_screen.dart';
import 'package:coffee_beans/screens/information_screen.dart';
import 'package:coffee_beans/screens/shops_screen.dart';
import 'package:coffee_beans/screens/tried_screen.dart';
import 'package:coffee_beans/screens/wrapped_screen.dart';
import 'package:coffee_beans/state/app_state.dart';
import 'package:coffee_beans/theme/app_theme.dart';
import 'package:coffee_beans/widgets/bean_detail_sheet.dart';
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
        beanPhotoAsset(_bean(id: 'bbcr-ethiopia', origin: 'Ethiopia', roast: 'Light')),
        'assets/beans/light_roast_beans.jpg',
      );
      expect(
        beanPhotoAsset(_bean(id: 'bbcr-sumatra', origin: 'Sumatra', roast: 'Dark')),
        'assets/beans/dark_roast_bowl.jpg',
      );
      expect(
        beanPhotoAsset(_bean(id: 'bbcr-colombia', origin: 'Colombia', roast: 'Medium-Dark')),
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
    test('Esri tile URLs need no API key', () {
      expect(
        esriTileUrl(dark: false),
        'https://server.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer/tile/{z}/{y}/{x}',
      );
      expect(
        esriTileUrl(dark: true),
        'https://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Dark_Gray_Base/MapServer/tile/{z}/{y}/{x}',
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
        _tasting(beanId: 'bbcr-ethiopia', rating: 5, liked: true),
        _tasting(beanId: 'bbcr-brazil', rating: 4, liked: true),
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
    test('the two new shops are present with exact coordinates', () {      final byId = {for (final s in SampleData.shops) s.id: s};
      expect(byId.length, greaterThanOrEqualTo(9));
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

    test('every shop has a valid region matching its address', () {
      const regions = {'Gatineau', 'Ottawa', 'Toronto'};
      for (final shop in SampleData.shops) {
        expect(regions, contains(shop.region), reason: shop.id);
        expect(shop.address, endsWith(', ${shop.region}'), reason: shop.id);
      }
      final counts = <String, int>{};
      for (final shop in SampleData.shops) {
        counts[shop.region] = (counts[shop.region] ?? 0) + 1;
      }
      expect(counts['Gatineau'], 16);
      expect(counts['Ottawa'], 42);
      expect(counts['Toronto'], 33);
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
      // The "Your Name" section sits above; scroll to the theme toggle.
      await tester.scrollUntilVisible(
        find.text('Appearance'),
        500,
        scrollable: find.byType(Scrollable).first,
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

  group('bean → shop linking', () {
    test('matches the roaster shop by name', () {
      final shop = shopForWhereToBuy(
        SampleData.shops,
        'Brown Bag Coffee Roasters',
      );
      expect(shop, isNotNull);
      expect(shop!.id, 'brown-bag');
    });

    test('matching is case-insensitive', () {
      expect(
        shopForWhereToBuy(SampleData.shops, 'brown bag coffee roasters')?.id,
        'brown-bag',
      );
    });

    test('returns null for online-only roasters and blanks', () {
      expect(shopForWhereToBuy(SampleData.shops, 'edika.com'), isNull);
      expect(shopForWhereToBuy(SampleData.shops, null), isNull);
      expect(shopForWhereToBuy(SampleData.shops, '  '), isNull);
    });

    test('beansForShop lists the roastery beans', () {
      final shop = SampleData.shops.firstWhere((s) => s.id == 'brown-bag');
      final beans = beansForShop(SampleData.beans, shop);
      expect(beans.length, 12);
      expect(beans.every((b) => b.roaster == 'Brown Bag Coffee Roasters'), isTrue);
    });

    test('beansForShop is empty for shops with no catalogue beans', () {
      final shop = SampleData.shops.firstWhere((s) => s.id != 'brown-bag');
      expect(beansForShop(SampleData.beans, shop), isEmpty);
    });
  });

  group('dark theme legibility', () {
    test('dark muted text is lighter than light muted text', () {
      expect(
        RoastedPalette.dark.muted.computeLuminance(),
        greaterThan(RoastedPalette.light.muted.computeLuminance()),
      );
    });
  });

  group('wrapped season lock', () {
    test('wrapped unlocks only in December', () {
      expect(isWrappedUnlocked(month: 12), isTrue);
      expect(isWrappedUnlocked(month: 1), isFalse);
      expect(isWrappedUnlocked(month: 6), isFalse);
      expect(isWrappedUnlocked(month: 11), isFalse);
    });
  });

  group('#1 pick', () {
    TriedCoffee tasting(String id, String beanId, double rating) =>
        TriedCoffee(
          id: id,
          beanId: beanId,
          brewMethod: 'Pour over',
          rating: rating,
          liked: true,
          date: DateTime(2026, 10, 17),
        );

    CoffeeBean? beanFor(Map<String, CoffeeBean> byId, String id) => byId[id];

    test('skips tastings for beans removed from the catalogue', () {
      final beans = {
        for (final b in SampleData.beans.take(3)) b.id: b,
      };
      final ids = beans.keys.toList();
      final tastings = [
        // Orphaned: highest rated, but its bean is gone.
        tasting('t1', 'gone-bean', 5.0),
        tasting('t2', ids[0], 4.0),
        tasting('t3', ids[1], 3.0),
      ];
      final pick = topPickFor(tastings, (id) => beanFor(beans, id));
      expect(pick, isNotNull);
      expect(pick!.id, 't2');
      expect(pick.beanId, ids[0]);
    });

    test('returns null when no tastings or all orphaned', () {
      final beans = {
        for (final b in SampleData.beans.take(3)) b.id: b,
      };
      expect(topPickFor([], (id) => beanFor(beans, id)), isNull);
      expect(
        topPickFor(
          [tasting('t1', 'gone-bean', 5.0)],
          (id) => beanFor(beans, id),
        ),
        isNull,
      );
    });
  });

  group('community posts', () {
    test('post survives a toMap/fromMap round trip', () {      final post = CommunityPost(
        id: 'p1',
        userId: 'u1',
        userName: 'Marc-André',
        kind: 'brewing',
        body: 'V60, 15g, 250ml — sweet and clean.',
        createdAt: DateTime(2026, 10, 18, 21, 30),
        likeCount: 3,
        likedBy: const ['u2', 'u3'],
      );
      final restored = CommunityPost.fromMap(post.toMap(), 'p1');
      expect(restored.userName, 'Marc-André');
      expect(restored.kind, 'brewing');
      expect(restored.body, contains('V60'));
      expect(restored.likeCount, 3);
      expect(restored.likedByUser('u2'), isTrue);
      expect(restored.likedByUser('u9'), isFalse);
      expect(restored.likedByUser(null), isFalse);
    });

    test('comment survives a toMap/fromMap round trip', () {
      final comment = PostComment(
        id: 'c1',
        userId: 'u1',
        userName: 'Marc-André',
        body: 'Try a coarser grind!',
        createdAt: DateTime(2026, 10, 18, 22, 10),
      );
      final restored =
          PostComment.fromMap(comment.toMap(), 'c1');
      expect(restored.userName, 'Marc-André');
      expect(restored.body, 'Try a coarser grind!');
    });

    test('leaderboard entry reads points and counters', () {
      final entry = LeaderboardEntry.fromMap(
        {
          'userName': 'Marc-André',
          'points': 27,
          'postCount': 2,
          'likeCount': 1,
          'commentCount': 1,
        },
        'u1',
      );
      expect(entry.points, 27);
      // 2 posts (20) + 1 like (2) + 1 comment (5) = 27.
      expect(
        entry.postCount * CommunityPoints.perPost +
            entry.likeCount * CommunityPoints.perLike +
            entry.commentCount * CommunityPoints.perComment,
        entry.points,
      );
    });

    test('post carries a comment count', () {
      final post = CommunityPost(
        id: 'p1',
        userId: 'u1',
        userName: 'Marc-André',
        kind: 'question',
        body: 'Best grinder under 200?',
        createdAt: DateTime(2026, 10, 18),
        commentCount: 4,
      );
      expect(
        CommunityPost.fromMap(post.toMap(), 'p1').commentCount,
        4,
      );
    });
  });
}
