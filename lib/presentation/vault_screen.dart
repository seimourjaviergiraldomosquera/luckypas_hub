import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // NECESARIO PARA COPIAR AL PORTAPAPEL
import 'package:local_auth/local_auth.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:math';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Escanea tu huella para acceder al Baúl de Seguridad',
        options: const AuthenticationOptions(stickyAuth: true, biometricOnly: false),
      );
      setState(() => _isAuthenticated = authenticated);
    } catch (e) {
      // Backup para emuladores o dispositivos sin hardware biométrico
      setState(() => _isAuthenticated = true);
    }
  }

  // LÓGICA DEL GENERADOR DE CONTRASEÑAS "CRIPTO-MÍSTICA"
  String _generateSecurePass({String? seed, int length = 12, bool includeSpecial = true}) {
    final Map<String, String> substitution = {
      'a': '4', 'A': '4',
      'e': '3', 'E': '3',
      'i': '1', 'I': '1',
      'o': '0', 'O': '0',
      's': '5', 'S': '5',
      't': '7', 'T': '7',
      'b': '8', 'B': '8',
      'g': '9', 'q': '9',
    };

    String transformedSeed = "";
    if (seed != null && seed.isNotEmpty) {
      for (int i = 0; i < seed.length; i++) {
        String char = seed[i];
        transformedSeed += substitution[char] ?? char;
      }
    }

    const String chars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    const String special = "!@#\$%^&*()_+";
    String combined = chars + (includeSpecial ? special : "");
    Random rand = Random();

    String result = transformedSeed;

    if (result.length > length) {
      result = result.substring(0, length);
    }

    while (result.length < length) {
      result += combined[rand.nextInt(combined.length)];
    }

    return result;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAuthenticated) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline, color: Colors.amber, size: 80),
              const SizedBox(height: 20),
              const Text("Contenido Protegido", style: TextStyle(fontSize: 18, color: Colors.white)),
              const SizedBox(height: 10),
              TextButton.icon(
                  onPressed: _authenticate,
                  icon: const Icon(Icons.fingerprint, color: Colors.amber),
                  label: const Text("REINTENTAR ACCESO", style: TextStyle(color: Colors.amber))
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Baúl de Seguridad", style: TextStyle(color: Colors.amber)),
        actions: [
          IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.amber),
              onPressed: () => _showAddEntryDialog(context)
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box('vault').listenable(),
        builder: (context, Box box, _) {
          if (box.isEmpty) {
            return const Center(child: Text("No hay credenciales guardadas.", style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final entry = box.getAt(index);
              return Card(
                color: const Color(0xFF1A1A1A),
                margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.vpn_key, color: Colors.amber),
                  title: Text(entry['site'] ?? "Sin nombre", style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(entry['user'] ?? ""),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.copy, size: 20, color: Colors.blueAccent),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: entry['pass']));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("¡Contraseña copiada!")),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                        onPressed: () => _confirmDelete(context, index, entry['site'] ?? "esta credencial"),
                      ),
                    ],
                  ),
                  onTap: () => _showViewDialog(context, entry),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _confirmDelete(BuildContext context, int index, String site) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.redAccent),
            borderRadius: BorderRadius.circular(15)
        ),
        title: const Text("¿Eliminar credencial?", style: TextStyle(color: Colors.redAccent)),
        content: Text("Estás a punto de borrar los datos de $site. Esta acción no se puede deshacer."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR", style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Hive.box('vault').deleteAt(index);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Credencial eliminada")),
              );
            },
            child: const Text("BORRAR", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAddEntryDialog(BuildContext context) {
    final siteC = TextEditingController();
    final userC = TextEditingController();
    final passC = TextEditingController();
    final seedC = TextEditingController();
    double length = 12;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.amber)),
          title: const Text("Nueva Credencial", style: TextStyle(color: Colors.amber)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: siteC, decoration: const InputDecoration(labelText: "Sitio / App")),
                TextField(controller: userC, decoration: const InputDecoration(labelText: "Usuario / Correo")),
                const Divider(height: 30, color: Colors.amber),
                const Text("Generador de Claves", style: TextStyle(fontSize: 12, color: Colors.grey)),
                TextField(
                  controller: seedC,
                  decoration: const InputDecoration(labelText: "Palabra semilla (Opcional)"),
                  onChanged: (v) {
                    setDialogState(() {
                      passC.text = _generateSecurePass(seed: v, length: length.toInt());
                    });
                  },
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Text("Longitud: ", style: TextStyle(fontSize: 12)),
                    Expanded(
                      child: Slider(
                        value: length, min: 6, max: 24, divisions: 18,
                        activeColor: Colors.amber,
                        label: length.round().toString(),
                        onChanged: (v) {
                          setDialogState(() {
                            length = v;
                            passC.text = _generateSecurePass(seed: seedC.text, length: length.toInt());
                          });
                        },
                      ),
                    ),
                    Text(length.toInt().toString(), style: const TextStyle(color: Colors.amber)),
                  ],
                ),
                TextField(
                    controller: passC,
                    decoration: InputDecoration(
                        labelText: "Contraseña Generada",
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.amber),
                          onPressed: () => setDialogState(() => passC.text = _generateSecurePass(seed: seedC.text, length: length.toInt())),
                        )
                    )
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR", style: TextStyle(color: Colors.grey))),
            ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () {
                  if(siteC.text.isNotEmpty && passC.text.isNotEmpty) {
                    Hive.box('vault').add({
                      'site': siteC.text,
                      'user': userC.text,
                      'pass': passC.text
                    });
                    Navigator.pop(context);
                  }
                },
                child: const Text("GUARDAR", style: TextStyle(color: Colors.black))
            ),
          ],
        ),
      ),
    );
  }

  void _showViewDialog(BuildContext context, dynamic item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.amber)),
        title: Text(item['site'] ?? "Credencial", style: const TextStyle(color: Colors.amber)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Usuario:", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text(item['user'] ?? "N/A", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 15),
            const Text("Contraseña:", style: TextStyle(color: Colors.grey, fontSize: 12)),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  Expanded(
                      child: Text(item['pass'] ?? "", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber))
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Colors.amber, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: item['pass']));
                      Navigator.pop(context); // Cierra el diálogo al copiar
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("¡Contraseña copiada!")),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CERRAR", style: TextStyle(color: Colors.amber)))
        ],
      ),
    );
  }
}