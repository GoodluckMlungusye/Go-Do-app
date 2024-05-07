import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';
import '../models/Task.dart';

class HomeModel extends BaseViewModel{

  HomeModel(){
    taskBox = Hive.box('task');
    getTodayTasks();
  }

  late Box<Task> taskBox;

  List<Task> completedTodayTasks = [];

  List<Task> totalTodayTasks = [];

  List<Task> todayTasks = [];

  int getTotalTasksAccomplishedToday(){
    for(Task task in taskBox.values.toList()){
      if(isTodayTask(task.tacklingDate) && task.isFinished == true ){
        completedTodayTasks.add(task);
        notifyListeners();
      }
    }
    return completedTodayTasks.length;
  }

  int getTotalTasksToday(){
    for(Task task in taskBox.values.toList()){
      if(isTodayTask(task.tacklingDate)){
        totalTodayTasks.add(task);
        notifyListeners();
      }
    }
    return totalTodayTasks.length;
  }

  double getPercentAccomplishedToday(){
    return getTotalTasksAccomplishedToday()/getTotalTasksToday();
  }

  bool isTodayTask(String todayDate){
    if(DateTime.parse(todayDate).year == DateTime.now().year
        &&
        DateTime.parse(todayDate).month == DateTime.now().month
        &&
        DateTime.parse(todayDate).day == DateTime.now().day){
      return true;
    }
    else{
      return false;
    }
  }

  List<Task> getTodayTasks(){
    for(Task task in taskBox.values.toList()){
      if(isTodayTask(task.tacklingDate)){
        todayTasks.add(task);
        notifyListeners();
      }
    }
    return todayTasks;
  }

  Widget getPriorityIcon(String priority) {
    Widget priorityIcon;

    switch(priority) {
      case 'High':
        priorityIcon = const Icon(Icons.keyboard_double_arrow_up,color: Colors.red);
        break;
      case 'Medium':
        priorityIcon = const Icon(Icons.dehaze,color: Colors.green);
        break;
      case 'Low':
        priorityIcon = const Icon(Icons.keyboard_double_arrow_down,color: Colors.yellow);
        break;
      default:
        priorityIcon = const Icon(Icons.keyboard_double_arrow_up,color: Colors.red);
    }
    return priorityIcon;
  }

  Future<void> deleteTask(int taskKey) async {
    await taskBox.delete(taskKey);
  }

  void handleCheckBoxChange(bool? value, Task task, int index){
      task.isFinished = value!;
      taskBox.putAt(index, Task(
          name: task.name,
          categoryKey: task.categoryKey,
          tacklingDate: task.tacklingDate,
          startTime: task.startTime,
          endTime: task.endTime,
          priority: task.priority,
          isFinished: value));
      notifyListeners();
    }
}