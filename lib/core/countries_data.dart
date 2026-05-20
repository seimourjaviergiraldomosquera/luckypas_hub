import 'package:flutter/material.dart';

class CountriesData {
  static final Map<String, List<Map<String, dynamic>>> data = {
    "Colombia": [
      // --- CHANCES DIARIOS ---
      {"name": "Chontico Día", "type": "Chance", "desc": "Gana tempranito", "icon": Icons.wb_sunny},
      {"name": "Chontico Noche", "type": "Chance", "desc": "Suerte nocturna", "icon": Icons.dark_mode},
      {"name": "Paisita Día", "type": "Chance", "desc": "Suerte antioqueña", "icon": Icons.agriculture},
      {"name": "Paisita Noche", "type": "Chance", "desc": "El favorito de todos", "icon": Icons.nightlife},
      {"name": "Sinuano Día", "type": "Chance", "desc": "Suerte caribeña", "icon": Icons.waves}, // Corregido: waves
      {"name": "Sinuano Noche", "type": "Chance", "desc": "Vibración costeña", "icon": Icons.brightness_3},
      {"name": "Caribeña Día", "type": "Chance", "desc": "Sol y fortuna", "icon": Icons.beach_access},
      {"name": "Caribeña Noche", "type": "Chance", "desc": "Luna tropical", "icon": Icons.nights_stay},
      {"name": "Dorado Mañana", "type": "Chance", "desc": "Oro matutino", "icon": Icons.light_mode},
      {"name": "Dorado Tarde", "type": "Chance", "desc": "Brillo de tarde", "icon": Icons.sunny_snowing},
      {"name": "Motilón Día", "type": "Chance", "desc": "Suerte en el norte", "icon": Icons.terrain},
      {"name": "Motilón Noche", "type": "Chance", "desc": "Energía fronteriza", "icon": Icons.landscape},
      {"name": "Cafeterito Tarde", "type": "Chance", "desc": "Aroma de triunfo", "icon": Icons.coffee},
      {"name": "Cafeterito Noche", "type": "Chance", "desc": "Esencia ganadora", "icon": Icons.coffee_maker},
      {"name": "Pijao de Oro", "type": "Chance", "desc": "Suerte del Tolima", "icon": Icons.monetization_on},
      {"name": "Super Astro Sol", "type": "Super Astro", "desc": "4 cifras + Signo", "icon": Icons.auto_awesome},
      {"name": "Super Astro Luna", "type": "Super Astro", "desc": "Suerte estelar", "icon": Icons.brightness_2},

      // --- JUEGOS MAYORES ---
      {"name": "Baloto", "type": "Baloto", "desc": "5 números + Superbolota", "icon": Icons.confirmation_number},
      {"name": "MiLoto", "type": "Chance", "desc": "5 números (1-39)", "icon": Icons.auto_graph},

      // --- LOTERÍAS POR DÍA ---
      {"name": "Lotería de Bogotá", "type": "Lotería", "desc": "Jueves de suerte", "icon": Icons.casino},
      {"name": "Lotería de Medellín", "type": "Lotería", "desc": "Viernes ganador", "icon": Icons.casino},
      {"name": "Lotería del Quindío", "type": "Lotería", "desc": "Regional (Jueves)", "icon": Icons.location_city},
      {"name": "Lotería del Valle", "type": "Lotería", "desc": "Miércoles de ganar", "icon": Icons.water_drop},
      {"name": "Lotería de Boyacá", "type": "Lotería", "desc": "Sábados de fortuna", "icon": Icons.castle}, // Corregido: castle
      {"name": "Lotería de Santander", "type": "Lotería", "desc": "Viernes millonario", "icon": Icons.account_balance},
      {"name": "Lotería del Tolima", "type": "Lotería", "desc": "Lunes de éxito", "icon": Icons.map},
      {"name": "Lotería del Huila", "type": "Lotería", "desc": "Martes de suerte", "icon": Icons.festival},
      {"name": "Lotería de Manizales", "type": "Lotería", "desc": "Miércoles místico", "icon": Icons.filter_hdr},
      {"name": "Lotería de Risaralda", "type": "Lotería", "desc": "Viernes de progreso", "icon": Icons.park},
      {"name": "Lotería del Cauca", "type": "Lotería", "desc": "Sábado de alegría", "icon": Icons.nature_people},
      {"name": "Lotería Cruz Roja", "type": "Lotería", "desc": "Martes humanitario", "icon": Icons.medical_services},

      // --- GENÉRICO ---
      {"name": "Chance Libre", "type": "Chance", "desc": "4 cifras personalizadas", "icon": Icons.casino},
    ],
    "China": [
      {"name": "Welfare Lottery", "type": "Chance", "desc": "Union Lotto (双色球)", "icon": Icons.card_giftcard},
      {"name": "Sports Lottery", "type": "Chance", "desc": "Super Lotto (大乐透)", "icon": Icons.sports_basketball},
      {"name": "Lotto 3D", "type": "Chance", "desc": "3 digits luck", "icon": Icons.looks_3},
    ],
    "USA": [
      {"name": "Powerball", "type": "Baloto", "desc": "Multi-state jackpot", "icon": Icons.star},
      {"name": "Mega Millions", "type": "Baloto", "desc": "Gigantic prizes", "icon": Icons.monetization_on},
      {"name": "Lucky for Life", "type": "Chance", "desc": "Daily winnings", "icon": Icons.today},
      {"name": "Cash4Life", "type": "Chance", "desc": "Lifetime prize", "icon": Icons.timer},
    ],
    "Brasil": [
      {"name": "Mega-Sena", "type": "Chance", "desc": "A maior do Brasil", "icon": Icons.casino},
      {"name": "Quina", "type": "Chance", "desc": "Sorte diária", "icon": Icons.looks_5},
      {"name": "Lotofácil", "type": "Chance", "desc": "Mais chances", "icon": Icons.thumb_up},
    ],
    "España": [
      {"name": "EuroMillones", "type": "Baloto", "desc": "Bote millonario", "icon": Icons.euro},
      {"name": "La Primitiva", "type": "Chance", "desc": "La clásica", "icon": Icons.history},
      {"name": "El Gordo", "type": "Lotería", "desc": "Domingos de suerte", "icon": Icons.redeem},
    ],
    "Alemania": [
      {"name": "Lotto 6aus49", "type": "Chance", "desc": "Der Klassiker", "icon": Icons.card_giftcard},
      {"name": "EuroJackpot", "type": "Baloto", "desc": "Europaweit gewinnen", "icon": Icons.language},
    ],
    "Japón": [
      {"name": "Lotto 7", "type": "Chance", "desc": "大きな夢", "icon": Icons.brightness_auto},
      {"name": "Numbers 4", "type": "Chance", "desc": "毎日チャンス", "icon": Icons.filter_4},
    ],
  };
}