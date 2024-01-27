import 'package:GoDo/themes/theme_assets.dart';
import 'package:flutter/material.dart';

import '../pages/new_task.dart';
import '../pages/new_category.dart';

class AddOptionPage extends StatelessWidget {
  const AddOptionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.primaryColor,
          elevation: 0,
          title: const Text(
            'Select Option',
            style: TextStyle(
                fontWeight: FontWeight.bold
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            children: [
               const SizedBox(height: 40),
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'You can add new category that matches your task or proceed to create a task based on added categories.',
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const NewCategoryPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                          width: 1,
                          color: AppColors.primaryColor
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child:  const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                          "Add Category",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black45
                          )
                      ),
                    )
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: MediaQuery.of(context).size.width * .9,
                child: ElevatedButton(
                    onPressed: (){
                      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const NewTaskPage()));
                    },
                    style: ElevatedButton.styleFrom(
                      side: const BorderSide(
                          width: 1,
                          color: AppColors.primaryColor
                      ),
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child:  const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                          "Create Task",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.black45
                          )
                      ),
                    )
                ),
              ),
            ],
          ),
        )
    );
  }
}
