import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/supabase_config.dart';

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
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
