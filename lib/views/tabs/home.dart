import 'dart:async';
import 'package:GoDo/themes/theme_assets.dart';
import 'package:GoDo/views/pages/my_task.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../components/progress_viewer.dart';
import '../../models/Task.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late Box<Task> taskBox;

  List<Task> completedTodayTasks = [];

  List<Task> totalTodayTasks = [];

  List<Task> todayTasks = [];

  int getTotalTasksAccomplishedToday(){
    for(Task task in taskBox.values.toList()){
      if(isTodayTask(task.tacklingDate) && task.isFinished == true ){
       setState(() {
         completedTodayTasks.add(task);
       });
      }
    }
    return completedTodayTasks.length;
  }

  int getTotalTasksToday(){
    for(Task task in taskBox.values.toList()){
      if(isTodayTask(task.tacklingDate)){
        setState(() {
          totalTodayTasks.add(task);
        });
      }
    }
    return totalTodayTasks.length;
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
        setState(() {
          todayTasks.add(task);
        });
      }
    }
    return todayTasks;
  }

  void showToast(String message,Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
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

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box('task');
    getTodayTasks();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            title: const Text(
              'GoDo',
              style: TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            centerTitle: true,
          ),
          body: todayTasks.isNotEmpty?
          Column(
            children:  [
               Padding(
                padding: const EdgeInsets.only(top: 30,left: 16,right: 18,bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Today's progress",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),

                    Text(
                      (getTotalTasksToday() == 0 || getTotalTasksAccomplishedToday() == 0)? "0%" : "${((getTotalTasksAccomplishedToday()/getTotalTasksToday())*100).toInt()}%",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                  padding: const EdgeInsets.only(left: 12,right: 12),
                  child: LinearPercentIndicator(
                    animation: true,
                    animationDuration: 1000,
                    lineHeight: 20,
                    percent: (getTotalTasksToday() == 0 || getTotalTasksAccomplishedToday() == 0)? 0 : getTotalTasksAccomplishedToday().toDouble()/getTotalTasksToday().toDouble(),
                    progressColor: AppColors.primaryColorLight,
                    backgroundColor: AppColors.lightGray,
                    barRadius: const Radius.circular(8),
                  )
              ),
              const Padding(
                padding: EdgeInsets.only(top: 30,left: 16,bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Today's Tasks",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ),

              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: taskBox.listenable(),
                    builder: (context, box, child){
                      return ListView.builder(
                          itemCount: taskBox.length,
                          itemBuilder: (BuildContext context, index) {
                          final task = taskBox.getAt(index) as Task;
                          if(isTodayTask(task.tacklingDate)){
                            return Padding(
                              padding: const EdgeInsets.only(left: 16,right: 16,bottom: 8),
                              child: SizedBox(
                                height: 80,
                                width: double.infinity,
                                child: Card(
                                  elevation: 4,
                                  child: ListTile(
                                    onTap: (){
                                      task.isFinished?
                                      showToast('The task has been accomplished', AppColors.primaryColorLight):
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyTask(task:task, isHomeReturn: true)));
                                    },
                                    title: Row(
                                      children: [
                                        Flexible(
                                          child: Text(
                                            task.name,
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: task.isFinished? FontWeight.normal: FontWeight.bold,
                                                decoration:  task.isFinished? TextDecoration.lineThrough : TextDecoration.none,
                                                overflow:TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 20),
                                        getPriorityIcon(task.priority)
                                      ],
                                    ),
                                    subtitle: Text(
                                      "${task.startTime} - ${task.endTime}",
                                      style: TextStyle(
                                        fontSize: 12,
                                        decoration:  task.isFinished? TextDecoration.lineThrough : TextDecoration.none,
                                      ),
                                    ),
                                    leading: Checkbox(
                                        activeColor: AppColors.primaryColorLight,
                                        side: const BorderSide(
                                            color: AppColors.primaryColorLight
                                        ),
                                        value: task.isFinished,
                                        onChanged: (newBool){
                                          setState(() {
                                            task.isFinished = newBool!;
                                            taskBox.putAt(index, Task(
                                                name: task.name,
                                                categoryKey: task.categoryKey,
                                                tacklingDate: task.tacklingDate,
                                                startTime: task.startTime,
                                                endTime: task.endTime,
                                                priority: task.priority,
                                                isFinished: newBool));
                                          });
                                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  ProgressViewer(isFinished: task.isFinished)));
                                        }
                                    ),
                                    trailing: task.isFinished? IconButton(onPressed: (){
                                      deleteTask(task.key);
                                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  ProgressViewer(isFinished: task.isFinished)));
                                    }, icon: const Icon(Icons.delete,color: Colors.red)) : const Icon(Icons.arrow_forward_ios_rounded),
                                  ),
                                ),
                              ),
                            );
                          }
                          return Container();
                          }
                      );
                    }
                ),
              ),
            ],
          ) :  const Center(
            child: Text("No tasks scheduled today!"),
          )
      ),
    );
  }
}
