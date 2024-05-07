import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';

import '../models/Category.dart';
import '../models/Task.dart';

class CategoryModel extends BaseViewModel {

  CategoryModel(){
    taskBox = Hive.box('task');
    categoryBox = Hive.box('category');
  }

  late Box<Task> taskBox;
  late Box<Category> categoryBox;

  List<Task> totalTasksAccomplished = [];

  List<Task> totalCategoryTasks = [];

  List<Task> totalCategoryTasksAccomplished = [];

  int getTotalTasks(){
    return taskBox.length;
  }

  int getTotalTasksAccomplished(){
    totalTasksAccomplished.clear();
    for(Task task in taskBox.values.toList()){
      if(task.isFinished){
        totalTasksAccomplished.add(task);
      }
    }
    return totalTasksAccomplished.length;
  }

  double getAccomplishedPercent(){
    return getTotalTasksAccomplished()/getTotalTasks();
  }

  int getTotalCategoryTasks(String categoryName){
    totalCategoryTasks.clear();
    for(Task task in taskBox.values.toList()){
      if(categoryBox.getAt(task.categoryKey)!.name == categoryName){
        totalCategoryTasks.add(task);
      }
    }
    return totalCategoryTasks.length;
  }

  int getTotalCategoryTasksAccomplished(String categoryName){
    totalCategoryTasksAccomplished.clear();
    for(Task task in taskBox.values.toList()){
      if(categoryBox.getAt(task.categoryKey)!.name == categoryName && task.isFinished){
        totalCategoryTasksAccomplished.add(task);
      }
    }
    return totalCategoryTasksAccomplished.length;
  }

  double getAccomplishedCategoryPercent(String categoryName){
    return getTotalCategoryTasksAccomplished(categoryName)/getTotalCategoryTasks(categoryName);
  }

  int getTotalCategoryTasksLeft(String categoryName){
    return (getTotalCategoryTasks(categoryName)-getTotalCategoryTasksAccomplished(categoryName));
  }
}
