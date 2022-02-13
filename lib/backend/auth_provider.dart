import 'package:flutter/material.dart';
import 'package:meeco_app/backend/client.dart';

class AuthProvider extends ChangeNotifier {
  late final Client client;
  late final bool isLoggedIn;

  AuthProvider({required this.client}) : isLoggedIn = client.isLoggedIn;

  bool loading = false;

  Future<void> logIn({required String id, required String pw}) async {
    const String logInUrl = '/index.php?mid=index&act=dispMemberLoginForm';

    if (!isLoggedIn) {
      loading = true;
      notifyListeners();

      await client.post(
        query: logInUrl,
        body: {
          'act': 'procMemberLogin',
          'user_id': id,
          'password': pw,
          'keep_signed': 'Y',
        },
        needsToken: true,
      );

      loading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    loading = true;
    notifyListeners();

    await client.get(query: '/index.php?act=dispMemberLogout&mid=index');
    loading = false;
    notifyListeners();
  }
}
