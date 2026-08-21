import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mental_health_game/main.dart';
import 'package:mental_health_game/features/mental_health_game/data/datasources/bird_local_data_source.dart';
import 'package:mental_health_game/features/mental_health_game/data/repositories/bird_repository_impl.dart';
import 'package:mental_health_game/features/mental_health_game/domain/repositories/bird_repository.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/providers/bird_provider.dart';
import 'package:mental_health_game/features/mental_health_game/presentation/providers/mental_health_provider.dart';

void main() {
  testWidgets('App starts and shows name entry', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<SharedPreferences>.value(value: sharedPreferences),
          Provider<BirdLocalDataSource>(
            create: (context) => BirdLocalDataSourceImpl(
              sharedPreferences: context.read<SharedPreferences>(),
            ),
          ),
          Provider<BirdRepository>(
            create: (context) => BirdRepositoryImpl(
              localDataSource: context.read<BirdLocalDataSource>(),
            ),
          ),
          ChangeNotifierProvider<BirdProvider>(
            create: (context) => BirdProvider(
              repository: context.read<BirdRepository>(),
            ),
          ),
          ChangeNotifierProvider<MentalHealthProvider>(
            create: (context) => MentalHealthProvider(),
          ),
        ],
        child: const MentalHealthGameApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text("What's your bird's name?"), findsOneWidget);
  });
}
