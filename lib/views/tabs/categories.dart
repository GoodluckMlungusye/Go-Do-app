import 'package:GoDo/views/pages/my_tasks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../../models/Category.dart';
import '../../models/Task.dart';
import '../../themes/theme_assets.dart';

class MyCategories extends StatefulWidget {
  const MyCategories({super.key});

  @override
  State<MyCategories> createState() => _MyCategoriesState();
}

class _MyCategoriesState extends State<MyCategories> {

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


  int getTotalCategoryTasksLeft(String categoryName){
    return (getTotalCategoryTasks(categoryName)-getTotalCategoryTasksAccomplished(categoryName));
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


  @override
  void initState() {
    super.initState();
    taskBox = Hive.box('task');
    categoryBox = Hive.box('category');
  }


  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          title: const Text(
              'My Tasks',
            style: TextStyle(
              fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          elevation: 0.0,
        ),
        body: taskBox.isNotEmpty?
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                width: double.infinity,
                height: 280,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: const DecorationImage(
                        image: AssetImage(
                          'assets/images/my_tasks.png',
                        ),
                      scale: 1
                    )
                ),
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      gradient: LinearGradient(
                          begin: Alignment.bottomRight,
                          colors: [
                            Colors.deepPurple.withOpacity(.2),
                            Colors.deepPurple.withOpacity(.2),
                          ]
                      )
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                         Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              getTotalTasksAccomplished()/getTotalTasks() < 0.5?
                              const Text(
                                "Finish more tasks, reach your plans!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  fontSize: 16
                                ),
                              )
                                  :
                              const Text(
                                "Hello, You are almost there!",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16
                                ),
                              )
                            ],
                          ),
                        ),
                         Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              getTotalTasksAccomplished() < 2?
                              Text(
                                "${getTotalTasksAccomplished()} out of ${getTotalTasks()} is completed",
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14
                                ),
                              )
                                  :
                              Text(
                                "${getTotalTasksAccomplished()} out of ${getTotalTasks()} are completed",
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14
                                ),
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 8,right: 8,top: 4),
                          child: LinearPercentIndicator(
                            animation: true,
                            animationDuration: 1000,
                            lineHeight: 15,
                            percent: getTotalTasksAccomplished().toDouble()/getTotalTasks().toDouble(),
                            progressColor: AppColors.primaryColorLight,
                            backgroundColor: AppColors.lightGray,
                            barRadius: const Radius.circular(8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: categoryBox.listenable(),
                  builder: (context, box, child){
                    return GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                      ),
                      itemCount: categoryBox.length,
                      itemBuilder: (BuildContext context, int index) {
                        final category = categoryBox.getAt(index) as Category;
                        return getTotalCategoryTasks(category.name) < 1?
                        GestureDetector(
                          onTap: (){
                            showToast('No tasks',Colors.red);
                          },
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Card(
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 28,right: 10,left: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircularPercentIndicator(
                                              radius: 25,
                                              animation: true,
                                              animationDuration: 1000,
                                              lineWidth: 5,
                                              percent: (getTotalCategoryTasks(category.name) == 0 || getTotalCategoryTasksAccomplished(category.name) == 0)? 0 : getTotalCategoryTasksAccomplished(category.name).toDouble()/getTotalCategoryTasks(category.name).toDouble(),
                                              backgroundColor: AppColors.lightGray,
                                              progressColor:Color(category.categoryColor),
                                              center: Text(
                                                (getTotalCategoryTasks(category.name) == 0 || getTotalCategoryTasksAccomplished(category.name) == 0)? "0%" : "${((getTotalCategoryTasksAccomplished(category.name)/getTotalCategoryTasks(category.name))*100).toInt()}%",
                                                style: const TextStyle(
                                                    fontSize: 12
                                                ),
                                              )
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(category.categoryColor),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          getTotalCategoryTasks(category.name) < 2?
                                          Text(
                                            '${getTotalCategoryTasks(category.name)} task',
                                            style: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                            ),
                                          )
                                              :
                                          Text(
                                            '${getTotalCategoryTasks(category.name)} tasks',
                                            style: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                    begin: Alignment.bottomRight,
                                                    colors: [
                                                      Color(category.categoryColor).withOpacity(.16),
                                                      Color(category.categoryColor).withOpacity(.16),
                                                    ]
                                                )
                                            ),
                                            child:  Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: Text(
                                                  '${getTotalCategoryTasksAccomplished(category.name)} completed',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(category.categoryColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                    begin: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.red.withOpacity(.16),
                                                      Colors.red.withOpacity(.16),
                                                    ]
                                                )
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: Text(
                                                  '${getTotalCategoryTasksLeft(category.name)} left',
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        )
                            :
                        GestureDetector(
                          onTap: (){
                            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  MyTasks(taskCategory:category.name)));
                          },
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Card(
                                elevation: 8,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 28,right: 10,left: 10),
                                  child: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          CircularPercentIndicator(
                                              radius: 25,
                                              animation: true,
                                              animationDuration: 1000,
                                              lineWidth: 5,
                                              percent: (getTotalCategoryTasks(category.name) == 0 || getTotalCategoryTasksAccomplished(category.name) == 0)? 0 : getTotalCategoryTasksAccomplished(category.name).toDouble()/getTotalCategoryTasks(category.name).toDouble(),
                                              backgroundColor: AppColors.lightGray,
                                              progressColor:Color(category.categoryColor),
                                              center: Text(
                                                (getTotalCategoryTasks(category.name) == 0 || getTotalCategoryTasksAccomplished(category.name) == 0)? "0%" : "${((getTotalCategoryTasksAccomplished(category.name)/getTotalCategoryTasks(category.name))*100).toInt()}%",
                                                style: const TextStyle(
                                                    fontSize: 12
                                                ),
                                              )
                                          ),
                                          Container(
                                            width: 30,
                                            height: 30,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(category.categoryColor),
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            category.name,
                                            style: const TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        children: [
                                          getTotalCategoryTasks(category.name) < 2?
                                          Text(
                                            '${getTotalCategoryTasks(category.name)} task',
                                            style: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                            ),
                                          )
                                              :
                                          Text(
                                            '${getTotalCategoryTasks(category.name)} tasks',
                                            style: const TextStyle(
                                                color: Colors.black26,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 5),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                    begin: Alignment.bottomRight,
                                                    colors: [
                                                      Color(category.categoryColor).withOpacity(.16),
                                                      Color(category.categoryColor).withOpacity(.16),
                                                    ]
                                                )
                                            ),
                                            child:  Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: Text(
                                                  '${getTotalCategoryTasksAccomplished(category.name)} completed',
                                                  style: TextStyle(
                                                    fontSize: 8,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(category.categoryColor),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 20,
                                            decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(10),
                                                gradient: LinearGradient(
                                                    begin: Alignment.bottomRight,
                                                    colors: [
                                                      Colors.red.withOpacity(.16),
                                                      Colors.red.withOpacity(.16),
                                                    ]
                                                )
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(5.0),
                                              child: Center(
                                                child: Text(
                                                  '${getTotalCategoryTasksLeft(category.name)} left',
                                                  style: const TextStyle(
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.red
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                            ),
                          ),
                        );
                      },
                    );

                  }
              ),
            ),
          ],
        )
            :
        const Center(
          child: Text("Add tasks to accomplish!"),
        )
      ),
    );
  }
}