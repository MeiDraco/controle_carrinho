import 'dart:developer' as dev;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ESP8266Service {
  /// Singleton instance
  static final ESP8266Service _instance = ESP8266Service._internal();
  factory ESP8266Service() => _instance;
  ESP8266Service._internal();

  static const String _ipKey = 'esp8266_ip';
  String? _ipAddress;

  /// Obtém o endereço IP salvo ou retorna null se não estiver configurado
  Future<String?> getIpAddress() async {
    if (_ipAddress != null) {
      return _ipAddress;
    }

    final prefs = await SharedPreferences.getInstance();
    _ipAddress = prefs.getString(_ipKey);
    return _ipAddress;
  }

  /// Salva o endereço IP nas preferências
  Future<bool> saveIpAddress(String ipAddress) async {
    // Validação simples de formato IP
    if (!_isValidIpAddress(ipAddress)) {
      dev.log('Endereço IP inválido: $ipAddress');
      return false;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ipKey, ipAddress);
    _ipAddress = ipAddress;
    dev.log('Endereço IP salvo: $ipAddress');
    return true;
  }

  /// Verifica se o endereço IP é válido
  bool _isValidIpAddress(String ip) {
    // Validação básica para formato de IP
    final RegExp ipRegex = RegExp(
      r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$',
    );
    return ipRegex.hasMatch(ip);
  }

  /// Envia coordenadas para o ESP8266
  Future<bool> enviarCoordenadas(int x, int y) async {
    final ip = await getIpAddress();
    if (ip == null) {
      dev.log('Endereço IP não configurado');
      return false;
    }

    try {
      final url = Uri.parse('http://$ip/posicao');
      final body = '$x,$y'; // formato texto simples conforme requisito
      dev.log('Enviando coordenadas: $body para $url');

      final response = await http.post(url, body: body)
          .timeout(const Duration(seconds: 3)); // Timeout para evitar bloqueios longos

      if (response.statusCode == 200) {
        dev.log('Comando enviado com sucesso');
        return true;
      } else {
        dev.log('Erro no envio: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      dev.log('Erro ao enviar coordenadas: $e');
      return false;
    }
  }

  /// Testa a conexão com o ESP8266
  Future<bool> testarConexao(String ipAddress) async {
    try {
      final url = Uri.parse('http://$ipAddress');
      dev.log('Testando conexão com: $url');

      final response = await http.get(url)
          .timeout(const Duration(seconds: 3));

      return response.statusCode == 200;
    } catch (e) {
      dev.log('Erro ao testar conexão: $e');
      return false;
    }
  }
}
