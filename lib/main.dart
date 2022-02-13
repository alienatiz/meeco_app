import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/backend/auth_provider.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/doc_provider.dart';
import 'package:meeco_app/backend/tab_provider.dart';
import 'package:meeco_app/backend/theme_provider.dart';
import 'package:meeco_app/constants.dart';
import 'package:meeco_app/pages/doc_page.dart';
import 'package:meeco_app/pages/menu_page.dart';
import 'package:meeco_app/pages/profile_page.dart';
import 'package:meeco_app/pages/write_page.dart';
import 'package:provider/provider.dart';

import 'package:meeco_app/pages/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

//인증서 만료 문제를 위해..
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Client(
            initialCookie: prefs.getString('cookies'),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProvider(
            client: Provider.of<Client>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => BoardProvider(
            client: Provider.of<Client>(context, listen: false),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => TabProvider(
            initialIndex: prefs.getInt('currentIndex') ?? 0,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(
            themeModeString: prefs.getString('themeMode') ?? 'ThemeMode.system',
            isDark: prefs.getBool('isDark') ?? false,
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Meeco App',
      theme: generateTheme(),
      darkTheme: generateTheme(isDark: true),
      themeMode: Provider.of<ThemeProvider>(context).themeMode,
      home: const MainPage(),
      routes: {
        '/main': (_) => const MainPage(),
        '/doc': (_) => ChangeNotifierProvider(
              create: (context) => DocProvider(
                client: Provider.of<Client>(context, listen: false),
              ),
              child: const DocPage(),
            ),
        '/menu': (_) => const MenuPage(),
        '/user': (_) => const UserPage(),
        '/write': (_) => const WritePage(),
      },
    );
  }
}
