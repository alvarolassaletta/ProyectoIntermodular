import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
class AppTheme {

  // Clase que define el tema de la aplicación, incluyendo estilos de texto, botones y otros componentes.
  static  ThemeData get lightTheme{
    return ThemeData(
      useMaterial3: true,
      //-------------------------------------------
      // TIPOGRAFÍA 
      //-------------------------------------------
      //Si se quiere aplicar estos estilos  de textTheme a un texto específicico, hay que hacerlo expresamente en el widget usando Theme.of(context).textTheme.titleMedium, por ejemplo.
      textTheme: const TextTheme(
        //AppBar 
        headlineMedium:  TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        //Título de pantalla
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
        //TItulos secundarios 
        titleMedium: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
        //Texto normal 
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
      ),
      
      // A diferencia de textTheme, los estilos para los widgets siguientes no hace falta aplicarlos en el widget concreto, sino que se aplican automáticamente a todos los widgets del  mismo tipo. 

      //-------------------------------------------
      // ESTILOS DE FILLED BUTTON DE FUNCIONALIDADES FICHAJE
      //-------------------------------------------
      ///Este estilo se aplicara  las funcionalidades  de fichaje:  fichar en clock_screen,  descargar historial en record_screen y seleccionar rango de fechas en sumamry_screen. 
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.timeEntryBackgroundButtonColor,
          foregroundColor: AppColors.primaryIconsColor,
          elevation: 4,
          shadowColor: Colors.black.withValues(),
          shape: RoundedRectangleBorder(
            borderRadius:   BorderRadius.circular(12),
          ),
          textStyle:  const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.timeEntryForegroundButtonColor,
          )
        )    
      ),

      //-------------------------------------------
      // ESTILOS DE  TEXT BUTTON 
      //-------------------------------------------
      // Se aplica los los textButton de login_scree, signup_screen y forgotpassword_screen.
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textButtonForegroundColor,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
          )
        )
      ),

      //-------------------------------------------
      // ESTILOS DE FLOATING ACTION BUTTON 
      //-------------------------------------------
      //Se aplica a los floatingActionButton de time_entry_record_screen y summary_screen.
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.gradientBackgroundStart,
        foregroundColor: AppColors.primaryIconsColor,
        elevation: 4,

      ),


      //-------------------------------------------
      // ESTILOS DE CIRCULAR PROGRESS INDICATOR (CÍRCULO DE CARGA)
      //-------------------------------------------
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.circurlarProgressIndicatorColor,
      ),

      //-------------------------------------------
      // ESTILOS DE DIVIDER  (LINEA DIVISORIA)
      //-------------------------------------------
      dividerTheme: DividerThemeData(
        color:AppColors.dividerColor,
        thickness: 1.5,
      ),

    );
  }

  //-------------------------------------------
  // ESTILOS DE FILLED BUTTON DE FUNCIONALIDADES de AUTENTIFICACION Y PERFIL 
  //-------------------------------------------
  ///Este estilo se aplicara as los botones de funcionalidades  de autentificacion y perfil: iniciar sesion en login screen; registrarse en en signUp screen;  pedir, verificar código y cambiar contraseña en forgotpassword screen y guardar cambios en profile screen.

  static ButtonStyle get authButtonStyle {
    return FilledButton.styleFrom(
      backgroundColor: AppColors.authBackgroundButtonColor,// O el color que uses en Auth
      foregroundColor: AppColors.authForegroundButtonColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Más redondeados para Auth
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}