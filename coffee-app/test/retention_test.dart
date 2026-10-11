import 'package:coffee_beans/data/streaks.dart';
import 'package:coffee_beans/models/tried_coffee.dart';
import 'package:coffee_beans/state/app_state.dart';
import 'package:flutter_test/flutter_test.dart';

TriedCoffee _tasting({
  required String id,
  required DateTime date,
}) =>
    TriedCoffee(
      id: id,
      beanId: 'bean-1',
      brewMethod: 'V60',
      rating: 4,
      liked: true,
      date: date,
    );

void main() {
  group('currentStreak', () {
    test('empty log gives 0', () {
      expect(currentStreak([]), 0);
    });

    test('counts consecutive days ending today', () {
      final now = DateTime(2026, 10, 10, 15, 30);
      final tried = [
        _tasting(id: 'a', date: DateTime(2026, 10, 10, 9)),
        _tasting(id: 'b', date: DateTime(2026, 10, 9, 9)),
        _tasting(id: 'c', date: DateTime(2026, 10, 8, 9)),
      ];
      expect(currentStreak(tried, now: now), 3);
    });

    test('stays alive when the last tasting was yesterday', () {
      final now = DateTime(2026, 10, 10, 15, 30);
      final tried = [
        _tasting(id: 'a', date: DateTime(2026, 10, 9, 9)),
        _tasting(id: 'b', date: DateTime(2026, 10, 8, 9)),
      ];
      expect(currentStreak(tried, now: now), 2);
    });

    test('breaks after a missed day', () {
      final now = DateTime(2026, 10, 10, 15, 30);
      final tried = [
        _tasting(id: 'a', date: DateTime(2026, 10, 10, 9)),
        _tasting(id: 'b', date: DateTime(2026, 10, 8, 9)),
      ];
      expect(currentStreak(tried, now: now), 1);
    });

    test('multiple tastings on one day count once', () {
      final now = DateTime(2026, 10, 10, 15, 30);
      final tried = [
        _tasting(id: 'a', date: DateTime(2026, 10, 10, 9)),
        _tasting(id: 'b', date: DateTime(2026, 10, 10, 18)),
        _tasting(id: 'c', date: DateTime(2026, 10, 9, 9)),
      ];
      expect(currentStreak(tried, now: now), 2);
    });
  });

  group('longestStreak', () {
    test('empty log gives 0', () {
      expect(longestStreak([]), 0);
    });

    test('finds the longest run', () {
      final tried = [
        _tasting(id: 'a', date: DateTime(2026, 10, 10, 9)),
        _tasting(id: 'b', date: DateTime(2026, 10, 9, 9)),
        _tasting(id: 'c', date: DateTime(2026, 10, 8, 9)),
        _tasting(id: 'd', date: DateTime(2026, 10, 5, 9)),
        _tasting(id: 'e', date: DateTime(2026, 10, 4, 9)),
      ];
      expect(longestStreak(tried), 3);
    });
  });

  group('perks', () {
    test('check-ins accumulate per shop', () {
      final state = AppState();
      state.checkInAtShop('shop-1');
      state.checkInAtShop('shop-1');
      expect(state.perkVisitsFor('shop-1'), 2);
      expect(state.perkVisitsFor('shop-2'), 0);
    });

    test('reward is ready at the threshold and redeem resets', () {
      final state = AppState();
      expect(state.perkRewardReady('shop-1'), isFalse);
      for (var i = 0; i < AppState.perkThreshold; i++) {
        state.checkInAtShop('shop-1');
      }
      expect(state.perkRewardReady('shop-1'), isTrue);
      state.redeemPerk('shop-1');
      expect(state.perkVisitsFor('shop-1'), 0);
      expect(state.perkRewardReady('shop-1'), isFalse);
    });

    test('check-ins notify listeners', () {
      final state = AppState();
      var notified = 0;
      state.addListener(() => notified++);
      state.checkInAtShop('shop-1');
      expect(notified, 1);
    });
  });
}
