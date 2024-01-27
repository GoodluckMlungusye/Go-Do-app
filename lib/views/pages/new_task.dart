import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../../models/Category.dart';
import '../../models/Task.dart';
import '../../themes/theme_assets.dart';
import 'package:intl/intl.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'new_category.dart';
import '../startups/navigation.dart';

class NewTaskPage extends StatefulWidget {
  const NewTaskPage({super.key});


  @override
  State<NewTaskPage> createState() => _NewTaskPageState();
}

class _NewTaskPageState extends State<NewTaskPage> {

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
  late  int _selectedCategory;
  late String _selectedPriority;

  late List<Category> categoryList;

  late List<String> _categoryItems;

  final List<String> _priorityItems = [
        'High',
        'Medium',
        'Low'
  ];

  List<String> getCategoryNames(List<Category> categories) {
    return categories.map((category) => category.name).toList();
  }

  void getCategoryKey(newValue) {
    for(int key in categoryBox.keys){
      var currentCategory = categoryBox.get(key);
      if(currentCategory != null && currentCategory.name == newValue){
        setState(() {
          _selectedCategory = key;
        });
      }
    }
  }

  void _showDatePicker() {
    showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2030)
    ).then((value) {
      setState(() {
        _dateTime = value!;
        _dateController.text = DateFormat('dd MMMM, y').format(_dateTime);
      });
    });
  }

  void _showTimePicker(bool isStartTime) async {
    TimeOfDay initialTime = isStartTime ? _startTime : _endTime;
    TextEditingController controller = isStartTime ? _startTimeController : _endTimeController;

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
        '${newTime.hour < 10? '0${newTime.hour}': newTime.hour}${newTime.minute < 10? '0${newTime.minute}': newTime.minute} hrs';
      });
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

  void addTask() {
    final isValid = _formKey.currentState?.validate();

    if(isValid != null && isValid){
      _formKey.currentState?.save();

      taskBox.add(
          Task(
            name: _nameController.text,
            categoryKey: _selectedCategory,
            tacklingDate: _dateTime.toString(),
            startTime: _startTimeController.text,
            endTime: _endTimeController.text,
            priority: _selectedPriority,
          )
      );

      setState(() {
        _nameController.text = '';
        _dateController.text = '';
        _startTimeController.text = '';
        _endTimeController.text = '';
        _selectedPriority = '';
      });
      showToast('task added successfully',Colors.green);
    }
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

  Future<void> deleteTask(int taskKey)async {
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
    return  SafeArea(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(onPressed: () {
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const Navigation()));
          }, icon: const Icon(Icons.arrow_back_ios,color: Colors.black26)),
          title: const Text(
            'Create Task',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),
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
                  padding: const EdgeInsets.only(top: 12,left: 12,right: 12),
                  child: Column(
                    children: [
                      TextFormField(
                        validator: validate,
                        controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Task Name',
                              focusColor: AppColors.primaryColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor)
                              )
                          )
                      ),
                      const SizedBox(height: 30),
                      _categoryItems.isNotEmpty?
                      DropdownButtonFormField<String>(
                        onChanged: (newValue){
                          getCategoryKey(newValue);
                        },
                        items: _categoryItems.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        decoration: InputDecoration(
                            labelText: 'Category',
                            focusColor: AppColors.primaryColor,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryColor)
                            )
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an option';
                          }
                          return null;
                        },
                      )
                      :
                      GestureDetector(
                        onTap: (){
                          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const NewCategoryPage()));
                        },
                        child: DropdownButtonFormField<String>(
                          onChanged: (newValue){},
                          items: _categoryItems.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          decoration: InputDecoration(
                              labelText: 'Category',
                              focusColor: AppColors.primaryColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor)
                              )
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        validator: validateTime,
                          controller: _dateController,
                          onTap: _showDatePicker,
                          decoration: InputDecoration(
                              hintText: DateFormat('dd MMMM, y').format(_dateTime),
                              labelText: 'Tackling date',
                              suffixIcon: const Icon(Icons.calendar_month,color: Colors.black26),
                              focusColor: AppColors.primaryColor,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(6)
                              ),
                              focusedBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(color: AppColors.primaryColor)
                              )
                          )
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        validator: validateTime,
                        controller: _startTimeController,
                        decoration: InputDecoration(
                            labelText: 'Start time',
                            focusColor: AppColors.primaryColor,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryColor)
                            )
                        ),
                        onTap: () => _showTimePicker(true),
                      ),
                      const SizedBox(height: 30),
                      TextFormField(
                        validator: validateTime,
                        controller: _endTimeController,
                        decoration: InputDecoration(
                            labelText: 'End time',
                            focusColor: AppColors.primaryColor,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryColor)
                            )
                        ),
                        onTap: () => _showTimePicker(false),
                      ),
                      const SizedBox(height: 30),
                      DropdownButtonFormField<String>(
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
                            labelText: 'Priority',
                            focusColor: AppColors.primaryColor,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6)
                            ),
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.primaryColor)
                            )
                        ),
                        validator: (value) {
                          if (value == null) {
                            return 'Please select an option';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        height: 45,
                        width: MediaQuery.of(context).size.width,
                        child: ElevatedButton(
                            onPressed: (){
                              addTask();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                            ),
                            child: const Text(
                                "Create",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18
                                )
                            )
                        ),
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

