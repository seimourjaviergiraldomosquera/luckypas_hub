import 'dart:math';

class LotteryLogic {
  static final Random _random = Random();

  // --- LÓGICA DE GENERACIÓN DE NÚMEROS ---

  // Generar 4 cifras (Chance / Astro)
  static String generateFourDigits() {
    return _random.nextInt(10000).toString().padLeft(4, '0');
  }

  // Generar 3 cifras para el Serial de las Loterías
  static String generateThreeDigits() {
    return _random.nextInt(1000).toString().padLeft(3, '0');
  }

  // NUEVO: Generar 5 números únicos del 1 al 39 para MiLoto
  static String generateMiLoto() {
    List<int> numbers = [];
    while (numbers.length < 5) {
      int next = _random.nextInt(39) + 1;
      if (!numbers.contains(next)) {
        numbers.add(next);
      }
    }
    numbers.sort();
    return numbers.join(" - ");
  }

  // Obtener signo para Super Astro
  static String getRandomSign() {
    List<String> signs = [
      "Aries", "Tauro", "Géminis", "Cáncer", "Leo", "Virgo",
      "Libra", "Escorpio", "Sagitario", "Capricornio", "Acuario", "Piscis"
    ];
    return signs[_random.nextInt(signs.length)];
  }

  // Generar Baloto (5 números del 1-43 + Superbolota 1-16)
  static Map<String, dynamic> generateBaloto() {
    List<int> numbers = [];
    while (numbers.length < 5) {
      int n = _random.nextInt(43) + 1;
      if (!numbers.contains(n)) numbers.add(n);
    }
    numbers.sort();
    return {
      "numbers": numbers.join(" - "),
      "superball": _random.nextInt(16) + 1
    };
  }

  // --- LÓGICA DE PERFIL PERSONALIZADO ---

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

  // Calcular Signo Chino
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

  // --- MOTOR DE INFORMACIÓN DETALLADA ---
  static String getInfoText(String tipo, String valor, String idioma) {
    bool isZh = idioma == "zh";
    String pLabel = isZh ? "个性" : "Personalidad";
    String cLabel = isZh ? "兼容性" : "Compatibilidad";

    // Textos para Agüeros y Favoritos (Botón i)
    if (tipo == "aguero") {
      return isZh
          ? "这种做法将你的直觉和梦想转化为幸运数字。"
          : "Esta práctica transforma tus intuiciones y sueños en números de poder místico.";
    }
    if (tipo == "favorito") {
      return isZh
          ? "这个数字已经根据你的能量水平和抽奖活动进行了调整。"
          : "Este número ha sido sintonizado según tu nivel de energía actual y el sorteo seleccionado.";
    }

    Map<String, Map<String, String>> infoZodiaco = {
      "Aries": {"p": isZh ? "勇敢且充满热情" : "Valiente y entusiasta.", "c": "Leo, Sagitario."},
      "Tauro": {"p": isZh ? "耐心且果断" : "Paciente y decidido.", "c": "Virgo, Capricornio."},
      "Géminis": {"p": isZh ? "好奇且适应力强" : "Curioso y adaptable.", "c": "Libra, Acuario."},
      "Cáncer": {"p": isZh ? "直觉敏锐且具有保护欲" : "Intuitivo y protector.", "c": "Escorpio, Piscis."},
      "Leo": {"p": isZh ? "慷慨且具领导力" : "Generoso y líder.", "c": "Aries, Sagitario."},
      "Virgo": {"p": isZh ? "善于分析且务实" : "Analítico y práctico.", "c": "Tauro, Capricornio."},
      "Libra": {"p": isZh ? "外交手腕强且善于交际" : "Diplomático y sociable.", "c": "Géminis, Acuario."},
      "Escorpio": {"p": isZh ? "热情且果断" : "Apasionado y decidido.", "c": "Cáncer, Piscis."},
      "Sagitario": {"p": isZh ? "乐观且向往自由" : "Optimista y libre.", "c": "Aries, Leo."},
      "Capricornio": {"p": isZh ? "自律且有雄心" : "Disciplinado y ambicioso.", "c": "Tauro, Virgo."},
      "Acuario": {"p": isZh ? "独创且独立" : "Original e independiente.", "c": "Géminis, Libra."},
      "Piscis": {"p": isZh ? "富有同情心且具艺术气息" : "Compasivo y artístico.", "c": "Cáncer, Escorpio."},
    };

    Map<String, Map<String, String>> infoChino = {
      "Rata": {"p": isZh ? "机智且多才多艺" : "Ingeniosa y versátil.", "c": "Dragón, Mono."},
      "Buey": {"p": isZh ? "强壮且可靠" : "Fuerte y confiable.", "c": "Gallo, Serpiente."},
      "Tigre": {"p": isZh ? "勇敢且冒险" : "Valiente y aventurero.", "c": "Caballo, Perro."},
      "Conejo": {"p": isZh ? "温柔且优雅" : "Amable y elegante.", "c": "Cerdo, Cabra."},
      "Dragón": {"p": isZh ? "强大且充满活力" : "Poderoso y vital.", "c": "Rata, Mono."},
      "Serpiente": {"p": isZh ? "聪明且神秘" : "Sabia y enigmática.", "c": "Buey, Gallo."},
      "Caballo": {"p": isZh ? "精力充充沛且热情" : "Energético y cálido.", "c": "Tigre, Perro."},
      "Cabra": {"p": isZh ? "温柔且富有创造力" : "Gentil y creativa.", "c": "Conejo, Cerdo."},
      "Mono": {"p": isZh ? "幽默且聪明" : "Divertido e inteligente.", "c": "Rata, Dragón."},
      "Gallo": {"p": isZh ? "自豪且准时" : "Orgulloso y puntual.", "c": "Buey, Serpiente."},
      "Perro": {"p": isZh ? "忠诚且诚实" : "Leal y honesto.", "c": "Caballo, Tigre."},
      "Cerdo": {"p": isZh ? "勤奋且慷慨" : "Diligente y generoso.", "c": "Conejo, Cabra."},
    };

    if (tipo == "vibracion") {
      return isZh
          ? "振动是你今天的能量调谐水平。它是根据你的名字和日期计算的。"
          : "La vibración es tu nivel de sintonía energética hoy. Se calcula uniendo tu energía personal con la del universo.";
    }

    if (tipo == "zodiaco" && infoZodiaco.containsKey(valor)) {
      return isZh
          ? "黄道十二宫 ($valor):\n• $pLabel: ${infoZodiaco[valor]!['p']}\n• $cLabel: ${infoZodiaco[valor]!['c']}"
          : "Zodíaco ($valor):\n• $pLabel: ${infoZodiaco[valor]!['p']}\n• $cLabel: ${infoZodiaco[valor]!['c']}";
    }

    if (tipo == "chino" && infoChino.containsKey(valor)) {
      return isZh
          ? "生肖 ($valor):\n• $pLabel: ${infoChino[valor]!['p']}\n• $cLabel: ${infoChino[valor]!['c']}"
          : "Horóscopo Chino ($valor):\n• $pLabel: ${infoChino[valor]!['p']}\n• $cLabel: ${infoChino[valor]!['c']}";
    }

    return isZh ? "暂无神秘信息。" : "Información mística no disponible por el momento.";
  }
}