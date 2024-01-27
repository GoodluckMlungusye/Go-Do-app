import 'package:GoDo/views/startups/loader.dart';
import 'package:flutter/material.dart';
import '../themes/theme_assets.dart';
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'GoDo App',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        primaryColor: AppColors.primaryColor,
        primaryColorDark: AppColors.primaryColorDark,
        primaryColorLight: AppColors.primaryColorLight,
        fontFamily: AppFonts.primaryFont,
      ),
      home: const Loader(),
    );
  }
}