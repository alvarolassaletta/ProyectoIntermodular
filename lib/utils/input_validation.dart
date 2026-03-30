/// Clase para alojar metodos de validación de los valores introducidos por el usuario en  los  formularios
///  Incluye 
/// - email 
/// - contraseña 
/// - nombre de usuario 
/// - nombre completo 

class InputValidation{


  /// Valida que el email introducido por el usuario tenga un formato correcto.
  ///
  /// Comprueba que [value] no esté vacío y que se ajuste al patrón estándar
  /// mediante una expresión regular.
  /// 
  /// Desglose de la expresión regular:
  /// * `r` : Crea una cadena cruda (raw string) para no escapar caracteres.
  /// * `^` : Indica el inicio exacto de la cadena (no se permite nada antes).
  /// * `[\w-\.]+` : Valida el nombre de usuario (letras, números, `_`, `-` y `.`).
  /// * `@` : Exige que exista el símbolo de arroba.
  /// * `([\w-]+\.)+` : Valida el dominio (letras, números o guiones seguidos de un punto).
  /// * `[\w-]{2,10}` : Valida la extensión (entre 2 y 10 caracteres).
  /// * `$` : Indica el final exacto de la cadena (no se permite nada después).
  ///
  /// Devuelve un mensaje de error si no se cumple alguna de las reglas definidas, o `null` si supera todas las validaciones.
  
  static String? validateEmail(String? value ){
    if(value==null || value.isEmpty){
        return 'Introduce tu email';
    }

    final RegExp  emailRegExp= RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,10}$');

    if(!emailRegExp.hasMatch(value)){
      return 'Introduce un email válido ( ej: micorreo@correo.com)';
    }
    //si se superran todas las validaciones se devuelve null
    return null;
  }


  /// Valida que la contraseña introducida por el usuario sea segura.
  ///
  /// Comprueba que [value] no esté vacío y que cumpla con los requisitos 
  /// mínimos de seguridad (longitud, letras, números y símbolos) 
  /// utilizando una expresión regular con "lookaheads".
  /// 
  /// Desglose de la expresión regular:
  /// * `r` : Crea una cadena cruda (raw string) para evitar escapes accidentales.
  /// * `^` : Indica el inicio exacto de la cadena.
  /// * `(?=.*[A-Za-z])` : Escáner que exige al menos una letra (mayúscula o minúscula).
  /// * `(?=.*\d)` : Escáner que exige al menos un número.
  /// * `(?=.*[@$!%*?&#\-_+.=^~()<>/\\|,:;\[\]{}])` : Escáner que exige al menos un carácter especial.
  /// * Símbolos permitidos: `@ $ ! % * ? & # - _ + . = ^ ~ ( ) < > / \ | , ; : [ ] { }`
  /// * `[A-Za-z\d@$!%*?&#\-_+.=^~()<>/\\|,:;\[\]{}]{8,}` : La validación final; permite letras, números y los símbolos anteriores, con una longitud mínima de 8.
  /// * `$` : Indica el final exacto de la cadena.
  ///
  /// Devuelve un mensaje de error si falla alguna regla, o `null` si la contraseña se ajusta a las reglas.
  static String?  validatePassword (String? value){
    if(value==null || value.isEmpty){
        return 'Introduce tu contraseña';
    }

    final RegExp  passwordRegExp = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&#\-_+.=^~()<>/\\|,:;\[\]{}])[A-Za-z\d@$!%*?&#\-_+.=^~()<>/\\|,:;\[\]{}]{8,}$');

    if(!passwordRegExp.hasMatch(value)){
      return 'La contraseña debe tener al menos 8 caracteres, contener letra, al menos un número y un caracter especial)';
    }
    return null; 
  }


  /// Valida que el nombre de usuario tenga el formato correcto.
  ///
  /// Exige una longitud entre 3 y 25 caracteres.
  /// Solo permite letras, números y barra baja (_).
  ///
  /// Desglose:
  /// * `^` y `$` : Inicio y fin exactos.
  /// * `[a-zA-Z0-9_]` : Permite mayúsculas, minúsculas, números y guion bajo.
  /// * `{3,25}` : Exige que tenga entre 3 y 25 caracteres de longitud.
  /// Devuelve null si el nombre de usuario se ajusta a las reglas. Si no, devuelve un mensaje
  
  static String?  validateUserName(String? value){

    if(value==null || value.isEmpty){
      return 'Introduce tu nombre de usuario';
    }
    final RegExp  userNameRegExp = RegExp(r'^[a-zA-Z0-9_]{3,25}$');
    
    if(! userNameRegExp.hasMatch(value)){
      return 'El nombre de usuario debe tener entre 3 y 25 caracteres  y  solo se permite letras,numeros o _'; 
    }
    
    return null;
  }

  /// Valida que el nombre completo sea real.
  ///
  /// Solo permite letras (incluyendo acentos y la letra ñ/Ñ) y espacios.
  /// Exige una longitud entre 2 y 50 caracteres.
  ///
  /// Desglose:
  /// * `[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]` : Letras, vocales acentuadas, eñes y espacios (`\s`).
  /// Devuelve null si el nombre completo se ajsuta a las reglas. Si no, devuelve un mensaje
  
  static String? validateFullName (String? value){

    if(value==null || value.isEmpty){
      return 'Introduce tu nombre  completo';
    }

      final RegExp  fullNameRegExp  = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]{2,50}$');

    if(!fullNameRegExp.hasMatch(value)){
       return 'Introduce un nombre válido'; 
    }
    
    return null;
  }

  /// Valida que el código OTP introducido sea correcto.
  ///
  /// Exige exactamente 8 dígitos numéricos.
  ///
  /// Desglose:
  /// * `^\d{6}$` : Solo dígitos (`\d`), exactamente 8.
  ///
  /// Devuelve null si el código es válido, o un mensaje de error si no.
  static String? validateOtpCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Introduce el código de recuperación';
    }

    final RegExp otpRegExp = RegExp(r'^\d{8}$');

    if (!otpRegExp.hasMatch(value)) {
      return 'El código debe tener exactamente 6 dígitos';
    }

    return null;
  }






}








