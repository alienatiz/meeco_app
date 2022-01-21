import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/backend/doc_provider.dart';
import 'package:meeco_app/backend/data_model/document.dart';
import 'package:provider/provider.dart';

class DocPage extends StatefulWidget {
  const DocPage({Key? key}) : super(key: key);

  @override
  _DocPageState createState() => _DocPageState();
}

class _DocPageState extends State<DocPage> {
  @override
  Widget build(BuildContext context) {
    final BoardItem? item =
        ModalRoute.of(context)?.settings.arguments as BoardItem;
    Provider.of<DocProvider>(context, listen: false).url = item?.url;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0x78bfbfbf),
        // const Color(0xff4c5c84),
        elevation: 0,
        centerTitle: true,
        title: Text(
          item?.title ?? '제목',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
        flexibleSpace: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.transparent),
          ),
        ),
      ),
      body: _renderPage(item),
    );
  }

  _renderPage(BoardItem? item) {
    final docProvider = Provider.of<DocProvider>(context);
    final doc = docProvider.doc;

    if (docProvider.loading && doc == null) {
      return const Center(child: CircularProgressIndicator());
    } else if (!docProvider.loading && doc == null) {
      Future.microtask(() => docProvider.fetch());
    } else {
      return ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            doc!.title,
            style: const TextStyle(
              fontSize: 25.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                doc.author.nickname,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black45,
                ),
              ),
              const Spacer(),
              Text(
                doc.time,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.black45,
                ),
              ),
            ],
          ),
          Html(
            data: doc.body,
            style: {
              'p': Style(
                fontSize: const FontSize(16.0),
              ),
              "body": Style(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
              ),
            },
          ),
          const SizedBox(height: 12.0),
          Center(child: VoteButton(doc.voteNum)),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Text(
                '댓글 ${doc.commentNum}개',
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
              ),
            ],
          ),
          ...?doc.comments?.map((e) {
            return CommentView(e);
          }).toList(),
        ],
      );
    }
  }
}

class VoteButton extends StatefulWidget {
  final int voteNum;

  const VoteButton(this.voteNum, {Key? key}) : super(key: key);

  @override
  _VoteButtonState createState() => _VoteButtonState();
}

class _VoteButtonState extends State<VoteButton> {
  @override
  Widget build(BuildContext context) {
    final docProvider = Provider.of<DocProvider>(context);
    final isVoted = docProvider.isVoted;
    return GestureDetector(
      onTap: () => Future.microtask(() => docProvider.vote()),
      child: Container(
          width: 84,
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isVoted ? Colors.red : Colors.white,
            border: Border.all(color: Colors.red),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isVoted ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isVoted ? Colors.white : Colors.red,
              ),
              const SizedBox(width: 4),
              Text(
                widget.voteNum.toString(),
                style: TextStyle(
                  fontSize: 20,
                  color: isVoted ? Colors.white : Colors.red,
                ),
              ),
            ],
          )),
    );
  }
}

class CommentView extends StatelessWidget {
  final Comment comment;

  const CommentView(this.comment, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(
              (comment.isReply ? 24.0 : 8.0), 8.0, 8.0, 8.0),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFEFEFEF)),
            borderRadius: const BorderRadius.all(
              Radius.circular(8.0),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 30.0,
                height: 30.0,
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(
                    Radius.circular(300.0),
                  ),
                  child: Image.network(comment.author.profileUrl ??
                      'https://meeco.kr/layouts/colorize02_layout/images/profile.png'),
                ),
              ),
              const SizedBox(
                width: 8,
              ),
              Expanded(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(comment.author.nickname),
                            const Spacer(),
                            Text(comment.voteNum.toString()),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Html(
                          data: comment.body,
                          style: {
                            'p': Style(
                              fontSize: const FontSize(16.0),
                            ),
                            "body": Style(
                              margin: EdgeInsets.zero,
                              padding: EdgeInsets.zero,
                            ),
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
