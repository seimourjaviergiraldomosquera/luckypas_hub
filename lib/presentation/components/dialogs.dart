import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../logic/lottery_logic.dart';

class AppDialogs {
  // Diálogo de Registro de Usuario
  static void showRegistrationDialog(BuildContext context, TextEditingController nameController, VoidCallback onComplete) {
    DateTime tempDate = DateTime(2000, 1, 1);
    TimeOfDay tempTime = const TimeOfDay(hour: 12, minute: 0);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text("✨ Perfil Místico", style: TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text("Tus datos nos ayudan a canalizar tu suerte.", style: TextStyle(fontSize: 13)),
              const SizedBox(height: 15),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: "Tu Nombre",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                title: Text("Fecha: ${DateFormat('dd/MM/yyyy').format(tempDate)}", style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.calendar_month, color: Colors.amber),
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: tempDate,
                    firstDate: DateTime(1940),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setStateDialog(() => tempDate = picked);
                },
              ),
              ListTile(
                title: Text("Hora: ${tempTime.format(context)}", style: const TextStyle(fontSize: 13)),
                trailing: const Icon(Icons.access_time, color: Colors.amber),
                onTap: () async {
                  final TimeOfDay? picked = await showTimePicker(
                    context: context,
                    initialTime: tempTime,
                  );
                  if (picked != null) setStateDialog(() => tempTime = picked);
                },
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                if (nameController.text.isNotEmpty) {
                  var box = Hive.box('userProfile');
                  box.put('name', nameController.text);
                  box.put('birthDate', tempDate);
                  box.put('birthHour', tempTime.hour);
                  Navigator.pop(context);
                  onComplete();
                }
              },
              child: const Text("COMENZAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  // Reporte de Intuición (Aciertos)
  static void showIntuitionReport(BuildContext context, String msg, Color col) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black,
        title: const Text("Reporte de Intuición", style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.stars, color: col, size: 60),
            const SizedBox(height: 20),
            Text(msg, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK"))
        ],
      ),
    );
  }
}