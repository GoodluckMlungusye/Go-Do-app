import 'package:GoDo/models/Task.dart';
import 'package:GoDo/views/pages/my_tasks.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hive/hive.dart';
import '../../models/Category.dart';
import '../../themes/theme_assets.dart';
import 'package:intl/intl.dart';

import '../startups/navigation.dart';

class MyTask extends StatefulWidget {
  final bool isHomeReturn;
  final Task task;
  const MyTask({super.key, required this.task, required this.isHomeReturn});

  @override
  State<MyTask> createState() => _MyTaskState();
}

class _MyTaskState extends State<MyTask> {
  double leftPadding = 13;
  late Box<Task> taskBox;
  late Box<Category> categoryBox;

  final _formKey = GlobalKey<FormState>();

  DateTime _dateTime = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  late int _selectedCategory = widget.task.categoryKey;
  late String _selectedPriority = widget.task.priority;

  late List<Category> categoryList;

  late List<String> _categoryItems;

  final List<String> _priorityItems = ['High', 'Medium', 'Low'];

  List<String> getCategoryNames(List<Category> categories) {
    return categories.map((category) => category.name).toList();
  }

  void getCategoryKey(newValue) {
    for (int key in categoryBox.keys) {
      var currentCategory = categoryBox.get(key);
      if (currentCategory != null && currentCategory.name == newValue) {
        setState(() {
          _selectedCategory = key;
        });
      }
    }
  }

  String? validate(String? input) {
    if (input == null || input.isEmpty) {
      return 'Field cannot be empty';
    } else if (input.length < 4) {
      return 'At least 4 characters are required!';
    }
    return null;
  }

  String? validateTime(String? input) {
    if (input == null || input.isEmpty) {
      return 'Field cannot be empty';
    }
    return null;
  }

