import '../models/profiles.dart'; 
import '../supabase_config.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ProfileService{

  ///recuperamos el cliente de SupabaseConfig 
   final SupabaseClient _supabase = SupabaseConfig.client; 

   /// SELECT 
   ///Busca el profiles por el id . Si lo encuentra devuelve un objeto Profile. Si no lo encuentra devuelve null.

  Future <Profile?> getProfile( String id) async{
    try{
      final data =  await _supabase.from('profiles')
      .select()
      .eq('id',id)
      .maybeSingle();

      return  data != null ? Profile.fromMap(data) : null; 
    }on PostgrestException catch(e){
      throw Exception('Error al obtener el perfil: ${e.message} , codigo: ${e.code}');
    }catch(e){
      throw Exception('Error inesperado al obtener el perfil');
    }
  }
    
   
   ///SELECT ALL
   /// Método pensado para que el  usuario que sea administrador pueda ver todos los perfiles 
  
   Future <List<Profile>> getProfiles() async{
    try{
      final data =  await _supabase.from('profiles').select();
      return data.map((profileMap)=> Profile.fromMap(profileMap)).toList(); 

    } on PostgrestException catch(e){
     throw Exception('Error al obtener los perfiles: ${e.message} , codigo: ${e.code}');
    }catch(e){
      throw Exception('Error inesperado al obtener los perfiles');
    }
  }


   /// UPDATE 
   ///el id es obligatorio y el nombre de usuario y el nobmre completo seran opcionales. El usuario puede querer modifcar uno u otro o ambos. 
   /// hay que comprobar que los datos del formulario no vengan vacios o con valor null para evitar  que al hacer el update se inserte null o vacio en la fila 

  Future <void> updateProfile( {required String id, String? userName, String? fullName})async {
    ///update toma un mapa 
    final Map<String,dynamic> updates = {}; 

    ///Solo cuando el usuario haya introducido un nombre de usuario, actualizaremos el campo
    if(userName!= null &&  userName.isNotEmpty){
      updates['user_name']=userName; 
    }
    ///Solo cuando el usuario haya introducido un nombre, actualizaremos el campo
    if(fullName !=null && fullName.isNotEmpty){
      updates['full_name'] = fullName;
    }

    if(updates.isNotEmpty){
      try{
        await _supabase.from('profiles')
          .update(updates)
          .eq('id',id);
      } on PostgrestException catch(e){
         throw Exception('Error al actualizar el perfil: ${e.message} , codigo: ${e.code}');
      }catch(e){
        throw Exception('Error inesperado al actulizar el perfil');
      }
       
    }
  }


   /// INSERT -> No configuramos una consulta insert porque  la creación del perfil  se realiza 
   /// mediante una función postgres y un trigger. Cuando  ocurre el signup y se inserta un profile en la tabla interna de supabase
   /// auth.users() , se activa un trigger que llama a la función  que realiza la insercción en nuestra tabla profiles 

   /// DELETE -> No interesa que un usuario pueda borrar su perfil. De hecho, ni siquiera se ha  creado la policy en supabase 



}