import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorTranslator {

  ///Método para recibir los errores de autentifcacion  de Supabase  y  traducirlos a fin de mostrar mensajes mas accesibles  y adaptados 
  ///Recibe la exception  para  poder acceder a las distitnas propiedades  si se desea: error.message, error.statusCode
static String translate(AuthException error) {
    // Pasamos el mensaje original a minúsculas para evitar fallos si Supabase 
    // cambia las mayúsculas en el futuro.
    final message = error.message.toLowerCase();

    return switch (message) {
      // 1. CASO LOGIN: El usuario intenta entrar pero no ha verificado el enlace de su correo.
      _ when message.contains('email not confirmed') => 
          'Debes confirmar tu email antes de iniciar sesión. Revisa tu correo.',
          
      // 2. CASO LOGIN: El correo no existe o la contraseña está mal escrita.
      _ when message.contains('invalid login') => 
          'El email o la contraseña son incorrectos.',
          
      // 3. CASO REGISTRO: El usuario intenta crear una cuenta con un correo que ya tenemos en la base de datos.
      _ when message.contains('user already registered') => 
          'Ya existe una cuenta registrada con este correo.',
          
      // 4. CASO REGISTRO: La contraseña no cumple los requisitos mínimos de seguridad de Supabase (ej. mínimo 6 caracteres).
      _ when message.contains('weak_password') => 
          'La contraseña es demasiado débil. Usa al menos 6 caracteres.',
          
      // 5. CASO CIERRE DE SESIÓN / NAVEGACIÓN: El token JWT ha caducado o la sesión ya se destruyó en el servidor.
      _ when message.contains('session_not_found') => 
          'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.',
      
      // 6. CASO POR DEFECTO: Errores imprevistos de red, caídas de servidor, o mensajes nuevos de Supabase.
      // Mostramos el error original para que el usuario pueda hacer captura de pantalla y reportarlo.
      _ => 'Error de autenticación: ${error.message}',
    };
}
}

