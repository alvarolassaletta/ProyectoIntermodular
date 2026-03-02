import 'package:proyecto_intermodular/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';



class AuthService{
  final  _supabase = SupabaseConfig.client; 

  /*REGISTRAR USUARIO - SIGN UP 
  Método para registrar un usuario  con  email y contraseña  usando el método auth.signUp
  Supabase enviía un correo de confirmación  que el usuario debe verificar 
  Devulve un Oobjeto AuthResponse que usaremos para obtener información del usuario y de la sesion
  Usamos la propiedad data para pasar  nombre de usuario y nombre completo.
  Cunado se activa este método, se activara un trigger  que llamará a un método para hacer la inserción del usuario en 
  la tabla profiles*/ 
  Future <AuthResponse> signUp({
     required String email,
     required String password, 
     required String userName,
     required fullName}) async {
     return await _supabase.auth.signUp(
      email:email,
      password: password,
      data: {
        'user_name': userName,
        'full_name': fullName,
        }
      );
  }
  
  /*  INICIAR SESION - SIGN IN 
  Método para que  un usuario existente en la tabla  interna de supabase auth.users inicie sesion  con email y contraseña utilizando  auth.signInWithPassword
  */ 
  Future <AuthResponse> signIn({required String email, required  String password}) async {
     return await  _supabase.auth.signInWithPassword(email: email, password: password); 
  }

  //CERRAR SESIÓN - SIGN OUT 
  //Cierra la sesión del usuario , si  tiene una sesión abierta 
  //requiere que el usuario  haya iniciado previamente sesión 
  Future <void>  signOut () async {
    return await  _supabase.auth.signOut();
  }

  //getter  para objener el usuario actual 
  //devuelve el user que ha iniciado sesión o null si no hay usuario loggeado
  User? get currrentUser =>  _supabase.auth.currentUser;

  
  //https://supabase.com/docs/reference/dart/auth-onauthstatechange
  //Getter para el stream de eventos authState cada vez que cambia el estado  de auth
  // inicio de sesion, cierre de sesión, etc
  Stream <AuthState>  get authStateChanges => _supabase.auth.onAuthStateChange;

  //neceistaremos un aurchivo con un StreamBuilder 




}