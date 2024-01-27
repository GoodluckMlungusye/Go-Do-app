import 'package:hive_flutter/hive_flutter.dart';
part'Task.g.dart';

@HiveType(typeId:0)
class Task extends HiveObject{

  @HiveField(0)
  final String name;
  @HiveField(1)
  final int categoryKey;
  @HiveField(2)
  final String tacklingDate;
  @HiveField(3)
  final String startTime;
  @HiveField(4)
  final String endTime;
  @HiveField(5)
  final String priority;
  @HiveField(6)
  late  bool isFinished;


  Task(
        {
          required this.name,
          required this.categoryKey,
          required this.tacklingDate,
          required this.startTime,
          required this.endTime,
          required this.priority,
          this.isFinished = false,
        }
      );
}
