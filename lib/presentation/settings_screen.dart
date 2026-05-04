import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import '../logic/lottery_logic.dart';

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

  @override
  void initState() {
    super.initState();
    var box = Hive.box('userProfile');
    _nameController.text = box.get('name') ?? "";
    _selectedDate = box.get('birthDate');
    _selectedHour = box.get('birthHour');
  }

  void _simularVideo() {
    // Aquí es donde irá la lógica de AdMob más adelante
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
          children: [
            const Icon(Icons.auto_fix_normal, size: 60, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              "Para alterar tus datos místico-vibracionales, debes ver 2 oráculos visuales.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
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

            // Selector de Fecha (Simulado como botón para simplificar)
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
                  // Aquí se guarda el cambio real
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("¡Destino actualizado con éxito!"))
                  );
                },
                child: const Text("GUARDAR CAMBIOS", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
          ],
        ),
      ),
    );
  }
}