import 'package:flutter/material.dart';

class TelaRedesWifi extends StatelessWidget {
  final List<String> redes = [
    'WiFi-Casa',
    'Rede Carrinho',
    'Internet-Vizinho',
    'MinhaRede5G',
    'XPTO Net',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Redes Wi-Fi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        itemCount: redes.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Icon(Icons.wifi, color: Colors.white),
            title: Text(redes[index], style: TextStyle(color: Colors.white)),
            onTap: () {
              print('Você escolheu: ${redes[index]}');
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
