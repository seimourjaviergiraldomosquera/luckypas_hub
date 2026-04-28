import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'core/constants.dart';
import 'logic/lottery_logic.dart';
import 'logic/aguero_logic.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  await Hive.openBox('userProfile');
  await Hive.openBox('settings');
  await Hive.openBox('resultsHistory'); // Caja para el historial de verificaciones
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
  String? oracleSelectedLottery;
  final TextEditingController _agueroController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _pqrController = TextEditingController();
  final TextEditingController _favFilterController = TextEditingController();
  final TextEditingController _resultCheckerController = TextEditingController();

  bool _videoVisto = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkUserProfile());
  }

  String get _currentLang {
    if (selectedCountry == "China") return "zh";
    if (selectedCountry == "USA") return "en";
    return "es";
  }

  String _getLabel(String key) {
    Map<String, Map<String, String>> labels = {
      "es": {
        "vibracion": "Vibración",
        "juegaen": "En",
        "canalizando": "Canalizando tu suerte...",
        "info_titulo": "Información Mística",
        "editar_nombre": "Nombre del sorteo",
        "buscar": "Buscar en favoritos...",
        "suerte_con": "¡Suerte con LuckyPass!",
        "apoyar_msj": "Próximamente: Canal de apoyo.",
        "juegos_de": "Juegos de:",
        "probabilidad": "Probabilidad de Éxito",
        "ganados": "¡PREMIADOS!",
        "marcar_ganador": "Marcar como ganador",
        "efectividad": "Efectividad",
        "tu_suerte_en": "Tu suerte está en:",
        "oraculo_titulo": "Oráculo de Resultados",
        "oraculo_hint": "Número ganador",
        "verificar": "VERIFICAR CONEXIÓN",
        "seleccionar_lotto": "Seleccionar sorteo",
        "tab_favs": "MIS NÚMEROS",
        "tab_historial": "HISTORIAL"
      },
      "en": {
        "vibracion": "Vibration",
        "juegaen": "In",
        "canalizando": "Channeling your luck...",
        "info_titulo": "Mystic Info",
        "editar_nombre": "Draw name",
        "buscar": "Search favorites...",
        "suerte_con": "Good luck with LuckyPass!",
        "apoyar_msj": "Coming soon: Support channel.",
        "juegos_de": "Games from:",
        "probabilidad": "Success Probability",
        "ganados": "WINNERS!",
        "marcar_ganador": "Mark as winner",
        "efectividad": "Effectiveness",
        "tu_suerte_en": "Your luck is in:",
        "oraculo_titulo": "Results Oracle",
        "oraculo_hint": "Winning number",
        "verificar": "CHECK CONNECTION",
        "seleccionar_lotto": "Select draw",
        "tab_favs": "MY NUMBERS",
        "tab_historial": "HISTORY"
      },
      "zh": {
        "vibracion": "能量振动",
        "juegaen": "建议投注",
        "canalizando": "正在感应你的财运...",
        "info_titulo": "神秘信息",
        "editar_nombre": "编辑名称",
        "buscar": "搜索收藏...",
        "suerte_con": "祝你好运 LuckyPass!",
        "apoyar_msj": "即将推出：支持渠道。",
        "juegos_de": "博彩游戏:",
        "probabilidad": "中奖概率",
        "ganados": "中奖号码!",
        "marcar_ganador": "设为中奖",
        "efectividad": "胜率",
        "tu_suerte_en": "你的财运在:",
        "oraculo_titulo": "开奖先知",
        "oraculo_hint": "中奖号码",
        "verificar": "检查连接",
        "seleccionar_lotto": "选择博彩",
        "tab_favs": "我的号码",
        "tab_historial": "历史记录"
      }
    };
    return labels[_currentLang]?[key] ?? labels["es"]?[key] ?? key;
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
    "China": [
      {"name": "Welfare Lottery", "desc": "Union Lotto (双色球)", "icon": Icons.card_giftcard},
      {"name": "Sports Lottery", "desc": "Super Lotto (大乐透)", "icon": Icons.sports_basketball},
      {"name": "Lotto 3D", "desc": "3 digits luck", "icon": Icons.looks_3},
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
    _buildFavoritesTabController(), // Función que maneja las pestañas
  ];

  Widget _buildLuckScreen() {
    var boxProfile = Hive.box('userProfile');
    var boxFavs = Hive.box('favorites');
    var settingsBox = Hive.box('settings');

    String name = boxProfile.get('name') ?? "Jugador";
    DateTime? bDay = boxProfile.get('birthDate');
    int? bHour = boxProfile.get('birthHour');
    String lang = _currentLang;

    String zodiac = bDay != null ? LotteryLogic.getZodiacSign(bDay) : "...";
    String chinese = bDay != null ? LotteryLogic.getChineseZodiac(bDay) : "...";
    String hourly = bHour != null ? LotteryLogic.getHourlySign(bHour) : "...";

    final prediction = LotteryLogic.getIAPrediction(name, zodiac);

    List<Map<String, dynamic>> lotteries = List.from(countriesData[selectedCountry] ?? []);
    List<String>? customOrder = settingsBox.get('order_$selectedCountry')?.cast<String>();

    if (customOrder != null) {
      lotteries.sort((a, b) {
        int indexA = customOrder.indexOf(a['name']);
        int indexB = customOrder.indexOf(b['name']);
        if (indexA == -1) return 1;
        if (indexB == -1) return -1;
        return indexA.compareTo(indexB);
      });
    }

    int totalFavs = boxFavs.length;
    int ganados = boxFavs.values.where((f) => f['isWinner'] == true).length;
    double efectividad = totalFavs > 0 ? (ganados / totalFavs) * 100 : 0.0;

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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Share.share(_getLabel('suerte_con')),
                    icon: const Icon(Icons.share, color: Colors.amber, size: 20),
                  ),
                  IconButton(
                    onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_getLabel('apoyar_msj')))),
                    icon: const Icon(Icons.volunteer_activism, color: Colors.redAccent, size: 20),
                  ),
                ],
              ),
              IconButton(
                onPressed: _showPQRDialog,
                icon: const Icon(Icons.mark_as_unread_outlined, color: Colors.amber),
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
                  _infoIcon(Icons.wb_sunny_outlined, zodiac, "zodiaco", zodiac, lang),
                  _infoIcon(Icons.pets, chinese, "chino", chinese, lang),
                  _infoIcon(Icons.access_time, hourly, "hora", hourly, lang),
                ],
              ),
              const Divider(color: Colors.amber, height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("${_getLabel('vibracion')}: ${prediction['nivel']}%", style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: () => _showInfoDialog("vibracion", "", lang),
                    child: const Icon(Icons.info_outline, size: 14, color: Colors.amber),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(prediction['numero'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text("${_getLabel('juegaen')}: ${prediction['loteria']}", style: const TextStyle(color: Colors.grey, fontSize: 13)),
            ],
          ),
        ),

        if (totalFavs > 0)
          Padding(
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
                  Icon(Icons.analytics_outlined, color: Colors.amber.shade300, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("${_getLabel('efectividad')}: ${efectividad.toStringAsFixed(1)}%",
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        Text("${_getLabel('tu_suerte_en')} $luckyLottery",
                            style: TextStyle(fontSize: 10, color: Colors.grey.shade400)),
                      ],
                    ),
                  ),
                  Icon(Icons.trending_up, color: Colors.green.shade400, size: 20),
                ],
              ),
            ),
          ),

        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${_getLabel('juegos_de')} $selectedCountry",
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
          child: ReorderableListView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            onReorder: (oldIndex, newIndex) {
              setState(() {
                if (newIndex > oldIndex) newIndex -= 1;
                final item = lotteries.removeAt(oldIndex);
                lotteries.insert(newIndex, item);
                List<String> newOrderNames = lotteries.map((e) => e['name'] as String).toList();
                settingsBox.put('order_$selectedCountry', newOrderNames);
              });
            },
            children: [
              for (var game in lotteries)
                _luckCard(game['name'], game['desc'], game['icon'], ValueKey(game['name'])),
            ],
          ),
        ),
      ],
    );
  }

  Widget _infoIcon(IconData icon, String label, String tipo, String valor, String lang) {
    return GestureDetector(
      onTap: () => _showInfoDialog(tipo, valor, lang),
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

  void _showInfoDialog(String tipo, String valor, String idioma) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(15)),
        title: Text(_getLabel('info_titulo'), style: const TextStyle(color: Colors.amber)),
        content: Text(LotteryLogic.getInfoText(tipo, valor, idioma)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Colors.amber)))
        ],
      ),
    );
  }

  void _showMysticLoading(String gameName, {String? customNumber}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pop(context);
          _showResultDialog(gameName, customNumber: customNumber);
        });
        return AlertDialog(
          backgroundColor: Colors.black,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: Colors.amber),
              const SizedBox(height: 20),
              Text(_getLabel('canalizando'), style: const TextStyle(color: Colors.amber, fontStyle: FontStyle.italic)),
            ],
          ),
        );
      },
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
            Center(child: Text(_getLabel('agueros'), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.amber))),
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
                    _showMysticLoading("Tu Sueño", customNumber: num);
                  }),
                  _agueroButton("PLACA", Icons.directions_car, () {
                    String num = AgueroLogic.obtenerNumeroPorPlaca(_agueroController.text);
                    _showMysticLoading("Tu Placa", customNumber: num);
                  }),
                  _agueroButton("FECHA", Icons.calendar_today, () {
                    String texto = _agueroController.text.replaceAll(RegExp(r'[^0-9]'), '');
                    if (texto.length >= 4) {
                      _showMysticLoading("Fecha Suerte", customNumber: texto.substring(0, 4));
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Ingresa una fecha (ej: 1205)")));
                    }
                  }),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("💎 AGÜEROS FAMOSOS", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.amber)),
            const SizedBox(height: 15),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: AgueroLogic.aguerosFamosos.length,
                itemBuilder: (context, index) {
                  final item = AgueroLogic.aguerosFamosos[index];
                  return GestureDetector(
                    onTap: () => _showMysticLoading(item['titulo']!, customNumber: item['numero']),
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
            ),
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

  // --- NUEVA ESTRUCTURA DE PESTAÑAS PARA FAVORITOS ---
  Widget _buildFavoritesTabController() {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 0, // Quitamos la barra superior para que las pestañas queden limpias
          bottom: TabBar(
            indicatorColor: Colors.amber,
            labelColor: Colors.amber,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: _getLabel('tab_favs')),
              Tab(text: _getLabel('tab_historial')),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildFavoritesScreen(),
            _buildOracleHistoryList(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.amber,
          onPressed: _showResultOracleDialog,
          child: const Icon(Icons.visibility, color: Colors.black),
          tooltip: _getLabel('oraculo_titulo'),
        ),
      ),
    );
  }

  Widget _buildOracleHistoryList() {
    var historyBox = Hive.box('resultsHistory');
    return ValueListenableBuilder(
      valueListenable: historyBox.listenable(),
      builder: (context, Box box, _) {
        List results = box.values.toList().reversed.toList();
        if (results.isEmpty) return const Center(child: Text("Sin registros en el historial"));

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final res = results[index];
            return Card(
              color: const Color(0xFF1A1A1A),
              shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.white12), borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: const Icon(Icons.history_toggle_off, color: Colors.amber),
                title: Text(res['lottery'] ?? "", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                subtitle: Text("Ganador: ${res['number']}"),
                trailing: Text(res['date'] ?? "", style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFavoritesScreen() {
    var box = Hive.box('favorites');
    return ValueListenableBuilder(
      valueListenable: box.listenable(),
      builder: (context, Box box, _) {
        List favs = box.values.toList();
        if (_favFilterController.text.isNotEmpty) {
          favs = favs.where((f) => f['title'].toString().toLowerCase().contains(_favFilterController.text.toLowerCase())).toList();
        }

        int winnersCount = box.values.where((f) => f['isWinner'] == true).length;

        return Column(
          children: [
            const SizedBox(height: 20),
            if (winnersCount > 0)
              Chip(
                backgroundColor: Colors.amber.withOpacity(0.2),
                label: Text("${_getLabel('ganados')}: $winnersCount ✨", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                controller: _favFilterController,
                onChanged: (v) => setState(() {}),
                decoration: InputDecoration(
                  hintText: _getLabel('buscar'),
                  prefixIcon: const Icon(Icons.search, color: Colors.amber),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                ),
              ),
            ),
            Expanded(
              child: favs.isEmpty ? const Center(child: Text("Sin favoritos")) : ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: favs.length,
                itemBuilder: (context, index) {
                  final fav = favs[index];
                  int realIndex = box.values.toList().indexOf(fav);
                  bool isWinner = fav['isWinner'] ?? false;

                  return Card(
                    color: isWinner ? const Color(0xFF2D2600) : const Color(0xFF1A1A1A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: isWinner ? Colors.amber : Colors.transparent, width: 1.5),
                    ),
                    child: ListTile(
                      title: Text(fav['title'] ?? "", style: TextStyle(color: isWinner ? Colors.amber : Colors.white, fontWeight: isWinner ? FontWeight.bold : FontWeight.normal)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${fav['content']}\n${fav['date']}"),
                          if (fav['prob'] != null)
                            Text("Prob: ${fav['prob'].toStringAsFixed(1)}%", style: const TextStyle(color: Colors.amber, fontSize: 10)),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(isWinner ? Icons.emoji_events : Icons.emoji_events_outlined, color: isWinner ? Colors.amber : Colors.grey),
                            tooltip: _getLabel('marcar_ganador'),
                            onPressed: () {
                              Map updatedFav = Map.from(fav);
                              updatedFav['isWinner'] = !isWinner;
                              box.putAt(realIndex, updatedFav);
                              setState(() {});
                            },
                          ),
                          IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () => box.deleteAt(realIndex)),
                        ],
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

  void _showResultOracleDialog() {
    List<Map<String, dynamic>> lotteries = countriesData[selectedCountry] ?? [];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(15)),
          title: Row(
            children: [
              const Icon(Icons.auto_fix_high, color: Colors.amber),
              const SizedBox(width: 10),
              Text(_getLabel('oraculo_titulo'), style: const TextStyle(color: Colors.amber, fontSize: 18)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: _getLabel('seleccionar_lotto')),
                dropdownColor: const Color(0xFF1A1A1A),
                items: lotteries.map((l) => DropdownMenuItem(value: l['name'].toString(), child: Text(l['name']))).toList(),
                onChanged: (val) => setDialogState(() => oracleSelectedLottery = val),
              ),
              const SizedBox(height: 15),
              TextField(
                controller: _resultCheckerController,
                keyboardType: TextInputType.number,
                maxLength: 6, // PERMITE HASTA 6 DÍGITOS PARA BALOTO O POWERBALL
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: "----",
                  labelText: _getLabel('oraculo_hint'),
                  border: const OutlineInputBorder(),
                  counterText: "", // Ocultamos el contador para que se vea más limpio
                ),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                if (oracleSelectedLottery != null && _resultCheckerController.text.isNotEmpty) {
                  String input = _resultCheckerController.text;
                  String lotto = oracleSelectedLottery!;
                  Navigator.pop(context);
                  _checkResults(input, lotto);
                }
              },
              child: Text(_getLabel('verificar'), style: const TextStyle(color: Colors.black)),
            )
          ],
        ),
      ),
    );
  }

  void _checkResults(String winningNumber, String lotteryName) {
    var boxFavs = Hive.box('favorites');
    var boxHistory = Hive.box('resultsHistory');
    List favs = boxFavs.values.toList();

    String message = "Sigue canalizando tu suerte...";
    Color color = Colors.grey;

    for (var fav in favs) {
      if (fav['title'] == lotteryName) {
        String favNum = fav['content'].toString();

        if (favNum == winningNumber) {
          message = "¡CONEXIÓN TOTAL! El número $winningNumber en $lotteryName fue un acierto místico.";
          color = Colors.green;
          break;
        } else if (winningNumber.endsWith(favNum.substring(favNum.length >= 2 ? favNum.length - 2 : 0))) {
          message = "¡CASI! Atrapaste las últimas cifras en $lotteryName. Tu vibración es alta.";
          color = Colors.amber;
        }
      }
    }

    boxHistory.add({
      'lottery': lotteryName,
      'number': winningNumber,
      'date': DateFormat('dd/MM HH:mm').format(DateTime.now()),
    });

    _showIntuitionReport(message, color);
    _resultCheckerController.clear();
    oracleSelectedLottery = null;
  }

  void _showIntuitionReport(String msg, Color col) {
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

  void _showPQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Buzón de Sugerencias", style: TextStyle(color: Colors.amber)),
        content: TextField(
          controller: _pqrController,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(hintText: "¿Cómo podemos mejorar?", border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
          ElevatedButton(onPressed: () { Navigator.pop(context); }, child: const Text("ENVIAR")),
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
    TextEditingController editController = TextEditingController(text: gameName);
    double probabilidad = (generatedNumber.hashCode % 30 + 70).toDouble();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A1A),
              title: TextField(
                controller: editController,
                style: const TextStyle(color: Colors.amber, fontSize: 16),
                decoration: InputDecoration(labelText: _getLabel('editar_nombre')),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_getLabel('probabilidad'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 8),
                  Stack(
                    children: [
                      Container(
                        height: 10,
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.grey.shade900, borderRadius: BorderRadius.circular(5)),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 800),
                        height: 10,
                        width: (MediaQuery.of(context).size.width * 0.5) * (probabilidad / 100),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [Colors.orange, Colors.amber]),
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Text("${probabilidad.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
                  const Divider(color: Colors.amber, height: 30),

                  Text(generatedNumber, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5)),
                  const SizedBox(height: 20),
                  if (gameName == "Super Astro" || gameName.contains("Lotería") || gameName.contains("Sueño") || gameName.contains("Diomedes") || gameName.contains("Lotto")) ...[
                    if (!_videoVisto)
                      ElevatedButton.icon(
                        onPressed: () { setDialogState(() => _videoVisto = true); },
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
                TextButton(onPressed: () { _videoVisto = false; Navigator.pop(context); }, child: const Text("CERRAR")),
                ElevatedButton(
                  onPressed: () {
                    var box = Hive.box('favorites');
                    box.add({
                      'title': editController.text,
                      'content': generatedNumber,
                      'prob': probabilidad,
                      'date': DateFormat('dd/MM HH:mm').format(DateTime.now()),
                      'isWinner': false
                    });
                    _videoVisto = false;
                    Navigator.pop(context);
                    setState(() {});
                  },
                  child: const Text("GUARDAR"),
                ),
              ],
            );
          }
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
        onTap: () => _showMysticLoading(title),
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