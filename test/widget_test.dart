import 'package:coffee_beans/main.dart';
import 'package:coffee_beans/screens/catalogue_screen.dart';
import 'package:coffee_beans/screens/discover_screen.dart';
import 'package:coffee_beans/state/app_state.dart';
import 'package:coffee_beans/widgets/tasting_form_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App boots to the login screen', (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));

    expect(find.text('Roasted'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
  });

  testWidgets('Signing in navigates to the tab shell', (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Catalogue'), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
  });

  testWidgets('Home greets the user with discoveries and recommendations',
      (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Marc-André'), findsOneWidget);
    expect(find.text('Discoveries'), findsOneWidget);

    // The recommendations section is below the fold and builds lazily:
    // drag the home list down to reveal it.
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

  testWidgets('Profile shows the name header and the four section cards',
      (tester) async {
    await tester.pumpWidget(RoastedApp(state: AppState()));
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    // Open the Profile tab (the last BottomNavigationBar "Profile" label).
    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();

    expect(find.text('Marc-André'), findsOneWidget);
    expect(find.text('Information'), findsOneWidget);
    expect(find.text('Coffees tried'), findsOneWidget);
    expect(find.text('Recommended'), findsOneWidget);
    expect(find.text('Wishlist'), findsOneWidget);

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
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

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

    // The form closed; open Profile > Coffees tried.
    expect(find.text('Log a tasting'), findsNothing);
    await tester.tap(find.text('Profile').last);
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
    await tester.tap(find.text('Log in'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Stats').last);
    await tester.pumpAndSettle();

    expect(find.text('Coffee stats'), findsOneWidget);
    expect(find.text('TASTINGS'), findsOneWidget);
    expect(find.text('DAY STREAK'), findsOneWidget);

    // Hall of fame is below the fold (lazy-built).
    await tester.scrollUntilVisible(find.text('Hall of fame'), 500);
    await tester.pumpAndSettle();
    expect(find.text('Hall of fame'), findsOneWidget);
  });
}
