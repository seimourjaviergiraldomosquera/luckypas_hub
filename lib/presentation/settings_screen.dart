import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../logic/lottery_logic.dart';
import '../logic/backup_logic.dart'; // Asegúrate de que esta ruta sea correcta
import 'components/dialogs.dart';    // Asegúrate de que esta ruta sea correcta

class SettingsScreen extends StatefulWidget {
  final String Function(String) getLabel;
  const SettingsScreen({super.key, required this.getLabel});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _nameController = TextEditingController();
  DateTime? _selectedDate;
  int? _selectedHour;

  int _videosVistos = 0;
  bool _isUnlocked = false;
  bool _isPremium = false; // Variable local para controlar el estado Premium

  @override
  void initState() {
    super.initState();
    var box = Hive.box('userProfile');
    var settingsBox = Hive.box('settings');

    _nameController.text = box.get('name') ?? "";
    _selectedDate = box.get('birthDate');
    _selectedHour = box.get('birthHour');

    // Cargamos el estado Premium guardado (por defecto false)
    _isPremium = settingsBox.get('isPremium', defaultValue: false);

    // Si el usuario ya es Premium, el perfil se desbloquea automáticamente
    if (_isPremium) {
      _isUnlocked = true;
    }
  }

  void _simularVideo() {
    setState(() {
      _videosVistos++;
      if (_videosVistos >= 2) {
        _isUnlocked = true;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Energía canalizada (${_videosVistos}/2)"),
          backgroundColor: Colors.amber.shade900,
        )
    );
  }

  // DIÁLOGO PARA PEGAR EL CÓDIGO DE IMPORTACIÓN
  void _showImportDialog(BuildContext context) {
    TextEditingController importController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(15)),
        title: const Text("Restaurar Datos", style: TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Pega aquí el código de respaldo místico:",
                style: TextStyle(fontSize: 12, color: Colors.white70)),
            const SizedBox(height: 10),
            TextField(
              controller: importController,
              maxLines: 4,
              style: const TextStyle(fontSize: 10, color: Colors.amber),
              decoration: const InputDecoration(
                hintText: "LUCKYPASS-BACKUP-START...",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green.shade800),
            onPressed: () async {
              try {
                await BackupLogic.importData(importController.text);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("¡Destino restaurado con éxito!")),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(e.toString())),
                );
              }
            },
            child: const Text("RESTAURAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Destino y Perfil", style: TextStyle(color: Colors.amber)),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.amber),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Icon(Icons.auto_fix_normal, size: 60, color: Colors.amber)),
            const SizedBox(height: 20),
            Center(
              child: Text(
                _isPremium
                    ? "¡Tu vibración es Premium! Tienes acceso total y libre de anuncios."
                    : "Para alterar tus datos místico-vibracionales, debes ver 2 oráculos visuales.",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 30),

            // Campo de Nombre
            TextField(
              controller: _nameController,
              enabled: _isUnlocked,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: "Tu Nombre",
                labelStyle: TextStyle(color: _isUnlocked ? Colors.amber : Colors.grey),
                prefixIcon: Icon(Icons.person, color: _isUnlocked ? Colors.amber : Colors.grey),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                disabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white12),
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Selector de Fecha
            ListTile(
              enabled: _isUnlocked,
              shape: RoundedRectangleBorder(
                side: BorderSide(color: _isUnlocked ? Colors.amber.withOpacity(0.5) : Colors.white12),
                borderRadius: BorderRadius.circular(15),
              ),
              leading: Icon(Icons.calendar_month, color: _isUnlocked ? Colors.amber : Colors.grey),
              title: Text(
                _selectedDate == null
                    ? "Fecha de Nacimiento"
                    : DateFormat('dd/MM/yyyy').format(_selectedDate!),
                style: TextStyle(color: _isUnlocked ? Colors.white : Colors.grey),
              ),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _selectedDate ?? DateTime(2000),
                  firstDate: DateTime(1940),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _selectedDate = picked);
              },
            ),
            const SizedBox(height: 30),

            if (!_isUnlocked)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: _simularVideo,
                icon: const Icon(Icons.play_circle_fill),
                label: Text("VER VIDEO PARA EDITAR (${_videosVistos}/2)"),
              )
            else
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                onPressed: () {
                  var box = Hive.box('userProfile');
                  box.put('name', _nameController.text);
                  box.put('birthDate', _selectedDate);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("¡Destino actualizado con éxito!"))
                  );
                },
                child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),

            const SizedBox(height: 40),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),

            // MODIFICADO: SECCIÓN PREMIUM INTERNA PARA PRUEBAS Y VALIDACIÓN NATIVA
            const Text("MEMBRESÍA",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 10),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Modo Premium (Cero Anuncios)", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              subtitle: const Text("Activa para remover anuncios de recarga, signos y series místicas", style: TextStyle(fontSize: 11, color: Colors.grey)),
              activeColor: Colors.amber,
              value: _isPremium,
              onChanged: (bool value) {
                setState(() {
                  _isPremium = value;
                  _isUnlocked = value ? true : (_videosVistos >= 2);
                  // Guardamos el estado directamente en la caja de Hive 'settings'
                  Hive.box('settings').put('isPremium', value);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(value ? "¡Modo Premium Activado!" : "Modo Premium Desactivado"),
                      backgroundColor: value ? Colors.green.shade800 : Colors.red.shade800,
                    )
                );
              },
            ),

            const SizedBox(height: 20),
            const Divider(color: Colors.white24),
            const SizedBox(height: 20),

            // SECCIÓN DE SEGURIDAD Y RESPALDO
            const Text("RESPALDO Y SEGURIDAD",
                style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1.2)),
            const SizedBox(height: 15),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_upload, color: Colors.blueAccent),
              title: const Text("Exportar Respaldo Total", style: TextStyle(fontSize: 14)),
              subtitle: const Text("Genera un código místico con todos tus datos", style: TextStyle(fontSize: 11, color: Colors.grey)),
              onTap: () => BackupLogic.exportAllData(),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_download, color: Colors.greenAccent),
              title: const Text("Importar Respaldo", style: TextStyle(fontSize: 14)),
              subtitle: const Text("Restaura tus datos desde un código", style: TextStyle(fontSize: 11, color: Colors.grey)),
              onTap: () => _showImportDialog(context),
            ),

            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.gavel, color: Colors.amberAccent),
              title: const Text("Términos y Condiciones", style: TextStyle(fontSize: 14)),
              subtitle: const Text("Aviso legal y Juego Responsable", style: TextStyle(fontSize: 11, color: Colors.grey)),
              onTap: () => AppDialogs.showOnlyTerms(context), // LLAMA A LA FUNCIÓN CORRECTA
            ),
          ],
        ),
      ),
    );
  }
}