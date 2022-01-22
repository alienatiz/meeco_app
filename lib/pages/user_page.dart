import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0x78bfbfbf),
        // const Color(0xff4c5c84),
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: TextButton(
          child: const Text(
            '로그아웃',
            style: TextStyle(
              color: Colors.red,
              fontSize: 20,
            ),
          ),
          onPressed: () async {
            await apiProvider.logOut();
            if (!apiProvider.isLoggedIn) {
              Navigator.pop(context);
            }
          },
        ),
      ),
    );
  }
}
