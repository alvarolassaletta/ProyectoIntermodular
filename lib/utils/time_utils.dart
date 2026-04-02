
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
  /// rangeStart y rangeEnd: paramentros posicionales opcionales. Representan incio y fin de rango de fechas
  /// Si se proporciona rangeStart y rangeEnd, recorta cada fichaje a los límites del rango
  /// para no contar tiempo fuera del periodo seleccionado (ej: turnos nocturnos que cruzan la medianoche (fichaje entrada: 31/03 22:00  - ficahje salida: 01/04 06:00 con rango seleccionado 01/04 - 31/04))
  
   static String calculateTotalDuration(List<TimeEntry> entries, {DateTime? rangeStart, DateTime? rangeEnd}) {
    Duration total = Duration.zero;
    for (final entry in entries) {

      // total += entry.clockOut!.difference(entry.clockIn);

      if (entry.clockOut != null) {

        //si el fichaje de entrada empieza antes del inicio del rango, el tiempo que media entre  la entrada y el inicio del rango se excluye del calculo  de tiempo trabajado entre inicio - fin de rango
        final effectiveStart = rangeStart != null && entry.clockIn.isBefore(rangeStart)
            ? rangeStart
            : entry.clockIn;
        
        // si el fichaje de salida orurre despues  del fin del rango, el tiempo que media entre el fin del rango y  el fichaje de salida se excluye del cálculo de tiempo trabajado entre inicio- fin de rango 
        final effectiveEnd = rangeEnd != null && entry.clockOut!.isAfter(rangeEnd)
            ? rangeEnd
            : entry.clockOut!;

        total += effectiveEnd.difference(effectiveStart);
      }
    }
    final hours = total.inHours;
    final minutes = total.inMinutes.remainder(60);
    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

}


