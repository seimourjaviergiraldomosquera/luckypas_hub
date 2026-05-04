import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'core/constants.dart';
import 'logic/lottery_logic.dart';
import 'logic/aguero_logic.dart';
import 'presentation/aguero_screen.dart';
import 'presentation/favorites_screen.dart';
import 'presentation/luck_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  await Hive.openBox('userProfile');
  await Hive.openBox('settings');
  await Hive.openBox('resultsHistory');
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
        "tu_suerte_en": "你的财运 en:",
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
    _buildFavoritesTabController(),
  ];

  Widget _buildLuckScreen() {
    var boxProfile = Hive.box('userProfile');
    var settingsBox = Hive.box('settings');

    List<Map<String, dynamic>> lotteries = List.from(countriesData[selectedCountry] ?? []);
    List<String>? customOrder = settingsBox.get('order_$selectedCountry')?.cast<String>();

    if (customOrder != null) {
      lotteries.sort((a, b) {
        int indexA = customOrder.indexOf(a['name']);
        int indexB = customOrder.indexOf(b['name']);
        return (indexA == -1 ? 1 : indexA).compareTo(indexB == -1 ? 1 : indexB);
      });
    }

    return LuckScreen(
      name: boxProfile.get('name') ?? "Jugador",
      selectedCountry: selectedCountry,
      currentLang: _currentLang,
      birthDate: boxProfile.get('birthDate'),
      birthHour: boxProfile.get('birthHour'),
      lotteries: lotteries,
      getLabel: _getLabel,
      onShowInfo: _showInfoDialog,
      onShowPQR: _showPQRDialog,
      onShowCountrySelector: _showCountrySelector,
      onShowMysticLoading: _showMysticLoading,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (newIndex > oldIndex) newIndex -= 1;
          final item = lotteries.removeAt(oldIndex);
          lotteries.insert(newIndex, item);
          List<String> newOrderNames = lotteries.map((e) => e['name'] as String).toList();
          settingsBox.put('order_$selectedCountry', newOrderNames);
        });
      },
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
    return AgueroScreen(
      controller: _agueroController,
      getLabel: _getLabel,
      showMysticLoading: _showMysticLoading,
    );
  }

  Widget _buildFavoritesTabController() {
    return FavoritesScreen(
      filterController: _favFilterController,
      getLabel: _getLabel,
      onShowOracle: _showResultOracleDialog,
      onToggleWinner: (index, fav) {
        var box = Hive.box('favorites');
        Map updatedFav = Map.from(fav);
        updatedFav['isWinner'] = !(fav['isWinner'] ?? false);
        box.putAt(index, updatedFav);
        setState(() {});
      },
      onDeleteFav: (index) {
        Hive.box('favorites').deleteAt(index);
        setState(() {});
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
                maxLength: 6,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: "----",
                  labelText: _getLabel('oraculo_hint'),
                  border: const OutlineInputBorder(),
                  counterText: "",
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