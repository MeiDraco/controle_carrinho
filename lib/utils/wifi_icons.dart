import 'package:flutter/material.dart';

class WifiIcons {
  /// Retorna o ícone apropriado com base na intensidade do sinal
  static IconData getSignalIcon(int level) {
    // Valores aproximados para níveis de sinal Wi-Fi
    if (level >= -50) {
      return Icons.signal_wifi_4_bar;
    } else if (level >= -60) {
      return Icons.network_wifi;
    } else if (level >= -70) {
      return Icons.signal_wifi_0_bar;
    } else {
      return Icons.signal_wifi_bad;
    }
  }

  /// Determina se a rede está protegida com senha
  static bool isSecured(String capabilities) {
    return capabilities.contains("WPA") || capabilities.contains("WEP");
  }
}
