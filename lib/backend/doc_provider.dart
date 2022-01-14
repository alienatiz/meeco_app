import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/backend/document.dart';

class DocProvider extends ChangeNotifier {
  ApiProvider api;

  DocProvider(this.api);

  String? url;
  bool loading = false;
  String? doc;



  fetch() async {
    loading = true;
    print('start loading: $loading');
    notifyListeners();

    doc = await api.fetchDoc(url);
    loading = false;
    print('loaded: $loading');

    notifyListeners();
  }

  vote() {}
}