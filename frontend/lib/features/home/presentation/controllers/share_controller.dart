import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:jedweli/features/home/data/datasources/schedule_service.dart';

class ShareController extends GetxController {
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  var isPublic = false.obs;
  var shareableLink = "".obs;
  var accessList = [].obs;
  var selectedPermission = "view".obs;
  final usernameController = TextEditingController();

  /// Fetch current sharing details
  Future<void> loadScheduleSharingDetails(int scheduleId) async {
    try {
      final response = await _scheduleService.getScheduleAccessList(scheduleId);
      if (response.statusCode == 200) {
        accessList.value = response.body["access_list"];
      }

      // ✅ Fetch Schedule Data
      final schedule = await _scheduleService.fetchScheduleById(scheduleId);
      if (schedule != null) {
        isPublic.value = schedule.isPublic;  // ✅ Ensure `isPublic` exists in ScheduleModel
        shareableLink.value = "http://yourapp.com/shared/${schedule.shareableId}";
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load sharing details");
    }
  }


  /// Toggle schedule sharing
  Future<void> toggleScheduleSharing(int scheduleId) async {
    final response = await _scheduleService.toggleSharing(scheduleId);
    if (response.statusCode == 200) {
      isPublic.value = response.body["is_public"];
    } else {
      Get.snackbar("Error", "Failed to update sharing settings");
    }
  }

  /// Grant access to a user
  Future<void> grantAccess(int scheduleId) async {
    final username = usernameController.text.trim();
    if (username.isEmpty) return;

    final response = await _scheduleService.grantAccess(scheduleId, username, selectedPermission.value);
    if (response.statusCode == 200) {
      Get.snackbar("Success", "Access granted");
      loadScheduleSharingDetails(scheduleId);
    } else {
      Get.snackbar("Error", response.body["error"] ?? "Failed to grant access");
    }
  }

  /// Revoke access
  Future<void> revokeAccess(int scheduleId, String username) async {
    final response = await _scheduleService.revokeAccess(scheduleId, username);
    if (response.statusCode == 200) {
      Get.snackbar("Success", "Access revoked");
      loadScheduleSharingDetails(scheduleId);
    } else {
      Get.snackbar("Error", response.body["error"] ?? "Failed to revoke access");
    }
  }

  /// Copy shareable link to clipboard
  void copyLinkToClipboard() {
    Clipboard.setData(ClipboardData(text: shareableLink.value));
    Get.snackbar("Copied!", "Shareable link copied to clipboard");
  }


}
