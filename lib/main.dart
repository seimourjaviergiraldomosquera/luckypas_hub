import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'core/constants.dart';
import 'core/labels.dart';
import 'core/countries_data.dart';
import 'logic/lottery_logic.dart';
import 'logic/aguero_logic.dart';
import 'presentation/aguero_screen.dart';
import 'presentation/favorites_screen.dart';
import 'presentation/luck_screen.dart';
import 'presentation/components/dialogs.dart'; // NUEVO IMPORT

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

  String get _currentLang => (selectedCountry == "China") ? "zh" : (selectedCountry == "USA") ? "en" : "es";

  String _getLabel(String key) => AppLabels.data[_currentLang]?[key] ?? AppLabels.data["es"]?[key] ?? key;

  void _checkUserProfile() {
    var box = Hive.box('userProfile');
    if (box.get('name') == null) {
      AppDialogs.showRegistrationDialog(context, _nameController, () => setState(() {}));
    }
  }

  List<Widget> get _screens => [
    _buildLuckScreen(),
    _buildAgueroScreen(),
    _buildFavoritesTabController(),
  ];

  Widget _buildLuckScreen() {
    var boxProfile = Hive.box('userProfile');
    var settingsBox = Hive.box('settings');
    List<Map<String, dynamic>> lotteries = List.from(CountriesData.data[selectedCountry] ?? []);
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
          settingsBox.put('order_$selectedCountry', lotteries.map((e) => e['name'] as String).toList());
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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK", style: TextStyle(color: Colors.amber)))],
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

  Widget _buildAgueroScreen() => AgueroScreen(controller: _agueroController, getLabel: _getLabel, showMysticLoading: _showMysticLoading);

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
    List<Map<String, dynamic>> lotteries = CountriesData.data[selectedCountry] ?? [];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A1A),
          shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.amber), borderRadius: BorderRadius.circular(15)),
          title: Row(children: [const Icon(Icons.auto_fix_high, color: Colors.amber), const SizedBox(width: 10), Text(_getLabel('oraculo_titulo'), style: const TextStyle(color: Colors.amber, fontSize: 18))]),
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
                decoration: InputDecoration(hintText: "----", labelText: _getLabel('oraculo_hint'), border: const OutlineInputBorder(), counterText: ""),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
              onPressed: () {
                if (oracleSelectedLottery != null && _resultCheckerController.text.isNotEmpty) {
                  _checkResults(_resultCheckerController.text, oracleSelectedLottery!);
                  Navigator.pop(context);
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
    String message = "Sigue canalizando tu suerte...";
    Color color = Colors.grey;

    for (var fav in boxFavs.values) {
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

    boxHistory.add({'lottery': lotteryName, 'number': winningNumber, 'date': DateFormat('dd/MM HH:mm').format(DateTime.now())});
    AppDialogs.showIntuitionReport(context, message, color);
    _resultCheckerController.clear();
    oracleSelectedLottery = null;
  }

  void _showPQRDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Buzón de Sugerencias", style: TextStyle(color: Colors.amber)),
        content: TextField(controller: _pqrController, maxLines: 4, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "¿Cómo podemos mejorar?", border: OutlineInputBorder())),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("CANCELAR")), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text("ENVIAR"))],
      ),
    );
  }

  void _showCountrySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      builder: (context) => ListView(
        shrinkWrap: true,
        children: CountriesData.data.keys.map((country) => ListTile(
          leading: const Icon(Icons.location_on, color: Colors.amber),
          title: Text(country),
          onTap: () { setState(() => selectedCountry = country); Navigator.pop(context); },
        )).toList(),
      ),
    );
  }

  void _showResultDialog(String gameName, {String? customNumber}) {
    String generatedNumber = customNumber ?? LotteryLogic.generateFourDigits();
    TextEditingController editController = TextEditingController(text: gameName);
    double probabilidad = (generatedNumber.hashCode % 30 + 70).toDouble();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: TextField(controller: editController, style: const TextStyle(color: Colors.amber, fontSize: 16), decoration: InputDecoration(labelText: _getLabel('editar_nombre'))),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_getLabel('probabilidad'), style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 8),
            Text("${probabilidad.toStringAsFixed(1)}%", style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12)),
            const Divider(color: Colors.amber, height: 30),
            Text(generatedNumber, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 5)),
            const SizedBox(height: 20),
            if (gameName == "Super Astro" || gameName.contains("Lotería") || gameName.contains("Sueño") || gameName.contains("Diomedes") || gameName.contains("Lotto"))
              if (!_videoVisto) ElevatedButton.icon(onPressed: () => setDialogState(() => _videoVisto = true), icon: const Icon(Icons.play_circle_fill), label: const Text("REVELAR SIGNO / SERIAL"))
              else Text(gameName == "Super Astro" ? "Signo: ${LotteryLogic.getRandomSign()}" : "Serial: ${LotteryLogic.generateThreeDigits()}", style: const TextStyle(color: Colors.amber, fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          TextButton(onPressed: () { _videoVisto = false; Navigator.pop(context); }, child: const Text("CERRAR")),
          ElevatedButton(onPressed: () {
            Hive.box('favorites').add({'title': editController.text, 'content': generatedNumber, 'prob': probabilidad, 'date': DateFormat('dd/MM HH:mm').format(DateTime.now()), 'isWinner': false});
            _videoVisto = false; Navigator.pop(context); setState(() {});
          }, child: const Text("GUARDAR")),
        ],
      )),
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