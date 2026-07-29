
import 'package:flutter/foundation.dart';
import 'package:dastra/core/models/models.dart';
import 'package:dastra/core/storage/storage_service.dart';

class UserPreferencesService extends ChangeNotifier {
  final StorageService _storage;
  UserProfile _profile = const UserProfile();

  UserPreferencesService(this._storage);

  UserProfile get profile => _profile;

  Future<void> init() async {
    final profileJson = _storage.getString('user_profile_json');
    if (profileJson != null && profileJson.isNotEmpty) {
      try {
        _profile = UserProfile.fromJson(profileJson);
      } catch (e) {
        // Fallback to defaults on corrupt data
        _profile = const UserProfile();
      }
    }
  }

  Future<void> saveProfile(UserProfile newProfile) async {
    _profile = newProfile;
    await _storage.setString('user_profile_json', _profile.toJson());
    notifyListeners();
  }

  bool get hasSeenOnboarding => _storage.getBool('hasSeenOnboarding') ?? false;

  Future<void> setHasSeenOnboarding(bool value) async {
    await _storage.setBool('hasSeenOnboarding', value);
    notifyListeners();
  }

  bool isFavorite(String toolId) {
    return _profile.favoriteToolIds.contains(toolId);
  }

  Future<void> toggleFavorite(String toolId) async {
    final currentFavorites = List<String>.from(_profile.favoriteToolIds);
    if (currentFavorites.contains(toolId)) {
      currentFavorites.remove(toolId);
    } else {
      currentFavorites.add(toolId);
    }
    
    await saveProfile(_profile.copyWith(favoriteToolIds: currentFavorites));
  }
}
