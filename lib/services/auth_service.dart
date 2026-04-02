import 'package:proyecto_intermodular/supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService{
  final  _supabase = SupabaseConfig.client; 

  ///REGISTRAR USUARIO - SIGN UP 
  ///Método para registrar un usuario  con  email y contraseña  usando el método auth.signUp
  ///Supabase envía un correo de confirmación  que el usuario debe verificar 
  ///Devuelve un Objeto AuthResponse que usaremos para obtener información del usuario y de la sesion
  ///Usamos la propiedad data para pasar  nombre de usuario y nombre completo.
  ///Cunado se activa este método, se activara un trigger  que llamará a un método para hacer la inserción del usuario en la tabla profiles
  Future <AuthResponse> signUp({
     required String email,
     required String password, 
     required String userName,
     required String fullName}) async {

      try{
        return await _supabase.auth.signUp(
          email:email,
          password: password,
          data: {
            'user_name': userName,
            'full_name': fullName,
          }
        );
      } on AuthException catch(_){
        ///relanza la misma excepcion  que fue capturada sin crear una nueva
        rethrow; 
      } catch(e){
        throw Exception('Error inesperado al registrarse.');
      }
  }
  
  ///  INICIAR SESION - SIGN IN 
  ///Método para que  un usuario existente en la tabla  interna de supabase auth.users inicie sesion  con email y contraseña utilizando  auth.signInWithPassword
  
  Future <AuthResponse> signIn({required String email, required  String password}) async {
    try{
      return await  _supabase.auth.signInWithPassword(email: email, password: password); 
    } on AuthException catch(_){
        //rethow necesario para que se devuelva la AuthExcepcion
        rethrow; 
    } catch(e){
      throw Exception('Error inesperado al iniciar sesion. Inténtelo de nuevo');
    } 
  }

  //CERRAR SESIÓN - SIGN OUT 
  //Cierra la sesión del usuario , si  tiene una sesión abierta 
  //requiere que el usuario  haya iniciado previamente sesión 
  Future <void>  signOut () async {
    try{
      return await  _supabase.auth.signOut();
    } on AuthException catch(_){
      //rethow necesario para que se devuelva la AuthExcepcion
      rethrow;
    } catch(e){
      throw Exception('Error inesperado al cerrar sesión.   Inténtelo de nuevo');
    }
  }

  //getter  para objener el usuario actual 
  //devuelve el user que ha iniciado sesión o null si no hay usuario loggeado
  User? get currentUser =>  _supabase.auth.currentUser;

  
  //https://supabase.com/docs/reference/dart/auth-onauthstatechange
  //Getter para el stream de eventos authState cada vez que cambia el estado  de auth
  // inicio de sesion, cierre de sesión, etc
  Stream <AuthState>  get authStateChanges => _supabase.auth.onAuthStateChange;

  /// Solicita a supabase que mande el correo electronico de recuperacion con un codigo  de 6 digitos.
  Future<void> sendEmailOTPCode (String email) async{
    try{
      await _supabase.auth.resetPasswordForEmail(email);
    }catch(e){
      
      //Lanza la excepcion para que se atrape en la pantalla para que  se pueda mostrar el SnackBar
      rethrow;
    }
  }
  /// https://supabase.com/docs/reference/dart/auth-verifyotp
  /// Verifica el codigo OTP tecleado pro el usuario
  /// VerifyOTP crea  una sesión temporal validada
  Future<bool> verifyRecoveryOTP ({required String email, required String token}) async{
    try{
      final response = await _supabase.auth.verifyOTP(
        //indica que el código es para recuperar contraseña 
        type: OtpType.recovery,
        email: email,
        token:token,
      );
      return response.session !=null;

    }catch(e){
      return false; 
    }
  }

  ///https://supabase.com/docs/reference/dart/auth-updateuser
  ///Actualiza la contraseña del usuario autentificado temporalmente
  /// Se puede usar updateUser porque VerifyOTP  ha creado  una sesión temporal validada. Si no updateUser no se podria usar porque esta pensado para ser usaoa por un usuario autenficado
  Future <void> updatePassword(String newPassword) async{
    try{
      await _supabase.auth.updateUser(
        UserAttributes(
          password: newPassword
        )
      );
    }catch(e){
      rethrow; 
    }
  }
}