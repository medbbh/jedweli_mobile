import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jedweli/features/home/data/models/schedule_model.dart';
import 'package:jedweli/routes/app_routes.dart';
import '../controllers/shared_schedule_controller.dart';

class SharedSchedulesScreen extends StatelessWidget {
  SharedSchedulesScreen({Key? key}) : super(key: key);

  final SharedScheduleController sharedController = Get.find<SharedScheduleController>();

  Future<void> _refresh() async {
    await sharedController.fetchSharedSchedules();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch schedules on build
    sharedController.fetchSharedSchedules();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Shared With Me",
          style: TextStyle(fontWeight: FontWeight.bold,color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade50, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Obx(() {
          if (sharedController.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sharedController.sharedSchedules.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.inbox, size: 80, color: Colors.blueAccent),
                  const SizedBox(height: 12),
                  const Text(
                    "No shared schedules available.",
                    style: TextStyle(fontSize: 18, color: Colors.black54),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh, color: Colors.blueAccent),
                    label: const Text("Reload", style: TextStyle(color: Colors.blueAccent)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  )
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sharedController.sharedSchedules.length,
              itemBuilder: (context, index) {
                final ScheduleModel schedule = sharedController.sharedSchedules[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Hero(
                    tag: "sharedSchedule_${schedule.shareableId}",
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Get.toNamed(AppRoutes.sharedScheduleDetail, arguments: schedule.shareableId);
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.blue.shade100, width: 1),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Row(
                            children: [
                              // Left accent bar
                              Container(
                                width: 6,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(16),
                                    bottomLeft: Radius.circular(16),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        schedule.title,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Tap to view details",
                                        style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
