import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_intermodular/components/custom_text_form_field.dart';
import 'package:proyecto_intermodular/components/gradient_background.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
import 'package:proyecto_intermodular/core/app_theme.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/utils/input_validation.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';

// Los enum se declaran fuera de las clases 
// Este enum se utiliza para controlar en que paso del proceso de recuperación de contraseña se encuentra el usuario, y mostrar los campos e instrucciones correspondientes en cada paso
enum RecoveryStep {email,otp,newPassword}

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {

  // instancia dew AuthService para poder acceder a los metodos para mandar el codigo, verificarlo y cambiar la contraseña 
  final _authService = AuthService(); 
  ///key para el widget Form 
  final _formKey = GlobalKey<FormState>();

  // controllers para los TestFormField 
  final _emailController = TextEditingController();
  final _otpController  = TextEditingController();
  final  _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //estado inicial 
  RecoveryStep _currentStep = RecoveryStep.email; 

  bool _isLoading = false; 


  ///  cuando este widget se elimina,se liberan los controladores 
  @override 
  void dispose(){
    _emailController.dispose();
    _otpController.dispose();
     _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  /// Utiliza  el metodo del servicio de autentificacion para enviar un codigo  al email introducido por el usuario.
  /// Muestra SnackBar de éxito y  y cambia el estado para mostrar el siguiente paso del proceso de recuperación (introducir el código OTP)
  /// Si hay un error, muestra un SnackBar con el mensaje de error
  /// 
  Future <void> _sendRecoveryCode()async{

    //validate() devuelve true si todos los validator han devuelto  null, esto es si se superan las validaciones. 
    //Si devuelve false, no se supera alguna validación y se detiene  la ejecución 
    if (!_formKey.currentState!.validate()){
      return; 
    }

    setState((){
      _isLoading =  true; 
    }); 

    try{
      //envia el email con al codigo al email introducido por el usuario
      _authService.sendEmailOTPCode(_emailController.text.trim());
      SnackBarMessenger.showSucces('Código de recuperación enviado a tu correo');
      //Como se ha enviado el email con el codigo, pasamos a la siguiente paso
      setState(() {
        _currentStep = RecoveryStep.otp; 
      });

    }catch(e){
      SnackBarMessenger.showError('Error al enviar el código de recuperación: $e');

    }finally{
       setState((){
      _isLoading =  false; 
    }); 

    }
  }

  /// Verifica si el código OTP introducido por el usuario es correcto utilizando el metodo del servicio de autentificacion.
  /// Si el código es correcto, muestra un SnackBar de éxito y cambia el estado para mostrar el siguiente paso del proceso de recuperación (introducir nueva contraseña)
  /// Si el código no es correcto, muestra un SnackBar con un mensaje de error
  Future <void> _verifyOTPCode() async{
    if (!_formKey.currentState!.validate()){
      return; 
    }

    setState((){
      _isLoading =  true; 
    }); 

    try{
      final isValid = await _authService.verifyRecoveryOTP(
        email: _emailController.text.trim(), 
        token: _otpController.text.trim(),
      );

      if(isValid){
        SnackBarMessenger.showSucces('Código verificado. Por favor, ingresa tu nueva contraseña.');
        setState(() {
          _currentStep = RecoveryStep.newPassword; 
        });
      }else{
        SnackBarMessenger.showError('Código de recuperación inválido. Por favor, inténtalo de nuevo.');
      }
    }catch(e){
      SnackBarMessenger.showError('Error al verificar el código de recuperación: $e');
    }finally{
       setState((){
      _isLoading =  false; 
      }); 

    }
  }

  ///Cambia la contraseña del usuario utilizando el metodo del servicio de autentificacion
  /// Si la contraseña se actualiza correctamente, muestra un SnackBar de éxito y redirige al usuario a la pantalla de inicio de sesión
  /// Si hay un error al actualizar la contraseña, muestra un SnackBar con un mensaje de error
  Future <void> _changePassword() async{
    if (!_formKey.currentState!.validate()){
      return; 
    }

    setState((){
      _isLoading =  true; 
    }); 

    try{
      await _authService.updatePassword(_confirmPasswordController.text);
      SnackBarMessenger.showSucces('Contraseña actualizada con éxito. Por favor, inicia sesión con tu nueva contraseña.');
      if(mounted){
        context.pop('/login');
      } 
    }catch(e){
      SnackBarMessenger.showError('Error al actualizar la contraseña: $e');
    }finally{
       setState((){
      _isLoading =  false; 
      }); 

    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child:  SafeArea(
          child: Padding(
            padding: EdgeInsets.all(40),
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400.0,
                ),
                child: SingleChildScrollView(
                  child: Form(
                    key:_formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                         Text(
                          'Recuperar Contraseña',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Divider(color: AppColors.dividerColor,  thickness: 1.5),
                        SizedBox(height: 30),

                        //----------------------
                        //PEDIR EMAIL  Y ENVIAR CÓDIGO
                        //----------------------
                        if(_currentStep == RecoveryStep.email)...[
                          Text(
                            'Ingresa tu correo electrónico para recibir un código de recuperación de 6 dígitos.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const  SizedBox(height: 20),

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
                            height: 30,
                          ), 
                        
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: FilledButton(
                              /// isLoading = false -> el boton no se ha pulsado, se muestra el texto 'Enviar Código' y si se pulsa se llama al metodo  para enviar el código
                              /// isLoading = true -> se ha pulsado el boton , muestra  espiral de carga y se evita llamar al metodo de nuevo
                              onPressed: _isLoading ? null : _sendRecoveryCode,  
                              child: _isLoading ? CircularProgressIndicator() : Text('Enviar Código'),
                              style: AppTheme.authButtonStyle,
                              ),
                          ),
                           
                          SizedBox(
                            height: 30,
                          ), 
                        
                          SizedBox(
                            height: 50, 
                            child: TextButton(
                              onPressed: (){
                                context.pop('/login');
                              }, child: Text(
                                'Volver a inicio de sesión'),
                            ),
                          ),
                        ],
                        //----------------------
                        //PEDIR CÓDIGO OTP Y VERIFICARLO 
                        //----------------------
                        if(_currentStep==RecoveryStep.otp)...[
                          Text(
                            'Introduce el código que hemos  enviado a tu correo electrónico',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const  SizedBox(height: 20),
                          CustomTextFormField(
                            controller: _otpController,
                            keyboardType: TextInputType.number,
                            label: 'Código de recuperación',
                            prefixIcon: Icons.password_outlined,
                            /// si se superan las validaciones, se devuelve null. Si no se devuelve un mensaje 
                            validator: (value){
                                return InputValidation.validateOtpCode(value);
                            }
                          ),
                           SizedBox(
                          height: 30,
                          ), 
                        
                          SizedBox(
                          height: 50,
                          width: double.infinity,
                          child: FilledButton(
                              /// isLoading = false -> el boton no se ha pulsado, se muestra el texto 'Ve' y si se pulsa se llama al metodo  para enviar el código
                              /// isLoading = true -> se ha pulsado el boton , muestra  espiral de carga y se evita llamar al metodo de nuevo
                              onPressed: _isLoading ? null : _verifyOTPCode,  
                              child: _isLoading ? CircularProgressIndicator() : Text('Verificar Código'),
                              style: AppTheme.authButtonStyle,
                            ),
                          ),
                           SizedBox(
                            height: 30,
                          ), 
                        
                          SizedBox(
                            height: 50, 
                            child: TextButton(
                              onPressed: (){
                                context.pop('/login');
                              }, child: Text(
                                'Volver a inicio de sesión'),
                            ),
                          ),
                        ],


                        //----------------------
                        //CREAR  Y CONFIRMAR NUEVA CONTRASEÑA 
                        //----------------------
                        if(_currentStep == RecoveryStep.newPassword)...[
                           Text(
                            'Crea la nueva contraseña. Debe ser mayor de 8 caracteres y contener al menos un numero y un caracter especial',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const  SizedBox(height: 20),

                          //CONTRASEÑA 
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
                          height: 30,
                          ), 
              
                          //CONFIRMAR CONTRASEÑA
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
                          ),
                          SizedBox(
                            height: 30,
                          ), 

                          //----------------------
                          //BOTON PARA CAMBIAR CONTRASEÑA 
                          //----------------------
                          SizedBox(
                            height: 50,
                            width: double.infinity,
                            child: FilledButton(
                              onPressed: _isLoading ? null : _changePassword,  
                              child: _isLoading ? CircularProgressIndicator() : Text('Cambiar Contraseña'),
                              style: AppTheme.authButtonStyle,
                            ),
                          ),
                             
                          SizedBox(
                            height: 30,
                          ),

                          //----------------------
                          // VOLVER A INICIO DE SESIÓN
                          //----------------------
                          SizedBox(
                            height: 50, 
                            child: TextButton(
                              onPressed: (){
                                context.pop();
                              }, child: Text('Volver al inicio de sesión'),
                            ),
                          ), 
                        ]
                      ]
                    )
                  )
                )
              )
            )
          )
        )
      )
    );
  }
}