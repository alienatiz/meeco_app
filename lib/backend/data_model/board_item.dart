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
}
