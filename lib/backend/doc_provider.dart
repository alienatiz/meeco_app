import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:html/parser.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/data_model/category.dart';
import 'package:meeco_app/backend/data_model/document.dart';

class DocProvider extends ChangeNotifier {
  late final Client client;

  DocProvider({required this.client});

  late String url;
  bool loading = false;
  Document? doc;

  bool isVoted = false;
  int voteNum = 0;

  Future<Document> fetchDoc(String url) async {
    final document = await client.get(query: url);
    final parsedDoc = parse(document.body).querySelector('article.bAtc');
    final header = parsedDoc?.querySelector('header.atc-hd');
    final authorSrl = header
        ?.querySelector('a[class^="member"]')
        ?.attributes['class']
        ?.split(' ')[0];
    final infoUnderTitle = header?.querySelector('ul.ldd-title-under');
    final userData = infoUnderTitle?.querySelector(
      'header.atc-hd > ul.ldd-title-under > li > a[class^="member_"]',
    );

    final comments = parsedDoc
        ?.querySelectorAll('section.bCmt > div.cmt-list > article')
        .map((e) {
      final commentHeader = e.querySelector('header.author');
      final isReply = commentHeader?.querySelector('span.parent') != null;
      final memberSrl = commentHeader
          ?.querySelector('a[class^="member"]')
          ?.attributes['class']
          ?.split(' ')[0];

      final cmtBody = e.querySelector('div.cmt-el-body');
      final sticker =
          cmtBody?.querySelector('div.xe_content > a[style*="img.meeco.kr"]');
      final cmtContent = cmtBody?.querySelector('div.xe_content');
      String? bodyWithSticker;
      if (sticker != null) {
        bodyWithSticker = cmtContent!.innerHtml.replaceAll(
            RegExp('<a .+img.meeco.kr.+></a>'),
            '<img class="sticker" src="' +
                RegExp('https://img.meeco.kr/[a-zA-Z0-9./]+')
                    .stringMatch(sticker.attributes['style']!)! +
                '" width ="100" height="100"></img>');
      }

      return Comment(
        isReply,
        commentHeader?.querySelector('div.date')?.text ?? '--',
        Author(
          authorSrl == 'member_0' || authorSrl == 'member'
              ? 0
              : int.parse(memberSrl?.substring(7) ?? '0'),
          commentHeader?.querySelector('a.member')?.text ?? '작성자',
          profileUrl: e.querySelector('img.bPf-img')?.attributes['src'],
        ),
        bodyWithSticker ??
            cmtBody
                ?.querySelector('div.xe_content')
                ?.innerHtml
                .replaceAll('src="//', 'src="https://') ??
            'body',
        int.parse(
            cmtBody?.querySelector('div.cmt-vote > a > span.num')?.text ?? '0'),
        replyTo: commentHeader?.querySelector('span.parent')?.text,
      );
    }).toList();

    return Document(
      infoUnderTitle?.querySelector('li.num')?.text ?? '--',
      Category(name: 'a', url: 'aaa'),
      parsedDoc?.querySelector('div.atc-vote-bts > a.up.up_on') != null,
      header?.querySelector('h1.atc-title > a')?.text ?? '제목',
      Author(
        authorSrl == 'member_0' ? 0 : int.parse(authorSrl?.substring(7) ?? '0'),
        userData?.text ?? '작성자',
        profileUrl: header?.querySelector('img.bPf-img')?.attributes['src'],
      ),
      parsedDoc
              ?.querySelector('div.atc-wrap > div[class^="document"]')
              ?.innerHtml
              .replaceAll('src="//', 'src="https://') ??
          'body',
      int.parse(infoUnderTitle?.querySelector('li > span.num')?.text ?? '0'),
      int.parse(
          parsedDoc?.querySelector('div.atc-wrap a.atc-vote-bt > span')?.text ??
              '0'),
      int.parse(
          parsedDoc?.querySelector('section.bCmt > div > span')?.text ?? '0'),
      comments: comments,
    );
  }

  Future<int?> voteDoc(String url) async {
    final urlList = url.split('/');
    final mid = urlList[1];
    final srl = urlList[2];

    final req = await client.post(
        query: '/',
        body: {
          'target_srl': srl,
          'cur_mid': mid,
          'mid': mid,
          'module': 'document',
          'act': 'procDocumentVoteUp',
          '_rx_ajax_compat': 'XMLRPC',
          'vid': '',
        },
        headers: {
          'x-requested-with': 'XMLHttpRequest',
        },
        needsToken: true);

    final jsonResponse = jsonDecode(req.body);
    if (jsonResponse['error'] == 0) {
      return jsonResponse['voted_count'];
    } else {
      return -1;
    }
  }

  fetch() async {
    loading = true;
    notifyListeners();

    doc = await fetchDoc(url);
    voteNum = doc!.voteNum;
    isVoted = doc!.isVoted;
    loading = false;
    notifyListeners();
  }

  vote() async {
    isVoted = !isVoted;
    notifyListeners();

    voteNum = await voteDoc(url) ?? voteNum - 1;
    notifyListeners();
  }
}
