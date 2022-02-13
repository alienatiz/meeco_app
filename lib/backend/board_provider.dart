import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/backend/data_model/category.dart';

class BoardProvider extends ChangeNotifier {
  late final Client client;

  List<BoardItem> items = [];
  String currentBoard = 'ITplus';
  int currentPage = 1;
  bool loading = false;

  BoardProvider({required this.client});

  Future<List<BoardItem>> fetchBoard(String board, int page) async {
    final url = "/" + (page == 1 ? board : "index.php?mid=$board&page=$page");
    var docList = await client.get(query: url);

    var docListBody =
        parse(docList.body).querySelectorAll('table.ldn > tbody > tr').map((e) {
      final numData = e.querySelectorAll("td.num");
      var commentNum = e.querySelector("td.title > a.num")?.text.trim();
      commentNum = commentNum?.substring(1, commentNum.length - 1);

      final title = e.querySelector('td.title');

      var url = title?.querySelector("span")?.parentNode?.attributes['href'] ??
          title?.querySelector('a')?.attributes['href'];

      if (double.tryParse(url?.split('/').last ?? '') == null) {
        url = '/' +
            RegExp('mid=[A-Za-z]+').stringMatch(url!)!.substring(4) +
            '/' +
            RegExp('document_srl=[0-9]+').stringMatch(url)!.substring(13);
      }

      final boardName = title?.querySelector('a.boardname');
      final isNotice = numData[0].text.trim() == "공지";

      return BoardItem(
        url ?? '',
        Category(
          isNotice ? '공지' : boardName?.text ?? '--',
          boardName?.attributes['href'] ?? '--',
        ),
        title?.querySelector('span')?.text.trim() ?? title?.text.trim() ?? '제목',
        e.querySelector('td.author > a')?.text ?? '작성자',
        numData[1].text,
        board == 'PricePlus'
            ? int.parse(numData[2].querySelector('span')?.text ?? "0")
            : int.parse(numData[3].querySelector('span')?.text ?? "0"),
        board == 'PricePlus'
            ? 0
            : int.parse(numData[2].querySelector('span')?.text ?? "0"),
        int.parse(commentNum ?? "0"),
        isNotice: isNotice,
      );
    }).toList();

    if (page > 1) {
      docListBody = docListBody.where((element) => !element.isNotice).toList();
    }

    return docListBody;
  }

  fetchItems() async {
    loading = true;
    notifyListeners();

    items.addAll(await fetchBoard(currentBoard, currentPage));
    var urlList = items.map((e) => e.url).toSet();
    items.retainWhere((x) => urlList.remove(x.url));
    currentPage++;
    loading = false;
    notifyListeners();
  }

  switchBoard(String board) async {
    if (currentBoard != board) {
      loading = true;
      notifyListeners();

      currentBoard = board;
      currentPage = 1;
      items = [];
      await fetchItems();
    }
  }

  refresh() async {
    loading = true;
    notifyListeners();

    currentPage = 1;
    items = [];
    await fetchItems();
  }
}
