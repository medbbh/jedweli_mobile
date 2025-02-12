import 'package:get/get.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/utils/constants.dart';
import '../models/favorite_model.dart';

/// A remote data source for managing Favorite schedules.
/// 
/// This class handles the creation, listing, and removal of
/// favorites from the server, using GetConnect for HTTP requests.
class FavoriteService extends GetConnect {
  final StorageService _storageService = Get.find<StorageService>();

  @override
  void onInit() {
    httpClient.baseUrl = Constants.baseApiUrl;
    httpClient.defaultContentType = 'application/json';
    httpClient.timeout = const Duration(seconds: 15);
    super.onInit();
  }

  /// Helper method to inject the Bearer token into request headers.
  Map<String, String> _getHeaders() {
    final token = _storageService.getAccessToken();
    if (token == null) {
      throw Exception("[FavoriteService] No token found. User might not be logged in.");
    }
    return {'Authorization': 'Bearer $token'};
  }

  // ---------------------------------------------------------------------------
  // CRUD methods for Favorites
  // ---------------------------------------------------------------------------

  /// Fetches all favorite entries from the server (list of [FavoriteModel]).
  /// Each entry typically includes an ID and a schedule ID (and possibly more data).
  Future<List<FavoriteModel>> getFavoriteEntries() async {
    try {
      final response = await get('favorites/', headers: _getHeaders());
      if (response.statusCode == 200 && response.body is List) {
        return (response.body as List)
            .map((json) => FavoriteModel.fromJson(json))
            .toList();
      }
      throw Exception("[FavoriteService] Failed to fetch favorites: ${response.body}");
    } catch (e) {
      rethrow;
    }
  }

  /// Adds the schedule with [scheduleId] to the user’s favorites.
  /// On success, returns normally; otherwise throws an [Exception].
  Future<void> addFavorite(int scheduleId) async {
    try {
      final response = await post(
        'favorites/',
        {'schedule': scheduleId},
        headers: _getHeaders(),
      );

      // 201 (Created) or 200 with a “message” typically means success
      if (response.statusCode == 201 ||
          (response.statusCode == 200 && response.body['message'] != null)) {
        return;
      }
      throw Exception("[FavoriteService] Failed to add favorite: ${response.body}");
    } catch (e) {
      rethrow;
    }
  }

  /// Removes the schedule with [scheduleId] from the user’s favorites.
  /// Finds the Favorite entry first, then deletes it by its favorite ID.
  Future<void> removeFavorite(int scheduleId) async {
    try {
      // First fetch all favorites
      final favorites = await getFavoriteEntries();
      // Find the specific favorite entry for the schedule
      final favoriteEntry = favorites.firstWhere(
        (f) => f.scheduleId == scheduleId,
        orElse: () => throw Exception(
          "[FavoriteService] Favorite entry not found for scheduleId: $scheduleId",
        ),
      );

      final response = await delete('favorites/${favoriteEntry.id}/', headers: _getHeaders());
      if (response.statusCode != 204) {
        throw Exception("[FavoriteService] Failed to remove favorite: ${response.body}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
