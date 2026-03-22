
import 'package:flutter/material.dart';
///intl para el formateo de fechas. Se puede hacer de forma nativa pero es mucho mas verboso
import 'package:intl/intl.dart';
import 'package:proyecto_intermodular/models/time_entries.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/services/time_entry_service.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});

  @override
  State<ClockScreen> createState() => _ClockScreenState();
}



class _ClockScreenState extends State<ClockScreen> {
  //instnacia de AuthService para poder utilizar el getter para obtener el usuario actual 
  final AuthService _authService = AuthService();

  //instancia  para poder acceder los metodos de fichar,ver fichaje activo,etc
  final TimeEntryService _timeEntryService = TimeEntryService();

  //declaración de una instancia  de TimeEntry 
  // si es null -> no se  hay un fichaje de entrada activo
  // si no es null-> hay un fichaje de entrada activo
  TimeEntry? activeTimeEntry ;
  TimeEntry? lastTimeEntry; 

  // para pintar el ciruculo de carga desde el principio
  bool _isLoading =true;
  
  // semaforo para evitar que al pulsar el boton se llame al metodo muchas veces
  //evita peticiones a la base de datos 
  bool _isProcessing = false; 



  @override
  void initState(){
    super.initState();
    _loadActiveEntry();
   }

  /// Obtiene el fichaje de entrada del usuario  en sesión, si existe. Si no, queda en null 
  Future <void> _loadActiveEntry() async{
    setState(()=>{
      _isLoading = true
    });
    try{
      final userId = _authService.currentUser?.id; 
      if(userId!= null){
        final entry = await _timeEntryService.getActiveTimeEntry(userId);
        final lastEntry= await _timeEntryService.getActiveTimeEntry(userId);

        if(mounted){
          setState(() { 
            activeTimeEntry = entry;
            lastTimeEntry = lastEntry; 
          });
        }
      }
    }catch(error){
      if (mounted){
        SnackBarMessenger.showError('Error al cargar el fichaje activo:  $error');
      }
    } finally{
      if(mounted){
        setState((){
          _isLoading = false; 
        });
      }
    }
  }

  /// FICHAJE DE ENTRADA: si no hay un fichaje activo ( activeTimeEntry es null porque ha venido asi de loadActiveEntry), realiza fichaje de entrada 
  /// FICHAJE SALIDA: Si hay un fichaje activo, se realiza el fichaje de salida

  Future <void> _handleClockInClockOut() async{
    setState(()=>{
        _isProcessing= true
    });

    try{
      final userId = _authService.currentUser?.id;
      
      if (userId==null){
        throw Exception('¡No hay sesión activa!');
      }

      if(activeTimeEntry ==null){
        final entry = await  _timeEntryService.clockIn(userId);
        if(mounted){
          setState((){
            activeTimeEntry = entry;
          });
          // HH:mm en formato 24 horas y si la hora solo tiena cifra, coloca un 0 delante. Hace lo mismo con los minutos 
          final clockInHour = DateFormat('HH:mm').format(entry!.clockIn.toLocal());
          SnackBarMessenger.showSucces('Fichaje de entrada realizado correctamente a las ${clockInHour}');
        }
      } else{
        //fichaje de salida
        await _timeEntryService.clockOut(activeTimeEntry!.id);
        //recupera este último fichaje que ya esta completo 
        final  lastEntry = await _timeEntryService.getLastCompletedTimeEntry(userId);
        if(mounted){
          setState((){
            lastTimeEntry= lastEntry;
            activeTimeEntry = null;
          });
          final currentTime = DateTime.now();
          final clockOutHour = DateFormat('HH:mm').format(currentTime);
          SnackBarMessenger.showSucces('Fichaje de salida correcto a las  ${clockOutHour}'); 
        }
      }
  
    } catch(error){
      SnackBarMessenger.showError("Error al realizar Fichaje: $error");
    }finally{
      if(mounted){
        setState(()=> _isProcessing= false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    //true: hay un fichaje de entrada activo, lo que implica que se esta trabajando
    //false: No hay un fichaje de entrada activo
    final isWorking = activeTimeEntry !=null;
    //formateo de la fecha 
    final DateFormat dateFormat= DateFormat('HH:mm - dd/MM/yyyy');

    return Center(
      child: _isLoading 
      ?  const CircularProgressIndicator.adaptive() 
      : Padding(
        padding: const EdgeInsets.all(40.0),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 400
          ),
          child: Column(
            mainAxisAlignment:MainAxisAlignment.center,
            children:[
              SizedBox(
                width: double.infinity,
                child: Card(
                  
                  elevation: 4,
                  shape:RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(16)
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column (
                      mainAxisAlignment: MainAxisAlignment.center,
                          children:[
                              
                              Text(
                                isWorking ? 'FICHAJE ENTRADA ACTIVO' : 'DESCONECTADO',
                                style: TextStyle(
                                  color: isWorking ? const Color(0xFF10A915) : Colors.grey,
                                  fontWeight: FontWeight.bold
                                )
                              ),
                               const SizedBox(
                                height: 8,
                              ),
                              Text(
                                isWorking 
                                ? '${dateFormat.format(activeTimeEntry!.clockIn.toLocal())}'
                                : lastTimeEntry!=null 
                                  ?'Última salida : ${dateFormat.format(lastTimeEntry!.clockOut!.toLocal())}'
                                  : 'Aún no hay registros' ,
                                style:TextStyle(
                                  fontWeight: FontWeight.bold
                                )
                              ),
                          ]
                        )
                    ),
                  ),
              ),
              SizedBox(
                height:30 ,
              ),
              
              
              SizedBox(
                height: 50,
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _isProcessing ? null : _handleClockInClockOut,  
                  icon: _isProcessing ? CircularProgressIndicator() : Icon(isWorking? Icons.run_circle : Icons.work),
                  label: Text(isWorking ? 'Registrar Salida': 'Registrar Entrada '),
                ),
              ),
              
            ]
          ),
        ),
      ) 
    );
  }
}