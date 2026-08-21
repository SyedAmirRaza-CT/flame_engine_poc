import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'features/mental_health_game/data/datasources/bird_local_data_source.dart';
import 'features/mental_health_game/data/repositories/bird_repository_impl.dart';
import 'features/mental_health_game/domain/repositories/bird_repository.dart';
import 'features/mental_health_game/presentation/providers/bird_provider.dart';
import 'features/mental_health_game/presentation/providers/mental_health_provider.dart';
import 'features/mental_health_game/presentation/pages/splash_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
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
}

class MentalHealthGameApp extends StatelessWidget {
  const MentalHealthGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental Health Life Simulation',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}
