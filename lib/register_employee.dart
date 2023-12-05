import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import 'main.dart';
import 'person.dart';

class RegisterEmployeePage extends StatefulWidget {
  const RegisterEmployeePage({super.key});

  @override
  State<RegisterEmployeePage> createState() => _RegisterEmployeePageState();
}

class _RegisterEmployeePageState extends State<RegisterEmployeePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Register"),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: () async {
                var box = await Hive.openBox<Person>(dbName);
                var newEmployee = Person(
                    nameController.text,
                    int.parse(phoneController.text),
                    bioController.text,
                    Role.employee,
                    emailController.text);
                box.add(newEmployee);
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
              controller: nameController,
              decoration: const InputDecoration(label: Text("Name")),
            ),
            TextFormField(
              controller: bioController,
              decoration: const InputDecoration(label: Text("Bio")),
            ),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(label: Text("Email")),
            ),
            TextFormField(
              controller: phoneController,
              decoration: const InputDecoration(label: Text("Phone")),
            ),
          ],
        ),
      )),
    );
  }
}
