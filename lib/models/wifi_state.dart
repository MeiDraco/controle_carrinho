import 'package:wifi_scan/wifi_scan.dart';

class WifiState {
  final List<WiFiAccessPoint> redes;
  final bool isScanning;
  final bool hasPermission;
  final String errorMessage;

  WifiState({
    this.redes = const [],
    this.isScanning = false,
    this.hasPermission = false,
    this.errorMessage = '',
  });

  WifiState copyWith({
    List<WiFiAccessPoint>? redes,
    bool? isScanning,
    bool? hasPermission,
    String? errorMessage,
  }) {
    return WifiState(
      redes: redes ?? this.redes,
      isScanning: isScanning ?? this.isScanning,
      hasPermission: hasPermission ?? this.hasPermission,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
