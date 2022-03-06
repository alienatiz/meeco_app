import 'package:html/dom.dart' as dom;

class Comment {
  bool isDeleted;

  bool isReply = false;
  String? replyTo;

  String time;

  String author;
  int authorSrl;
  String profileImgUrl;
  String body;

  int voteNum;
  bool isVoted;

  Comment({
    required this.isReply,
    required this.time,
    required this.author,
    required this.authorSrl,
    required this.profileImgUrl,
    required this.body,
    required this.voteNum,
    this.isDeleted = false,
    this.isVoted = false,
    this.replyTo,
  });

  factory Comment.fromElement(dom.Element element) {
    final Map<String, dynamic> replyInfo = _getReplyInfo(element);
    final bool isReply = replyInfo['isReply'];
    final String? replyTo = replyInfo['replyTo'];
    final String profileImgUrl = _getProfileImgUrl(element);

    final Map<String, dynamic> header = _getHeader(element);
    final String time = header['time'];
    final String author = header['author'];
    final int authorSrl = header['authorSrl'];

    final String body = _getBody(element);

    final Map<String, dynamic> voteInfo = _getVoteInfo(element);
    final int voteNum = voteInfo['voteNum'];
    final bool isVoted = voteInfo['isVoted'];

    return Comment(
      isReply: isReply,
      replyTo: replyTo,
      profileImgUrl: profileImgUrl,
      time: time,
      author: author,
      authorSrl: authorSrl,
      body: body,
      voteNum: voteNum,
      isVoted: isVoted,
    );
  }

  static Map<String, dynamic> _getReplyInfo(dom.Element element) {
    final bool isReply = element.classes.contains('reply');
    late final String? replyTo = element.querySelector('span.parent')?.text;

    return {
      'isReply': isReply,
      'replyTo': replyTo,
    };
  }

  static String _getProfileImgUrl(dom.Element element) {
    const String defaultProfileImgUrl =
        'https://meeco.kr/layouts/colorize02_layout/images/profile.png';
    final String profileImgUrl =
        element.querySelector('img.bPf-img')?.attributes['src'] ??
            defaultProfileImgUrl;
    return profileImgUrl;
  }

  static Map<String, dynamic> _getHeader(dom.Element element) {
    final header = element.querySelector('header.author')!;
    final String time = header.querySelector('div.date')!.text;
    final String author = header.querySelector('a.member')?.text ?? '닉네임';
    final int authorSrl = int.parse(header
            .querySelector('a.member')
            ?.classes
            .where((element) => element.startsWith('member_'))
            .first
            .substring(7) ??
        '0');
    return {
      'time': time,
      'author': author,
      'authorSrl': authorSrl,
    };
  }

  static String _getBody(dom.Element element) =>
      element.querySelector('div.xe_content')?.innerHtml ?? '삭제됨';

  static Map<String, dynamic> _getVoteInfo(dom.Element element) {
    final int voteNum = int.parse(
        element.querySelector('a.cmt-vote-up > span')?.text.trim() ?? '0');
    final bool isVoted = element
            .querySelector('div.cmt-vote')
            ?.classes
            .contains('cmt_vote_on') ??
        false;
    return {
      'voteNum': voteNum,
      'isVoted': isVoted,
    };
  }
}
