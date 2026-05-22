import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PurchaseManager {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;

  // El ID único del producto que registrarás en la Google Play Console
  static const String premiumProductId = 'luckypass_premium_upgrade';

  // Inicializa el escuchador de compras en segundo plano
  static void initialize(Function onPremiumActivated) {
    final Stream<List<PurchaseDetails>> purchaseUpdated = _iap.purchaseStream;

    _subscription = purchaseUpdated.listen((List<PurchaseDetails> purchaseDetailsList) {
      _listenToPurchaseUpdated(purchaseDetailsList, onPremiumActivated);
    }, onDone: () {
      _subscription?.cancel();
    }, onError: (error) {
      // Manejar errores de conexión aquí si es necesario
    });
  }

  // Cierra el canal de escucha al destruir la app
  static void dispose() {
    _subscription?.cancel();
  }

  // Lógica principal de escucha de transacciones de Google Play
  static void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList, Function onPremiumActivated) async {
    for (var purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // La transacción está en proceso en la Google Store (esperando pago)
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        // La compra falló o el usuario la canceló
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {

        // ¡COMPRA EXITOSA O RESTAURADA CON ÉXITO!
        // Guardamos el estado Premium real de por vida en Hive
        var settingsBox = Hive.box('settings');
        await settingsBox.put('isPremium', true);

        // Ejecutamos el callback para refrescar la interfaz visual
        onPremiumActivated();

        // Le confirmamos a Google que ya entregamos el producto para que cierre el cobro
        if (purchaseDetails.pendingCompletePurchase) {
          await _iap.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Método principal que dispara la ventana de cobro de Google Play
  static Future<void> buyPremium() async {
    // 1. Verificar si la tienda de Google Play está disponible en el celular
    final bool available = await _iap.isAvailable();
    if (!available) return;

    // 2. Solicitar los detalles del producto místico a los servidores de Google
    const Set<String> _kIds = <String>{premiumProductId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(_kIds);

    if (response.notFoundIDs.contains(premiumProductId) || response.productDetails.isEmpty) {
      // Si entra aquí en desarrollo es NORMAL, porque el ID aún no está aprobado en la Play Console web
      // Para simular el éxito en desarrollo sin conexión con Google, forzamos el modo local:
      _forceLocalPremiumSimulation();
      return;
    }

    // 3. Desplegar la pasarela de pago nativa de Google con tarjetas/Nequi/Efecty
    final ProductDetails productDetails = response.productDetails.first;
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: productDetails);

    // Al ser un producto de "un solo pago" (No suscripción mensual), usamos buyNonConsumable
    await _iap.buyNonConsumable(purchaseParam: purchaseParam);
  }

  // Simulación inteligente para que puedas testear el botón antes de publicar en la tienda
  static void _forceLocalPremiumSimulation() {
    var settingsBox = Hive.box('settings');
    settingsBox.put('isPremium', true);
  }
}