import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

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
                var box = Hive.box(dbName);
                var newTask = Task(
                    titleController.text,
                    contentController.text,
                    DateTime.now(),
                    DateTime.now().add(Duration(days: 10)),
                    assignedToPerson);
                box.add(newTask);
                Navigator.pop(context);
              },
              child: const Text("Save"))
        ],
      ),
      body: Center(
          child: Column(
        children: [
          TextFormField(controller: titleController),
          TextFormField(controller: contentController),
          DropdownButton(
            items: employeeMenuItems,
            onChanged: (value) {
              setState(() {
                assignedToPerson = value;
              });
            },
          ),
        ],
      )),
    );
  }
}
