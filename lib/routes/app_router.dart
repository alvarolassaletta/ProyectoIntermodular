import 'package:go_router/go_router.dart';
import 'package:proyecto_intermodular/screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/splash_screen.dart';

///navegacion anidada dentro de homeScreen.
//navegacion del menu NavigationBar
import  '../screens/clock_screen.dart';
import '../screens/summary_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/time_entry_record_screen.dart'; 

final GoRouter appRouter = GoRouter(
  initialLocation:  '/splash',
  routes: [
    GoRoute(
      path:'/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path:'/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path:'/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path:'/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    StatefulShellRoute.indexedStack(
      builder: (context,state,navigationShell){
        return HomeScreen(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes:[
            GoRoute(
              path:'/home',  
              builder: (context,state) => const ClockScreen(),
            )
          ]
        ),
        StatefulShellBranch(
          routes:[
            GoRoute(
              path:'/time_entry_record', 
              builder: (context,state) => const TimeEntryRecordScreen(),
            )
          ]
        ),
        StatefulShellBranch(
          routes:[
            GoRoute(
              path:'/summary', 
              builder: (context,state) => SummaryScreen(),
            )
          ]
        ),
        StatefulShellBranch(
          routes:[
            GoRoute(
              path:'/profile', 
              builder: (context,state) => const ProfileScreen(),
            )
          ]
        ),
      ]
    )
  ]
);