  void _showDatePicker() {
    showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime(2030))
        .then((value) {
      setState(() {
        _dateTime = value!;
        _dateController.text = DateFormat('dd MMMM, y').format(_dateTime);
      });
    });
  }

  void _showTimePicker(bool isStartTime) async {
    TimeOfDay initialTime = isStartTime ? _startTime : _endTime;
    TextEditingController controller =
        isStartTime ? _startTimeController : _endTimeController;

    TimeOfDay? newTime = await showTimePicker(
      context: context,
      initialTime: initialTime,
    );

    if (newTime != null) {
      setState(() {
        if (isStartTime) {
          _startTime = newTime;
        } else {
          _endTime = newTime;
        }
        controller.text =
            '${newTime.hour < 10 ? '0${newTime.hour}' : newTime.hour}${newTime.minute < 10 ? '0${newTime.minute}' : newTime.minute} hrs';
      });
    }
  }

  void updateTask() {
    final isValid = _formKey.currentState?.validate();

    if (isValid != null && isValid) {
      _formKey.currentState?.save();

      taskBox.put(
          widget.task.key,
          Task(
            name: _nameController.text,
            categoryKey: _selectedCategory,
            tacklingDate: _dateTime.toString(),
            startTime: _startTimeController.text,
            endTime: _endTimeController.text,
            priority: _selectedPriority,
          ));
      showToast('task updated successfully', Colors.green);
      Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const Navigation()));
    }
  }

  void showToast(String message, Color backgroundColor) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: backgroundColor,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  Future<void> deleteTask(int taskKey) async {
    await taskBox.delete(taskKey);
  }

  @override
  void initState() {
    super.initState();
    taskBox = Hive.box('task');
    categoryBox = Hive.box('category');
    categoryList = categoryBox.values.toList();
    _categoryItems = getCategoryNames(categoryList);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                widget.isHomeReturn
                    ? Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => const Navigation()))
                    : Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) => MyTasks(
                            taskCategory: categoryBox
                                .getAt(widget.task.categoryKey)!
                                .name)));
              },
              icon: const Icon(Icons.arrow_back_ios, color: Colors.black26)),
          title: const Text(
            'Manage Task',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.only(top: 12, left: 12, right: 12),
                  child: Column(
                    children: [
                      widget.task.isFinished? const Row() : Row(
                        children: [
                          Checkbox(
                              activeColor: AppColors.primaryColorLight,
                              side: const BorderSide(
                                  color: AppColors.primaryColorLight),
                              value: widget.task.isFinished,
                              onChanged: (newBool) {
                                setState(() {
                                  widget.task.isFinished = newBool!;
                                  taskBox.put(
                                      widget.task.key,
                                      Task(
                                          name: widget.task.name,
                                          categoryKey: widget.task.categoryKey,
                                          tacklingDate:
                                              widget.task.tacklingDate,
                                          startTime: widget.task.startTime,
                                          endTime: widget.task.endTime,
                                          priority: widget.task.priority,
                                          isFinished: newBool));
                                });
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => MyTasks(
                                        taskCategory: categoryBox
                                            .getAt(widget.task.categoryKey)!
                                            .name)));
                              }),
                          const SizedBox(width: 10),
                          widget.task.isFinished
                              ? const Text('Re-schedule task')
                              : const Text('Accomplish task')
                        ],
                      ),
                      const SizedBox(height: 15),
                      widget.task.isFinished
                          ? Padding(
                            padding: EdgeInsets.only(left: leftPadding),
                            child: Row(children: [
                                const Text('Task Name:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(widget.task.name, style: const TextStyle(fontSize: 15))
                              ]),
                          )
                          : TextFormField(
                              controller: _nameController,
                              validator: validate,
                              decoration: InputDecoration(
                                  hintText: widget.task.name,
                                  labelText: 'Name',
                                  focusColor: AppColors.primaryColor,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor)))),
                      const SizedBox(height: 30),
                      widget.task.isFinished
                          ? Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                            child: Row(children: [
                                const Text('Category:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(categoryBox
                                    .getAt(widget.task.categoryKey)!
                                    .name, style: const TextStyle(fontSize: 15))
                              ]),
                          )
                          : DropdownButtonFormField<String>(
                              onChanged: (newValue) {
                                getCategoryKey(newValue);
                              },
                              items: _categoryItems.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                hintText: categoryBox
                                    .getAt(widget.task.categoryKey)!
                                    .name,
                                labelText: 'Category',
                                focusColor: AppColors.primaryColor,
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(6)),
                                focusedBorder: const OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: AppColors.primaryColor)),
                              ),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an option';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 30),
                      widget.task.isFinished
                          ? Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                            child: Row(children: [
                                const Text('Tackling date:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(DateFormat('dd MMMM, y').format(
                                    DateTime.parse(widget.task.tacklingDate)), style: const TextStyle(fontSize: 15))
                              ]),
                          )
                          : TextFormField(
                              controller: _dateController,
                              validator: validateTime,
                              onTap: _showDatePicker,
                              decoration: InputDecoration(
                                  labelText: 'Tackling date',
                                  hintText: DateFormat('dd MMMM, y').format(
                                      DateTime.parse(widget.task.tacklingDate)),
                                  suffixIcon: const Icon(Icons.calendar_month,
                                      color: Colors.black26),
                                  focusColor: AppColors.primaryColor,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor)))),
                      const SizedBox(height: 30),
                      widget.task.isFinished
                          ? Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                            child: Row(children: [
                                const Text('Start time:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(widget.task.startTime, style: const TextStyle(fontSize: 15))
                              ]),
                          )
                          : TextFormField(
                              controller: _startTimeController,
                              validator: validateTime,
                              decoration: InputDecoration(
                                  hintText: widget.task.startTime,
                                  labelText: 'Start time',
                                  focusColor: AppColors.primaryColor,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor))),
                              onTap: () => _showTimePicker(true),
                            ),
                      const SizedBox(height: 30),
                      widget.task.isFinished
                          ? Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                            child: Row(children: [
                                const Text('End time:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(widget.task.endTime, style: const TextStyle(fontSize: 15))
                              ]),
                          )
                          : TextFormField(
                              controller: _endTimeController,
                              validator: validateTime,
                              decoration: InputDecoration(
                                  hintText: widget.task.endTime,
                                  labelText: 'End time',
                                  focusColor: AppColors.primaryColor,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(4)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor))),
                              onTap: () => _showTimePicker(false),
                            ),
                      const SizedBox(height: 30),
                      widget.task.isFinished
                          ? Padding(
                        padding: EdgeInsets.only(left: leftPadding),
                            child: Row(children: [
                                const Text('Priority:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                const SizedBox(width: 10),
                                Text(widget.task.priority, style: const TextStyle(fontSize: 15))
                              ]),
                          )
                          : DropdownButtonFormField<String>(
                              onChanged: (newValue) {
                                setState(() {
                                  _selectedPriority = newValue!;
                                });
                              },
                              items: _priorityItems.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              decoration: InputDecoration(
                                  hintText: widget.task.priority,
                                  labelText: 'Priority',
                                  focusColor: AppColors.primaryColor,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                  focusedBorder: const OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: AppColors.primaryColor))),
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select an option';
                                }
                                return null;
                              },
                            ),
                      const SizedBox(height: 20),
                      widget.task.isFinished?
                      Row(
                        children: [
                          Checkbox(
                              activeColor: AppColors.primaryColorLight,
                              side: const BorderSide(
                                  color: AppColors.primaryColorLight),
                              value: widget.task.isFinished,
                              onChanged: (newBool) {
                                setState(() {
                                  widget.task.isFinished = newBool!;
                                  taskBox.put(
                                      widget.task.key,
                                      Task(
                                          name: widget.task.name,
                                          categoryKey: widget.task.categoryKey,
                                          tacklingDate:
                                          widget.task.tacklingDate,
                                          startTime: widget.task.startTime,
                                          endTime: widget.task.endTime,
                                          priority: widget.task.priority,
                                          isFinished: newBool));
                                });
                                Navigator.of(context).pushReplacement(MaterialPageRoute(
                                    builder: (context) => MyTasks(
                                        taskCategory: categoryBox
                                            .getAt(widget.task.categoryKey)!
                                            .name)));
                              }),
                          const SizedBox(width: 2),
                          widget.task.isFinished
                              ? const Text('Re-schedule task')
                              : const Text('Accomplish task')
                        ],
                      )
                      :
                      const Row(),
                      const SizedBox(height: 25),
                      widget.task.isFinished
                          ? SizedBox(
                              height: 45,
                              width: MediaQuery.of(context).size.width * .9,
                              child: ElevatedButton(
                                  onPressed: () {
                                    deleteTask(widget.task.key);
                                    widget.isHomeReturn
                                        ? Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Navigation()))
                                        : Navigator.of(context).pushReplacement(
                                            MaterialPageRoute(
                                                builder: (context) => MyTasks(
                                                    taskCategory: categoryBox
                                                        .getAt(widget
                                                            .task.categoryKey)!
                                                        .name)));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6.0),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text("Remove",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                      SizedBox(width: 5),
                                      Icon(Icons.delete)
                                    ],
                                  )),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                SizedBox(
                                  height: 45,
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        updateTask();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("Save",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          Icon(Icons.save)
                                        ],
                                      )),
                                ),
                                SizedBox(
                                  height: 45,
                                  width: MediaQuery.of(context).size.width * .4,
                                  child: ElevatedButton(
                                      onPressed: () {
                                        deleteTask(widget.task.key);
                                        widget.isHomeReturn
                                            ? Navigator.of(context)
                                                .pushReplacement(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Navigation()))
                                            : Navigator.of(context)
                                                .pushReplacement(MaterialPageRoute(
                                                    builder: (context) => MyTasks(
                                                        taskCategory: categoryBox
                                                            .getAt(widget.task
                                                                .categoryKey)!
                                                            .name)));
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(6.0),
                                        ),
                                      ),
                                      child: const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceAround,
                                        children: [
                                          Text("Remove",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18)),
                                          Icon(Icons.delete)
                                        ],
                                      )),
                                ),
                              ],
                            ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
