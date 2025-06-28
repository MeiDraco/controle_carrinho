import 'package:flutter/material.dart';
import 'package:flutter_joystick/flutter_joystick.dart';

class CustomJoystick extends StatelessWidget {
  final void Function(StickDragDetails) onChanged;

  const CustomJoystick({required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Joystick(mode: JoystickMode.all, listener: onChanged);
  }
}
