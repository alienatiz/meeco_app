import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Client extends ChangeNotifier {
  static const String baseUrl = 'https://meeco.kr';

  late CookieJar _cookieJar;
  late bool isLoggedIn;

  Client({String? initialCookie}) {
    _cookieJar = CookieJar(cookies: initialCookie);
    isLoggedIn = _cookieJar.cookies?['rx_autologin'] != null;
  }

  Future<http.Response> get({
    required String query,
    Map<String, String>? headers,
    bool needsToken = false,
  }) async {
    String? csrfToken;
    if (needsToken) csrfToken = await _getToken(query);
    var req = await http.get(Uri.parse(baseUrl + query), headers: {
      ...?headers,
      if (needsToken) 'X-CSRF-Token': csrfToken!,
    });

    _cookieJar.saveCookies(req.headers['set-cookie']);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('cookies', _cookieJar.cookies.toString());
      prefs.setBool('isLoggedIn', isLoggedIn);
    });
    isLoggedIn = _cookieJar.cookies?['rx_autologin'] != null;
    notifyListeners();

    return req;
  }

  Future<http.Response> post({
    required String query,
    required Map<String, String> body,
    Map<String, String>? headers,
    bool needsToken = false,
  }) async {
    String? csrfToken;
    if (needsToken) csrfToken = await _getToken(query);

    var req = await http.post(Uri.parse(baseUrl + query), headers: {
      ...?headers,
      if (needsToken) 'X-CSRF-Token': csrfToken!,
    }, body: {
      ...body,
      if (needsToken) '_rx_csrf_token': csrfToken!,
    });

    _cookieJar.saveCookies(req.headers['set-cookie']);
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('cookies', _cookieJar.cookies.toString());
      prefs.setBool('isLoggedIn', isLoggedIn);
    });
    isLoggedIn = _cookieJar.cookies?['rx_autologin'] != null;
    notifyListeners();

    return req;
  }

  Future<String> _getToken(String query) async {
    final req = await http.get(Uri.parse(baseUrl + query));
    String? csrfToken = parse(req.body)
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
    if (csrfToken == null) {
      throw Exception('CSRF Token not found');
    }
    return csrfToken;
  }
}

class CookieJar {
  Map<String, String>? cookies = {};

  CookieJar({String? cookies}) {
    cookies?.split(';').forEach((e) {
      var cookie = e.split(';')[0].split('=');
      this.cookies![cookie[0]] = cookie[1];
    });
  }

  saveCookies(String? rawCookies) {
    rawCookies?.split(RegExp(r'(?<=)(,)(?=[^;]+?=)')).forEach((e) {
      var cookie = e.split(';')[0].split('=');
      cookies![cookie[0]] = cookie[1];
    });
    cookies?.removeWhere((k, v) => v == 'deleted');
  }

  @override
  String toString() {
    List cookieToString = [];
    cookies?.forEach((k, v) => cookieToString.add('$k=$v'));
    return cookieToString.join(';');
  }
}
