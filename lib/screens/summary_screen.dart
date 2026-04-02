import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:proyecto_intermodular/components/custom_sumary_row.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
import 'package:proyecto_intermodular/models/time_entries.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/services/time_entry_service.dart';
import 'package:proyecto_intermodular/utils/time_utils.dart';

class SummaryScreen extends StatefulWidget {
  const SummaryScreen({super.key});

  @override
  State<SummaryScreen> createState() => _SummaryScreenState();
}




class _SummaryScreenState extends State<SummaryScreen> {
  
  //servicio de TimeEntry para poder ejecutar las consultas
  final TimeEntryService _timeEntryService = TimeEntryService();
  
  final _authServive  = AuthService(); 

  late Future<List<TimeEntry>> _futureTimeEntries; 

  final DateFormat  _dateFormat= DateFormat('dd/MM/yyyy');
  
  // si no hay rango seleccionado vale null 
  // tiene dos propiedades start y end 
  // variable de estado para el rango de fechas

  DateTimeRange? _selectedDateRange; 

  
  ///Establece un valor inicial para el rango de fechas
  ///Carga los fichajes dentro de ese rango inicial
  @override
  void initState(){
    super.initState();

    final  now = DateTime.now();
    // Primer dia del mes 
    final firstDayOfMonth = DateTime(now.year,now.month,1);
    //Ultimo día del mes. El  dia cero  del mes siguiente da el ultimo del actual
    final lastDayOfMonth = DateTime(now.year,now.month +1,0);

    // Establece un valor por defecto al rango de fechas. 
    _selectedDateRange = DateTimeRange(
      start:firstDayOfMonth,
       end: lastDayOfMonth
    ); 

    _loadTimeEntries();
  }

  /// Obtiene la promesa (Future) de la base de datos y la guarda en la variable.
  ///  Este método NO usa 'async' ni 'await' porque el encargado de 
  /// esperar a que lleguen los datos y gestionar los estados de carga es el 
  /// widget FutureBuilder, el cual necesita recibir el Future intacto.
  /// Si hay rango de fechas, carga los fichajes dentro de ese rango
  void _loadTimeEntries(){
    
    final userId  = _authServive.currentUser?.id;
    //print('userId: $userId'); 
   

    if (userId ==null){
      _futureTimeEntries= Future.value([]);
      return; 
    }

    if(_selectedDateRange == null){
       _futureTimeEntries = _timeEntryService.getAllTimeEntries();
    } else{
      final start = _selectedDateRange!.start;
      final end = _selectedDateRange!.end.add(Duration(days:1));
      //print('start: $start'); 
      //print('end: $end');

        //fichajes ordenados del mas reciente al mas antiguo dentro de un rango de fechas
      _futureTimeEntries = _timeEntryService.getTimeEntriesByDateRange(userId, start, end);
    }
  }


  /// refresh  tiene que devolver Future  para ReFreshIndicator funcione correctamente
  /// Se usa por el RefreshIndicator y por el botton de Scafold para actualizar 
  Future <void> _refresh() async {
    setState(() {
      _loadTimeEntries();
    });
    await _futureTimeEntries;
  }


