// widgets/add_class_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/class_model.dart';
import '../services/schedule_service.dart';

class AddClassDialog extends StatefulWidget {
  final int scheduleId;

  const AddClassDialog({super.key, required this.scheduleId});

  @override
  _AddClassDialogState createState() => _AddClassDialogState();
}

class _AddClassDialogState extends State<AddClassDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _instructorController = TextEditingController();
  final TextEditingController _dayController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';
  final ScheduleService _scheduleService = Get.find<ScheduleService>();

  @override
  void dispose() {
    _nameController.dispose();
    _instructorController.dispose();
    _dayController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _addClass() async {
    final String name = _nameController.text.trim();
    final String instructor = _instructorController.text.trim();
    final String day = _dayController.text.trim();
    final String startTime = _startTimeController.text.trim();
    final String endTime = _endTimeController.text.trim();
    final String location = _locationController.text.trim();

    if (name.isEmpty ||
        instructor.isEmpty ||
        day.isEmpty ||
        startTime.isEmpty ||
        endTime.isEmpty ||
        location.isEmpty) {
      setState(() {
        _errorMessage = 'All fields are required.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final ClassModel newClass = await _scheduleService.createClass(
        scheduleId: widget.scheduleId,
        name: name,
        instructor: instructor,
        day: day,
        startTime: startTime,
        endTime: endTime,
        location: location,
      );

      Get.back(result: newClass); // Return the new class to the parent
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to add class: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Class"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: "Class Name"),
            ),
            TextField(
              controller: _instructorController,
              decoration: const InputDecoration(labelText: "Instructor"),
            ),
            TextField(
              controller: _dayController,
              decoration: const InputDecoration(labelText: "Day (e.g., Monday)"),
            ),
            TextField(
              controller: _startTimeController,
              decoration: const InputDecoration(labelText: "Start Time (HH:MM)"),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _endTimeController,
              decoration: const InputDecoration(labelText: "End Time (HH:MM)"),
              keyboardType: TextInputType.datetime,
            ),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: "Location"),
            ),
            if (_isLoading) const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Get.back(),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addClass,
          child: const Text("Add"),
        ),
      ],
    );
  }
}
