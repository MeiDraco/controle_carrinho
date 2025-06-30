import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionsUtil {
  /// Solicita as permissões necessárias para o escaneamento de redes Wi-Fi
  static Future<bool> solicitarPermissoesWiFi(BuildContext context) async {
    dev.log('Solicitando permissões de localização para Wi-Fi');
    
    // Android 10+ requer permissões de localização para escanear redes Wi-Fi
    final statusFine = await Permission.locationWhenInUse.status;
    final statusCoarse = await Permission.location.status;
    
    dev.log('Status permissão de localização precisa: $statusFine');
    dev.log('Status permissão de localização aproximada: $statusCoarse');
    
    if (statusFine.isDenied || statusCoarse.isDenied) {
      dev.log('Solicitando permissão de localização');
      
      // Solicita permissões
      final result = await [
        Permission.locationWhenInUse,
        Permission.location,
      ].request();
      
      dev.log('Resultado da solicitação: $result');
      
      // Se o usuário recusou alguma permissão, mostra um diálogo explicativo
      if (result[Permission.locationWhenInUse] == PermissionStatus.denied || 
          result[Permission.location] == PermissionStatus.denied) {
        
        // Verifica se o context está disponível antes de mostrar o diálogo
        if (context.mounted) {
          _mostrarDialogoPermissao(context);
        }
        return false;
      }
      
      return result[Permission.locationWhenInUse] == PermissionStatus.granted || 
             result[Permission.location] == PermissionStatus.granted;
    }
    
    return statusFine.isGranted || statusCoarse.isGranted;
  }
  
  /// Mostra um diálogo explicando por que a permissão é necessária
  static Future<void> _mostrarDialogoPermissao(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: Text(
            'Permissão necessária',
            style: TextStyle(color: Colors.white),
          ),
          content: Text(
            'Para escanear redes Wi-Fi, é necessário permitir o acesso à localização do dispositivo. Sem essa permissão, não é possível encontrar redes Wi-Fi disponíveis.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Configurações', style: TextStyle(color: Colors.blue)),
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
            ),
          ],
        );
      },
    );
  }
}
