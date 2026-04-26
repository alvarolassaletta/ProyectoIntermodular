
import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';

/// Creo esta clase para  no tener métodos  en cada clase para mostrar un SnackBar si el login o el signUp falla 
/// Se necesita una GLobal Key  de MaterialApp  scaffoldMessengerKey  que actua como puente para acceder al context raiz 
/// Permite acceder al tamaño de la pantalla  y  pintar los SnackBar en cada pantalla 
/// a MaterialApp router se le pasa una propiedad scaffoldMessangerKey con esta GlobalKey


 final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =  GlobalKey <ScaffoldMessengerState>(); 

class SnackBarMessenger {

  /// utliza la clave global mostrar un SnakcBar indicado el fallo de la operación 
  static void showError(String message){
   //oculta SnackBar anteriores para que no se acumulen 
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

    //calculo de las dimensiones responsive 
    final context = scaffoldMessengerKey.currentContext;
    //width y height sí son double 
    double? snackWidth;
    //margin  y padding son de  tipo EdgeInsetsGeometry o EdgeInsets 
    EdgeInsetsGeometry? snackMargin; 

    if (context != null) {
      //obtiene el width de la pantalla 
      final screenWidth = MediaQuery.of(context).size.width;
      //600 es el breakpoint de homeScreen 
      if (screenWidth >= 600) {
        //si hay usuario autentificado, la pantalla es HomeScreen y hay un barra de navegacion a la izquierda
        final bool hasSideBar = AuthService().currentUser !=null;
        final double railWidth = hasSideBar? 120.0 : 0.0;
        final double availableWidth = screenWidth - railWidth;
        final double sideMargin = (availableWidth-400) /2;
        snackMargin =EdgeInsets.only(
          left: railWidth + sideMargin,
          right:sideMargin,
          bottom:24,
        );
        snackWidth = null;
      } else {
        snackMargin = const EdgeInsets.only(left: 46, right: 46, bottom: 46); 
        snackWidth = null;
      }
    } else {
      //si falla , se usa el diseño movil 
      snackMargin = const EdgeInsets.only(left: 46, right: 46, bottom: 46); 
      snackWidth = null;
    }
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content:  Text(
          message, 
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade400,
        width: snackWidth,
        margin:snackMargin,
        behavior: SnackBarBehavior.floating ,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      )
    );
  }
  
  /// utliza la clave global mostrar un SnakcBar  indicando el éxito de la operación 
  static void showSucces(String message){
    //oculta SnackBar anteriores para que no se acumulen 
    scaffoldMessengerKey.currentState?.hideCurrentSnackBar();

    //calculo de las dimensiones responsive 
    final context = scaffoldMessengerKey.currentContext;
    //width y height sí son double 
    double? snackWidth;
    //margin  y padding son de  tipo EdgeInsetsGeometry o EdgeInsets 
    EdgeInsetsGeometry? snackMargin; 

    if (context != null) {
      //obtiene el width de la pantalla 
      final screenWidth = MediaQuery.of(context).size.width;
      //600 es el breakpoint de homeScreen 
      if (screenWidth >= 600) {
        //si hay usuario autentificado, la pantalla es HomeScreen y hay un barra de navegacion a la izquierda
        final bool hasSideBar = AuthService().currentUser !=null;
        final double railWidth = hasSideBar? 120.0 : 0.0;
        final double availableWidth = screenWidth - railWidth;
        final double sideMargin = (availableWidth-400) /2;
        snackMargin =EdgeInsets.only(
          left: railWidth + sideMargin,
          right:sideMargin,
          bottom:24,
        );
        snackWidth = null;
      } else {
         
        snackMargin = const EdgeInsets.only(left: 46, right: 46, bottom: 46); 
        snackWidth = null;
      }
    } else {
      //si falla se usa el diseño movil 
      snackMargin = const EdgeInsets.only(left: 46, right: 46, bottom: 46); 
      snackWidth = null;
    }
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content:  Text(
          message, 
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white, 
            fontWeight: FontWeight.bold,
          )
        ),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating ,
        width: snackWidth,
        margin: snackMargin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      )
    );
  
  }
}