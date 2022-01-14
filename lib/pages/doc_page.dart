import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:meeco_app/backend/board_item.dart';
import 'package:meeco_app/backend/doc_provider.dart';
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
        title: Text(item?.title ?? '제목'),
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
        ],
      );
    }

    /*
    if (!docProvider.loading && doc != null) {
      print('isn\'t print this....?');
      return Text(doc ?? 'body');

      return


    } else {
      return const Center(child: CircularProgressIndicator());
    }

     */
  }
}
