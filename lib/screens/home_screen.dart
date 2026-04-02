import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:proyecto_intermodular/components/gradient_background.dart';
import 'package:proyecto_intermodular/core/app_colors.dart';
import 'package:proyecto_intermodular/services/auth_service.dart';
import 'package:proyecto_intermodular/utils/auth_error_translator.dart';
import 'package:proyecto_intermodular/utils/snack_bar_messenger.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; 

class HomeScreen extends StatefulWidget {

  ///Es un controlador generado por go_router a partir de StatefulShellRoute y branch del app_router
  /// Contiene el estado visual (IndexedStack), mantiene el historial independiente de cada pestaña 
  /// y proporciona los métodos para leer la pestaña actual (currentIndex) o cambiar entre ellas (goBranch).
  final StatefulNavigationShell  navigationShell; 
  
  const HomeScreen(
    {super.key, required  this.navigationShell}
  );

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}



class _HomeScreenState extends State<HomeScreen> {

  //instancia de AuthSerive pra poder usar signOut
  final AuthService _authService = AuthService();

  // La propiedad destinations de NavigationBar require una lista de NavigationDestination
  final List<NavigationDestination> _mobileDestinatios = const [
    NavigationDestination(
      icon: Icon(Icons.punch_clock,color:AppColors.primaryIconsColor),
      label: 'Fichar',
    ),
    NavigationDestination(
      icon: Icon(Icons.list_alt,color: AppColors.primaryIconsColor,),
      label: 'Historial Fichajes',
    ),
    NavigationDestination(
      icon: Icon(Icons.bar_chart,color: AppColors.primaryIconsColor,),
      label: 'Cómputo Horas',
    ),
    NavigationDestination(
      icon: Icon(Icons.person,color:AppColors.primaryIconsColor),
      label: 'Perfil',
    ),
  ];

  /// la propiedad destinations de NavigationRail toma una lista de NavigationRailDestination
  final  List <NavigationRailDestination> _desktopDestinations = const [
     NavigationRailDestination(
      icon: Icon(Icons.punch_clock),
      label: Text('Fichar'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.list_alt),
      label: Text('Historial Fichajes'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.bar_chart),
      label: Text('Cómputo horas'),
    ),
    NavigationRailDestination(
      icon: Icon(Icons.person),
      label: Text('Perfil'),
    ),
    

  ];

  ///Recibe el index del icono  pulsado en el navigationBar o NavigationRail y cambia a esa pantalla con goBranch 
  ///La pantalla ocupara el espacio debajo por AppBar y la Barra de navegacion 
  void _onTap(int index){
    widget.navigationShell.goBranch(
      index,
      initialLocation:  index== widget.navigationShell.currentIndex,
      );
  }

  /// Metodo para cerrar sesion. Sale de homeScreen hacia la pantalla login sin que se pueda volver a homeScreen sin hacer de nuevo login
  ///Si ocurre un error muestra un mensaje adaptado (Fallo conexion, sesion caducada, etc)
  Future <void> _signOut() async{
    try{
        await _authService.signOut();
        
        if(mounted){
          //salimos de homeScreen a login sin que se pueda volver atras 
          context.go('/login');
       }
    }on AuthException catch(error){
      if(mounted){
        final translatedErrorMessage = AuthErrorTranslator.translate(error);
        SnackBarMessenger.showError(translatedErrorMessage);
      }
    }catch (error){
      if(mounted){
        SnackBarMessenger.showError('Error inesperado al cerrar sesión. Inténtalo de nuevo');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDesktop = MediaQuery.of(context).size.width >=600; 
    // AppbAR solo se usará cuando la pantalla sea de movil
    // Si la Pantalla es desktop, no se mostrara el AppBar
    final PreferredSizeWidget mobileAppBar = AppBar(
        title: Text("Registro de Fichaje"),
        centerTitle:true, 
        //por defecto, los componentes de Material Design llevan un color por defecto.Hay que hacerlo transparente para que se vea el fondo del container. Lo mismo se hace para el NavigationBar  y el NavigationRail
        backgroundColor:  Colors.transparent,
        flexibleSpace: Container(
          decoration: GradientBackground.backgroundDecorationWithShadow(const Offset(0,4))
        ),
        actions:[ 
          //----------------------------------------------------
          //   CERRAR SESIÓN (MOVIL) 
          //-----------------------------------------------------
          Padding(
            //padding solo a la derecha para separar el IconButton del borde derecho
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: const Icon(Icons.logout,color:AppColors.primaryIconsColor,),
              tooltip: 'CerrarSesión',
              onPressed: () => _signOut()
            ),
          )
        ]
      );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      //Si la pantalla es de movil se muestra el AppBar.
      //Si es desktop, el appBar no se muestra
      appBar: isDesktop ? null : mobileAppBar,
      //-----------------------------------------------------
      //   NAVIGATION BAR ( SOLO MOVIL) 
      //-----------------------------------------------------
      // Si la pantalla es de movil,  mostramos el NavigatioBar, En caso contrario, no se muestra el navigationBar
      bottomNavigationBar:  isDesktop ? null : Container(
        decoration: GradientBackground.backgroundDecoration,
        child: NavigationBar(
          backgroundColor: Colors.transparent,
          selectedIndex:  widget.navigationShell.currentIndex,
          onDestinationSelected: _onTap,
          destinations: _mobileDestinatios,
    
        ),
      ),
      body: Row(
        children: [
          //-----------------------------------------------------
          //  NAVIGATION RAIL ( SOLO DESKTOP)
          //-----------------------------------------------------
          if (isDesktop)
            Container(
              width: 150,
              // Degradado con sombra a la derecha 
              decoration: GradientBackground.backgroundDecorationWithShadow(const Offset(4, 0)),
              //  Column para  permite usar Expanded y poner el botón abajo
              child: Column(
                children: [
                  // Expanded empuja el menú hacia arriba y el botón hacia abajo
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: NavigationRail(
                        backgroundColor: Colors.transparent,
                        unselectedIconTheme: IconThemeData(color: AppColors.primaryIconsColor),
                        selectedIndex: widget.navigationShell.currentIndex,
                        onDestinationSelected: _onTap,
                        labelType: NavigationRailLabelType.all,
                        destinations: _desktopDestinations,
                      ),
                    ),
                  ),
                  //----------------------------------------------------
                  //   CERRAR SESIÓN (DESKTOP) 
                  //----------------------------------------------------
                  // Botón de Cerrar Sesión anclado abajo del todo en PC
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0),
                    child: IconButton(
                      icon: const Icon(Icons.logout,color: AppColors.primaryIconsColor,),
                      tooltip: 'Cerrar Sesión',
                      onPressed: () => _signOut(),
                    ),
                  )
                ],
              ),
            ),
          //----------------------------------------------------- 
          // AREA A OCUPAR POR LAS PANTALLAS ANIDADAS DE HOME SCREEN (fichar, historial, perfil y resumen)
          //-----------------------------------------------------
          // La pantalla 'anidada' actual ocupara el espacio restante
          Expanded(
              child: widget.navigationShell,
            )
        ]
      )
    );
  }
}