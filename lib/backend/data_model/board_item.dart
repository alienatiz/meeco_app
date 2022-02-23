import 'package:html/dom.dart' as dom;

class BoardItem {
  String url;

  bool isNotice;

  String categoryText;
  String title;
  String author;

  String time;
  int viewNum;
  int voteNum;
  int commentNum;

  BoardItem({
    required this.url,
    required this.categoryText,
    required this.title,
    required this.author,
    required this.time,
    required this.viewNum,
    required this.voteNum,
    required this.commentNum,
    this.isNotice = false,
  });

  factory BoardItem.fromElement(dom.Element element) {
    final tdList = element.querySelectorAll('td');

    final bool isNotice = _getIsNotice(tdList[0]);

    final Map<String, dynamic> titleData = _parseTitle(tdList[1]);
    final String categoryText = titleData['categoryText'];
    final String url = titleData['url'];
    final String title = titleData['title'];
    final int commentNum = titleData['commentNum'];

    final String author = _getAuthor(tdList[2]);
    final String time = _getTime(tdList[3]);
    final int voteNum = _getNum(tdList[4]);
    final int viewNum = _getNum(tdList[5]);

    return BoardItem(
      url: url,
      isNotice: isNotice,
      categoryText: categoryText,
      title: title,
      author: author,
      time: time,
      viewNum: viewNum,
      voteNum: voteNum,
      commentNum: commentNum,
    );
  }

  static bool _getIsNotice(dom.Element element) {
    return element.text == '공지';
  }

  static Map<String, dynamic> _parseTitle(dom.Element element) {
    final List<dom.Element> children = element.querySelectorAll('a');

    final String categoryText = children[0].text;
    final String url = children[1].attributes['href'] ?? '/';
    final String title = children[1].querySelector('span')?.text ?? '제목';
    late final int commentNum;
    if (children.length == 3) {
      commentNum =
          int.parse(children[2].text.trim().replaceAll(RegExp('[\\[\\]]'), ''));
    } else {
      commentNum = 0;
    }

    return {
      'categoryText': categoryText,
      'title': title,
      'commentNum': commentNum,
      'url': url,
    };
  }

  static String _getAuthor(dom.Element element) {
    return element.querySelector('a')?.text ?? '작성자';
  }

  static String _getTime(dom.Element element) {
    return element.text;
  }

  static int _getNum(dom.Element element) {
    final String numString = element.querySelector('span')?.text ?? '0';
    return int.parse(numString);
  }
}
