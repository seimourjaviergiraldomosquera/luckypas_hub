import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../logic/lottery_logic.dart';
import '../../logic/backup_logic.dart'; // IMPORTANTE: Para la restauración inicial

class AppDialogs {
  // Diálogo de Registro de Usuario con Validación Legal e Importación
  static void showRegistrationDialog(BuildContext context, TextEditingController nameController, VoidCallback onComplete) {
    DateTime tempDate = DateTime(2000, 1, 1);
    TimeOfDay tempTime = const TimeOfDay(hour: 12, minute: 0);
    bool aceptoTerminos = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: StatefulBuilder(
          builder: (context, setStateDialog) => AlertDialog(
            backgroundColor: const Color(0xFF1A1A1A),
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Colors.amber),
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("✨ Perfil Místico", style: TextStyle(color: Colors.amber)),
            content: SingleChildScrollView(
              child: Column(
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
                  const Divider(color: Colors.amber, height: 20),
                  CheckboxListTile(
                    value: aceptoTerminos,
                    onChanged: (val) => setStateDialog(() => aceptoTerminos = val!),
                    title: InkWell(
                      onTap: () => showOnlyTerms(context),
                      child: const Text(
                        "Acepto los términos de uso, privacidad local y el aviso de juego responsable (Toca para leer).",
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.amber,
                            decoration: TextDecoration.underline
                        ),
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    activeColor: Colors.amber,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
            actions: [
              // NUEVO BOTÓN: PARA USUARIOS QUE YA TIENEN UNA COPIA
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Cierra este diálogo
                  _showImportDialogFromStart(context, onComplete); // Abre el importador
                },
                child: const Text("¿TIENES UN RESPALDO?",
                    style: TextStyle(color: Colors.blueAccent, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: aceptoTerminos ? Colors.amber : Colors.grey,
                ),
                onPressed: (aceptoTerminos && nameController.text.isNotEmpty)
                    ? () {
                  var box = Hive.box('userProfile');
                  box.put('name', nameController.text);
                  box.put('birthDate', tempDate);
                  box.put('birthHour', tempTime.hour);
                  box.put('termsAccepted', true);
                  Navigator.pop(context);
                  onComplete();
                }
                    : null,
                child: Text(
                  "COMENZAR",
                  style: TextStyle(
                    color: aceptoTerminos ? Colors.black : Colors.white60,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  // DIÁLOGO DE IMPORTACIÓN RÁPIDA AL INICIO
  static void _showImportDialogFromStart(BuildContext context, VoidCallback onComplete) {
    TextEditingController importController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.blueAccent),
            borderRadius: BorderRadius.circular(15)),
        title: const Text("Restaurar Destino", style: TextStyle(color: Colors.blueAccent)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pega el código de tu respaldo anterior para recuperar tus datos.",
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 15),
            TextField(
              controller: importController,
              maxLines: 5,
              style: const TextStyle(fontSize: 10, color: Colors.blueAccent),
              decoration: const InputDecoration(
                hintText: "LUCKYPASS-BACKUP-START...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => showRegistrationDialog(context, TextEditingController(), onComplete),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
            onPressed: () async {
              try {
                await BackupLogic.importData(importController.text);
                Navigator.pop(context);
                onComplete(); // Refresca la app con los nuevos datos
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Código inválido o mística interrumpida.")),
                );
              }
            },
            child: const Text("RESTAURAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // DIÁLOGO CON EL TEXTO LEGAL DETALLADO
  static void showOnlyTerms(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(15),
        ),
        title: const Text("Términos y Condiciones", style: TextStyle(color: Colors.amber)),
        content: const SingleChildScrollView(
          child: Text(
            "1. JUEGO RESPONSABLE: LuckyPass Hub es una herramienta de simulación mística. Los números sugeridos no garantizan premios reales. El juego puede causar adicción. Prohibida su utilización por menores de 18 años.\n\n"
                "2. PRIVACIDAD LOCAL: Tus datos y contraseñas se almacenan EXCLUSIVAMENTE en tu dispositivo mediante Hive. No subimos información a servidores externos. Si desinstalas la app, los datos se perderán.\n\n"
                "3. RESPONSABILIDAD: El desarrollador no se hace responsable por el uso que el usuario dé a los números generados o a la gestión de sus claves.",
            style: TextStyle(fontSize: 12, color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ENTENDIDO", style: TextStyle(color: Colors.amber)),
          )
        ],
      ),
    );
  }

  // Reporte de Intuición
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