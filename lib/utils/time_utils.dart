
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
}