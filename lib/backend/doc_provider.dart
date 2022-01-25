import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/backend/data_model/document.dart';

class DocProvider extends ChangeNotifier {
  ApiProvider api;

  DocProvider(this.api);

  String? url;
  bool loading = false;
  Document? doc;

  bool isVoted = false;
  int voteNum = 0;



  fetch() async {
    loading = true;
    notifyListeners();

    doc = await api.fetchDoc(url);
    voteNum = doc!.voteNum;
    isVoted = doc!.isVoted;
    loading = false;
    notifyListeners();
  }

  vote() async {
    isVoted = !isVoted;
    notifyListeners();

    voteNum = await api.voteDoc(url!) ?? voteNum - 1;
    notifyListeners();
  }
}