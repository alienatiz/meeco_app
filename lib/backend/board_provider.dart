import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:html/dom.dart' as dom;
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';

class BoardProvider extends ChangeNotifier {
  late final Client client;

  List<BoardItem> items = [];
  String currentBoard = 'ITplus';
  int currentPage = 1;
  bool loading = false;

  BoardProvider({required this.client});

  fetchItems() async {
    loading = true;
    notifyListeners();

    items.addAll(await _fetchBoard(currentBoard, currentPage));
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

  Future<List<BoardItem>> _fetchBoard(String board, int page) async {
    final url = "/" + (page == 1 ? board : "index.php?mid=$board&page=$page");
    var docList = await client.get(query: url);

    var docListBody = parse(docList.body)
        .querySelectorAll('table.ldn > tbody > tr')
        .map(_parseBoard)
        .toList();

    if (page > 1) {
      docListBody = docListBody.where((element) => !element.isNotice).toList();
    }

    return docListBody;
  }

  BoardItem _parseBoard(dom.Element el) {
    final String? categoryText = _getInnerText(el, 'td.title > a.boardname');
    final String? url = _replaceUrl(
      el.querySelector('td.title > a.title_a')?.attributes['href'] ?? '/',
    );
    final String? title = _getInnerText(el, 'td.title > a.title_a > span');
    final int commentNum = int.parse(
        _getInnerText(el, 'td.title > a[title="Replies"]')
                ?.replaceAll(RegExp('[\\[\\]]'), '') ??
            '0');
    // final memberSrl = element.querySelector('td.author > a')?.className ?? '0';
    final String? author = _getInnerText(el, 'td.author > a');
    final numData =
        el.querySelectorAll('td.num').map((e) => e.text.trim()).toList();
    final String time = numData[1];
    final int voteNum = int.tryParse(numData[2]) ?? 0;
    final int viewNum = int.tryParse(numData[3]) ?? 0;
    final isNotice = numData[0] == "공지";

    return BoardItem(
      url: url ?? '',
      categoryText: categoryText ?? '--',
      title: title ?? '제목',
      author: author ?? '작성자',
      time: time,
      viewNum: viewNum,
      voteNum: voteNum,
      commentNum: commentNum,
      isNotice: isNotice,
    );
  }

  String _replaceUrl(String url) {
    if (double.tryParse(url.split('/').last) == null) {
      final urlMatches = RegExp('mid=([A-Za-z]+)/document_srl=([0-9]+)')
          .allMatches(url)
          .elementAt(0);
      return '/${urlMatches.group(1)}/${urlMatches.group(2)}';
    }
    return url;
  }

  String? _getInnerText(dom.Element element, String query) {
    return element.querySelector(query)?.text.trim();
  }
}
