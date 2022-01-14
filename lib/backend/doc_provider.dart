import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/backend/document.dart';

class DocProvider extends ChangeNotifier {
  ApiProvider api;

  DocProvider(this.api);

  String? url;
  bool loading = false;
  Document? doc;



  fetch() async {
    loading = true;
    notifyListeners();

    doc = await api.fetchDoc(url);
    loading = false;
    notifyListeners();
  }

  vote() {}
}