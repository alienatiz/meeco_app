import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/data_model/document.dart';

class DocProvider extends ChangeNotifier {
  late final Client client;

  DocProvider({required this.client});

  late String url;
  bool loading = false;
  Document? doc;

  bool isVoted = false;
  int voteNum = 0;

  Future<Document> fetchDoc(String url) async {
    final document = await client.get(query: url);
    return Document.fromElement(
      parse(document.body).querySelector('article.bAtc')!,
    );
  }

  Future<int?> voteDoc(String url) async {
    final urlList = url.split('/');
    final mid = urlList[1];
    final srl = urlList[2];

    final req = await client.post(
        query: '/',
        body: {
          'target_srl': srl,
          'cur_mid': mid,
          'mid': mid,
          'module': 'document',
          'act': 'procDocumentVoteUp',
          '_rx_ajax_compat': 'XMLRPC',
          'vid': '',
        },
        headers: {
          'x-requested-with': 'XMLHttpRequest',
        },
        needsToken: true);

    final jsonResponse = jsonDecode(req.body);
    if (jsonResponse['error'] == 0) {
      return jsonResponse['voted_count'];
    } else {
      return -1;
    }
  }

  fetch() async {
    loading = true;
    notifyListeners();

    doc = await fetchDoc(url);
    voteNum = doc!.voteNum;
    isVoted = doc!.isVoted;
    loading = false;
    notifyListeners();
  }

  vote() async {
    isVoted = !isVoted;
    notifyListeners();

    voteNum = await voteDoc(url) ?? voteNum - 1;
    notifyListeners();
  }
}
