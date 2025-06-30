import 'package:flutter/material.dart';
import 'package:wifi_scan/wifi_scan.dart';
import '../utils/wifi_icons.dart';

class WifiNetworkTile extends StatelessWidget {
  final WiFiAccessPoint rede;
  final Function(String) onNetworkSelected;

  const WifiNetworkTile({
    Key? key,
    required this.rede,
    required this.onNetworkSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final signalIcon = WifiIcons.getSignalIcon(rede.level);
    final isSecured = WifiIcons.isSecured(rede.capabilities);
    
    return ListTile(
      leading: Icon(signalIcon, color: Colors.white),
      title: Text(
        rede.ssid.isNotEmpty ? rede.ssid : 'Rede sem nome',
        style: TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        'Força: ${rede.level} dBm',
        style: TextStyle(color: Colors.white70),
      ),
      trailing: isSecured
        ? Icon(Icons.lock, color: Colors.white70, size: 16)
        : Icon(Icons.lock_open, color: Colors.white70, size: 16),
      onTap: () => onNetworkSelected(rede.ssid),
    );
  }
}
