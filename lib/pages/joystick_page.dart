import 'dart:async';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import '../services/esp8266_service.dart';
import 'conectar_ip_page.dart';
import 'redes_wifi_page.dart';

class JoystickPage extends StatefulWidget {
  @override
  _JoystickPageState createState() => _JoystickPageState();
}

class _JoystickPageState extends State<JoystickPage> {
  double eixoX = 0;
  double eixoY = 0;
  
  // Serviço ESP8266
  final ESP8266Service _esp8266Service = ESP8266Service();
  
  // Estado da conexão
  String? ipConectado;
  bool enviandoComandos = false;
  bool conexaoAtiva = false;
  
  // Controlador para limitar o envio de comandos
  Timer? _commandThrottleTimer;
  static const _commandThrottleMs = 100; // Envia comando a cada 100ms para evitar sobrecarga
  
  @override
  void initState() {
    super.initState();
    _verificarConexao();
  }
  
  @override
  void dispose() {
    _commandThrottleTimer?.cancel();
    super.dispose();
  }
  
  /// Verifica se já existe uma conexão com ESP8266
  Future<void> _verificarConexao() async {
    final ip = await _esp8266Service.getIpAddress();
    if (ip != null && mounted) {
      setState(() {
        ipConectado = ip;
        conexaoAtiva = true;
      });
      
      // Exibe mensagem
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conectado ao ESP8266: $ip'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  
  /// Envia coordenadas para o ESP8266 com limitação de taxa
  void _enviarCoordenadas() {
    if (!conexaoAtiva) return;
    
    // Limita a frequência de envio para evitar sobrecarga
    if (_commandThrottleTimer?.isActive ?? false) return;
    
    setState(() {
      enviandoComandos = true;
    });
    
    // Converte valores do joystick (-1 a 1) para valores inteiros (0 a 255)
    final x = ((eixoX + 1) * 127.5).round();
    final y = ((eixoY + 1) * 127.5).round();
    
    _commandThrottleTimer = Timer(Duration(milliseconds: _commandThrottleMs), () async {
      await _esp8266Service.enviarCoordenadas(x, y);
      if (mounted) {
        setState(() {
          enviandoComandos = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Eixo X/Y Textos e Status de Conexão
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Status da conexão
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: conexaoAtiva ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        conexaoAtiva ? Icons.check_circle : Icons.error_outline,
                        color: Colors.white,
                        size: 16,
                      ),
                      SizedBox(width: 6),
                      Text(
                        conexaoAtiva 
                          ? 'Conectado: $ipConectado'
                          : 'Desconectado',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
                // Coordenadas X e Y
                Text(
                  'X: ${eixoX.toStringAsFixed(2)} → ${((eixoX + 1) * 127.5).round()}',
                  style: TextStyle(fontSize: 16),
                ),
                Text(
                  'Y: ${eixoY.toStringAsFixed(2)} → ${((eixoY + 1) * 127.5).round()}',
                  style: TextStyle(fontSize: 16),
                ),
                // Indicador de envio
                if (enviandoComandos)
                  Container(
                    margin: EdgeInsets.only(top: 6),
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Enviando...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Joystick
          Center(
            child: Joystick(
              mode: JoystickMode.all,
              listener: (details) {
                setState(() {
                  eixoX = details.x;
                  eixoY = details.y;
                });
                
                // Envia as coordenadas para o ESP8266
                _enviarCoordenadas();
              },
            ),
          ),

          // Botões
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.grey[900],
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(Icons.wifi_tethering, Colors.blue, () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaConectarIP()),
                    );
                    
                    // Se a conexão foi bem-sucedida, atualiza o estado
                    if (result == true) {
                      _verificarConexao();
                    }
                  }),
                  _buildCircleButton(Icons.wifi, Colors.green, () async {
                    final redeEscolhida = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaRedesWifi()),
                    );
                    
                    if (redeEscolhida != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Conectando à rede: $redeEscolhida...'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      // Aqui você poderia implementar a lógica de conexão à rede Wi-Fi
                    }
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton(
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(),
        padding: EdgeInsets.all(16),
        backgroundColor: color,
      ),
      child: Icon(icon, size: 28, color: Colors.white),
    );
  }
}
