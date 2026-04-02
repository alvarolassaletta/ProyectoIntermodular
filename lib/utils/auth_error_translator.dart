import 'package:supabase_flutter/supabase_flutter.dart';

class AuthErrorTranslator {

  ///Método para recibir los errores de autentifcacion  de Supabase  y  traducirlos a fin de mostrar mensajes mas accesibles  y adaptados 
  ///Recibe la exception  para  poder acceder a las distitnas propiedades  si se desea: error.message, error.statusCode
  /// Documentacion de los codes: https://supabase.com/docs/guides/auth/debugging/error-codes
static String translate(AuthException error) {
    // Pasamos el mensaje original a minúsculas para evitar fallos si Supabase 
    // cambia las mayúsculas en el futuro.
    final code = error.code ?? ''; 
    final message = error.message.toLowerCase();

    return switch (code) {
      // LOGIN
    'invalid_credentials'     => 'El email o la contraseña son incorrectos.',
    'email_not_confirmed'     => 'Debes confirmar tu email antes de iniciar sesión. Revisa tu correo.',
    'user_banned'             => 'Esta cuenta ha sido desactivada.',

    // REGISTRO
    'email_exists'            => 'Ya existe una cuenta registrada con este correo.',
    'weak_password'           => 'La contraseña es demasiado débil. Usa al menos 8 caracteres.',
    'signup_disabled'         => 'El registro de nuevos usuarios no está disponible en este momento.',

    // CAMBIO DE CONTRASEÑA
    'same_password'           => 'La nueva contraseña debe ser diferente a la actual.',

    // SESIÓN
    'session_expired'         => 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.',
    'session_not_found'       => 'Tu sesión ha expirado. Por favor, vuelve a iniciar sesión.',

    // OTP
    'otp_expired'             => 'El código de verificación ha caducado. Solicita uno nuevo.',

    // RATE LIMIT
    'over_request_rate_limit' => 'Demasiados intentos. Espera unos minutos antes de volver a intentarlo.',
    'over_email_send_rate_limit' => 'Demasiados emails enviados. Espera unos minutos.',

    // SERVIDOR
    'unexpected_failure'      => 'Ha ocurrido un error inesperado. Inténtalo más tarde.',
    'request_timeout'         => 'La solicitud tardó demasiado. Comprueba tu conexión e inténtalo de nuevo.',

    // FALLBACK por mensaje (para errores sin code)
    _ when message.contains('email not confirmed') =>
        'Debes confirmar tu email antes de iniciar sesión. Revisa tu correo.',

    // DEFAULT
    _ => 'Error de autenticación: ${error.message}',


    
    };
  }
}

