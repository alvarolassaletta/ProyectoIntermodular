//Importa el paquete dotenv para trabajar con varaibles de entorno 
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfig {
  // Inicializa Supabase
  
  static Future<void> init() async {
    
    //cargar el archivo con las variables de entorno 
    await  dotenv.load(fileName: '.env');

    await Supabase.initialize(
      //Usamos dotenv para acceder a las variables de entorno
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,

      // la documentación recomienda añadir estas opciones. 
      //authOptions aporta una capa de seguridad en el login  
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  // Atajo para acceder al cliente a traves de una funcion static, un  getter estático 
  // para poder acceder a Supabase.instance.client  usando SupabaseConfig.client
  static SupabaseClient get client => Supabase.instance.client;
}
