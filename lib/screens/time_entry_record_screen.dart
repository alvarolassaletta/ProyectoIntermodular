
import 'package:flutter/material.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
import 'package:proyecto_intermodular/models/time_entries.dart';
import 'package:proyecto_intermodular/services/time_entry_service.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_intermodular/utils/export_helper.dart';
import 'package:proyecto_intermodular/utils/time_utils.dart';

class TimeEntryRecordScreen extends StatefulWidget {
  const TimeEntryRecordScreen({super.key});

  @override
  State<TimeEntryRecordScreen> createState() => _TimeEntryRecordScreenState();
}



class _TimeEntryRecordScreenState extends State<TimeEntryRecordScreen> {
  
  final TimeEntryService _timeEntryService = TimeEntryService();

  late Future<List<TimeEntry>> _futureTimeEntries; 

  //  Patrones  de formateo de fechas 
  //dd/MM/yyyy
  final DateFormat _dateFormat= DateFormat('dd/MM/yyyy');
  //HH:mm
  final DateFormat _timeFormat= DateFormat('HH:mm');
  //dd/MM/yyyy - HH:mm
  final DateFormat _createdAtFormat = DateFormat('dd/MM/yyyy - HH:mm');

  String _searchQuery = ''; 

  // controller para  la barra de busqueda 
  final TextEditingController _searchController = TextEditingController(); 

  @override
    void initState(){
      super.initState();
      _loadTimeEntries();
    }

  ///Cuando se cierra la pantalla, se  liberan los controladores 
  @override 
  void dispose(){
    _searchController.dispose();
    super.dispose();
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

  ///Recibe la lista de fichajes y filtra por el por la fecha introducida en la barra de búsqueda
  ///Si no se introduce nada, se devuelve la lsita con todos los fichajes 
  List<TimeEntry> _filterEntries(List<TimeEntry> entries){
     // si no hay busqueda se, devuelve toda la lista de fichajes 
    if(_searchQuery.isEmpty){
      return entries; 
    }
    List<TimeEntry> filteredEntries= [];
    
    for(int i= 0;i<entries.length;i++){
      TimeEntry entry= entries[i];
      final dayString = _dateFormat.format(entry.clockIn.toLocal());
      if (dayString.toLowerCase().contains(_searchQuery.toLowerCase())){
        filteredEntries.add(entry);
      }
    }
    return filteredEntries;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body:  FutureBuilder<List<TimeEntry>>(
        future: _futureTimeEntries,
        builder: (context,snapshot) {
          
          if(snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData){
            return const Center(child:CircularProgressIndicator.adaptive());
          }
          //-----------------------------------------------------
          // PANTALLA DE ERROR 
          //-----------------------------------------------------
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
                  //Se evita así tener que operar  con un bool para evitar que muchos clics puedan ejecutar muchas peticiones
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

          //-----------------------------------------------------
          //  PANTALLA DE NO HAY REGISTROS 
          //-----------------------------------------------------
          // Si la lista esta vacia de modo que no hay fichajes, se muestra este Center 
          if(timeEntries.isEmpty){
            return Center(
              child:Column(
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                  const SizedBox(height: 16),
                  Text( 'No hay registros de fichajes todavía',
                  style: Theme.of(context).textTheme.titleMedium,),
                ],
              )
            );
          }
          //-----------------------------------------------------
          //  PANTALLA HISTORIAL DE FICHAJES 
          //-----------------------------------------------------
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left:40,right: 40,top:36,bottom:16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children:[
                    //-----------------------------------------------------
                    // BARA DE BÚSQUEDA. PERMITE BUSCAR FICHAJES POR FECHA (dd/MM)
                    //-----------------------------------------------------
                    Expanded(
                      child: Container(
                        height:48,
                        decoration: BoxDecoration(
                          color: Colors.white, 
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26, // Opacidad suave, como la sombra por defecto de Flutter
                              blurRadius: 6,         // Lo difuminada que está la sombra
                              offset: Offset(0, 2),  // Ligero desplazamiento hacia abajo
                            ),
                          ],
                        ),

                        child: TextField(
                          controller: _searchController,
                          keyboardType: TextInputType.datetime,
                          //maxLength:10,
                          onChanged: (value){
                            setState((){
                              _searchQuery= value; 
                            }); 
                          },
                          decoration: InputDecoration(
                            hintText: 'Buscar...(ej:  23/03)',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            filled:true,
                            fillColor: AppColors.gradientBackgroundStart.withValues(),
                            contentPadding: const EdgeInsets.symmetric(vertical:14),
                            prefixIcon:  const Icon(Icons.search),
                            suffixIcon: _searchQuery.isNotEmpty 
                            //IconButton para limpiar la  barra de busqueda  si se ha escrito algo
                            ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear(); 
                                setState(() {
                                  _searchQuery= ""; 
                                  
                                });
                                //oculta el teclado tras limpiar
                                FocusScope.of(context).unfocus();
                              },
                            ) 
                            : null
                          )
                        ),
                      ),
                    ),
                    SizedBox(width: 10),

