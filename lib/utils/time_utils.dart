
import 'package:proyecto_intermodular/models/time_entries.dart';

class TimeUtils {

 

  /// Calcula la duración 
  ///Calcula el tiempo transcurrido entre el fichaje de entrada y el fichaje de salida 
  /// Se llamara usando el valor de clockIn y clockOut
  static String calculateDuration(DateTime start, DateTime? end){
    if(end== null){
      return 'En curso...';
    }
    Duration difference = end.difference(start);

    int hours = difference.inHours; 
    int minutes = difference.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  
  /// Suma la duración de todos los fichajes completados de la lista
  /// El objetivo es calcular el tiempo de trabajo acumulado en los fichajes de la lista 
   static String calculateTotalDuration(List<TimeEntry> entries) {
    Duration total = Duration.zero;
    for (final entry in entries) {
      if (entry.clockOut != null) {
        total += entry.clockOut!.difference(entry.clockIn);
      }
    }
    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

}


