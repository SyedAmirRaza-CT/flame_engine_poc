import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/bird_local_data_source.dart';
import '../../data/repositories/bird_repository_impl.dart';
import '../../domain/repositories/bird_repository.dart';
import '../controllers/bird_controller.dart';
import '../../domain/entities/bird_profile.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final birdLocalDataSourceProvider = Provider<BirdLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BirdLocalDataSourceImpl(sharedPreferences: prefs);
});

final birdRepositoryProvider = Provider<BirdRepository>((ref) {
  final localDataSource = ref.watch(birdLocalDataSourceProvider);
  return BirdRepositoryImpl(localDataSource: localDataSource);
});

final birdControllerProvider = StateNotifierProvider<BirdController, BirdProfile?>((ref) {
  final repository = ref.watch(birdRepositoryProvider);
  return BirdController(repository: repository);
});
