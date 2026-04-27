import 'package:hive/hive.dart';

part 'favorite_model.g.dart'; // Esto es para que Hive funcione después

@HiveType(typeId: 0)
class Favorite extends HiveObject {
  @HiveField(0)
  String title; // Nombre personalizado o fecha/hora

  @HiveField(1)
  String content; // El número o la contraseña generada

  @HiveField(2)
  String type; // "Lotería", "Astro", "Password", etc.

  @HiveField(3)
  DateTime date;

  Favorite({
    required this.title,
    required this.content,
    required this.type,
    required this.date,
  });
}