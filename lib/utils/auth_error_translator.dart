import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorTranslator {

  ///Método para recibir los errores de autentifcacion  de Supabase  y  traducirlos a fin de mostrar mensajes mas accesibles  y adaptados 
  ///Recibe la exception  para  poder acceder a las distitnas propiedades  si se desea: error.message, error.statusCode
static String translate(AuthException error) {
    // Pasamos el mensaje original a minúsculas para evitar fallos si Supabase 
    // cambia las mayúsculas en el futuro.
    final message = error.message.toLowerCase();

    // 1. Error de Login: Email sin verificar
    if (message.contains('email not confirmed')) {
      return 'Debes confirmar tu email antes de iniciar sesión. Revisa tu correo.';
    } 
    // 2. Error de Login: Credenciales incorrectas
    else if (message.contains('invalid login credentials')) {
      return 'El email o la contraseña son incorrectos.';
    } 
    // 3. Error de Registro: El email ya existe
    else if (message.contains('user already registered')) {
      return 'Ya existe una cuenta registrada con este correo.';
    } 
    // 4. Error de Registro: Contraseña débil (por si se nos escapa en el frontend)
    else if (message.contains('weak_password') || message.contains('password should be')) {
      return 'La contraseña es demasiado débil.';
    }
    
    // Si Supabase lanza un error extraño que no tenemos en nuestro radar,
    // devolvemos un mensaje genérico para que la app no explote.
    return 'Error de autenticación: ${error.message}';
  }
}

