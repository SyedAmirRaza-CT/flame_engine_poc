import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:two_d_flamee_engine/main.dart';
import 'package:two_d_flamee_engine/features/bird_game/presentation/providers/bird_providers.dart';

void main() {
  testWidgets('App starts and shows name entry', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const BirdLifeGameApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("What's your bird's name?"), findsOneWidget);
  });
}
