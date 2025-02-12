import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import '../models/class_model.dart';
import '../services/class_service.dart';
  
Future<ClassModel?> showClassDialog({
  int? scheduleId,
  ClassModel? existingClass,z
}) async {
  final isUpdate = (existingClass != null);
  final classService = Get.find<ClassService>();
  final completer = Completer<ClassModel?>();
  final formKey = GlobalKey<FormState>();

  final nameCtrl = TextEditingController(text: existingClass?.name ?? '');
  final instructorCtrl = TextEditingController(text: existingClass?.instructor ?? '');
  final startTimeCtrl = TextEditingController(text: existingClass?.startTime ?? '');
  final endTimeCtrl = TextEditingController(text: existingClass?.endTime ?? '');
  final locationCtrl = TextEditingController(text: existingClass?.location ?? '');

  final days = ['Monday','Tuesday','Wednesday','Thursday','Friday','Saturday','Sunday'];
  String? selectedDay = existingClass?.day;
  String errorMessage = '';
  bool isLoading = false;

  int toMinutes(TimeOfDay t) => t.hour * 60 + t.minute;

  Future<void> pickTime(TextEditingController ctrl) async {
    final picked = await showTimePicker(
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
      ctrl.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  late final AwesomeDialog dialog;

  Future<void> onSubmit() async {
    if (!formKey.currentState!.validate()) return;

    final name = nameCtrl.text.trim();
    final instructor = instructorCtrl.text.trim();
    final startTxt = startTimeCtrl.text.trim();
    final endTxt = endTimeCtrl.text.trim();
    final location = locationCtrl.text.trim();
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

    if (startTxt.isNotEmpty && endTxt.isNotEmpty) {
      final sParts = startTxt.split(':');
      final eParts = endTxt.split(':');
      final sTOD = TimeOfDay(hour: int.parse(sParts[0]), minute: int.parse(sParts[1]));
      final eTOD = TimeOfDay(hour: int.parse(eParts[0]), minute: int.parse(eParts[1]));
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

    isLoading = true;
    final loadingDialog = AwesomeDialog(
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
        final newClass = await classService.createClass(
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
        final updatedModel = existingClass.copyWith(
          name: name,
          instructor: instructor,
          day: selectedDay,
          startTime: startTxt,
          endTime: endTxt,
          location: location,
        );
        final res = await classService.updateClass(updatedModel);
        loadingDialog.dismiss();
        dialog.dismiss();
        completer.complete(res);
      }
    } catch (e) {
      loadingDialog.dismiss();
      isLoading = false;
      errorMessage = 'Failed: $e';
      AwesomeDialog(
        context: Get.context!,
        dialogType: DialogType.error,
        title: 'Error',
        desc: errorMessage,
        btnOkOnPress: () {},
      ).show();
    }
  }

  dialog = AwesomeDialog(
    context: Get.context!,
    dialogType: DialogType.noHeader,
    animType: AnimType.scale,
    headerAnimationLoop: false,
    showCloseIcon: true,
    dismissOnTouchOutside: false,
    dismissOnBackKeyPress: false,
    body: StatefulBuilder(
      builder: (ctx, setState) {
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
                  decoration: const InputDecoration(labelText: 'Class Name', prefixIcon: Icon(Icons.class_)),
                  validator: (v) => v!.trim().isEmpty ? 'Enter class name' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: instructorCtrl,
                  decoration: const InputDecoration(labelText: 'Instructor', prefixIcon: Icon(Icons.person)),
                  validator: (v) => v!.trim().isEmpty ? 'Enter instructor' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedDay,
                  decoration: const InputDecoration(labelText: 'Day', prefixIcon: Icon(Icons.calendar_today)),
                  items: days.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                  onChanged: (val) => setState(() => selectedDay = val),
                  validator: (v) => (v == null) ? 'Select a day' : null,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startTimeCtrl,
                        readOnly: true,
                        onTap: () => pickTime(startTimeCtrl),
                        decoration: const InputDecoration(labelText: 'Start Time', prefixIcon: Icon(Icons.access_time)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: endTimeCtrl,
                        readOnly: true,
                        onTap: () => pickTime(endTimeCtrl),
                        decoration: const InputDecoration(labelText: 'End Time', prefixIcon: Icon(Icons.access_time)),
                        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: locationCtrl,
                  decoration: const InputDecoration(labelText: 'Location', prefixIcon: Icon(Icons.location_on)),
                  validator: (v) => v!.trim().isEmpty ? 'Enter location' : null,
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

  dialog.show();
  return completer.future;
}
