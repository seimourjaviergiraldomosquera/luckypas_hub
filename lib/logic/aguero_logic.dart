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

  // NUEVO: Lista de Agüeros Famosos (Contenido para la nueva sección)
  static final List<Map<String, String>> aguerosFamosos = [
    {"titulo": "Diomedes (Nacimiento)", "numero": "2605"},
    {"titulo": "Diomedes (Muerte)", "numero": "2212"},
    {"titulo": "Virgen del Carmen", "numero": "1607"},
    {"titulo": "El Número del Papa", "numero": "1303"},
    {"titulo": "La Mariposa Blanca", "numero": "0214"},
    {"titulo": "Billete Encontrado", "numero": "5588"},
  ];

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
}