import 'package:flutter/material.dart';
import 'models/Category.dart';
import 'models/Task.dart';
import 'app/my_app.dart';
import 'package:path_provider/path_provider.dart' as path;
import 'package:hive_flutter/hive_flutter.dart';
import 'package:hive_flutter/adapters.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await path.getApplicationDocumentsDirectory();
  Hive.init(directory.path);
  Hive.initFlutter('godo_db');

  Hive.registerAdapter<Task>(TaskAdapter());
  Hive.registerAdapter<Category>(CategoryAdapter());

  await Hive.openBox<Task>('task');
  await Hive.openBox<Category>('category');

  runApp(const MyApp());
}


