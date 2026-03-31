  import 'package:flutter/material.dart';
  import 'package:proyecto_intermodular/core/app_colors.dart';


/// Widget personalizado  para mostrar informacion sobre el tiempo total de trabajo en summary_screen 
class CustomSummaryRow  extends StatelessWidget{

  final IconData icon; 
  final String  label;
  final String value; 
  final bool highlight; 

  const CustomSummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.highlight = false,
  }); 

 @override
  Widget build(BuildContext context){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryIconsColor),
          const SizedBox(width:12),
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: highlight ? 18 : 16,
              fontWeight:  highlight? FontWeight.bold : FontWeight.normal
            )
          )
        ]
      ),
    );
  }
  


}