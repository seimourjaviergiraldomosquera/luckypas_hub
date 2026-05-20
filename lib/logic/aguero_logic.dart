class AgueroLogic {
  static final Map<String, String> _diccionarioSuenos = {
    "perro": "06",
    "gato": "05",
    "agua": "01",
    "muerto": "47",
    "dinero": "10",
    "serpiente": "21",
    "boda": "40",
    "sangre": "14",
    "fuego": "08",
    "bebe": "22",
    "dientes": "33",
    "raton": "11",
    "lluvia": "39",
    "oro": "50",
    "diablo": "66",
    "embarazo": "17",
  };

  // LISTA ACTUALIZADA: Agüeros Famosos y Datos de Colombia
  static final List<Map<String, String>> aguerosFamosos = [
    {"titulo": "Diomedes (Nacimiento)", "numero": "2605"},
    {"titulo": "Diomedes (Muerte)", "numero": "2212"},
    {"titulo": "Juancho Rois", "numero": "0421"},
    {"titulo": "Virgen del Carmen", "numero": "1607"},
    {"titulo": "El Número del Papa", "numero": "1303"},
    {"titulo": "El Chavo del 8", "numero": "0808"},
    {"titulo": "La Mariposa Blanca", "numero": "0214"},
    {"titulo": "Billete Encontrado", "numero": "5588"},
  ];

  // VALIDACIÓN DE PLACA (Carro: AAA123, Moto: AAA123A)
  static bool esPlacaValida(String texto) {
    final limpia = texto.toUpperCase().replaceAll(' ', '');
    // Formato: 3 letras seguidas de 3 números o 3 letras, 2 números y 1 letra
    final regExp = RegExp(r'^[A-Z]{3}[0-9]{2}[0-9A-Z]$');
    final regExpTradicional = RegExp(r'^[A-Z]{3}[0-9]{3}$');
    return regExp.hasMatch(limpia) || regExpTradicional.hasMatch(limpia);
  }

  // VALIDACIÓN DE FECHA (Mínimo 4 dígitos para procesar un año o día/mes)
  static bool esFechaValida(String texto) {
    final numeros = texto.replaceAll(RegExp(r'[^0-9]'), '');
    return numeros.length >= 4;
  }

  static String obtenerNumeroPorSueno(String texto) {
    String normalizado = texto.toLowerCase();
    String base = "00";

    bool encontrado = false;
    for (var entrada in _diccionarioSuenos.entries) {
      if (normalizado.contains(entrada.key)) {
        base = entrada.value;
        encontrado = true;
        break;
      }
    }

    if (!encontrado) {
      base = (texto.length * 7 % 100).toString().padLeft(2, '0');
    }

    String relleno = (DateTime.now().millisecond % 100).toString().padLeft(2, '0');
    return "$base$relleno";
  }

  static String obtenerNumeroPorPlaca(String placa) {
    String limpia = placa.replaceAll(RegExp(r'[^A-Z0-9]'), '').toUpperCase();
    String numeros = placa.replaceAll(RegExp(r'[^0-9]'), '');

    if (numeros.length >= 4) return numeros.substring(0, 4);
    if (numeros.length == 3) return "${numeros}0";

    int valor = 0;
    for (int i = 0; i < limpia.length; i++) {
      valor += limpia.codeUnitAt(i);
    }
    return (valor * 13 % 10000).toString().padLeft(4, '0');
  }

  // NUEVA LÓGICA PARA PROCESAR FECHAS
  static String obtenerNumeroPorFecha(String fecha) {
    String numeros = fecha.replaceAll(RegExp(r'[^0-9]'), '');
    if (numeros.length >= 4) {
      return numeros.substring(numeros.length - 4); // Toma los últimos 4 (ej. el año)
    }
    return "0000";
  }
}