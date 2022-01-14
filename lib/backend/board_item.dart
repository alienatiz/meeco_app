class BoardItem {
  String url;

  bool isNotice;

  String title;
  String author;

  String time;
  int viewNum;
  int voteNum;
  int commentNum;

  BoardItem(
      this.url,
      this.title,
      this.author,
      this.time,
      this.viewNum,
      this.voteNum,
      this.commentNum, {
        this.isNotice = false,
      });

  @override
  String toString() {
    return (isNotice ? "[공지]" : "") +
        "<$url>$author: $title [$viewNum 조회][$voteNum 공감][$commentNum개의 댓글]";
  }
}
