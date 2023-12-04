import 'package:hive/hive.dart';

part 'person.g.dart';

@HiveType(typeId: 1)
enum Role {
  @HiveField(0)
  manger,

  @HiveField(1)
  employee,

  @HiveField(2)
  admin
}

@HiveType(typeId: 0)
class Person extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  String? email;

  @HiveField(2)
  int? phoneNumber;

  @HiveField(3)
  Role role = Role.employee;

  @HiveField(4)
  String? bio;

  @HiveField(5)
  List<Task>? tasks;

  Person(this.name, this.phoneNumber, this.bio, this.role, this.email);
}

@HiveType(typeId: 2)
class Task extends HiveObject {
  @HiveField(0)
  late String title;

  @HiveField(1)
  String? content;

  @HiveField(2)
  DateTime? startTime;

  @HiveField(3)
  DateTime? endTime;

  @HiveField(4)
  Person? assignedTo;

  Task(this.title, this.content, this.startTime, this.endTime, this.assignedTo);
}
