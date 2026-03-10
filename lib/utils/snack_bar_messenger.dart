
import 'package:flutter/material.dart';

/// Creo esta clase para  no tener mÉtodos  en cada clase para mostrar un SnackBar si el login o el signUp falla 
/// Se necesita una GLobal Key  para poder  pintar en el SnackBar en las pantallas ya que desde este archivo no hay acceso a los context de cada pantalla 
/// a MaterialApp router se le pasa una propiedad scaffoldMessangerKey con esta GlobalKey


 final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =  GlobalKey <ScaffoldMessengerState>(); 

class SnackBarMessenger {

  /// utliza la clave global mostrar un SnakcBar indicado el fallo de la operación sin usar el context de la propia pantalla
  static void showError(String message){
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content:  Text(
          message, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating ,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      )
    );
  }
  
  /// utliza la clave global mostrar un SnakcBar  indicando el éxito de la operación sin usar el context de la propia pantalla
  static void showSucces(String message){
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content:  Text(
          message, 
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating ,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      )
    );
  
  }
}