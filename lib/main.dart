import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/screens/splash_screen.dart';
import 'package:proyecto_intermodular/supabase_config.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';
import './routes/app_router.dart';
//necesaria para configuraciones del calendario  en summary_screen
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async  {
  
  WidgetsFlutterBinding.ensureInitialized();
  // Inicializa Supabase antes de ejecutar la app
  // init es el metodo que definimos en SupabaseConfig para configurar la conexión
  await SupabaseConfig.init();

  runApp(const MainApp());
}


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return  MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Aplicación de Fichajes',
      routerConfig: appRouter,
      scaffoldMessengerKey: scaffoldMessengerKey,
      // delegates que usa Flutter  para traducir los widgets  y controlar la dirección de texto flutter 
      localizationsDelegates:  const[
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      //indica los idiomas sopordados por la app
      supportedLocales: const[
        Locale('es','ES')
      ]
    );
  }
}
