import 'package:coffee_beans/main.dart';
import 'package:coffee_beans/models/tried_coffee.dart';
import 'package:coffee_beans/screens/catalogue_screen.dart';
import 'package:coffee_beans/screens/discover_screen.dart';
import 'package:coffee_beans/state/app_state.dart';
import 'package:coffee_beans/widgets/tasting_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Fills the login form and taps "Log in". Tests run with Firebase
/// disabled, so any non-empty credentials enter offline.
Future<void> _signIn(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField).at(0), 'test@roasted.app');
  await tester.enterText(find.byType(TextField).at(1), 'password123');
  await tester.tap(find.text('Log in'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('App boots to the login screen', (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));

    expect(find.text('Roasted'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Signing in navigates to the tab shell', (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await _signIn(tester);

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets(
      'Home greets generically, shows discoveries, and reveals recommendations only after 3 tastings',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.pumpWidget(RoastedApp(state: state));
    await _signIn(tester);

    // No name set: no hardcoded name anywhere, generic greeting.
    expect(find.textContaining('Marc-André'), findsNothing);
    expect(find.text('Discoveries'), findsOneWidget);
    expect(find.text('Recommended for you'), findsNothing);

    // Setting a name personalizes the greeting.
    await state.setUserName('Jules');
    await tester.pumpAndSettle();
    expect(find.textContaining('Jules'), findsOneWidget);

    // Log three tastings → the recommendations section appears.
    final beanIds = state.beans.take(3).map((b) => b.id).toList();
    for (var i = 0; i < 3; i++) {
      state.logTasting(TriedCoffee(
        id: 't$i',
        beanId: beanIds[i],
        brewMethod: 'V60',
        rating: 4,
        liked: true,
        date: DateTime.now(),
      ));
    }
    await tester.pumpAndSettle();

    final homeList = find
        .descendant(
          of: find.byType(DiscoverScreen),
          matching: find.byType(ListView),
        )
        .first;
    await tester.drag(homeList, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Recommended for you'), findsOneWidget);
  });

  testWidgets('Profile shows the name header and three section rows',
      (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await _signIn(tester);

    // Open the Profile tab (the last BottomNavigationBar "Profile" label).
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    // No name set: friendly fallback, never someone else's name.
    expect(find.text('Coffee lover'), findsOneWidget);
    expect(find.textContaining('Marc-André'), findsNothing);

    // The section rows sit below the fold (Perks summary + Wrapped banner).
    await tester.scrollUntilVisible(
      find.text('Information'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Information'), findsOneWidget);
    expect(find.text('Coffees tried'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);
    // "Recommended" lives on Home now (after 3 tastings), not on Profile.
    expect(find.text('Recommended'), findsNothing);

    // Tapping "Wishlist" opens the wishlist screen (empty state).
    await tester.ensureVisible(find.text('Wishlist'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Wishlist'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Nothing saved yet'), findsOneWidget);
  });

  testWidgets('Marking a bean as tried opens the tasting form and logs it',
      (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await _signIn(tester);

    // Catalogue tab.
    await tester.tap(find.text('Catalogue').last);
    await tester.pumpAndSettle();

    // "Mark as tried" on the first bean card (Yirgacheffe Dawn).
    final markTried = find.descendant(
      of: find.byType(CatalogueScreen),
      matching: find.widgetWithIcon(OutlinedButton, Icons.coffee_outlined),
    );
    await tester.ensureVisible(markTried.first);
    await tester.pumpAndSettle();
    await tester.tap(markTried.first);
    await tester.pumpAndSettle();

    // The tasting form sheet is open.
    expect(find.text('Log a tasting'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(TastingFormSheet),
        matching: find.text('Yirgacheffe Dawn'),
      ),
      findsOneWidget,
    );

    // Pick a brew method.
    await tester.tap(find.text('V60'));
    await tester.pumpAndSettle();

    // Give 4 stars.
    final formStars = find.descendant(
      of: find.byType(TastingFormSheet),
      matching: find.byIcon(Icons.star_border),
    );
    await tester.tap(formStars.at(3));
    await tester.pumpAndSettle();

    // Write a note.
    final noteField = find.descendant(
      of: find.byType(TastingFormSheet),
      matching: find.byType(TextField),
    );
    await tester.enterText(noteField, 'Bright and floral.');
    await tester.pumpAndSettle();

    // Save (now enabled: method + rating chosen).
    await tester.ensureVisible(find.text('Save tasting'));
    await tester.tap(find.text('Save tasting'));
    await tester.pumpAndSettle();

    // The form closed; open Profile > Coffees tried (below the fold).
    expect(find.text('Log a tasting'), findsNothing);
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Coffees tried'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Coffees tried'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Coffees tried'));
    await tester.pumpAndSettle();

    // The logged tasting is grouped under its bean with its details.
    expect(find.text('Yirgacheffe Dawn'), findsWidgets);
    expect(find.textContaining('V60'), findsOneWidget);
    expect(find.text('“Bright and floral.”'), findsOneWidget);
    expect(find.byIcon(Icons.thumb_up), findsOneWidget);
  });

  testWidgets('Stats tab shows the journey numbers and hall of fame',
      (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await _signIn(tester);

    await tester.tap(find.text('Stats').last);
    await tester.pumpAndSettle();

    expect(find.text('Coffee stats'), findsOneWidget);
    expect(find.text('TASTINGS'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsOneWidget);

    // Hall of fame is below the fold (lazy-built). Scope the scrollable:
    // the brew calendar's GridView is a Scrollable too.
    await tester.scrollUntilVisible(
      find.text('Hall of fame'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Hall of fame'), findsOneWidget);
  });
}
