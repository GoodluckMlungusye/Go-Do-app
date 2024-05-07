import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:stacked/stacked.dart';
import '../../components/progress_viewer.dart';
import '../../models/Task.dart';
import '../../themes/theme_assets.dart';
import '../../utils/toast_messages/success_toast_message.dart';
import '../../view_models/home_model.dart';
import '../pages/my_task.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<HomeModel>.reactive(
        builder: (context, model, child) => SafeArea(
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
              body: model.todayTasks.isNotEmpty?
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
                          (model.getTotalTasksToday() == 0 || model.getTotalTasksAccomplishedToday() == 0)? "0%" : "${((model.getPercentAccomplishedToday())*100).toInt()}%",
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
                        percent: (model.getTotalTasksToday() == 0 || model.getTotalTasksAccomplishedToday() == 0)? 0 : model.getPercentAccomplishedToday(),
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
                        valueListenable: model.taskBox.listenable(),
                        builder: (context, box, child){
                          return ListView.builder(
                              itemCount: model.taskBox.length,
                              itemBuilder: (BuildContext context, index) {
                                final task = model.taskBox.getAt(index) as Task;
                                if(model.isTodayTask(task.tacklingDate)){
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
                                            showSuccessToastMessage('The task has been accomplished') :
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
                                              model.getPriorityIcon(task.priority)
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
                                                model.handleCheckBoxChange(newBool, task, index);
                                                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) =>  ProgressViewer(isFinished: task.isFinished)));
                                              }
                                          ),
                                          trailing: task.isFinished? IconButton(onPressed: (){
                                            model.deleteTask(task.key);
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
        ),
        viewModelBuilder: () => HomeModel()
    );
  }
}
