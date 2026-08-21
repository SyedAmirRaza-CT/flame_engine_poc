import '../entities/bird_profile.dart';

abstract class BirdRepository {
  Future<BirdProfile?> getBirdProfile();
  Future<void> saveBirdProfile(BirdProfile profile);
  Future<void> deleteBirdProfile();
}
