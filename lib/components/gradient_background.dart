import 'package:flutter/material.dart';

/// Contenedor personalizado  
/// actáa como fondo para las screens 
/// 
class GradientBackground extends StatelessWidget {
  final Widget child; 
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height:double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin:Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:[
            Color(0xFFDAD5D0), // Naranja superior
            Color(0xFF17DB93), // Caqui central
            Color(0xFF00D3CC), // Naranja inferior
            ]
          )
      ),
      child: child,
    );
  }
}