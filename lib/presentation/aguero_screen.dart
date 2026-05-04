import 'package:flutter/material.dart';
import '../logic/aguero_logic.dart';
import '../logic/lottery_logic.dart'; // Importante para el botón de info

class AgueroScreen extends StatelessWidget {
  final TextEditingController controller;
  final String Function(String) getLabel;
  final Function(String, {String? customNumber}) showMysticLoading;

  const AgueroScreen({
    super.key,
    required this.controller,
    required this.getLabel,
    required this.showMysticLoading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            const Center(child: Icon(Icons.auto_fix_high, color: Colors.amber, size: 50)),
            const SizedBox(height: 10),
            Center(child: Text(getLabel('agueros'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber))),
            const SizedBox(height: 20),
            TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Sueño, placa o fecha...",
                prefixIcon: const Icon(Icons.edit, color: Colors.amber),
                // Botón de información añadido aquí
                suffixIcon: IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.amber),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: const Color(0xFF1A1A1A),
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.amber),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        title: const Text("Sobre los Agüeros", style: TextStyle(color: Colors.amber)),
                        content: Text(LotteryLogic.getInfoText("aguero", "", "es")),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text("ENTENDIDO", style: TextStyle(color: Colors.amber)),
                          )
                        ],
                      ),
                    );
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Wrap(
                spacing: 10,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  _agueroBtn("SUEÑO", Icons.bed),
                  _agueroBtn("PLACA", Icons.directions_car),
                  _agueroBtn("FECHA", Icons.calendar_today),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("💎 AGÜEROS FAMOSOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            _buildFamosos(),
          ],
        ),
      ),
    );
  }

  Widget _agueroBtn(String type, IconData icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), side: const BorderSide(color: Colors.amber)),
      onPressed: () {
        String? num;
        if (type == "SUEÑO") num = AgueroLogic.obtenerNumeroPorSueno(controller.text);
        if (type == "PLACA") num = AgueroLogic.obtenerNumeroPorPlaca(controller.text);
        if (type == "FECHA") {
          String texto = controller.text.replaceAll(RegExp(r'[^0-9]'), '');
          if (texto.length >= 4) num = texto.substring(0, 4);
        }
        showMysticLoading(type, customNumber: num);
      },
      icon: Icon(icon, color: Colors.amber),
      label: Text(type, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildFamosos() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: AgueroLogic.aguerosFamosos.length,
        itemBuilder: (context, index) {
          final item = AgueroLogic.aguerosFamosos[index];
          return GestureDetector(
            onTap: () => showMysticLoading(item['titulo']!, customNumber: item['numero']),
            child: Container(
              width: 150, margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.amber.withOpacity(0.4))),
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(item['titulo']!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(item['numero']!, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
          );
        },
      ),
    );
  }
}