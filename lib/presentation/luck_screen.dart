import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. IMPORTACIÓN PARA NEQUI (Portapapeles)
import 'package:hive_flutter/hive_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../logic/lottery_logic.dart';

class LuckScreen extends StatelessWidget {
  final String name;
  final String selectedCountry;
  final String currentLang;
  final DateTime? birthDate;
  final int? birthHour;
  final List<Map<String, dynamic>> lotteries;
  final String Function(String) getLabel;
  final Function(String, String, String) onShowInfo;
  final VoidCallback onShowPQR;
  final VoidCallback onShowCountrySelector;
  final Function(String, {String? customNumber}) onShowMysticLoading;
  final Function(int, int) onReorder;
  final VoidCallback onShowSettings;

  const LuckScreen({
    super.key,
    required this.name,
    required this.selectedCountry,
    required this.currentLang,
    this.birthDate,
    this.birthHour,
    required this.lotteries,
    required this.getLabel,
    required this.onShowInfo,
    required this.onShowPQR,
    required this.onShowCountrySelector,
    required this.onShowMysticLoading,
    required this.onReorder,
    required this.onShowSettings,
  });

  // 2. FUNCIÓN PARA EL DIÁLOGO DE AGRADECIMIENTO (Nequi + PayPal)
  void _showDonationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(
            side: const BorderSide(color: Colors.amber),
            borderRadius: BorderRadius.circular(15)),
        title: const Text("Canaliza tu Gratitud",
            style: TextStyle(color: Colors.amber, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tu apoyo permite que la energía mística de la app siga creciendo. ¡Gracias por ser parte del destino!",
              style: TextStyle(color: Colors.white70, fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // OPCIÓN PAYPAL
            ListTile(
              leading: const Icon(Icons.language, color: Colors.blueAccent),
              title: const Text("PayPal (Internacional)", style: TextStyle(color: Colors.white, fontSize: 14)),
              onTap: () {
                Navigator.pop(context);
                _donarPayPal(context);
              },
            ),
            // OPCIÓN NEQUI (CORREGIDA: Con Scroll para evitar Overflow)
            ListTile(
              leading: const Icon(Icons.phone_android, color: Colors.purpleAccent),
              title: const Text("Nequi (Colombia)", style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: const Text("Cel: 317 426 7719", style: TextStyle(color: Colors.grey, fontSize: 11)),
              onTap: () {
                // Copiamos al portapapeles
                Clipboard.setData(const ClipboardData(text: "3174267719"));
                Navigator.pop(context); // Cierra el menú de donación

                // Mostramos el QR / Llave
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.white, // Fondo blanco para lectura de QR
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    title: const Text("Llave Nequi",
                        style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold)),
                    content: SizedBox(
                      width: double.maxFinite,
                      child: SingleChildScrollView( // <--- SOLUCIÓN AL DESBORDAMIENTO
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text("Escanea o usa el número para tu aporte místico.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.black54, fontSize: 12)),
                            const SizedBox(height: 15),
                            // Se añade errorBuilder por seguridad si el asset falla
                            Image.asset(
                              "assets/images/qr_nequi.png",
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) => const Column(
                                children: [
                                  Icon(Icons.qr_code_2, size: 80, color: Colors.grey),
                                  Text("QR no encontrado", style: TextStyle(color: Colors.grey, fontSize: 10)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 15),
                            const Text("Número: 317 426 7719",
                                style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold)),
                            const Text("(Número copiado al portapapeles)",
                                style: TextStyle(color: Colors.purple, fontSize: 10, fontWeight: FontWeight.w500)),
                          ],
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("LISTO", style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("LUEGO", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
  }

  Future<void> _donarPayPal(BuildContext context) async {
    final Uri url = Uri.parse("https://paypal.me/LuckyPassHub");
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("No se pudo abrir el portal de donación")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    var boxFavs = Hive.box('favorites');
    String zodiac = birthDate != null ? LotteryLogic.getZodiacSign(birthDate!) : "...";
    String chinese = birthDate != null ? LotteryLogic.getChineseZodiac(birthDate!) : "...";
    String hourly = birthHour != null ? LotteryLogic.getHourlySign(birthHour!) : "...";
    final prediction = LotteryLogic.getIAPrediction(name, zodiac);

    int totalFavsCount = boxFavs.length;
    int ganados = boxFavs.values.where((f) => f['isWinner'] == true).length;
    double efectividad = totalFavsCount > 0 ? (ganados / totalFavsCount) * 100 : 0.0;
    String luckyLottery = "N/A";
    if (ganados > 0) {
      Map<String, int> counts = {};
      for (var f in boxFavs.values.where((f) => f['isWinner'] == true)) {
        String title = f['title'] ?? "Desconocido";
        counts[title] = (counts[title] ?? 0) + 1;
      }
      luckyLottery = counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
    }

    return Column(
      children: [
        const SizedBox(height: 50),
        _buildTopBar(context),
        _buildMysticBanner(name, zodiac, chinese, hourly, prediction, efectividad, luckyLottery),
        _buildLotteryHeader(),
        const Divider(color: Colors.amber, thickness: 0.5),
        Expanded(
          child: ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            onReorder: onReorder,
            children: [
              for (var game in lotteries)
                _luckCard(game['name'], game['desc'], game['icon'], ValueKey(game['name'])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {
                  const String packageName = "com.seimour.luckypas_hub";
                  const String playStoreLink = "https://play.google.com/store/apps/details?id=$packageName";

                  Share.share(
                    '${getLabel('suerte_con')}\n\nDescarga la app aquí: $playStoreLink',
                    subject: 'LuckyPass Hub',
                  );
                },
                icon: const Icon(Icons.share, color: Colors.amber, size: 20),
              ),
              IconButton(
                onPressed: () => _showDonationDialog(context),
                icon: const Icon(Icons.volunteer_activism, color: Colors.redAccent, size: 20),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                onPressed: onShowPQR,
                icon: const Icon(Icons.mark_as_unread_outlined, color: Colors.amber),
              ),
              IconButton(
                onPressed: onShowSettings,
                icon: const Icon(Icons.settings, color: Colors.amber),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMysticBanner(String name, String zodiac, String chinese, String hourly, Map prediction, double efectividad, String luckyLottery) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [Colors.amber.shade900, Colors.black]),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.amber, width: 0.5),
          ),
          child: Column(
            children: [
              Text("¡Suerte, $name!", style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _infoIcon(Icons.wb_sunny_outlined, zodiac, "zodiaco", zodiac),
                  _infoIcon(Icons.pets, chinese, "chino", chinese),
                  _infoIcon(Icons.access_time, hourly, "hora", hourly),
                ],
              ),
              const Divider(color: Colors.amber, height: 25),
              _buildVibrationInfo(prediction),
              const SizedBox(height: 5),
              Text(prediction['numero'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text("${getLabel('juegaen')}: ${prediction['loteria']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        if (totalFavs > 0) _buildStatsCard(efectividad, luckyLottery),
      ],
    );
  }

  Widget _buildVibrationInfo(Map prediction) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("${getLabel('vibracion')}: ${prediction['nivel']}%", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
        const SizedBox(width: 5),
        GestureDetector(
          onTap: () => onShowInfo("vibracion", "", currentLang),
          child: const Icon(Icons.info_outline, size: 14, color: Colors.amber),
        ),
      ],
    );
  }

  Widget _buildStatsCard(double efectividad, String luckyLottery) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.amber.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(Icons.analytics_outlined, color: Colors.amber, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${getLabel('efectividad')}: ${efectividad.toStringAsFixed(1)}%", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text("${getLabel('tu_suerte_en')} $luckyLottery", style: const TextStyle(fontSize: 10, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.trending_up, color: Colors.green, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildLotteryHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("${getLabel('juegos_de')} $selectedCountry", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
          IconButton(
            icon: const Icon(Icons.public, color: Colors.amber, size: 30),
            onPressed: onShowCountrySelector,
          ),
        ],
      ),
    );
  }

  Widget _infoIcon(IconData icon, String label, String tipo, String valor) {
    return GestureDetector(
      onTap: () => onShowInfo(tipo, valor, currentLang),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 11)),
              const Icon(Icons.info_outline, size: 10, color: Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  Widget _luckCard(String title, String subtitle, IconData icon, Key key) {
    return Card(
      key: key,
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.amber, width: 0.5)),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.drag_handle, size: 20, color: Colors.amber),
        onTap: () => onShowMysticLoading(title),
      ),
    );
  }

  int get totalFavs => Hive.box('favorites').length;
}