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

  Person(this.name, this.phoneNumber, this.bio, this.role, this.email);
}
