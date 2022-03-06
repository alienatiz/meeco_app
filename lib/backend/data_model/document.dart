import 'package:meeco_app/backend/data_model/comment.dart';
import 'package:html/dom.dart' as dom;

class Document {
  String time;

  bool isVoted;
  String title;
  String author;
  int authorSrl;
  String profileImgUrl;
  String body;

  int viewNum;
  int voteNum;
  int commentNum;

  List<Comment>? comments;

  Document({
    required this.time,
    required this.isVoted,
    required this.title,
    required this.author,
    required this.authorSrl,
    required this.profileImgUrl,
    required this.body,
    required this.viewNum,
    required this.voteNum,
    required this.commentNum,
    this.comments,
  });

  factory Document.fromElement(dom.Element element) {
    final header = element.querySelector('header.atc-hd')!;
    final article = element.querySelector('div.atc-wrap')!;

    final Map<String, dynamic> headerData = _parseHeader(header);
    final Map<String, dynamic> articleData = _parseArticle(article);

    final String profileImgUrl = headerData['profileImgUrl'];
    final String title = headerData['title'];
    final int authorSrl = headerData['authorSrl'];
    final String author = headerData['author'];
    final int viewNum = headerData['viewNum'];
    final String time = headerData['time'];

    final String body = articleData['body'];
    final int voteNum = articleData['voteNum'];
    final bool isVoted = articleData['isVoted'];

    final Map<String, dynamic> elementData = _parseElement(element);

    final int commentNum = elementData['commentNum'];
    final List<Comment> comments = elementData['comments'];

    return Document(
      time: time,
      isVoted: isVoted,
      title: title,
      author: author,
      authorSrl: authorSrl,
      profileImgUrl: profileImgUrl,
      body: body,
      viewNum: viewNum,
      voteNum: voteNum,
      commentNum: commentNum,
      comments: comments,
    );
  }

  static Map<String, dynamic> _parseHeader(dom.Element header) {
    final profileImgUrl =
        header.querySelector('div.bPf > img.bPf-img')!.attributes['src'];
    final title = header.querySelector('h1.atc-title > a.title_a')!.text;
    final author = header.querySelector('ul.ldd-title-under > li > a')!.text;
    final authorSrl = int.parse(header
            .querySelector('ul.ldd-title-under > li > a')
            ?.className
            .substring(8) ??
        '0');
    final viewNum =
        int.parse(header.querySelector('li > span.num')?.text ?? '0');
    final time = header.querySelector('li.num')?.text;

    return {
      'profileImgUrl': profileImgUrl,
      'title': title,
      'author': author,
      'authorSrl': authorSrl,
      'viewNum': viewNum,
      'time': time,
    };
  }

  static Map<String, dynamic> _parseArticle(dom.Element article) {
    final body = article.querySelector('div.xe_content')!.innerHtml;
    final voteNum = int.parse(
        article.querySelector('a.atc-vote-bt > span.num')?.text ?? '0');
    final isVoted =
        article.querySelector('a.atc-vote-bt')?.classes.contains('up_on') ??
            false;

    return {
      'body': body,
      'voteNum': voteNum,
      'isVoted': isVoted,
    };
  }

  static Map<String, dynamic> _parseElement(dom.Element element) {
    final commentNum =
        int.parse(element.querySelector('section#bCmt span.num')?.text ?? '0');
    final comments = element
        .querySelectorAll('div.cmt-list > article')
        .map(Comment.fromElement)
        .toList();

    return {
      'commentNum': commentNum,
      'comments': comments,
    };
  }
}
