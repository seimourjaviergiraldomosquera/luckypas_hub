import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'core/constants.dart';
import 'logic/lottery_logic.dart';
import 'logic/aguero_logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  await Hive.openBox('userProfile');
  runApp(const LuckyPassApp());
}

class LuckyPassApp extends StatelessWidget {
  const LuckyPassApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFFFFD700),
        scaffoldBackgroundColor: Colors.black,
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFFD700)),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;
  String selectedCountry = "Colombia";
  final TextEditingController _agueroController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pqrController = TextEditingController();

  bool _videoVisto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUserProfile());
  }

  void _checkUserProfile() {
    var box = Hive.box('userProfile');
    if (box.get('name') == null) {
      _showRegistrationDialog();
    }
  }

  void _showRegistrationDialog() {
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
                controller: _nameController,
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
                if (_nameController.text.isNotEmpty) {
                  var box = Hive.box('userProfile');
                  box.put('name', _nameController.text);
                  box.put('birthDate', tempDate);
                  box.put('birthHour', tempTime.hour);
                  Navigator.pop(context);
                  setState(() {});
                }
              },
              child: const Text("COMENZAR", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            )
          ],
        ),
      ),
    );
  }

  final Map<String, List<Map<String, dynamic>>> countriesData = {
    "Colombia": [
      {"name": "Super Astro", "desc": "4 cifras + Signo", "icon": Icons.auto_awesome},
      {"name": "Baloto", "desc": "5 números + Superbolota", "icon": Icons.confirmation_number},
      {"name": "Lotería del Quindío", "desc": " Regional", "icon": Icons.location_city},
      {"name": "Lotería de Bogotá", "desc": "Jueves de suerte", "icon": Icons.casino},
      {"name": "Lotería de Medellín", "desc": "Viernes ganador", "icon": Icons.casino},
      {"name": "Chontico Día", "desc": "Gana tempranito", "icon": Icons.wb_sunny},
      {"name": "Chontico Noche", "desc": "Suerte nocturna", "icon": Icons.dark_mode},
      {"name": "Paisita Día", "desc": "Suerte antioqueña", "icon": Icons.agriculture},
      {"name": "Paisita Noche", "desc": "El favorito de todos", "icon": Icons.nightlife},
      {"name": "Cafeterito Tarde", "desc": "Aroma de triunfo", "icon": Icons.coffee},
      {"name": "Motilón Día", "desc": "Suerte en el norte", "icon": Icons.terrain},
      {"name": "Pijao de Oro", "desc": "Suerte del Tolima", "icon": Icons.monetization_on},
      {"name": "Chance", "desc": "4 cifras personalizadas", "icon": Icons.casino},
    ],
    "USA": [
      {"name": "Powerball", "desc": "Multi-state jackpot", "icon": Icons.star},
      {"name": "Mega Millions", "desc": "Gigantic prizes", "icon": Icons.monetization_on},
      {"name": "Lucky for Life", "desc": "Daily winnings", "icon": Icons.today},
      {"name": "Cash4Life", "desc": "Lifetime prize", "icon": Icons.timer},
    ],
    "Brasil": [
      {"name": "Mega-Sena", "desc": "A maior do Brasil", "icon": Icons.casino},
      {"name": "Quina", "desc": "Sorte diária", "icon": Icons.looks_5},
      {"name": "Lotofácil", "desc": "Mais chances", "icon": Icons.thumb_up},
    ],
    "España": [
      {"name": "EuroMillones", "desc": "Bote millonario", "icon": Icons.euro},
      {"name": "La Primitiva", "desc": "La clásica", "icon": Icons.history},
      {"name": "El Gordo", "desc": "Domingos de suerte", "icon": Icons.redeem},
    ],
    "Alemania": [
      {"name": "Lotto 6aus49", "desc": "Der Klassiker", "icon": Icons.card_giftcard},
      {"name": "EuroJackpot", "desc": "Europaweit gewinnen", "icon": Icons.language},
    ],
    "Japón": [
      {"name": "Lotto 7", "desc": "大きな夢", "icon": Icons.brightness_auto},
      {"name": "Numbers 4", "desc": "毎日チャンス", "icon": Icons.filter_4},
    ],
  };

  List<Widget> get _screens => [
    _buildLuckScreen(),
    _buildAgueroScreen(),
    _buildFavoritesScreen(),
  ];

  Widget _buildLuckScreen() {
    var box = Hive.box('userProfile');
    String name = box.get('name') ?? "Jugador";
    DateTime? bDay = box.get('birthDate');
    int? bHour = box.get('birthHour');

    String zodiac = bDay != null ? LotteryLogic.getZodiacSign(bDay) : "...";
    String chinese = bDay != null ? LotteryLogic.getChineseZodiac(bDay) : "...";
    String hourly = bHour != null ? LotteryLogic.getHourlySign(bHour) : "...";

    final prediction = LotteryLogic.getIAPrediction(name, zodiac);

    final lotteries = countriesData[selectedCountry] ?? [];
    return Column(
      children: [
        const SizedBox(height: 50),
        // BOTÓN PQR DISCRETO EN CABECERA
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: _showPQRDialog,
                icon: const Icon(Icons.help_outline, color: Colors.amber),
                tooltip: "Buzón de Sugerencias",
              ),
            ],
          ),
        ),
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
                  _infoIcon(Icons.wb_sunny_outlined, zodiac, "zodiaco", valor: zodiac),
                  _infoIcon(Icons.pets, chinese, "chino", valor: chinese),
                  _infoIcon(Icons.access_time, hourly, "hora", valor: hourly),
                ],
              ),
              const Divider(color: Colors.amber, height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Vibración: ${prediction['nivel']}%", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => _showInfoDialog("vibracion", "", ""),
                    child: const Icon(Icons.info_outline, size: 14, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text("Juega: ${prediction['numero']}", style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text("En: ${prediction['loteria']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Juegos de: $selectedCountry",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.amber)),
              IconButton(
                icon: const Icon(Icons.public, color: Colors.amber, size: 30),
                onPressed: _showCountrySelector,
              ),
            ],
          ),
        ),
        const Divider(color: Colors.amber, thickness: 0.5),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: lotteries.length,
            itemBuilder: (context, index) {
              final game = lotteries[index];
              return _luckCard(game['name'], game['desc'], game['icon']);
            },
          ),
        ),
      ],
    );
  }

  Widget _infoIcon(IconData icon, String label, String tipo, {required String valor}) {
    return GestureDetector(
      onTap: () => _showInfoDialog(tipo, valor, "es"),
      child: Column(
        children: [
          Icon(icon, color: Colors.amber, size: 20),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 11)),
              const SizedBox(width: 2),
              const Icon(Icons.info_outline, size: 10, color: Colors.amber),
            ],
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String tipo, String valor, String idioma) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(15)),
        title: const Text("Información Mística", style: TextStyle(color: Colors.amber)),
        content: Text(LotteryLogic.getInfoText(tipo, valor, idioma)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("ENTENDIDO", style: TextStyle(color: Colors.amber)))
        ],
      ),
    );
  }

  Widget _buildAgueroScreen() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Center(child: const Icon(Icons.auto_fix_high, color: Colors.amber, size: 50)),
            const SizedBox(height: 10),
            Center(
              child: const Text("CALCULADORA DE AGÜEROS",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber)),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _agueroController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Sueño, placa o fecha...",
                prefixIcon: const Icon(Icons.edit, color: Colors.amber),
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
                  _agueroButton("SUEÑO", Icons.bed, () {
                    String num = AgueroLogic.obtenerNumeroPorSueno(_agueroController.text);
                    _showResultDialog("Tu Sueño", customNumber: num);
                  }),
                  _agueroButton("PLACA", Icons.directions_car, () {
                    String num = AgueroLogic.obtenerNumeroPorPlaca(_agueroController.text);
                    _showResultDialog("Tu Placa", customNumber: num);
                  }),
                  _agueroButton("FECHA", Icons.calendar_today, () {
                    String texto = _agueroController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    if (texto.length >= 4) {
                      _showResultDialog("Fecha de la Suerte", customNumber: texto.substring(0, 4));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Ingresa una fecha (ej: 1205)"))
                      );
                    }
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("💎 AGÜEROS FAMOSOS",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AgueroLogic.aguerosFamosos.length,
                itemBuilder: (context, index) {
                  final item = AgueroLogic.aguerosFamosos[index];
                  return GestureDetector(
                    onTap: () => _showResultDialog(item['titulo']!, customNumber: item['numero']),
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A1A),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.amber.withOpacity(0.4)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(item['titulo']!,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(item['numero']!, style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 40),
            const Divider(color: Colors.amber, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () => Share.share("¡Descubrí mi número de la suerte en LuckyPass Hub! Descárgala ya."),
                  icon: const Icon(Icons.share, color: Colors.amber),
                  label: const Text("COMPARTIR", style: TextStyle(color: Colors.white)),
                ),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Próximamente: Canal de apoyo para ganar juntos.")));
                  },
                  icon: const Icon(Icons.volunteer_activism, color: Colors.redAccent),
                  label: const Text("APOYAR", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _agueroButton(String tipo, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1A1A1A), side: const BorderSide(color: Colors.amber)),
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.amber),
      label: Text(tipo, style: const TextStyle(color: Colors.white)),
    );
  }

  Widget _buildFavoritesScreen() {
    var box = Hive.box('favorites');
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        return Column(
          children: [
            const SizedBox(height: 60),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, color: Colors.amber),
                const SizedBox(width: 10),
                const Text("TUS FAVORITOS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const Divider(color: Colors.amber, indent: 50, endIndent: 50),
            Expanded(
              child: box.isEmpty
                  ? const Center(child: Text("No hay favoritos guardados"))
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: box.length,
                itemBuilder: (context, index) {
                  final fav = box.getAt(index);
                  return Card(
                    color: const Color(0xFF1A1A1A),
                    child: ListTile(
                      title: Text(fav['title'] ?? "", style: const TextStyle(color: Colors.amber)),
                      subtitle: Text("${fav['content']}\n${fav['date']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => box.deleteAt(index),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  void _showPQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Buzón de Sugerencias", style: TextStyle(color: Colors.amber)),
        content: TextField(
          controller: _pqrController,
          maxLines: 4,
          decoration: const InputDecoration(
            hintText: "¿Cómo podemos mejorar LuckyPass Hub?",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("¡Gracias! Tus comentarios nos ayudan a mejorar.")));
                _pqrController.clear();
                Navigator.pop(context);
              },
              child: const Text("ENVIAR")
          ),
        ],
      ),
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: countriesData.keys.map((country) {
            return ListTile(
              leading: const Icon(Icons.location_on, color: Colors.amber),
              title: Text(country),
              onTap: () {
                setState(() => selectedCountry = country);
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  void _showResultDialog(String gameName, {String? customNumber}) {
    String generatedNumber = customNumber ?? LotteryLogic.generateFourDigits();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: Text("Resultado: $gameName", style: const TextStyle(color: Colors.amber)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(generatedNumber, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  if (gameName == "Super Astro" || gameName.contains("Lotería") || gameName.contains("Sueño") || gameName.contains("Diomedes")) ...[
                    if (!_videoVisto)
                      ElevatedButton.icon(
                        onPressed: () {
                          setDialogState(() => _videoVisto = true);
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Video recompensado (Simulado)")));
                        },
                        icon: const Icon(Icons.play_circle_fill),
                        label: const Text("REVELAR SIGNO / SERIAL"),
                      )
                    else
                      Text(
                        gameName == "Super Astro"
                            ? "Signo: ${LotteryLogic.getRandomSign()}"
                            : "Serial: ${LotteryLogic.generateThreeDigits()}",
                        style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                    onPressed: () {
                      _videoVisto = false;
                      Navigator.pop(context);
                    },
                    child: const Text("CERRAR")
                ),
                ElevatedButton(
                  onPressed: () {
                    var box = Hive.box('favorites');
                    box.add({
                      'title': gameName,
                      'content': generatedNumber,
                      'date': DateFormat('dd/MM HH:mm').format(DateTime.now()),
                    });
                    _videoVisto = false;
                    Navigator.pop(context);
                  },
                  child: const Text("GUARDAR"),
                ),
              ],
            );
          }
      ),
    );
  }

  Widget _luckCard(String title, String subtitle, IconData icon) {
    return Card(
      color: const Color(0xFF1A1A1A),
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: const BorderSide(color: Colors.amber, width: 0.5)),
      child: ListTile(
        leading: Icon(icon, color: Colors.amber, size: 30),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 15, color: Colors.amber),
        onTap: () => _showResultDialog(title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFFFFD700),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Suerte"),
          BottomNavigationBarItem(icon: Icon(Icons.auto_fix_high), label: "Agüeros"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favoritos"),
        ],
      ),
    );
  }
}