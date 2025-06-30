import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import '../models/wifi_state.dart';
import '../services/wifi_service.dart';
import '../utils/permission_handler.dart';
import '../widgets/wifi_network_tile.dart';
import '../widgets/wifi_state_widgets.dart';

class TelaRedesWifi extends StatefulWidget {
  @override
  _TelaRedesWifiState createState() => _TelaRedesWifiState();
}

class _TelaRedesWifiState extends State<TelaRedesWifi> {
  // Instância do serviço WiFi
  final _wifiService = WifiService();
  
  // Estado do WiFi
  late WifiState _wifiState;

  @override
  void initState() {
    super.initState();
    _wifiState = WifiState();
    _verificarPermissoes();
  }

  Future<void> _verificarPermissoes() async {
    // Atualizar estado para mostrar que estamos verificando permissões
    setState(() {
      _wifiState = _wifiState.copyWith(isScanning: true);
    });
    
    // Solicitar permissões de localização (necessárias para escanear WiFi no Android)
    final permissoesConcedidas = await PermissionsUtil.solicitarPermissoesWiFi(context);
    
    // Verificar se ainda estamos na tela
    if (!mounted) return;
    
    if (!permissoesConcedidas) {
      setState(() {
        _wifiState = _wifiState.copyWith(
          hasPermission: false,
          isScanning: false,
          errorMessage: 'É necessário conceder permissões de localização para escanear redes Wi-Fi.',
        );
      });
      return;
    }
    
    // Verificar se o WiFiScan está disponível no dispositivo
    final canScan = await _wifiService.verificarDisponibilidade();
    
    // Verificar se ainda estamos na tela
    if (!mounted) return;
    
    if (!canScan) {
      setState(() {
        _wifiState = _wifiState.copyWith(
          hasPermission: false,
          isScanning: false,
          errorMessage: 'Não foi possível iniciar o scanner Wi-Fi. Verifique se o Wi-Fi está ativado.',
        );
      });
      return;
    }

    // Verificar permissões para escanear redes Wi-Fi
    final hasPermission = await _wifiService.verificarPermissoes();
    
    // Verificar se ainda estamos na tela
    if (!mounted) return;
    
    if (!hasPermission) {
      setState(() {
        _wifiState = _wifiState.copyWith(
          hasPermission: false,
          isScanning: false,
          errorMessage: 'Permissão para escanear redes Wi-Fi negada. Por favor, conceda as permissões necessárias nas configurações do aplicativo.',
        );
      });
      return;
    }

    setState(() {
      _wifiState = _wifiState.copyWith(
        hasPermission: true,
        isScanning: false,
      );
    });
    
    // Iniciar o scan inicial
    _scanearRedes();
  }

  Future<void> _scanearRedes() async {
    setState(() {
      _wifiState = _wifiState.copyWith(
        isScanning: true,
        errorMessage: '', // Limpar mensagens de erro anteriores
      );
    });
    
    try {
      // Iniciar o escaneamento
      final resultado = await _wifiService.iniciarScan();
      if (resultado != true) {
        setState(() {
          _wifiState = _wifiState.copyWith(
            errorMessage: 'Erro ao iniciar escaneamento. Verifique as permissões do aplicativo.',
            isScanning: false,
          );
        });
        return;
      }
      
      // Aguardar um pouco para que o sistema tenha tempo de escanear
      // Alguns dispositivos precisam deste delay
      await Future.delayed(Duration(seconds: 2));
      
      // Obter resultados do scan
      final resultados = await _wifiService.obterRedesEscaneadas();
      
      // Verificar se ainda estamos na tela antes de atualizar o estado
      if (!mounted) return;
      
      setState(() {
        if (resultados.isEmpty) {
          _wifiState = _wifiState.copyWith(
            redes: resultados,
            isScanning: false,
            errorMessage: 'Nenhuma rede encontrada. Verifique se o Wi-Fi está ativado.',
          );
        } else {
          _wifiState = _wifiState.copyWith(
            redes: resultados,
            isScanning: false,
            errorMessage: '',
          );
        }
      });
    } catch (e) {
      // Verificar se ainda estamos na tela antes de atualizar o estado
      if (!mounted) return;
      
      setState(() {
        _wifiState = _wifiState.copyWith(
          errorMessage: 'Erro ao escanear redes: $e',
          isScanning: false,
        );
      });
    }
  }

  void _onNetworkSelected(String ssid) {
    print('Você escolheu: $ssid');
    // Retorna o SSID da rede para a tela anterior
    Navigator.pop(context, ssid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Redes Wi-Fi', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _wifiState.isScanning ? null : _scanearRedes,
            tooltip: 'Atualizar redes',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    // Se estiver carregando
    if (_wifiState.isScanning) {
      return LoadingIndicator();
    }
    
    // Se tiver erro de permissão
    if (!_wifiState.hasPermission) {
      return ErrorDisplay(
        errorMessage: _wifiState.errorMessage,
        onRetry: _verificarPermissoes,
      );
    }
    
    // Se não tiver redes encontradas
    if (_wifiState.redes.isEmpty) {
      return EmptyNetworksList(
        errorMessage: _wifiState.errorMessage,
        onRetry: _scanearRedes,
      );
    }
    
    // Lista de redes encontradas
    return ListView.builder(
      itemCount: _wifiState.redes.length,
      itemBuilder: (context, index) {
        return WifiNetworkTile(
          rede: _wifiState.redes[index],
          onNetworkSelected: _onNetworkSelected,
        );
      },
    );
  }
}
