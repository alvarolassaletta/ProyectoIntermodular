import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_intermodular/components/gradient_background.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import  '../services/auth_service.dart'; 
import './login_screen.dart';
import './signup_screen.dart'; 


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
 
  //instancia del servicio de autentificacion 
  final _authService = AuthService();

  @override
  void initState(){
    super.initState();
    _checkSession();
  }

  ///Comprueba si existe una sesión abierta. 
  ///Si existe se navega HomeScreen. En caso contrario, redirige a LoginScreen
  ///
  Future <void> _checkSession() async{
    //pausa para que initState termine y flutter puede ejecutar el metodo build
    await Future.delayed(const Duration(seconds: 2)); 

    //Si durante la pausa  la app se cierra , la función se detiene
    if(!mounted) return; 

    final user = _authService.currentUser;

    if(user != null){
      context.go('/home');
    } else{
      context.go('/login');
    }
  }

  //-----------------------------------------------------
  // CARGA INICIAL
  //-----------------------------------------------------
  // Mientras se comprueba la sesión, se muestra una pantalla de carga con un fondo degradado y un indicador circular
  // si hay sesión abierta, navega a HomeScreen, si no, navega a LoginScreen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:GradientBackground(
        child: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 4.0,
          )
        ),
      ) 
    );
  }
}