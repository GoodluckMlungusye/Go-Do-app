import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:stacked/stacked.dart';

import '../models/Category.dart';
import '../models/Task.dart';

class MyTaskModel extends BaseViewModel{

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

  void getCategoryKey(String categoryName, int selectedCategory) {
    for (int key in categoryBox.keys) {
      var currentCategory = categoryBox.get(key);
      if (currentCategory != null && currentCategory.name == categoryName) {
        selectedCategory = key;
        notifyListeners();
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
}