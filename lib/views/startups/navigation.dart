import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:GoDo/themes/theme_assets.dart';
import 'package:flutter/material.dart';
import '../tabs/add_option.dart';
import '../tabs/home.dart';
import '../tabs/categories.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {

  int _currentIndex = 1;

  final _tabs = [
    const MyCategories(),
    const Home(),
    const AddOptionPage()
  ];

  final _items = [
    const Icon(Icons.task,size: 30),
    const Icon(Icons.home,size: 30),
    const Icon(Icons.add,size: 30)
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBody: true,
        body: _tabs[_currentIndex],
        bottomNavigationBar: Theme(
          data: Theme.of(context).copyWith(
              iconTheme: const IconThemeData(color: Colors.white)
          ),
          child: CurvedNavigationBar(
            index: _currentIndex,
            backgroundColor: Colors.transparent,
            color: Colors.black38,
            buttonBackgroundColor: AppColors.primaryColor,
            height: 60,
            onTap: (index){
              setState(() {
                _currentIndex = index;
              });
            },
            items: _items,
          ),
        ),
      ),
    );
  }
}
