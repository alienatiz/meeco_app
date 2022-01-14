import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/backend/doc_provider.dart';
import 'package:meeco_app/pages/doc_page.dart';
import 'package:provider/provider.dart';

import 'package:meeco_app/pages/main_page.dart';

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
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ApiProvider(),
        ),
        ChangeNotifierProvider(
          create: (context) =>
              BoardProvider(Provider.of<ApiProvider>(context, listen: false)),
        )
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
      home: const MainPage(),
      routes: {
        '/main': (_) => const MainPage(),
        '/doc': (_) => ChangeNotifierProvider(
              create: (context) =>
                  DocProvider(Provider.of<ApiProvider>(context, listen: false)),
              child: const DocPage(),
            ),
      },
    );
  }
}
