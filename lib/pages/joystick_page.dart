import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';
import 'conectar_ip_page.dart';
import 'redes_wifi_page.dart';

class JoystickPage extends StatefulWidget {
  @override
  _JoystickPageState createState() => _JoystickPageState();
}

class _JoystickPageState extends State<JoystickPage> {
  double eixoX = 0;
  double eixoY = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Eixo X/Y Textos
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'X: ${eixoX.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
                ),
                Text(
                  'Y: ${eixoY.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18),
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
                  _buildCircleButton(Icons.wifi_tethering, Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaConectarIP()),
                    );
                  }),
                  _buildCircleButton(Icons.wifi, Colors.green, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => TelaRedesWifi()),
                    );
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
