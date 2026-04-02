import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/components/custom_text_form_field.dart';
import 'package:proyecto_intermodular/core/app_theme.dart';
import 'package:proyecto_intermodular/models/profiles.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/services/profile_service.dart';
import 'package:proyecto_intermodular/utils/input_validation.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}


class _ProfileScreenState extends State<ProfileScreen> {

//instancia de servicio de autentificacion para poder acceder al currentUser 
final _authService = AuthService(); 

// instnacia del servicio profile para utilizar las consultas 
final _profileService = ProfileService(); 

//controladores para los TextFormField
final _userNameController = TextEditingController();
final _fullNameController = TextEditingController();

//key para el widget Form 
final _formKey = GlobalKey<FormState>();

//  Esta variable tendra el perfil cargado cuando se navege a la pantalal y se llame al metodo _loadProfile 
Profile? _profile;
//variables para controlar el estado de carga y guardado del perfil, para mostrar indicadores de progreso y deshabilitar el boton de guardar mientras se esta guardando.
bool _isLoading = true; 
bool _isSaving = false; 


@override
  void initState(){
  super.initState(); 
  _loadProfile();
}
///Limpia los controlares cuando  el widget se elimine del arbol de widgets 
@override 
void dispose(){
  super.dispose();
  _userNameController.dispose();
  _fullNameController.dispose(); 
}


///Obtiene el perfil del usuario  y carga la información de nombre de usuario y nombre completo en los 'input' del formulario 
Future<void> _loadProfile ()async{
  //obtiene el usuario en sesión
  final user = _authService.currentUser;
  if (user == null){
    return; 
  }
  setState(() {
    _isLoading = true; 
  });
  try{
      //obtiene la informacion del perfil
      final profile =  await _profileService.getProfile(user.id); 
      // se inyecta  la informacion del perfil en los controladores de los 'input'
      if(mounted){
        setState(() {
          _profile =  profile; 
          _userNameController.text = _profile?.userName ?? " ";
          _fullNameController.text = _profile?.fullName ?? " ";
        });
      }

  } catch(e){
    SnackBarMessenger.showError(" Error al cargar el perfil.");
  } finally{
    if(mounted){
      setState(() {
        _isLoading = false; 
      });
    }
  }
}

///Valida el formulario y si se superan las validaciones, actualiza el perfil del usuario con la información de los 'input' del formulario.
Future <void> _saveProfile() async{
    
  //validate() devuelve true si todos los validator han devuelto  null, esto es si se superan las validaciones. 
  //Si devuelve false, no se supera alguna validación y se detiene  la ejecución 
  if (!_formKey.currentState!.validate()){
    return; 
  }
  setState(() {
    _isSaving = true; 
  });
  try{
    _profileService.updateProfile(
      id: AuthService().currentUser!.id,
      userName: _userNameController.text.trim(),
      fullName: _fullNameController.text.trim(),
      ); 

      if(mounted){
        SnackBarMessenger.showSucces("Perfil actualizado correctamente ");
        _loadProfile();
      }

  }catch(e){
    SnackBarMessenger.showError("Error al actualizar el perfil."); 
  
  }finally{
    if(mounted){
      setState(() {
        _isSaving = false; 
      });
    }
  }

}

  @override
  Widget build(BuildContext context) {

    final email = _authService.currentUser?.email ?? ""; 

    if (_isLoading){
      return Center(
        child:  CircularProgressIndicator.adaptive());
    }
    //Utiliza un scaffold,  padding, center, ConstrainedBox  SingleChildScrollView Form y dentro  de Form una column con CustomTextForm View:
    return  Scaffold(
      backgroundColor: Colors.transparent,
      body: Padding(
        padding: EdgeInsets.all(40),
        child: Center(
          child: ConstrainedBox(
            constraints:  BoxConstraints(
              maxWidth: 400.0
            ),
            child: SingleChildScrollView(
              child: Form(
                  key: _formKey,
                  child: Column(
                    children:[
                       Text(
                          'Modificar perfil',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      Divider(),
                      SizedBox(height: 30),
                      Text( 
                        email,
                        //meter style con thmeOf Context)
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                       SizedBox(
                        height: 30,
                      ),
                        //-----------------------------------------------------
                        //   NOMBRE DE USUARIO 
                        //----------------------------------------------------
                      CustomTextFormField(
                        controller: _userNameController,
                        label: 'Nombre de Usuario',
                        prefixIcon: Icons.account_circle,
                        /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                        validator: (value){
                          return InputValidation.validateUserName(value);
                        },
                      ),
              
                        //-----------------------------------------------------
                        //   NOMBRE COMPLETO
                        //----------------------------------------------------
                      SizedBox(
                        height: 15,
                      ),
                      CustomTextFormField(
                        controller: _fullNameController,
                        label: 'Nombre completo',
                        prefixIcon: Icons.account_circle,
                        /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                        validator: (value){
                            return InputValidation.validateFullName(value);
                        },
                      ),
                      const SizedBox(
                        height:30,
                      ),
                      
                        //-----------------------------------------------------
                        //  BOTON GUARDAR CAMBIOS 
                        //-----------------------------------------------------
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: _isSaving ? 
                            CircularProgressIndicator.adaptive() : Icon(Icons.save_outlined),
                          label: Text(
                            _isSaving ? 'Guardando..' : 'Guardar cambios'),
                          style: AppTheme.authButtonStyle,
                        ),
                          
                      ),
                    ]
                  )
                )
              )
            )
          )
        ),
    );
  }
}