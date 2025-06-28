import 'package:flutter/material.dart';

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
