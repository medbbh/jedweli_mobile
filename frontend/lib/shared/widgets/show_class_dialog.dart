import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../../features/class/data/models/class_model.dart';
import '../../features/class/data/datasources/class_service.dart';

/// Displays a dialog for creating or updating a class.
///
/// If [existingClass] is provided, the dialog will be in update mode.
/// Returns a [Future] that completes with a [ClassModel] if the user submits the form,
/// or `null` if cancelled.
Future<ClassModel?> showClassDialog({
  int? scheduleId,
  ClassModel? existingClass,
}) async {
  final bool isUpdate = existingClass != null;
  final ClassService classService = Get.find<ClassService>();
  final Completer<ClassModel?> completer = Completer<ClassModel?>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Text controllers for form fields, with initial values if updating.
  final TextEditingController nameCtrl = TextEditingController(text: existingClass?.name ?? '');
  final TextEditingController instructorCtrl = TextEditingController(text: existingClass?.instructor ?? '');
  final TextEditingController startTimeCtrl = TextEditingController(text: existingClass?.startTime ?? '');
  final TextEditingController endTimeCtrl = TextEditingController(text: existingClass?.endTime ?? '');
  final TextEditingController locationCtrl = TextEditingController(text: existingClass?.location ?? '');

  final List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  String? selectedDay = existingClass?.day;
  String errorMessage = '';

  // Helper function to convert a TimeOfDay into minutes since midnight.
  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  /// Opens a time picker and updates the [controller] with the selected time.
  Future<void> pickTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: Get.context!,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child!,
          ),
        );
      },
    );
    if (picked != null) {
      controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  // The dialog widget built with AwesomeDialog and StatefulBuilder.
  late final AwesomeDialog dialog;

  /// Called when the user submits the form.
  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final String name = nameCtrl.text.trim();
    final String instructor = instructorCtrl.text.trim();
    final String startTxt = startTimeCtrl.text.trim();
    final String endTxt = endTimeCtrl.text.trim();
    final String location = locationCtrl.text.trim();

    if (selectedDay == null) {
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.error,
        title: 'Day Required',
        desc: 'Please select a day',
        btnOkOnPress: () {},
      ).show();
      return;
    }

    // Validate that start time is before end time.
    if (startTxt.isNotEmpty && endTxt.isNotEmpty) {
      final List<String> sParts = startTxt.split(':');
      final List<String> eParts = endTxt.split(':');
      final TimeOfDay sTOD = TimeOfDay(hour: int.parse(sParts[0]), minute: int.parse(sParts[1]));
      final TimeOfDay eTOD = TimeOfDay(hour: int.parse(eParts[0]), minute: int.parse(eParts[1]));
      if (toMinutes(sTOD) >= toMinutes(eTOD)) {
        AwesomeDialog(
          context: Get.context!,
          dialogType: DialogType.error,
          title: 'Invalid Time',
          desc: 'End time must be after start time',
          btnOkOnPress: () {},
        ).show();
        return;
      }
    }

    // Show a loading dialog while the network call is made.
    final AwesomeDialog loadingDialog = AwesomeDialog(
      context: Get.context!,
      dialogType: DialogType.noHeader,
      animType: AnimType.scale,
      dismissOnTouchOutside: false,
      dismissOnBackKeyPress: false,
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Please wait...'),
          ],
        ),
      ),
    )..show();

    try {
      if (!isUpdate) {
        final ClassModel newClass = await classService.createClass(
          ClassModel(
            scheduleId: scheduleId ?? 0,
            name: name,
            instructor: instructor,
            day: selectedDay!,
            startTime: startTxt,
            endTime: endTxt,
            location: location,
          ),
        );
        loadingDialog.dismiss();
        dialog.dismiss();
        completer.complete(newClass);
      } else {
        final ClassModel updatedModel = existingClass.copyWith(
          name: name,
          instructor: instructor,
          day: selectedDay,
          startTime: startTxt,
          endTime: endTxt,
          location: location,
        );
        final ClassModel res = await classService.updateClass(updatedModel);
        loadingDialog.dismiss();
        dialog.dismiss();
        completer.complete(res);
      }
    } catch (e) {
      loadingDialog.dismiss();
      errorMessage = 'Failed Updating Class. Please try again.';
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.error,
        title: 'Error',
        desc: errorMessage,
        btnOkOnPress: () {},
      ).show();
    }
  }

  // Build the AwesomeDialog with a StatefulBuilder for live updates.
  dialog = AwesomeDialog(
    context: Get.context!,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    showCloseIcon: true,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    body: StatefulBuilder(
      builder: (BuildContext ctx, void Function(void Function()) setState) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isUpdate ? 'Update Class' : 'Add New Class',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Class Name',
                    prefixIcon: Icon(Icons.class_),
                  ),
                  validator: (value) => value!.trim().isEmpty ? 'Enter class name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: instructorCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Instructor',
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) => value!.trim().isEmpty ? 'Enter instructor' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(
                    labelText: 'Day',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  items: days.map((day) => DropdownMenuItem(value: day, child: Text(day))).toList(),
                  onChanged: (val) => setState(() => selectedDay = val),
                  validator: (value) => value == null ? 'Select a day' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startTimeCtrl,
                        readOnly: true,
                        onTap: () => pickTime(startTimeCtrl),
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: endTimeCtrl,
                        readOnly: true,
                        onTap: () => pickTime(endTimeCtrl),
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          prefixIcon: Icon(Icons.access_time),
                        ),
                        validator: (value) => (value == null || value.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    prefixIcon: Icon(Icons.location_on),
                  ),
                  validator: (value) => value!.trim().isEmpty ? 'Enter location' : null,
                ),
                const SizedBox(height: 16),
                if (errorMessage.isNotEmpty)
                  Text(errorMessage, style: const TextStyle(color: Colors.red)),
              ],
            ),
          ),
        );
      },
    ),
    btnCancelOnPress: () => completer.complete(null),
    btnCancelText: 'Cancel',
    btnOkOnPress: onSubmit,
    btnOkText: isUpdate ? 'Update Class' : 'Add Class',
  );

  // Show the dialog and return the completer's future.
  dialog.show();
  return completer.future;
}
