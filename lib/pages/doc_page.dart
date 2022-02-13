import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:meeco_app/backend/auth_provider.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/backend/doc_provider.dart';
import 'package:meeco_app/backend/data_model/document.dart';
import 'package:meeco_app/constants.dart';
import 'package:meeco_app/widgets/custom_circular_progress_indicator.dart';
import 'package:meeco_app/widgets/log_in_form.dart';
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
    Provider.of<DocProvider>(context, listen: false).url = item!.url;

    return Scaffold(
      appBar: AppBar(
        title: Text(item.title),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz))
        ],
      ),
      body: _renderPage(item),
    );
  }

  _renderPage(BoardItem? item) {
    final docProvider = Provider.of<DocProvider>(context);
    final doc = docProvider.doc;

    if (docProvider.loading && doc == null) {
      return const Center(child: CustomCircularProgressIndicator());
    } else if (!docProvider.loading && doc == null) {
      Future.microtask(() => docProvider.fetch());
    } else {
      return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            doc!.title,
            style: Theme.of(context).textTheme.headline5,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ProfileImage(author: doc.author),
              const SizedBox(width: 16.0),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.author.nickname,
                    style: Theme.of(context).textTheme.caption,
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    doc.time,
                    style: Theme.of(context).textTheme.caption,
                  ),
                ],
              )
            ],
          ),
          BodyView(data: doc.body),
          const SizedBox(height: 12.0),
          Center(child: VoteButton(doc.voteNum)),
          const SizedBox(height: 12.0),
          Row(
            children: [
              Text(
                '댓글 ${doc.commentNum}개',
                style: Theme.of(context).textTheme.bodyText1!.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {},
                color: textInfoDark,
              ),
            ],
          ),
          ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (doc.comments != null) {
                  return CommentView(doc.comments![index]);
                } else {
                  return const SizedBox();
                }
              },
              separatorBuilder: (context, i) {
                return const Divider(
                  height: 1,
                );
              },
              itemCount: doc.commentNum),
        ],
      );
    }
  }
}

class BodyView extends StatelessWidget {
  final String data;

  const BodyView({
    Key? key,
    required this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Html(
      data: data,
      style: {
        'p': Style(
          color: Theme.of(context).textTheme.bodyText1!.color,
          fontSize: FontSize(
            Theme.of(context).textTheme.bodyText1!.fontSize,
          ),
        ),
        "body": Style(
          margin: EdgeInsets.zero,
          padding: EdgeInsets.zero,
          color: Theme.of(context).textTheme.bodyText1!.color,
          fontSize: FontSize(
            Theme.of(context).textTheme.bodyText1!.fontSize,
          ),
        ),
      },
    );
  }
}

class ProfileImage extends StatelessWidget {
  final Author author;
  final double? size;
  const ProfileImage({
    Key? key,
    required this.author,
    this.size = 40.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: const BorderRadius.all(
          Radius.circular(300.0),
        ),
        child: Image.network(
          author.profileUrl ??
              'https://meeco.kr/layouts/colorize02_layout/images/profile.png',
        ),
      ),
    );
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
    final client = Provider.of<Client>(context);
    final docProvider = Provider.of<DocProvider>(context);
    final isVoted = docProvider.isVoted;

    return GestureDetector(
      onTap: () async {
        if (!client.isLoggedIn) {
          customModalBottomSheet(
            context: context,
            builder: (_) => const LogInForm(),
          );
        } else {
          return Future.microtask(() => docProvider.vote());
        }
      },
      child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          decoration: BoxDecoration(
            color: isVoted ? voteColorLight : Colors.transparent,
            border: Border.all(color: voteColorLight),
            borderRadius: const BorderRadius.all(
              Radius.circular(16.0),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                isVoted ? Icons.favorite : Icons.favorite_border,
                size: 20,
                color: isVoted ? Colors.black : voteColorLight,
              ),
              const SizedBox(width: 4),
              Text(
                '${docProvider.voteNum}',
                style: TextStyle(
                  fontSize: 20,
                  color: isVoted ? Colors.black : voteColorLight,
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
          padding: EdgeInsets.only(
            left: comment.isReply ? 40.0 : 0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileImage(author: comment.author, size: 30),
              const SizedBox(width: 8),
              Expanded(child: _buildCommentText(context)),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Column _buildCommentText(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              comment.author.nickname,
              style:
                  Theme.of(context).textTheme.bodyText1!.copyWith(fontSize: 13),
            ),
            const Spacer(),
            Text(
              comment.time.trim(),
              style: Theme.of(context).textTheme.caption!.copyWith(
                    fontSize: 11,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        BodyView(data: comment.body),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.favorite_border,
              size: 17,
              color: voteColorLight,
            ),
            const SizedBox(width: 2),
            Text(
              comment.voteNum.toString(),
              style: TextStyle(
                color: comment.voteNum >= 4
                    ? voteColorLight
                    : Theme.of(context).textTheme.bodyText1!.color,
                fontSize: 17,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.reply_rounded,
              size: 20,
              color: textInfoDark,
            ),
            const SizedBox(width: 6),
            const Icon(Icons.more_horiz, size: 20, color: textInfoDark),
          ],
        ),
      ],
    );
  }
}
