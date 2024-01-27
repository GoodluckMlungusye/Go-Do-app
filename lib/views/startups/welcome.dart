import 'package:GoDo/themes/theme_assets.dart';
import 'package:flutter/material.dart';

import 'navigation.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 100),
            Image.asset('assets/images/task.png'),
            const SizedBox(height: 50),
            const Text(
                'Welcome to GoDo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20
              )
            ),
            const SizedBox(height: 20),
            const Text(
                'Manage your everyday task list systematically',
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    fontSize: 15,
                ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
            SizedBox(
              width: MediaQuery.of(context).size.width * .9,
              child: ElevatedButton(
                  onPressed: (){
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const Navigation()));
                  },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                  child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text(
                        "Let's Start",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                        )
                    ),
                  )
              ),
            )
          ],
        ),
      )
    );
  }
}
