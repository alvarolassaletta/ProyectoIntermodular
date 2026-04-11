
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
//permite leer archivos en la carpeta assets con rootBundle 
import 'package:flutter/services.dart' show rootBundle;
// Permite usar Uint8List(lista de bytes)
import 'dart:typed_data'; 
// Para codificar el CSV a bytes
import 'dart:convert'; 
// Permite crear y diseñar documentos PDF desde cero usando una sintaxis idéntica a los widgets de Flutter.
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
// utilidad para mostrar snackBar de éxito o fallo 
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';
//contiene un metodo para calcular el tiempo trabajado  entre fichaje entrada y salida 
import 'package:proyecto_intermodular/utils/time_utils.dart';

// Abre el menú nativo del sistema operativo para compartir archivos (por WhatsApp, Email, Bluetooth, etc.).
import 'package:share_plus/share_plus.dart';
//paquete para trabajar y formatear con fechas 
import 'package:intl/intl.dart';

// importa el modelo time_entries 
import '../models/time_entries.dart';


/// Gestiona  la exportación de datos  de fichaje en formato CSV y PDF y la descarga y compartición
class ExportHelper {

  //Patrones  de formateo de fechas 
  //dd/MM/yyyy
  static final DateFormat _dateFormat= DateFormat('dd/MM/yyyy');
  //HH:mm
  static final DateFormat _timeFormat= DateFormat('HH:mm');


  ///  Muestra el  un Alert Dialog  para que el usuario seleccion el formato deseado para la descarga. 
  /// Recibe BuildContext para poder mostrar la alerta en pantalla y las lista de fichajes 
  static Future<void> showExportDialog(BuildContext context, List<TimeEntry> entries) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar registros'),
        content: const Text('Elige el formato de exportación:'),
        actions: [
          TextButton.icon(
            onPressed: () {
              context.pop();
              _exportToCsv(entries);
            },
            icon: const Icon(Icons.table_chart_outlined),
            label: const Text('CSV'),
          ),
          TextButton.icon(
            onPressed: () {
              context.pop();
              _exportToPdf(entries);
            },
            icon: const Icon(Icons.picture_as_pdf_outlined, color: Colors.red),
            label: const Text('PDF', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  /// Genera un archivo en CSV  con los fichajes
  /// Crea el archivo directamente en la memoria RAM codificando el texto a bytes (Uint8List) para garantizar la compatibilidad multiplataforma (Web, Android e iOS). 
  ///Invoca el menú de compartir nativo o fuerza la descarga en navegadores.
  static Future<void> _exportToCsv(List<TimeEntry> entries) async {
    try{
    
      final buffer = StringBuffer();
      //Cabeceras del CSV
      buffer.writeln('Fecha entrada,Hora entrada,Fecha salida,Hora salida,Tiempo trabajado');

      for (final entry in entries) {
        final clockIn = entry.clockIn.toLocal();
        final clockOut = entry.clockOut?.toLocal();

      buffer.writeln(
        //formatea fecha (dd/MM/yyyy) y hora ('HH:mm')de  entrada
        '${_dateFormat.format(clockIn)},'
        '${_timeFormat.format(clockIn)},'
         //formatea  fecha (dd/MM/yyyy) y hora ('HH:mm')de   salida 
        '${clockOut != null ? _dateFormat.format(clockOut) : 'En curso'},'
        '${clockOut != null ? _timeFormat.format(clockOut) : 'En curso'},'
        '${TimeUtils.calculateDuration(clockIn, clockOut)}',
      );
    }
      //Convierte  el texto a Bytes (RAM) para soporte web 
      final bytes = utf8.encode(buffer.toString());
      
      // Crea el archivo directamente en memoria
      final xFile = XFile.fromData(
        Uint8List.fromList(bytes), 
        mimeType: 'text/csv', 
        name: 'historial_fichajes.csv'
      );
     
     //Dispara la accion de compartir/descargar 
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Historial de fichajes en CSV',
        ),
      );
      
    }catch(e){
      debugPrint('Error al exportar a CSV: $e');
      SnackBarMessenger.showError('Error al exportar a CSV.');
    }
  }

  /// Genera un archivo en PDF  con los fichajes
   /// Carga fuentes TrueType (.ttf) locales desde la carpeta `assets` para asegurar
  /// el correcto dibujado de caracteres especiales (tildes, eñes) de forma offline.
  /// Dibuja una tabla con los datos y gestiona el archivo resultante en memoria
  /// para su descarga o compartición.
  static Future<void> _exportToPdf(List<TimeEntry> entries) async {
    try{
      final pdf = pw.Document();

      //carga las fuentes desde el directorio assets 
      // Roboto-Regular.ttf
      final regularData= await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
      final fontRegular = pw.Font.ttf(regularData);
      // Roboto-Bold.ttf
      final boldData = await rootBundle.load('assets/fonts/Roboto-Bold.ttf');
      final fontBold = pw.Font.ttf(boldData);

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          //inyecta el tema para aplicar fuentes al documento 
          theme: pw.ThemeData.withFont(
            base: fontRegular,
            bold: fontBold,
          ),

          build: (context) => [
            pw.Header(
              level: 0,
              child: pw.Text('Historial de Fichajes', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            ),
            pw.SizedBox(height: 16),
            //crea la tabla 
            pw.TableHelper.fromTextArray(
              headers: ['Fecha entrada', 'Hora entrada', 'Fecha salida', 'Hora salida', 'Tiempo'],
              data: entries.map((entry) {
                final clockIn = entry.clockIn.toLocal();
                final clockOut = entry.clockOut?.toLocal();
                return [
                  //formateo fecha (dd/MM/yyyy) y hora ('HH:mm')de  entrada
                  _dateFormat.format(clockIn),
                  _timeFormat.format(clockIn),
                   //formatea  fecha (dd/MM/yyyy) y hora ('HH:mm')de   salida 
                  clockOut != null ? _dateFormat.format(clockOut) : 'En curso',
                  clockOut != null ? _timeFormat.format(clockOut) : 'En curso',
                  TimeUtils.calculateDuration(clockIn, clockOut),
                ];
              }).toList(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              cellHeight: 30,
              cellAlignments: {
                0: pw.Alignment.centerLeft, 1: pw.Alignment.center,
                2: pw.Alignment.centerLeft, 3: pw.Alignment.center,
                4: pw.Alignment.center,
              },
            ),
          ],
        ),
      );
     // La función pdf.save() retorna directamente los Bytes para almacenar en RAM
      final bytes = await pdf.save();
      
      // Creamos el archivo en memoria
      final xFile = XFile.fromData(
        bytes, 
        mimeType: 'application/pdf', 
        name: 'historial_fichajes.pdf'
      );

      // Dispara la acción de compartir/descargar
      await SharePlus.instance.share(
        ShareParams(
          files: [xFile],
          text: 'Historial de fichajes en PDFfñlu',
        ),
      );

    }catch(e){
      debugPrint('Error al exportar a PDF: $e');
      SnackBarMessenger.showError("Error al exportar a PDF");
    }
  }
}