                    //-----------------------------------------------------
                    // FILLED BUTTON PARA DESCARGAR HISTORIAL DE FICHAJES
                    //-----------------------------------------------------
                    SizedBox(
                      height:48,
                      child: FilledButton.icon(
                        onPressed: () async {
                            // Obtenemos la lista actual de fichajes
                            final entries = await _futureTimeEntries; 
                            final  filteredEntries= _filterEntries(entries);
                            // Pasamos el context (para abrir el pop-up) y la lista al ExportHelper
                            if (context.mounted) {
                              ExportHelper.showExportDialog(context, filteredEntries);
                            }
                          },
                        label: Text('Descargar Historial'),
                        icon:  Icon(
                          Icons.download_rounded,
                          color: AppColors.primaryIconsColor,
                          ),    
                          //elimino la propiedad style porque ya estan aplicando estilos en el theme global      
                      ),
                    ),
                  ]
                ),
              ),
                //-----------------------------------------------------
                // LISTA DE FICHAJES 
                //-----------------------------------------------------
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _refresh,
                
                  child: Builder(
                    builder: (context) {
                      final filteredEntries = _filterEntries(timeEntries);

                      return ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 40,vertical:24),
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: filteredEntries.length,
                        itemBuilder: (context,index){
                                      
                          final timeEntry =filteredEntries[index];
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
                          bool isActive = timeEntry.clockOut ==null; 
                                      
                          String totalTime = TimeUtils.calculateDuration(timeEntry.clockIn.toLocal(), timeEntry.clockOut?.toLocal());
                      
                          return Card(
                      
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            elevation:4, // sombra para la Card
                            shadowColor: Colors.black26,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              //si el fichakje esta activo, que tengo un sobreado
                              side: isActive ? BorderSide(color: Colors.lightGreen, width: 1.5) : BorderSide.none),
                          
                            child: ListTile(
                              minVerticalPadding: 8,
                              title: Text(
                               'Día $clockIndayFormatted - $clockOutDarFormatted',
                               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(children:[
                                    Text('Entrada: $timeClockInFormatted '),
                                    SizedBox(width: 36),
                                    Text('Salida: $timeClockOutFormatted'),
                                    ]
                                  ),
                                  SizedBox(height: 8),
                                  Text('Tiempo trabajado: $totalTime'),
                                  SizedBox(height: 8),
                                  Text('Fecha registro : $createdAt')
                                ],
                              ),
                              leading: Icon(
                                isActive ? Icons.access_time_filled : Icons.check_circle,
                                color: isActive ? AppColors.activeTimeEntryColor: AppColors.completedTimeEntryIcon,
                              )
                            ),
                          );
                        });
                    }
                  ),
                ),
              ),
            ],
          );
        },
      ),
          //-----------------------------------------------------
          // FLOATING ACTION BUTTON PARA REFRESCAR LA LISTA DE FICHAJES
          //-----------------------------------------------------
      // sin este botton llamando a refresh, no  apacecen fichajes nuevos realizados al navegar a clockScreen
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Actualizar Historial',
        child: const Icon(Icons.refresh),
        )

    );
  }
}