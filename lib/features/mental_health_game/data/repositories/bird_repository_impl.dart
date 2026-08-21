import '../../domain/entities/bird_profile.dart';
import '../../domain/repositories/bird_repository.dart';
import '../datasources/bird_local_data_source.dart';
import '../models/bird_profile_model.dart';

class BirdRepositoryImpl implements BirdRepository {
  final BirdLocalDataSource localDataSource;

  BirdRepositoryImpl({required this.localDataSource});

  @override
  Future<BirdProfile?> getBirdProfile() async {
    return await localDataSource.getBirdProfile();
  }

  @override
  Future<void> saveBirdProfile(BirdProfile profile) async {
    await localDataSource.saveBirdProfile(BirdProfileModel.fromEntity(profile));
  }

  @override
  Future<void> deleteBirdProfile() async {
    await localDataSource.deleteBirdProfile();
  }
}
