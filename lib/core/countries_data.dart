import 'package:flutter/material.dart';

class CountriesData {
  static final Map<String, List<Map<String, dynamic>>> data = {
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
}