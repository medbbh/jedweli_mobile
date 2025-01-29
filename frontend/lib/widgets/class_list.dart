// widgets/class_list.dart
import 'package:flutter/material.dart';
import '../models/class_model.dart';

class ClassList extends StatelessWidget {
  final List<ClassModel> classes;

  const ClassList(this.classes, {super.key});

  @override
  Widget build(BuildContext context) {
    if (classes.isEmpty) {
      return const Center(
        child: Text("No classes available."),
      );
    }

    return ListView.separated(
      itemCount: classes.length,
      separatorBuilder: (context, index) => const Divider(),
      itemBuilder: (context, index) {
        final classItem = classes[index];
        return ListTile(
          leading: const Icon(Icons.class_),
          title: Text(classItem.name),
          subtitle: Text('${classItem.day} | ${classItem.startTime} - ${classItem.endTime}'),
          trailing: Text(classItem.location),
        );
      },
    );
  }
}
