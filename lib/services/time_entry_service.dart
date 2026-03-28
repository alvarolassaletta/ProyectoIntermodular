import '../supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/time_entries.dart';


class TimeEntryService{

  ///recuperamos el cliente de SupabaseConfig 
  final SupabaseClient _supabase =  SupabaseConfig.client; 

  ///  INSERT - FICHAJE ENTRADA 
  /// Solo pasamos el usuario que realiza el fichaje. El campo para el fichaje de entrada (clock_in) tiene un valor por defecto NOW() y el de salida queda en null de momento
  //en vez de hacer INSERT y SELECT del fichaje de entrada  en dos consultas separadas, se puede hacer en una 
  /// Devuelve objeto timeEntry si existe. Si no, devuelve null

  Future <TimeEntry?> clockIn(String userId) async {
    try{
      final data =  await _supabase.from('time_entries')
        .insert({'user_id':userId})
        .select()
        .maybeSingle();
      return data != null ? TimeEntry.fromMap(data) : null; 
    } on PostgrestException catch(e){
      throw Exception('Error DB: ${e.message} , codigo: ${e.code}');
    }catch(e){
      throw Exception('Error $e'); 
    }
  }

  ///UPDATE - FICHAJE SALIDA 
  ///clock_out habia quedado en null. Ahora se guarda  el fichade de salida en UTC y en un formato compatible con el tipo de dato del campo (TIMESTAMP WITH TIME ZONE)

  Future<void> clockOut(String timeEntryId) async{
    try{
      final clockOut = DateTime.now().toUtc().toIso8601String();
      await _supabase.from('time_entries')
        .update({'clock_out': clockOut})
        .eq('id',timeEntryId);

    } on PostgrestException catch(e){
      throw Exception('Error DB: ${e.message} , codigo: ${e.code}');
    }catch(e){
      throw Exception('Error $e'); 
    }
  }

  /// SELECT - COMPROBAR SI HAY FICHAJE ACTIVO
  ///Buscamos el registro en el que el campo clock_out es null
  ///Esto es, el fichaje en el que solo se ha realizado la entrada y no la salida
  ///Devuelve objeto TimeEntry si existe. Si no , devulve null

  Future <TimeEntry?>  getActiveTimeEntry(String userId) async{
    try{
      final data = await _supabase.from('time_entries')
        .select()
        .eq('user_id', userId)
        .isFilter('clock_out', null)
        .maybeSingle();
      return data != null ? TimeEntry.fromMap(data) : null; 

    } on PostgrestException catch(e){
      print('Error DB: ${e.message} , codigo: ${e.code}');
      return null; 
    }catch(e){
      print('Error $e'); 
      return null; 
    }
  }

  /// SELECT ALL TIME-ENTRIES 
  /// El usuario puede ver sus registros
  /// el administrador puede ver todos los registros 
  Future <List<TimeEntry>>  getAllTimeEntries()async {
    try{
      final data = await _supabase.from('time_entries')
        .select()
        .order('created_at',ascending:false); 
      return data.map((timeEntryMap)=> TimeEntry.fromMap(timeEntryMap) ).toList(); 

    }on PostgrestException catch(e){
      print('Error DB: ${e.message} , codigo: ${e.code}');
      return []; 
    }catch(e){
      print('Error $e'); 
      return []; 
    }
  }


  /// SELECT TIME-ENTRIES DENTRO DE UN RANGO 
  /// Obtiene los fichajes dentro de un rango de fechas  ordenados del mas reciente al  más antiguo
  /// El rango concreto se elige en summary_screen 
  Future <List<TimeEntry>>  getTimeEntriesByDateRange(
    String userId, DateTime start, DateTime end
  )async {
    try{
      final data = await _supabase.from('time_entries')
        .select()
        .eq('user_id',userId)
        .gte('clock_in',start.toIso8601String())
        .lte('clock_in',end.toIso8601String())
        .order('created_at',ascending:false); 
      return data.map((timeEntryMap)=> TimeEntry.fromMap(timeEntryMap) ).toList(); 

    }on PostgrestException catch(e){
      print('Error DB al filtrar: ${e.message} , codigo: ${e.code}');
      return []; 
    }catch(e){
      print('Error al filtrar $e'); 
      return []; 
    }
  }


  /// SELECT - OBTENER ÚLTIMO FICHAJE 
  /// Devuelve el último registro donde clockOut no sea null, si existe. Si no, devuelve null
  /// Devolvera null en casos excepcionales: tabla timeEntry vacia, perdida de conexión a internet, etc
  
  Future<TimeEntry?> getLastCompletedTimeEntry(String userId) async{
    try{
       final data = await _supabase
      .from('time_entries')
      .select()
      .eq('user_id',userId)
      .not('clock_out', 'is', null)
      .order('clock_in',ascending:false)
      .limit(1)
      .maybeSingle();
      return data != null ? TimeEntry.fromMap(data) : null; 
    } on PostgrestException catch(e){
       print('Error DB: ${e.message} , codigo: ${e.code}');
       return null;
    }catch(e){
      print('Error $e'); 
      return null; 
    }
  }
  
  ///DELETE 
  ///No interesa que el usuario pueda eliminar  sus fichajes
  ///Nuevamente, tampoco se ha creado una politica  para DELETE

}