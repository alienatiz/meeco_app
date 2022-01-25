import 'package:meeco_app/backend/data_model/category.dart';

class BoardItem {
  String url;

  bool isNotice;

  Category category;
  String title;
  String author;

  String time;
  int viewNum;
  int voteNum;
  int commentNum;

  BoardItem(
    this.url,
    this.category,
    this.title,
    this.author,
    this.time,
    this.viewNum,
    this.voteNum,
    this.commentNum, {
    this.isNotice = false,
  });
}
