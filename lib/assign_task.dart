import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'main.dart';
import 'person.dart';

class AssignTaskPage extends StatefulWidget {
  const AssignTaskPage({super.key});

  @override
  State<AssignTaskPage> createState() => _AssignTaskPageState();
}

class _AssignTaskPageState extends State<AssignTaskPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  Person? assignedToPerson;
  List<Person> employees = [];
  List<DropdownMenuItem> employeeMenuItems = [];

  void getEmployees() async {
    final box = await Hive.openBox<Person>(dbName);
    List<Person> people = [];
    for (var employee in box.values.toList()) {
      if (employee.role == Role.employee) {
        people.add(employee);
        print("added ${employee.name}");
      }
    }
    setState(() {
      employees = people;
    });
    List<DropdownMenuItem> menuItems = [
      for (var p in employees)
        DropdownMenuItem(value: p, child: Text(p.name.toString())),
    ];
    setState(() {
      employeeMenuItems = menuItems;
    });
  }

  @override
  void initState() {
    getEmployees();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign"),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () async {
                final box = Hive.box<Person>(dbName);
                var indexOfEmployee = employees.indexOf(assignedToPerson!);
                var newTask = Task(
                    titleController.text,
                    contentController.text,
                    DateTime.now(),
                    DateTime.now().add(const Duration(days: 10)),
                    assignedToPerson);

                box.putAt(
                    indexOfEmployee,
                    Person(
                        assignedToPerson!.name,
                        assignedToPerson!.phoneNumber,
                        assignedToPerson!.bio,
                        assignedToPerson!.role,
                        assignedToPerson!.email,
                        tasks: [newTask]));

                Navigator.pop(context);
              },
              child: const Text("Save"))
        ],
      ),
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(label: Text("Title")),
            ),
            TextFormField(
                controller: contentController,
                minLines: 5,
                maxLines: 10,
                decoration: const InputDecoration(label: Text("Content"))),
            Text(DateTime.now().toString()),
            Text(DateTime.now().add(const Duration(days: 10)).toString()),
            DropdownButton(
              hint: const Text("Assign To"),
              items: employeeMenuItems,
              value: assignedToPerson,
              onChanged: (value) {
                setState(() {
                  assignedToPerson = value;
                });
              },
            ),
          ],
        ),
      )),
    );
  }
}