  /// Usa la funcion nativa de Flutter showDateRangePicker  que abre un dialogo visual para que el usuario eliga un rango de fechas.
  /// Devuelve un DateTimeRange con el rango
  /// Cuando se eliga el rango, cargamos los fichajes dentro de ese rango
  Future <void> _pickDateRange() async{
  
    DateTimeRange? picked = await showDateRangePicker(
      context: context, 
      firstDate: DateTime(2025),
      //necesario poner un margen amplio para que no haya conflicto con el fin de rango inicial  de _selectedDateRange 
      lastDate: DateTime(2030),
      initialDateRange: _selectedDateRange,
      helpText: 'Seleccciona el periodo',
      cancelText:'Cancelar',
      confirmText: 'Aplicar',
      saveText:'Guardar',
    );
    //cuando se eliga el rango, cargamos los fichajes dentro de ese rango 
    if(picked != null){
      setState(() {
        _selectedDateRange = picked; 
        _loadTimeEntries();
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: 
      FutureBuilder(
        future: _futureTimeEntries,
        builder: (context,snapshot){

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
          //  PANTALLA DE NO HAY REGISTROS EN ESTE RANGO DE FECHAS
          //-----------------------------------------------------
          // si la lista esta vacia de modo que no hay fichajes, se muestra este Center 

          if(timeEntries.isEmpty){
            return Padding(
              padding: const EdgeInsets.all(40.0),
              child: ListView( // con  ListView para que el botón se quede arriba
                children: [
                  //-----------------------------------------------------
                  // BOTON PARA SELECCIONAR RANGO DE FECHAS
                  //-----------------------------------------------------
                  _buildDateRangeButton(),
                  
                  const SizedBox(height: 100), // Empuja el mensaje hacia el centro
                  
                  const Column(
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.redAccent),
                      SizedBox(height: 16),
                      Text(
                        'No hay registros en estas fechas',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )
                ],
              ),
            );
          }
          

          final String  rangeStartString = _dateFormat.format(_selectedDateRange!.start);
          final String  rangeEndString = _dateFormat.format(_selectedDateRange!.end);

          //accede al fichaje de salida del fichaje mas reciente. Es el primero de la lista porque los fichajes en la lista están ordenados del más reciente al más antiguo. 
          final String lastRealClockOut = timeEntries.first.clockOut != null 
          ? _dateFormat.format(timeEntries.first.clockOut!.toLocal())
          : 'En Curso'; 

          // se pasa la lista  de fichajes y el inicio y fin de rango
          final String totalDuration = TimeUtils.calculateTotalDuration(
            timeEntries,
            rangeStart: _selectedDateRange!.start.toUtc(),
            rangeEnd: _selectedDateRange!.end.add(const Duration(days: 1)).toUtc(),
          ); 


          return RefreshIndicator(
            onRefresh: _refresh,
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Center(

                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: ListView(
                    children: [
                      //-----------------------------------------------------
                      // BOTON PARA SELECCIONAR RANGO DE FECHAS
                      //-----------------------------------------------------
                      _buildDateRangeButton(),

                      SizedBox(
                        height: 48,
                      ),

                      //-----------------------------------------------------
                      // RESUMEN DE HORAS TRABAJADAS
                      //-----------------------------------------------------
                      Card(
                        elevation: 4,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadiusGeometry.circular(16),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top:10.0),
                              child: const Text(
                                'Cómputo de horas trabajadas',
                                style: TextStyle(
                                  fontSize:18,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                            ),
                            const Divider(color: AppColors.dividerColor ,height:32),
                            CustomSummaryRow(
                              icon: Icons.work, 
                              label: 'Inicio del rango: ', 
                              value: rangeStartString,
                            ),
                            const SizedBox(height: 16),
                            CustomSummaryRow(
                              icon: Icons.work, 
                              label: 'Fin del rango: ', 
                              value: rangeEndString,
                            ),
                            const SizedBox(height: 16),
                            CustomSummaryRow(
                              icon: Icons.logout, 
                              label: 'Último fichaje:  ', 
                              value: lastRealClockOut,
                            ),  
                            const SizedBox(height: 16),
                            CustomSummaryRow(
                              icon: Icons.timer_outlined, 
                              label:  'Total horas trabajadas: ', 
                              value: totalDuration,
                              highlight:  true,
                            ),
                            const SizedBox(height: 16),
                          ]
                        )
                  
                      )
                  
                  
                    ],
                  ),
                ),
              ),
            )
          );
        }
      ),
      //-----------------------------------------------------
      // BOTON REFRESH
      //-----------------------------------------------------
      //Boton para refresar  los datos manualmente sin cambiar el rango de fechas. Por ejemplo, si alguien ficha en otra pestaña y se quiere ver el cómputo actualizado.
      floatingActionButton: FloatingActionButton(
        onPressed: _refresh,
        tooltip: 'Refrescar Cómputo',
        child: const Icon(Icons.refresh),
        )

    );
  }

  //-----------------------------------------------------
  //  DISEÑO BOTON PARA SELECCIONAR RANGO DE FECHAS
  //-----------------------------------------------------
  ///  boton para  seleccionar rango de fechas
  Widget _buildDateRangeButton(){
    return  ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: 56,
        maxWidth: 300,
      ),
      child: FilledButton.icon(
        onPressed: _pickDateRange,
        label: Text(
          'Seleccionar rango de fechas',
         /*  _selectedDateRange !=null
          ? '${_dateFormat.format(_selectedDateRange!.start)} -  ${_dateFormat.format(_selectedDateRange!.end)}'
          :'Filtrar por fechas' */
        ),
        icon:  Icon(
          Icons.calendar_month,
          color: AppColors.primaryIconsColor,
        ), 
        //elimino la propiedad style porque ya se aplican los estilos de ThemeData   a lso filledButton
      ),
    );
  }
}
