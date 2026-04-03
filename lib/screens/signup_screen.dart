import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_intermodular/components/custom_text_form_field.dart';
import 'package:proyecto_intermodular/components/gradient_background.dart';
import 'package:proyecto_intermodular/core/app_theme.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/utils/auth_error_translator.dart';
import 'package:proyecto_intermodular/utils/input_validation.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}


class _SignUpScreenState extends State<SignUpScreen> {

  //instancia de AuthService para  poder usar el metodo signUp
  final  _authService = AuthService();

  ///controladores para los TextFormField
  final _userNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  ///key para el widget Form
  final _formKey = GlobalKey<FormState>();

  /// boolean para cambiar el valor de onPressed  y  el texto del botón de  signup en funcion  de que se haya pulsado o no
  bool _isLoading = false; 

  @override
  void initState(){
    super.initState();
  }

   ///  cuando este widget se elimina,se liberan los controladores  email y password 
  @override 
  void dispose(){
    super.dispose();
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose(); 
    _confirmPasswordController.dispose();
  }

  Future <void> _signUp() async{

    //validate() devuelve true si todos los validator han devuelto  null, esto es si se superan las validaciones. 
    //Si devuelve false, no se supera alguna validación y se detiene  la ejecución 
    if (!_formKey.currentState!.validate()){
      return; 
    }

    setState((){
      _isLoading =  true; 
    }); 

    try{
      final response = await _authService.signUp(
        email: _emailController.text.trim(), 
        password: _passwordController.text, 
        userName: _userNameController.text.trim(), 
        fullName: _fullNameController.text.trim(),
      );
      //identitities es una lista de proveedores de autentificacion vinculadas al usuario.
      //cuando hay un intento de registro, con un email  ya existente y en supabase esta activada la proteccion anti-enunemracion , suapbase devuelve  un objeto User 'falso' y con  la lsita identities vacia. 
      if(response.user?.identities?.isEmpty ?? true){
        SnackBarMessenger.showError('Ya existe una cuenta registrada con este email');
        return; 
      }

       /// comprueba si la pantalla actual no se ha cerrado por el usuario
      if(mounted){
        SnackBarMessenger.showSucces('¡Registro completado! Por favor, revisa tu bandeja de entrada para confirmar tu email');
        context.pop();
      }
    } on AuthException catch(error){
      final   translatedErrorMessage = AuthErrorTranslator.translate(error);
      SnackBarMessenger.showError(translatedErrorMessage);
    }catch(error){
      SnackBarMessenger.showError('Error inesperado. Intentálo de nuevo'); 
    } finally{
      setState((){
      _isLoading =  false; 
      }); 
    } 
  }

  

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child:  Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400.0
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child:  Column(
                      children:[
                
                        //-----------------------------------------------------
                        //  NOBMRE DE USUARIO
                        //-----------------------------------------------------
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
                        //  NOMBRE COMPLETO
                        //-----------------------------------------------------
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
                          SizedBox(
                          height: 15,
                        ),
                        
                        //-----------------------------------------------------
                        //EMAIL
                        //-----------------------------------------------------
                        CustomTextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          label: 'Email',
                          prefixIcon: Icons.email_outlined,
                          /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                          validator: (value){
                              return InputValidation.validateEmail(value);
                          }
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        
                        //-----------------------------------------------------
                        //CONTRASEÑA 
                        //-----------------------------------------------------
                        CustomTextFormField(
                          controller:_passwordController,
                          isPassword: true,
                          label: 'Contraseña',
                          prefixIcon: Icons.lock_clock_outlined,
                            /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                          validator: (value){
                            return InputValidation.validatePassword(value);
                          },
                        ),
                        SizedBox(
                          height: 15,
                        ),
                
                        //-----------------------------------------------------
                        // CONFIRMAR CONTRASEÑA 
                        //-----------------------------------------------------
                        CustomTextFormField(
                          controller: _confirmPasswordController,
                          isPassword: true,
                          label: 'Confirma la contraseña',
                          prefixIcon: Icons.lock_clock_outlined,
                            /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                          validator: (value){
                            if(value==null || value.isEmpty){
                              return 'Escribe de nuevo la contraseña';
                            }
                            if( value != _passwordController.text){
                              return 'Las contraseñas no coinciden';
                            }
                            return null; 
                          },
                          onFieldSubmitted: (_) =>_signUp(),
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        //-----------------------------------------------------
                        // REGISTRARSE  
                        //-----------------------------------------------------
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: FilledButton(
                            /// isLoading = false -> el boton no se ha pulsado, se muestra el texto 'registrarse' y si se pulsa se llama al metodo signUp
                            /// isLoading = true -> se ha pulsado el boton , muestra  espiral de carga y se evita llamar al método de nuevo
                            onPressed: _isLoading ? null : _signUp,  
                            style: AppTheme.authButtonStyle,
                            child: _isLoading ? CircularProgressIndicator() : Text('Registrarse'),
                          ),
                        ),
                          SizedBox(
                          height: 15,
                        ), 
                        //-----------------------------------------------------
                        // ¿YA TIENES CUENTA? INICIA SESIÓN
                        //-----------------------------------------------------
                        SizedBox(
                          height: 50, 
                          child: TextButton(
                            onPressed: (){
                              context.pop('/login');
                            }, child: Text(
                              '¿Ya tienes cuenta? Inicia sesión'),
                          ),
                        ),
                      ]
                    )
                  )
                ),
              )
            )
          )
        )
      )
    );
    
  }
}