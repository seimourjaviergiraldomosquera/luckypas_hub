import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';

class BackupLogic {
  static Future<void> exportAllData() async {
    try {
      // Función interna para limpiar mapas de Hive antes de codificar (convierte DateTime a String)
      Map<String, dynamic> cleanMap(Map map) {
        return map.map((key, value) {
          if (value is DateTime) {
            return MapEntry(key.toString(), value.toIso8601String());
          }
          return MapEntry(key.toString(), value);
        });
      }

      // 1. Recolectamos datos de todas las cajas con limpieza de fechas
      final Map<String, dynamic> allData = {
        "favorites": Hive.box('favorites').values.toList(),
        "vault": Hive.box('vault').values.toList(),
        "userProfile": cleanMap(Hive.box('userProfile').toMap()),
        "resultsHistory": Hive.box('resultsHistory').values.toList(),
        "exportDate": DateTime.now().toIso8601String(),
        "app": "LuckyPass Hub"
      };

      // 2. Convertimos a JSON y luego a Base64 para ofuscar
      String jsonString = jsonEncode(allData);
      List<int> bytes = utf8.encode(jsonString);
      String base64String = base64.encode(bytes);

      // 3. Compartir el código de respaldo
      await Share.share(
        "LUCKYPASS-BACKUP-START\n\n$base64String\n\nLUCKYPASS-BACKUP-END\n\nInstrucciones: Copia todo el código entre las etiquetas para restaurar en otro dispositivo.",
        subject: "Respaldo Místico LuckyPass Hub",
      );
    } catch (e) {
      print("Error al exportar: $e");
    }
  }

  static Future<void> importData(String rawInput) async {
    try {
      // 1. Limpiar el texto (quitar las etiquetas de inicio y fin)
      String cleanInput = rawInput
          .replaceAll("LUCKYPASS-BACKUP-START", "")
          .replaceAll("LUCKYPASS-BACKUP-END", "")
          .trim();

      // 2. Decodificar Base64 a JSON
      List<int> bytes = base64.decode(cleanInput);
      String jsonString = utf8.decode(bytes);
      final Map<String, dynamic> decoded = jsonDecode(jsonString);

      // 3. Restaurar cajas de forma segura
      if (decoded["app"] == "LuckyPass Hub") {
        if (decoded.containsKey("favorites")) {
          await Hive.box('favorites').clear();
          await Hive.box('favorites').addAll(decoded["favorites"]);
        }
        if (decoded.containsKey("vault")) {
          await Hive.box('vault').clear();
          await Hive.box('vault').addAll(decoded["vault"]);
        }
        if (decoded.containsKey("resultsHistory")) {
          await Hive.box('resultsHistory').clear();
          await Hive.box('resultsHistory').addAll(decoded["resultsHistory"]);
        }
        if (decoded.containsKey("userProfile")) {
          var profileBox = Hive.box('userProfile');
          Map<String, dynamic> profile = Map<String, dynamic>.from(decoded["userProfile"]);

          // CORRECCIÓN: Convertir de vuelta Strings a DateTime para evitar errores de tipo
          profile.forEach((key, value) {
            if (key == 'birthDate' && value is String) {
              profileBox.put(key, DateTime.parse(value));
            } else {
              profileBox.put(key, value);
            }
          });
        }
      } else {
        throw Exception("Este respaldo no pertenece a LuckyPass Hub");
      }
    } catch (e) {
      print("Error detallado en import: $e");
      throw Exception("Error al importar: Datos corruptos o incompatibles.");
    }
  }
}