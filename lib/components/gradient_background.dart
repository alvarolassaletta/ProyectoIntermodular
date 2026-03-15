import 'package:flutter/material.dart';
import '../core/app_colors.dart';

/// Contenedor personalizado  
/// Actúa como fondo para las pantallas Login, SignUp y Splash 
/// Tambien se utiliza en HomeScreen para AppBar, NavigationBar y NavigationRail
class GradientBackground extends StatelessWidget {
  
  static final BoxDecoration backgroundDecoration= BoxDecoration(
        gradient: const LinearGradient(
          begin:Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors:[
            AppColors.gradientBackgroundStart, 
            AppColors.gradientBackgroundMiddle, 
            AppColors.gradientBackgroundEnd, 
            ]
          ),
      );

  ///Aplica el fondo degradado y sombras en la direccion indicada.
  ///Se usara para AppBar, y en la barra de navegación NavigationRail(Desktop))
  static BoxDecoration backgroundDecorationWithShadow(Offset shadowOffset) {
    return backgroundDecoration.copyWith(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(),
          blurRadius: 12,
          spreadRadius: 0,
          offset: shadowOffset, 
        )
      ],
    );
  }

  final Widget child; 
  const GradientBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height:double.infinity,
      decoration: backgroundDecoration,
      child: child,
    );
  }
}