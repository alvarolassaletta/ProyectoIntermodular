import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
import 'package:proyecto_intermodular/models/time_entries.dart';
import 'package:proyecto_intermodular/services/time_entry_service.dart';
import 'package:intl/intl.dart';

class TimeEntryRecordScreen extends StatefulWidget {
  const TimeEntryRecordScreen({super.key});

  @override
  State<TimeEntryRecordScreen> createState() => _TimeEntryRecordScreenState();
}



class _TimeEntryRecordScreenState extends State<TimeEntryRecordScreen> {
  
  TimeEntryService _timeEntryService = TimeEntryService();

  late Future<List<TimeEntry>> _futureTimeEntries; 

  //  Patrones  de formateo de fechas 
  //dd/MM/yyyy
  final DateFormat _dateFormat= DateFormat('dd/MM/yyyy');
  //HH:mm
  final DateFormat _timeFormat= DateFormat('HH:mm');
  //dd/MM/yyyy - HH:mm
  final DateFormat _createdAtFormat = DateFormat('dd/MM/yyyy - HH:mm');


  @override
    void initState(){
      super.initState();
      _loadTimeEntries();
    }

  /// Obtiene la promesa (Future) de la base de datos y la guarda en la variable.
  ///  Este método NO usa 'async' ni 'await' porque el encargado de 
  /// esperar a que lleguen los datos y gestionar los estados de carga es el 
  /// widget FutureBuilder, el cual necesita recibir el Future intacto.
  void _loadTimeEntries(){
    _futureTimeEntries = _timeEntryService.getAllTimeEntries();
  }

  /// refresh  tiene que devolver Future  para ReFreshIndicator funcione correctamente
  /// Se usa por el RefreshIndicator y por el botton de Scafold para actualizar 
  Future <void> _refresh() async {
    setState(() {
      _loadTimeEntries();
    });
    await _futureTimeEntries;
  }

  ///Calcula el tiempo transcurrido entre el fichaje de entrada y el fichaje de salida 
  /// Se llamara usando el valor de clockIn y clockOut
  String calculateDuration(DateTime start, DateTime? end){
    if(end== null){
      return 'En curso...';
    }
    Duration difference = end.difference(start);

    int hours = difference.inHours; 
    int minutes = difference.inMinutes.remainder(60);

    return '${hours.toString().padLeft(2, '0')}h ${minutes.toString().padLeft(2, '0')}m';
  }

  Future<void> _showExportDialog() async {

  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:  FutureBuilder<List<TimeEntry>>(
        future: _futureTimeEntries,
        builder: (context,snapshot) {
          
          if(snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData){
            return const Center(child:CircularProgressIndicator.adaptive());
          }
          //Si hay error, mostramos este widget  Center
          if(snapshot.hasError){
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  const Text(
                    '¡Whoops! Ha ocurrido un problema de conexión',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height:16
                  ),
                  Text('${snapshot.error}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,
                    color: Colors.redAccent),
                  ),
                  const SizedBox(height: 36),
                  // Cuando se pulse el boton, desapare este widget de error y se muestra el CircularProgressIndicador. El ConnetionState sera waiting
                  //Se evita así teneer que operar  con un bool para evitar que muchos clics puedan ejecutar muchas peticiones
                  ElevatedButton.icon(
                    onPressed: _refresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  )
                ]
              )
            );
          }
          final timeEntries = snapshot.data ?? [];

          if(timeEntries.isEmpty){
            return const Center(
              child:Column(
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text( 'No hay registros de fichajes todavía',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
                ],
              )
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:40,right: 40,top:24,bottom:24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    Text(
                      'Historial',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20
                       
                      )
                    ),
                    FilledButton.icon(
                      onPressed: _showExportDialog,
                      label: Text('Descargar Historial'),
                      icon:  Icon(
                        Icons.download_rounded,
                        color: AppColors.primaryIconsColor,
                        ),    
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.gradientBackgroundStart,
                        foregroundColor: AppColors.primaryIconsColor,
                        elevation: 4,
                        shadowColor: Colors.black.withValues(),
                        shape: RoundedRectangleBorder(
                          borderRadius:   BorderRadius.circular(12),
                        )
                      )     
                    ),
                  ]
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 40,vertical:24),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: timeEntries.length,
                    itemBuilder: (context,index){
                
                      final timeEntry = timeEntries[index];
                      //dia  entrada dd/MM/yyyy
                      final clockIndayFormatted = _dateFormat.format(timeEntry.clockIn.toLocal());
                      //dia salida 
                      final clockOutDarFormatted = timeEntry.clockOut !=null ?  _dateFormat.format(timeEntry.clockOut!.toLocal()) : 'En curso';
                      // hora entrada 
                      final timeClockInFormatted = _timeFormat.format(timeEntry.clockIn.toLocal());
                      //hora salida 
                      final timeClockOutFormatted=  timeEntry.clockOut !=null ?  _timeFormat.format(timeEntry.clockOut!.toLocal()) : 'En curso'; 
                      
                      //ultima modicafión pra mostrar integridad 
                      final createdAt = _createdAtFormat.format(timeEntry. 
                      createdAt);
                  
                      //si no hay fichaje de salida, el fichaje esta en curso 
                      bool IsActive = timeEntry.clockOut ==null; 
                
                      String totalTime = calculateDuration(timeEntry.clockIn.toLocal(), timeEntry.clockOut?.toLocal());
                  
                      return Card(
                  
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        elevation:4, // sombra para la Card
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          //si el fichakje esta activo, que tengo un sobreado
                          side: IsActive ? BorderSide(color: Colors.lightGreen, width: 1.5) : BorderSide.none),
                      
                        child: ListTile(
                          minVerticalPadding: 8,
                          title: Text(
                           'Día ${clockIndayFormatted} - ${clockOutDarFormatted}',
                           style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children:[
                                Text('Entrada: ${timeClockInFormatted} '),
                                SizedBox(width: 36),
                                Text('Salida: ${timeClockOutFormatted}'),
                                ]
                              ),
                              SizedBox(height: 8),
                              Text('Tiempo trabajado: ${totalTime}'),
                              SizedBox(height: 8),
                              Text('Fecha registro : ${createdAt}')
                            ],
                          ),
                          leading: Icon(
                            IsActive ? Icons.access_time_filled : Icons.check_circle,
                            color: IsActive ? Colors.orange: Colors.lightGreen
                          )
                        ),
                      );
                    }),
                ),
              ),
            ],
          );
        },
      ),
      //Boton  en Scaffold para  actualizar el historial
      // sin este botton llamando a refresh, no  apacecen fichajes nuevos realizados al navegar a clockScreen
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Actualizar Historial',
        backgroundColor: AppColors.gradientBackgroundStart,
        foregroundColor: AppColors.primaryIconsColor,
        child: const Icon(Icons.refresh),
        )

    );
  }
}