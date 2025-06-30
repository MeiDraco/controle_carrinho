import 'package:flutter/material.dart';
import '../services/esp8266_service.dart';

class TelaConectarIP extends StatefulWidget {
  @override
  _TelaConectarIPState createState() => _TelaConectarIPState();
}

class _TelaConectarIPState extends State<TelaConectarIP> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ipController = TextEditingController();
  final ESP8266Service _esp8266Service = ESP8266Service();
  bool _isTesting = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void initState() {
    super.initState();
    _carregarIpSalvo();
  }

  Future<void> _carregarIpSalvo() async {
    final ip = await _esp8266Service.getIpAddress();
    if (ip != null && mounted) {
      setState(() {
        _ipController.text = ip;
      });
    }
  }

  Future<void> _conectar() async {
    if (_formKey.currentState!.validate()) {
      final ip = _ipController.text;
      
      setState(() {
        _isTesting = true;
        _statusMessage = "Testando conexão...";
        _isSuccess = false;
      });
      
      // Testa a conexão com o ESP8266
      final success = await _esp8266Service.testarConexao(ip);
      
      if (!mounted) return;
      
      if (success) {
        // Salva o IP se a conexão for bem-sucedida
        await _esp8266Service.saveIpAddress(ip);
        setState(() {
          _statusMessage = "Conexão estabelecida com sucesso!";
          _isSuccess = true;
          _isTesting = false;
        });
        
        // Feedback visual e navegação
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Conectado ao ESP8266: $ip'))
        );
        
        // Aguarda um momento antes de retornar para a tela anterior
        Future.delayed(Duration(seconds: 1), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
      } else {
        setState(() {
          _statusMessage = "Falha ao conectar. Verifique o IP e se o ESP8266 está ligado.";
          _isSuccess = false;
          _isTesting = false;
        });
      }
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
              
              // Status da conexão
              if (_statusMessage != null)
                Container(
                  margin: EdgeInsets.only(bottom: 20),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isSuccess ? Colors.green[900] : Colors.red[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isSuccess ? Icons.check_circle : Icons.error_outline, 
                        color: Colors.white,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusMessage!,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                
              ElevatedButton(
                onPressed: _isTesting ? null : _conectar,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  minimumSize: Size(double.infinity, 50),
                ),
                child: _isTesting
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text('Conectando...'),
                        ],
                      )
                    : Text('Conectar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
