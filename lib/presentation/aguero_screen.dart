import 'package:flutter/material.dart';
import '../logic/aguero_logic.dart';
import '../logic/lottery_logic.dart';

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

  // Función auxiliar para mostrar alertas de validación
  void _showValidationError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Función para mostrar diálogos de información específicos
  void _showInfoPopup(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: Colors.amber),
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(title, style: const TextStyle(color: Colors.amber)),
        content: Text(content, style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("ENTENDIDO", style: TextStyle(color: Colors.amber)),
          )
        ],
      ),
    );
  }

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
                suffixIcon: IconButton(
                  icon: const Icon(Icons.info_outline, color: Colors.amber),
                  onPressed: () => _showInfoPopup(context, "Sobre los Agüeros", LotteryLogic.getInfoText("aguero", "", "es")),
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
                  _agueroBtn(context, "SUEÑO", Icons.bed, "Convierte tus sueños en números de la suerte."),
                  _agueroBtn(context, "PLACA", Icons.directions_car, "Extrae la vibración numérica de vehículos (ej: ABC123)."),
                  _agueroBtn(context, "FECHA", Icons.calendar_today, "Analiza fechas importantes (mínimo 4 dígitos)."),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // NUEVO: Botón para guardar número manual si el usuario ya lo tiene pensado
            Center(
              child: TextButton.icon(
                onPressed: () {
                  if (controller.text.isNotEmpty) {
                    showMysticLoading("MI NÚMERO", customNumber: controller.text);
                  } else {
                    _showValidationError(context, "Escribe tu número primero");
                  }
                },
                icon: const Icon(Icons.save_alt, color: Colors.greenAccent, size: 18),
                label: const Text("GUARDAR MI PROPIO NÚMERO", style: TextStyle(color: Colors.greenAccent, fontSize: 12)),
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

  Widget _agueroBtn(BuildContext context, String type, IconData icon, String infoContent) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A1A1A),
              side: const BorderSide(color: Colors.amber),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
          ),
          onPressed: () {
            String texto = controller.text.trim();
            if (texto.isEmpty) {
              _showValidationError(context, "Escribe algo primero");
              return;
            }

            String? num;
            if (type == "SUEÑO") {
              num = AgueroLogic.obtenerNumeroPorSueno(texto);
              showMysticLoading(type, customNumber: num);
            } else if (type == "PLACA") {
              if (AgueroLogic.esPlacaValida(texto)) {
                num = AgueroLogic.obtenerNumeroPorPlaca(texto);
                showMysticLoading(type, customNumber: num);
              } else {
                _showValidationError(context, "Placa no válida (ej: ABC123)");
              }
            } else if (type == "FECHA") {
              if (AgueroLogic.esFechaValida(texto)) {
                num = AgueroLogic.obtenerNumeroPorFecha(texto);
                showMysticLoading(type, customNumber: num);
              } else {
                _showValidationError(context, "Ingresa al menos 4 números para la fecha");
              }
            }
          },
          icon: Icon(icon, color: Colors.amber, size: 16),
          label: Text(type, style: const TextStyle(color: Colors.white, fontSize: 12)),
        ),
        GestureDetector(
          onTap: () => _showInfoPopup(context, "Información de $type", infoContent),
          child: const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Icon(Icons.help_outline, size: 14, color: Colors.grey),
          ),
        ),
      ],
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
              width: 150,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.amber.withOpacity(0.4))
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['titulo']!, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(item['numero']!, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                  ]
              ),
            ),
          );
        },
      ),
    );
  }
}