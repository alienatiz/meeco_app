import 'package:meeco_app/backend/data_model/category.dart';

class Document {
  String time;

  Category category;

  bool isVoted;
  String title;
  Author author;
  String body;

  int viewNum;
  int voteNum;
  int commentNum;

  List<Comment>? comments;

  Document(
    this.time,
    this.category,
    this.isVoted,
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
  String nickname;
  String? profileUrl;
  String? signature;

  Author(
    this.memberSrl,
    this.nickname, {
    this.profileUrl,
    this.signature,
  });
}

