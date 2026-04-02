import 'dart:ui';

///Clase que contiene los colores usados en la aplicación.
class AppColors{

  //  FILLEDBUTTON FUNCINALIDAD FICHAR 
  //color de los botones de las funcionalidades de fichaje (fichar en clock_screen, descargar historial en record_screen y seleccionar rango de fechas en sumamry_screen)
  
  static const Color timeEntryBackgroundButtonColor= Color(0xCA9EEAB3);
  static const Color timeEntryForegroundButtonColor= Color(0xC8030503);

  // FILLEDBUTTON  AUTENTIFICACIÓN  Y PERFIL 
  // color de los botones de las funcionalidades de autentificacion  y el perfil (login, signup, forgotpassword Y profile screen )
  static const Color authBackgroundButtonColor= Color(0xC5170331);
  static const Color authForegroundButtonColor= Color(0xFFF9FAF7);
  
  //TextButton
  static const Color textButtonForegroundColor= Color(0xC8030503);

  //color de los iconos 
  static const Color primaryIconsColor = Color(0xC8030503);
  static const Color activeTimeEntryIcon =  Color(0xFFFF9800);
  //static const Color completedTimeEntryIcon = Color(0xD607DD07);
  static const Color completedTimeEntryIcon = Color(0xFF6C7575);
  static const Color  noEntriesIconColor = Color(0xFFE90303);
  
  //Divider 
  static const Color dividerColor = Color.fromARGB(181, 119, 119, 119);

  //Fichaje activo / completado
  static const Color activeTimeEntryColor =  Color(0xFFFF9800);
  static const Color completedTimeEntryColor = Color(0xFF6C7575);

  //Colores de fondo para component GradientBackground
  //Componen el fondo las pantallas de splash, login, signup  y  forgotpassword 
  // Se utilizan en el AppBar y en las barras de navegacion 
  static const Color gradientBackgroundStart =  Color(0xCA9EEAB3);
  static const Color gradientBackgroundMiddle = Color(0xFF17DB93);
  static const Color gradientBackgroundEnd=   Color(0xFF00D3CC);

  // Color  para el círculo de carga ( Circular progress indicator)
  static const Color circurlarProgressIndicatorColor= Color(0xFFF9FAF7);


}