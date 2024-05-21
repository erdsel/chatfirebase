import 'package:chatfirebase/pages/home_page.dart';
import 'package:chatfirebase/pages/login.dart';
import 'package:chatfirebase/pages/login_page.dart';
import 'package:chatfirebase/pages/splash_screen.dart';
import 'package:chatfirebase/providers/authentication_provider.dart';
import 'package:flutter/material.dart';


import 'package:provider/provider.dart';

//Services
import './services/navigation_service.dart';



//Pages


void main() {
  runApp(
    SplashPage(
      key: UniqueKey(),
      onInitializationComplete: () {
        runApp(
          MainApp(),
        );
      },
    ),
  );
}

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthenticationProvider>(
          create: (BuildContext _context) {
            return AuthenticationProvider();
          },
        )
      ],
      child: MaterialApp(
        title: 'Chatify',
        theme: ThemeData(
          backgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
          scaffoldBackgroundColor: Color.fromRGBO(36, 35, 49, 1.0),
          bottomNavigationBarTheme: BottomNavigationBarThemeData(
            backgroundColor: Color.fromRGBO(30, 29, 37, 1.0),
          ),
        ),
        navigatorKey: NavigationService.navigatorKey,
        initialRoute: '/login',
        routes: {
          '/login': (BuildContext _context) => LoginPage(),
          '/home': (BuildContext _context) => HomePage(),

        },
      ),
    );
  }
}