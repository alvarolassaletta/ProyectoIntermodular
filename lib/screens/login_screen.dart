import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_intermodular/components/custom_text_form_field.dart';
import 'package:proyecto_intermodular/components/gradient_background.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/utils/auth_error_translator.dart';
import 'package:proyecto_intermodular/utils/input_validation.dart';
import 'package:proyecto_intermodular/utils/preferences_keys.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart'; 


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}


/// FALTA LA PERSINTENCIA DE DATOS ->  CONTRAÑASEÑA SESION 


class _LoginScreenState extends State<LoginScreen> {

  ///Instancia de AuthService para poder acceder al metodo signIn
  final  _authService = AuthService();

  ///controladores para textFormField. Permite acceder a los valores introducidos
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  ///key para el widget Form 
  final _formKey = GlobalKey<FormState>();

  /// boolean para cambiar el valor de onPressed  y  el texto del botón de login en funcion  de que se haya pulsado o no
  bool _isLoading = false; 

  ///boolean para controlar si el checkBox esta marcado o no
  bool _rememberCredentials = false; 

  /// instancia de FlutterSecureStorage
  final FlutterSecureStorage _secureStorage= FlutterSecureStorage(); 


  @override
    void initState(){
    super.initState(); 
    _loadSavedCredentials();
  }

  ///  cuando este widget se elimina,se liberan los controladores  email y password 
  @override 
  void dispose(){
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose(); 
  }

  Future <void> _signIn() async{
    ///validate() devuelve true si todos los validator han devuelto  null, esto es si superar las validaciones. 
    ///Si devuelve false, no se supera alguna validacion y se detiene ejecuciñon 
    if (!_formKey.currentState!.validate()){
      return; 
    }
    ///Si se ha llamado al metodo _signIn es, es porque se ha pulsado al boton iniciar Sesion
    ///Se ejecuta de nuevo el metodo build para pintar de neuvo la pantalla y que cambie el valor de onPressed y el texto del boton login
    setState((){
      _isLoading =  true; 
    }); 

    try{
       await _authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text
      );

       await _saveCredentials(); 
      /// comprueba si la pantalal actual no se ha cerrado por el usuario
      /// comprueba si el context se mantiene,  navega a HomeScreen
      if(mounted){
        context.go('/home');
      }
    } on AuthException catch(error){
       final  translatedErrorMessage = AuthErrorTranslator.translate(error);
      SnackBarMessenger.showError(translatedErrorMessage);
    }catch(error){
      SnackBarMessenger.showError('Error inesperado. Intentálo de nuevo'); 
    } finally{
      setState((){
      _isLoading =  false; 
    }); 
    }
  }

  /// Metodo para cargar la opcion marcada por el usuario sobre recordar email y contraseña. 
  /// Si estaba marcada, recupera los valores y los inyecta en los controladores de los CustomTextFormField
  /// 
  Future <void> _loadSavedCredentials() async{
    ///lee  si el usuario  tenia marcado la opcion recordar email y contraseña 
    ///hay que 'convertir' a bool porque FlutterSecureStorage guarda en formato String
    final String? rememberCredentialString =  await _secureStorage.read(key: PreferencesKeys.rememberCredentials);
    final bool rememberCredentialBool = rememberCredentialString == 'true'; 

    if(rememberCredentialBool){
      final String email = await _secureStorage.read(key:PreferencesKeys.savedEmail) ?? ''; 
      final String password = await _secureStorage.read(key:PreferencesKeys.savedPassword) ?? '';

      if(mounted){
        setState((){
          _rememberCredentials = true; 
          _emailController.text= email;
          _passwordController.text= password; 
        });
      }
    }
    

  }

  /// Si usuario marca el CheckBoxListTile para recordar email y contraseña se guardan usando el metodo write  de flutter_secure_storage 
  /// Si desmarca, se eliminan 
  Future <void> _saveCredentials() async{
    // hay que guardar la eleccion del usuario sobre recordar email y contraseña 
    await _secureStorage.write(
      key: PreferencesKeys.rememberCredentials,
      value: _rememberCredentials.toString()
    ); 
    // Si no esta marcada, no se guarda email y contraseña 
    if(_rememberCredentials){
      await _secureStorage.write(
        key: PreferencesKeys.savedEmail,
        value: _emailController.text.trim()
      );
      await _secureStorage.write(
        key:PreferencesKeys.savedPassword,
        value: _passwordController.text
      );
    } else{
      await _secureStorage.delete(
        key:PreferencesKeys.savedEmail
      );
      await _secureStorage.delete(
        key:PreferencesKeys.savedPassword
      );
    }
  }



  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //como  no se usa AppBar, se recomienda usar SafeArea  para evitar solapamiento con el contenido 'nativo' del dispositivo ( hora, bateria,etc)
      body:  GradientBackground(
        child:SafeArea( 
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Center(
              
              child:ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400.0),
                  //Aunque todo el contenido vaya a caber en la pantalla, se requiere SingleChildScroolView
                  // para que la apertura del teclado por los TextFormField no genere overflow 
                child: SingleChildScrollView(
                  child:Form(
                    key:_formKey,
                    child: Column(
                      children:[
                
                
                        /// EMAIL 
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
                        
                        ///CONTRASEÑA 
                        CustomTextFormField(
                          controller: _passwordController,
                          isPassword: true,
                          label: 'Contraseña',
                          prefixIcon: Icons.lock_clock_outlined,
                            /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                          validator: (value){
                              if(value==null || value.isEmpty){
                              return 'Introduce  tu contraseña';
                            }
                            return null; 
                          },
                          onFieldSubmitted: (_) =>_signIn(),
                        ),
                        SizedBox(
                          height: 15
                          ),
                
                        /// RECORDAR EMAIL Y CONTRASEÑA 
                        /// cuando se marca, el valor de value se invierte  sin que haya que hacerlo manualmente
                        CheckboxListTile(
                          title: Text('Recordar email y contraseña'),
                          //controla posicion 
                          controlAffinity: ListTileControlAffinity.leading,
                          value: _rememberCredentials, 
                          //activeColor 
                          //checkColor
                          onChanged:(bool? value){
                            setState((){
                              _rememberCredentials = value ?? false; 
                            });
                          }
                        ),
                        SizedBox(
                          height: 15,
                        ), 
                            
                        /// INICIAR SESION - BUTTON 
                        SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: FilledButton(
                            /// isLoading = false -> el boton no se ha pulsado, se muestra el texto 'iniciar sesion' y si se pulsa se llama al metodo signIn
                            /// isLoading = true -> se ha pulsado el boton , muestra  espiral de carga y se evita llamar al metodo de nuevo
                            onPressed: _isLoading ? null : _signIn,  
                            child: _isLoading ? CircularProgressIndicator() : Text('Iniciar Sesión')
                          ),
                        ),
                
                          SizedBox(
                          height: 15,
                        ), 
                        
                        ///  NAVEGAR A SIGNUP SCREEN
                        SizedBox(
                          height: 50, 
                          child: TextButton(
                            onPressed: (){
                              context.push('/signup');
                            }, child: Text('¿No tienes cuenta? Regístrate ',
                              style: TextStyle(
                                color: AppColors.primaryIconsColor
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 50, 
                          child: TextButton(
                            onPressed: (){
                              context.push('/forgot-password');
                            }, child: Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(
                                color: AppColors.primaryIconsColor
                                )
                              ),
                          ),
                        ),
                        // ¿OLVIDASTE LA CONTRASEÑA?
                
                        /// LOGIN WITH GOOGLE 
                        
                
                
                      ]
                    ))
                ),
              )
            ),
          )
        )
      )
    );
  }
}