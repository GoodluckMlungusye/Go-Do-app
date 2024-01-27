import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:hive_flutter/adapters.dart';
import '../../models/Category.dart';
import '../../themes/theme_assets.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../startups/navigation.dart';

class NewCategoryPage extends StatefulWidget {
  const NewCategoryPage({super.key});

  @override
  State<NewCategoryPage> createState() => _NewCategoryPageState();
}

class _NewCategoryPageState extends State<NewCategoryPage> {

  late Box<Category> categoryBox;

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  Color categoryColor = Colors.deepPurple;

  Widget buildColorPicker() => ColorPicker(
      pickerColor: categoryColor,
      enableAlpha: false,
      onColorChanged: (color) => setState(() {
        categoryColor = color;
      })
  );

  void pickColor(BuildContext context) => showDialog(
      context: context,
      builder: (context) => SingleChildScrollView(
        child: AlertDialog(
          title: const Text('Pick Your Color'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildColorPicker(),
              TextButton(
                onPressed: () {
                      Navigator.of(context).pop();
                  },
                child: const Text('SELECT'),
              ),
            ],
          ),
        ),
      )
  );

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

  String? validateName(String? name) {
    if (name == null || name.isEmpty) {
      return 'Field cannot be empty';
    } else if (name.length < 4) {
      return 'At least 4 characters are required!';
    }
    return null;
  }

  void addCategory() {
    final isValid = _formKey.currentState?.validate();

    if(isValid != null && isValid){
      _formKey.currentState?.save();
      categoryBox.add(
          Category(
              name:_nameController.text,
              categoryColor: categoryColor.value
          )
      );
      setState(() {
        _nameController.text = '';
         categoryColor = AppColors.primaryColor;
      });
      showToast('category added Successfully', Colors.green);
    }
  }

  @override
  void initState() {
    super.initState();
    categoryBox = Hive.box('category');
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
            'Add Category',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Column(
          children: [
            Form(
              key: _formKey,
              child: Padding(
                padding: const EdgeInsets.only(top: 12,left: 12,right: 12),
                child: Column(
                  children: [
                    TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Category Name',
                          focusColor: AppColors.primaryColor,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)
                          ),
                          focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(color: AppColors.primaryColor)
                          ),
                        ),
                        validator: validateName
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Select favourite category color',
                              style: TextStyle(
                                  fontSize: 16,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Container(
                                width: 25,
                                height: 25,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: categoryColor
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: ()=>pickColor(context),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6.0),
                              ),
                              side: const BorderSide(color: AppColors.primaryColor)
                          ),
                          child: const Text(
                              "Choose Color",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: AppColors.primaryColor
                              )
                          )
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      height: 45,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          onPressed: (){
                            addCategory();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6.0),
                            ),
                          ),
                          child: const Text(
                              "Save",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18
                              )
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 16,right: 16,bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    'Category List',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: categoryBox.listenable(),
                  builder: (context, box, child){
                    return ListView.builder(
                        itemCount: categoryBox.length,
                        itemBuilder: (BuildContext context, index) {
                          final category = categoryBox.getAt(index) as Category;
                          return Padding(
                            padding: const EdgeInsets.only(left: 16,right: 16,bottom: 8),
                            child: SizedBox(
                              height: 75,
                              width: double.infinity,
                              child: Card(
                                elevation: 4,
                                child: ListTile(
                                  leading: Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(category.categoryColor)
                                    ),
                                  ),
                                  title: Text(
                                    category.name,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }
                    );
                  }
              ),
            )
          ],
        ),
      ),
    );
  }
}

