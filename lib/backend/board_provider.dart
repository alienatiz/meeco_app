import 'package:flutter/material.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/backend/api_provider.dart';

class BoardProvider extends ChangeNotifier {
  final ApiProvider api;

  List<BoardItem> items = [];
  String currentBoard = 'ITplus';
  int currentPage = 1;
  bool loading = false;

  BoardProvider(this.api);

  fetchItems() async {
    loading = true;
    notifyListeners();

    items.addAll(await api.fetchBoard(currentBoard, currentPage));
    currentPage++;
    loading = false;
    notifyListeners();
  }

  refresh(String board) async {
    if (currentBoard != board) {
      loading = true;
      notifyListeners();

      currentBoard = board;
      currentPage = 1;
      items = [];
      await fetchItems();
    }
  }
}
