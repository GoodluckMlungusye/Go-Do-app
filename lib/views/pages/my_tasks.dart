import 'package:GoDo/themes/theme_assets.dart';
import 'package:GoDo/views/startups/navigation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import '../../models/Category.dart';
import '../../models/Task.dart';
import 'my_task.dart';

class MyTasks extends StatefulWidget {
  final String taskCategory;
  const MyTasks({super.key, required this.taskCategory});

  @override
  State<MyTasks> createState() => _MyTasksState();
}

class _MyTasksState extends State<MyTasks> {

  late Box<Task> taskBox;
  late Box<Category> categoryBox;

  List<Task> taskList = [];

  List<Task> filteredTaskList = [];

  List<Task> categoryTasks = [];

  List<Task> getCategoryTasks(){
    categoryTasks.clear();
    for(Task task in taskBox.values.toList()){
      if(categoryBox.getAt(task.categoryKey)!.name == widget.taskCategory){
        categoryTasks.add(task);
      }
    }
    return categoryTasks;
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

  Widget getDurationWidget(String date) {
    Widget textWidget;
    double fontSize = 14;
    int currentYear = DateTime.now().year;
    int currentMonth = DateTime.now().month;
    int today = DateTime.now().day;
    if(DateTime.parse(date).year == currentYear && DateTime.parse(date).month == currentMonth && DateTime.parse(date).day == today){
      textWidget =  Text('Today',style: TextStyle(color: Colors.green,fontSize: fontSize));
    }else if(DateTime.parse(date).year == currentYear && DateTime.parse(date).month == currentMonth && DateTime.parse(date).day == today + 1) {
      textWidget =  Text('Tomorrow', style: TextStyle(color: Colors.amber,fontSize: fontSize));
    }
    else if(DateTime.parse(date).year == currentYear && DateTime.parse(date).month == currentMonth && DateTime.parse(date).day == today - 1) {
      textWidget = Text('Yesterday', style: TextStyle(color: Colors.red,fontSize: fontSize));
    }else{
      textWidget =  Text(
          DateFormat('dd MMMM, y').format(DateTime.parse(date)),
          style: TextStyle(color: AppColors.primaryColor,fontSize: fontSize));
    }
    return textWidget;
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

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box('task');
    categoryBox = Hive.box('category');
    taskList = getCategoryTasks();
    filteredTaskList = taskList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: AppBar(
            leading: IconButton(onPressed: (){
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context)=>const Navigation()));
            },
                icon: const Icon(Icons.arrow_back_ios)),
            backgroundColor: AppColors.primaryColor,
            elevation: 0,
            title: Text(
              widget.taskCategory,
              style: const TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
            centerTitle: true,
          ),
          body: Column(
            children:  [
              Padding(
                padding: const EdgeInsets.only(top: 20,left: 12,right: 12,bottom: 10),
                child: TextField(
                  onChanged: (value) {
                    if(value.isEmpty){
                      setState(() {
                      filteredTaskList = taskList;
                      });

                    }else{
                      setState(() {
                        value = value.toLowerCase();
                       filteredTaskList = taskList.where((item) => item.name.toLowerCase().contains(value.toLowerCase())).toList();
                      });

                    }
                  },
                  decoration: InputDecoration(
                      focusColor: AppColors.primaryColor,
                      hintText: 'search task',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Colors.black38,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)
                      ),
                      focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primaryColor)
                      )
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ValueListenableBuilder(
                    valueListenable: taskBox.listenable(),
                    builder: (context, box, child){
                      return ListView.builder(
                          itemCount: filteredTaskList.length,
                          itemBuilder: (BuildContext context, index) {
                            final task = filteredTaskList[index];
                            return Padding(
                              padding: const EdgeInsets.only(left: 16,right: 16,bottom: 8),
                              child: SizedBox(
                                height: 120,
                                width: double.infinity,
                                child: Card(
                                  elevation: 4,
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 20),
                                    child: ListTile(
                                      onTap: (){
                                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MyTask(task:task, isHomeReturn: false)));
                                      },
                                      title: Column(
                                        children: [
                                          Flexible(
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  task.name,
                                                  style: TextStyle(
                                                      fontSize: 16,
                                                      fontWeight: task.isFinished? FontWeight.normal: FontWeight.bold,
                                                      decoration:  task.isFinished? TextDecoration.lineThrough : TextDecoration.none,
                                                      overflow:TextOverflow.ellipsis
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                           Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              getDurationWidget(task.tacklingDate),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "${task.startTime} - ${task.endTime}",
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  decoration:  task.isFinished? TextDecoration.lineThrough : TextDecoration.none,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      leading: getPriorityIcon(task.priority),
                                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                      );
                    }
                ),
              ),
            ],
          )
      ),
    );
  }
}
