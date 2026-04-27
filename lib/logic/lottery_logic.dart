import 'dart:math';

class LotteryLogic {
  static final Random _random = Random();

  // Generar 4 cifras (Chance / Astro)
  static String generateFourDigits() {
    return _random.nextInt(10000).toString().padLeft(4, '0');
  }

  // Generar 3 cifras para el Serial de las Loterías
  static String generateThreeDigits() {
    return _random.nextInt(1000).toString().padLeft(3, '0');
  }

  // Obtener signo para Super Astro
  static String getRandomSign() {
    List<String> signs = [
      "Aries", "Tauro", "Géminis", "Cáncer", "Leo", "Virgo",
      "Libra", "Escorpio", "Sagitario", "Capricornio", "Acuario", "Piscis"
    ];
    return signs[_random.nextInt(signs.length)];
  }

  // --- NUEVAS FUNCIONES DE PERSONALIZACIÓN MÍSTICA ---

  // Calcular Signo Zodiacal según fecha
  static String getZodiacSign(DateTime date) {
    int day = date.day;
    int month = date.month;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return "Acuario";
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return "Piscis";
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return "Aries";
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return "Tauro";
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return "Géminis";
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return "Cáncer";
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return "Leo";
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return "Virgo";
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return "Libra";
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return "Escorpio";
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return "Sagitario";
    return "Capricornio";
  }

  // Calcular Signo Chino con corrección de año lunar
  static String getChineseZodiac(DateTime date) {
    int year = date.year;
    if (date.month < 2 || (date.month == 2 && date.day < 10)) {
      year--;
    }
    List<String> animals = [
      "Rata", "Buey", "Tigre", "Conejo", "Dragón", "Serpiente",
      "Caballo", "Cabra", "Mono", "Gallo", "Perro", "Cerdo"
    ];
    return animals[(year - 1924) % 12];
  }

  // Calcular Signo por Hora de Nacimiento
  static String getHourlySign(int hour) {
    if (hour >= 23 || hour < 1) return "Rata";
    if (hour >= 1 && hour < 3) return "Buey";
    if (hour >= 3 && hour < 5) return "Tigre";
    if (hour >= 5 && hour < 7) return "Conejo";
    if (hour >= 7 && hour < 9) return "Dragón";
    if (hour >= 9 && hour < 11) return "Serpiente";
    if (hour >= 11 && hour < 13) return "Caballo";
    if (hour >= 13 && hour < 15) return "Cabra";
    if (hour >= 15 && hour < 17) return "Mono";
    if (hour >= 17 && hour < 19) return "Gallo";
    if (hour >= 19 && hour < 21) return "Perro";
    return "Cerdo";
  }

  // MOTOR DE PREDICCIÓN IA PERSONALIZADA
  static Map<String, dynamic> getIAPrediction(String name, String zodiac) {
    final now = DateTime.now();
    final int seed = name.hashCode + now.day + now.month + now.year;
    final randomIA = Random(seed);

    int level = 70 + randomIA.nextInt(30);
    String luckyNumber = randomIA.nextInt(10000).toString().padLeft(4, '0');

    List<String> recomendations = [
      "Chontico Noche", "Super Astro", "Paisita Día",
      "Lotería del Quindío", "Cafeterito Tarde", "Sinuano Noche"
    ];
    String selectedLottery = recomendations[randomIA.nextInt(recomendations.length)];

    return {
      "nivel": level,
      "numero": luckyNumber,
      "loteria": selectedLottery,
      "mensaje": "Vibración mística detectada. Tu conexión con $selectedLottery es fuerte hoy."
    };
  }

  // Generar Baloto
  static Map<String, dynamic> generateBaloto() {
    List<int> numbers = [];
    while (numbers.length < 5) {
      int n = _random.nextInt(43) + 1;
      if (!numbers.contains(n)) numbers.add(n);
    }
    numbers.sort();
    return {
      "numbers": numbers,
      "superball": _random.nextInt(16) + 1
    };
  }

  // NUEVO: MOTOR DE INFORMACIÓN DETALLADA (PERSONALIDAD Y COMPATIBILIDAD)
  static String getInfoText(String tipo, String valor, String idioma) {
    Map<String, Map<String, String>> infoZodiaco = {
      "Aries": {"p": "Valiente y entusiasta.", "c": "Leo y Sagitario."},
      "Tauro": {"p": "Paciente y decidido.", "c": "Virgo y Capricornio."},
      "Géminis": {"p": "Curioso y adaptable.", "c": "Libra y Acuario."},
      "Cáncer": {"p": "Intuitivo y protector.", "c": "Escorpio y Piscis."},
      "Leo": {"p": "Generoso y líder.", "c": "Aries y Sagitario."},
      "Virgo": {"p": "Analítico y práctico.", "c": "Tauro y Capricornio."},
      "Libra": {"p": "Diplomático y sociable.", "c": "Géminis y Acuario."},
      "Escorpio": {"p": "Apasionado y decidido.", "c": "Cáncer y Piscis."},
      "Sagitario": {"p": "Optimista y libre.", "c": "Aries y Leo."},
      "Capricornio": {"p": "Disciplinado y ambicioso.", "c": "Tauro y Virgo."},
      "Acuario": {"p": "Original e independiente.", "c": "Géminis y Libra."},
      "Piscis": {"p": "Compasivo y artístico.", "c": "Cáncer y Escorpio."},
    };

    Map<String, Map<String, String>> infoChino = {
      "Rata": {"p": "Ingeniosa y versátil.", "c": "Dragón y Mono."},
      "Buey": {"p": "Fuerte y confiable.", "c": "Gallo y Serpiente."},
      "Tigre": {"p": "Valiente y aventurero.", "c": "Caballo y Perro."},
      "Conejo": {"p": "Amable y elegante.", "c": "Cerdo y Cabra."},
      "Dragón": {"p": "Poderoso y vital.", "c": "Rata y Mono."},
      "Serpiente": {"p": "Sabia y enigmática.", "c": "Buey y Gallo."},
      "Caballo": {"p": "Energético y cálido.", "c": "Tigre y Perro."},
      "Cabra": {"p": "Gentil y creativa.", "c": "Conejo y Cerdo."},
      "Mono": {"p": "Divertido e inteligente.", "c": "Rata y Dragón."},
      "Gallo": {"p": "Orgulloso y puntual.", "c": "Buey y Serpiente."},
      "Perro": {"p": "Leal y honesto.", "c": "Caballo y Tigre."},
      "Cerdo": {"p": "Diligente y generoso.", "c": "Conejo y Cabra."},
    };

    if (tipo == "vibracion") {
      return "La vibración es tu nivel de sintonía energética hoy. Se calcula uniendo tu energía personal con la del universo.";
    }

    if (tipo == "zodiaco" && infoZodiaco.containsKey(valor)) {
      return "Zodíaco ($valor):\n• Personalidad: ${infoZodiaco[valor]!['p']}\n• Compatibilidad: ${infoZodiaco[valor]!['c']}";
    }

    if (tipo == "chino" && infoChino.containsKey(valor)) {
      return "Horóscopo Chino ($valor):\n• Personalidad: ${infoChino[valor]!['p']}\n• Compatibilidad: ${infoChino[valor]!['c']}";
    }

    return "Información mística no disponible por el momento.";
  }
}