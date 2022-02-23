import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';

class BoardProvider extends ChangeNotifier {
  late final Client client;

  List<BoardItem> items = [];
  String currentBoard = 'ITplus';
  int currentPage = 1;
  bool loading = false;

  BoardProvider({required this.client});

  Future<void> fetchItems() async {
    loading = true;
    notifyListeners();

    items.addAll(await _fetchBoard(currentBoard, currentPage));
    var urlList = items.map((e) => e.url).toSet();
    items.retainWhere((x) => urlList.remove(x.url));
    currentPage++;
    loading = false;
    notifyListeners();
  }

  Future<void> switchBoard(String board) async {
    if (currentBoard != board) {
      loading = true;
      notifyListeners();

      currentBoard = board;
      currentPage = 1;
      items = [];
      await fetchItems();
    }
  }

  Future<void> refresh() async {
    loading = true;
    notifyListeners();

    currentPage = 1;
    items = [];
    await fetchItems();
  }

  Future<List<BoardItem>> _fetchBoard(String board, int page) async {
    final url = "/" + (page == 1 ? board : "index.php?mid=$board&page=$page");
    var docList = await client.get(query: url);

    var docListBody = parse(docList.body)
        .querySelectorAll('table.ldn > tbody > tr')
        .map(BoardItem.fromElement)
        .toList();

    if (page > 1) {
      return docListBody.where((element) => !element.isNotice).toList();
    }

    return docListBody;
  }
}
