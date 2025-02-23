import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:jedweli/core/services/storage_service.dart';
import '../../data/models/favorite_model.dart';
import '../../data/datasources/favorite_service.dart';

/// A GetX controller to manage user's Favorites.
/// 
/// Holds an observable list of [favoriteEntries], which contain 
/// schedule IDs the user has favorited.
class FavoriteController extends GetxController {
  final FavoriteService _favoriteService = Get.find<FavoriteService>();

  /// A list of all favorite entries for the current user.
  final RxList<FavoriteModel> favoriteEntries = <FavoriteModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    // ✅ Fetch Favorite Schedules when the controller is initialized
    _loadFavoritesIfLoggedIn();
  }

  Future<void> _loadFavoritesIfLoggedIn() async {
    final storageService = Get.find<StorageService>();
    if (storageService.isLoggedIn()) {
      await loadFavorites();
    }
  }

  /// Loads all favorite entries from the API and updates [favoriteEntries].
  Future<void> loadFavorites() async {
    try {
      debugPrint("[FavoriteController] Loading favorites...");
      final fetched = await _favoriteService.getFavoriteEntries();
      favoriteEntries.assignAll(fetched);
      debugPrint("[FavoriteController] Fetched ${favoriteEntries.length} favorites.");
    } catch (e) {
      debugPrint("❌ [FavoriteController] Error loading favorites: $e");
      Get.snackbar("Error", "Failed to load favorites: $e");
    }
  }

  /// Adds a schedule to the user's favorites, then reloads the local list.
  Future<void> addFavorite(int scheduleId) async {
    try {
      await _favoriteService.addFavorite(scheduleId);
      await loadFavorites(); // Refresh local data
      Get.snackbar("Success", "Schedule $scheduleId added to favorites.");
    } catch (e) {
      debugPrint("❌ [FavoriteController] Error adding favorite: $e");
      Get.snackbar("Error", "Failed to add favorite: $e");
    }
  }

  /// Removes a schedule from favorites, then updates [favoriteEntries].
  Future<void> removeFavorite(int scheduleId) async {
    try {
      await _favoriteService.removeFavorite(scheduleId);
      favoriteEntries.removeWhere((f) => f.scheduleId == scheduleId);
      Get.snackbar("Success", "Schedule $scheduleId removed from favorites.");
    } catch (e) {
      debugPrint("❌ [FavoriteController] Error removing favorite: $e");
      Get.snackbar("Error", "Failed to remove favorite: $e");
    }
  }

  /// Checks if a given [scheduleId] is currently in favorites.
  bool isFavorite(int scheduleId) {
    return favoriteEntries.any((f) => f.scheduleId == scheduleId);
  }
}
