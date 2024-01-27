import 'package:hive_flutter/hive_flutter.dart';
part'Category.g.dart';

@HiveType(typeId:1)
class Category extends HiveObject{

  @HiveField(0)
  final String name;
  @HiveField(1)
  final int categoryColor;

  Category(
      {
        required this.name,
        required this.categoryColor
      }
      );
}



























