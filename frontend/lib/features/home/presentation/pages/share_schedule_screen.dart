import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/features/home/data/models/schedule_model.dart';
import 'package:jedweli/features/home/presentation/controllers/share_controller.dart';

class ShareScheduleScreen extends StatelessWidget {
  final ShareController shareController = Get.find<ShareController>();

  ShareScheduleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Retrieve schedule from arguments and load its sharing details.
    final ScheduleModel schedule = Get.arguments;
    shareController.loadScheduleSharingDetails(schedule.id);

    return Scaffold(
      appBar: AppBar(
        title: Text("Share ${schedule.title}",style: TextStyle(color: Colors.white),),
        centerTitle: true,
        backgroundColor: Colors.indigo[800],
        elevation: 0,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Increase horizontal padding on larger screens.
            final horizontalPadding = constraints.maxWidth > 800 ? 64.0 : 16.0;
            // Adjust header text size for larger screens.
            final headerTextSize = constraints.maxWidth > 800 ? 28.0 : 22.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Schedule Header Card.
                  Card(
                    color: Colors.indigo[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 6,
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        children: [
                          const Icon(Icons.share, size: 48, color: Colors.white),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              schedule.title,
                              style: TextStyle(
                                fontSize: headerTextSize,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Public Sharing Toggle Card.
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    child: Obx(
                          () => SwitchListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        title: const Text(
                          "Enable Public Sharing",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text("Anyone with the link can view"),
                        activeColor: Colors.indigo,
                        value: shareController.isPublic.value,
                        onChanged: (value) {
                          shareController.toggleScheduleSharing(schedule.id);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Shareable Link Card.
                  Obx(
                        () => shareController.isPublic.value
                        ? Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      elevation: 4,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: const Text(
                          "Shareable Link",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: SelectableText(
                          shareController.shareableLink.value,
                          style: const TextStyle(color: Colors.indigo),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.copy, color: Colors.indigo),
                          onPressed: shareController.copyLinkToClipboard,
                        ),
                      ),
                    )
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  // Invite Users Section Header.
                  Text(
                    "Invite Users",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Invite Users Input Card.
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: shareController.usernameController,
                              decoration: const InputDecoration(
                                hintText: "Enter username",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                          Obx(
                                () => DropdownButton<String>(
                              value: shareController.selectedPermission.value,
                              underline: const SizedBox(),
                              items: ["view", "edit"]
                                  .map(
                                    (permission) => DropdownMenuItem(
                                  value: permission,
                                  child: Text(
                                    permission.toUpperCase(),
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              )
                                  .toList(),
                              onChanged: (value) {
                                shareController.selectedPermission.value = value!;
                              },
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send, color: Colors.indigo),
                            onPressed: () {
                              shareController.grantAccess(schedule.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Users with Access Section Header.
                  Text(
                    "Users with Access",
                    style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Expanded List of Users with Access.
                  Obx(() {
                    if (shareController.accessList.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.people_outline, size: 60, color: Colors.indigo.shade200),
                            const SizedBox(height: 8),
                            const Text("No users have access"),
                          ],
                        ),
                      );
                    }
                    return ListView.separated(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: shareController.accessList.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final user = shareController.accessList[index];
                        return Card(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          elevation: 4,
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: Colors.indigo.shade100,
                              child: Text(
                                user["user__username"].substring(0, 1).toUpperCase(),
                                style: TextStyle(color: Colors.indigo.shade800),
                              ),
                            ),
                            title: Text(user["user__username"], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text("Permission: ${user["permission"].toUpperCase()}"),
                            trailing: IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: () {
                                shareController.revokeAccess(schedule.id, user["user__username"]);
                              },
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
