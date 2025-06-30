import 'dart:developer' as dev;
import 'package:wifi_scan/wifi_scan.dart';

class WifiService {
  /// Singleton instance
  static final WifiService _instance = WifiService._internal();
  factory WifiService() => _instance;
  WifiService._internal();

  /// Verifica se é possível iniciar o scanner de WiFi
  Future<bool> verificarDisponibilidade() async {
    try {
      final canScan = await WiFiScan.instance.canStartScan();
      dev.log('CanStartScan status: $canScan');
      
      if (canScan != CanStartScan.yes) {
        dev.log('Não é possível iniciar o scan: $canScan');
        return false;
      }
      return true;
    } catch (e) {
      dev.log('Erro ao verificar disponibilidade: $e');
      return false;
    }
  }

  /// Verifica se há permissões para obter os resultados do scan
  Future<bool> verificarPermissoes() async {
    try {
      final permissoes = await WiFiScan.instance.canGetScannedResults();
      dev.log('CanGetScannedResults status: $permissoes');
      
      if (permissoes != CanGetScannedResults.yes) {
        dev.log('Sem permissão para escanear redes: $permissoes');
        return false;
      }
      return true;
    } catch (e) {
      dev.log('Erro ao verificar permissões: $e');
      return false;
    }
  }

  /// Inicia o escaneamento de redes Wi-Fi
  Future<bool> iniciarScan() async {
    try {
      final resultado = await WiFiScan.instance.startScan();
      dev.log('Resultado do startScan: $resultado');
      return resultado;
    } catch (e) {
      dev.log('Erro ao iniciar o scan: $e');
      return false;
    }
  }

  /// Obtém os resultados do escaneamento
  Future<List<WiFiAccessPoint>> obterRedesEscaneadas() async {
    try {
      final resultados = await WiFiScan.instance.getScannedResults();
      dev.log('Redes encontradas: ${resultados.length}');
      for (var rede in resultados) {
        dev.log('Rede: ${rede.ssid}, Força: ${rede.level} dBm');
      }
      return resultados;
    } catch (e) {
      dev.log('Erro ao obter resultados do scan: $e');
      return [];
    }
  }
}
