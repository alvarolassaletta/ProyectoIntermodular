import 'package:flutter/material.dart';

/// TestFormField personalizado 
/// usa  el atributo isPassword para aplicas propiedades adicionales al widget cuando el 'input' sea para contraseña (suffixIcon y obscureText) 

class CustomTextFormField extends StatefulWidget {

  final TextEditingController controller; 
  final String label; 
  final IconData prefixIcon; 
  /// sera true cuando sea para contraseña 
  /// se usará este atributo para establecer un valor para suffixIcon ( un IconButton con un Icon) cuando el 'input' sea para la contraseña 
  final bool isPassword; 
  final TextInputType keyboardType;
  final String? Function(String?)? validator; 
  final void Function(String)? onFieldSubmitted; 
  final Widget? suffixIcon; 

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.label,
    required this.prefixIcon,
    // por defecto, los 'input' no serán para contraseñas, y no tendrán suffixIcon
    this.isPassword = false, 
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onFieldSubmitted,
    this.suffixIcon,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {

  /// booelan para ocultar la contraseña 
  bool _hidePassword = true; 

  @override
  Widget build(BuildContext context) {
    return  TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: widget.isPassword ?  _hidePassword : false,
      decoration: InputDecoration(
        labelText: widget.label,
        errorMaxLines: 3,
        errorStyle: TextStyle(fontSize:14),
        prefixIcon: Icon(widget.prefixIcon),
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
        /// si isPassword es true  suffixIcon tiene valor (IconButton) Si es false,  suffixIcon sera null
        /// IconButton -> interactividad   Icon -> el icono
        /// _hidePassword  true -> no se ve la contraseña  y el 'ojo' esta tachado
        /// _hidePassword false -> se ve la contraseña y el 'ojo' no esta tachado
        suffixIcon: widget.isPassword 
          ? IconButton(
            icon: Icon(
              _hidePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined
            ),
            onPressed: () => setState(() {
              _hidePassword = !_hidePassword; 
              }
            ),
        ) : widget.suffixIcon,
      ),
      validator:widget.validator,
      onFieldSubmitted: widget.onFieldSubmitted,
    );
  }
}