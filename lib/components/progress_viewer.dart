import 'dart:async';
import 'package:flutter/material.dart';
import '../themes/theme_assets.dart';
import '../views/startups/navigation.dart';


class ProgressViewer extends StatefulWidget {
  final bool isFinished;
  const ProgressViewer({super.key, required this.isFinished});


  @override
  State<ProgressViewer> createState() => _ProgressViewerState();

}

class _ProgressViewerState extends State<ProgressViewer> {

  void checkTimer(){
    Timer(const Duration(seconds: 2),() {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (BuildContext context) => const Navigation()));
    });
  }

  @override
  void initState() {
    super.initState();
    checkTimer();
  }

  @override
  Widget build(BuildContext context) {
    return  SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              widget.isFinished?
              const Text('Accomplishing task...', style: TextStyle(color: Colors.white))
                  :
              const Text('Re-assigning task...', style: TextStyle(color: Colors.white)),

              const SizedBox(height: 20),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            ],
          ),
        ),
      ),
    );
  }
}
