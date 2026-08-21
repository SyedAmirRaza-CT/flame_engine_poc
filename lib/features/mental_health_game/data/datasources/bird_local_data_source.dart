import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/constants.dart';
import '../models/bird_profile_model.dart';

abstract class BirdLocalDataSource {
  Future<BirdProfileModel?> getBirdProfile();
  Future<void> saveBirdProfile(BirdProfileModel profile);
  Future<void> deleteBirdProfile();
}

class BirdLocalDataSourceImpl implements BirdLocalDataSource {
  final SharedPreferences sharedPreferences;

  BirdLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<BirdProfileModel?> getBirdProfile() async {
    final jsonString = sharedPreferences.getString(GameConstants.mental_healthProfileKey);
    if (jsonString != null) {
      return BirdProfileModel.fromJson(json.decode(jsonString));
    }
    return null;
  }

  @override
  Future<void> saveBirdProfile(BirdProfileModel profile) async {
    await sharedPreferences.setString(
      GameConstants.mental_healthProfileKey,
      json.encode(profile.toJson()),
    );
  }

  @override
  Future<void> deleteBirdProfile() async {
    await sharedPreferences.remove(GameConstants.mental_healthProfileKey);
  }
}
