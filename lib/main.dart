import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: JoystickPage(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(scaffoldBackgroundColor: Colors.black),
    );
  }
}

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
          Positioned(
            top: 40,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'X: ${eixoX.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
                Text(
                  'Y: ${eixoY.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ],
            ),
          ),
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
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.grey[900],
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TelaConectarIP()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                      backgroundColor: Colors.blue,
                    ),
                    child: Icon(
                      Icons.wifi_tethering,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TelaRedesWifi()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      shape: CircleBorder(),
                      padding: EdgeInsets.all(16),
                      backgroundColor: Colors.green,
                    ),
                    child: Icon(Icons.wifi, size: 28, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class TelaConectarIP extends StatefulWidget {
  @override
  _TelaConectarIPState createState() => _TelaConectarIPState();
}

class _TelaConectarIPState extends State<TelaConectarIP> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ipController = TextEditingController();

  void _conectar() {
    if (_formKey.currentState!.validate()) {
      String ip = _ipController.text;
      print('Conectando ao IP: $ip');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Conectando ao IP: $ip')));
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'Conectar IP da Placa',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _ipController,
                keyboardType: TextInputType.number,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Digite o IP da placa',
                  labelStyle: TextStyle(color: Colors.white),
                  hintText: 'Exemplo: 192.168.0.100',
                  hintStyle: TextStyle(color: Colors.white54),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white70),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira um IP';
                  }
                  final ipRegex = RegExp(r'^(\d{1,3}\.){3}\d{1,3}$');
                  if (!ipRegex.hasMatch(value)) {
                    return 'IP inválido';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(onPressed: _conectar, child: Text('Conectar')),
            ],
          ),
        ),
      ),
    );
  }
}

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
