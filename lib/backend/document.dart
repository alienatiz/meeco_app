class Document {
  String time;

  String title;
  Author author;
  String body;

  int viewNum;
  int voteNum;
  int commentNum;

  List<Comment>? comments;

  Document(
    this.time,
    this.title,
    this.author,
    this.body,
    this.viewNum,
    this.voteNum,
    this.commentNum, {
    this.comments,
  });
}

class Comment {
  bool? isDeleted = false;

  bool isReply = false;
  String? replyTo;

  String time;

  Author author;
  String body;

  int voteNum;

  Comment(
    this.isReply,
    this.time,
    this.author,
    this.body,
    this.voteNum, {
    this.isDeleted,
    this.replyTo,
  });
}

class Author {
  int memberSrl;
  String author;
  String? profileUrl;
  String? signature;

  Author(
    this.memberSrl,
    this.author, {
    this.profileUrl,
    this.signature,
  });
}
