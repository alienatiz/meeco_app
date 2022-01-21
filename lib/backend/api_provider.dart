import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/backend/data_model/category.dart';
import 'package:meeco_app/backend/data_model/document.dart';

// import 'dart:math';

class ApiProvider extends ChangeNotifier {
  String? _cookie;
  bool isLoggedIn = false;
  static const String logInUrl = '/index.php?mid=index&act=dispMemberLoginForm';

  Future<void> logIn(String id, String pw) async {
    if (!isLoggedIn) {
      final logInPage = await _get(logInUrl);
      final csrf = _getCsrfToken(logInPage);

      final logInAction = await _post(
        logInUrl,
        headers: {'x-csrf-token': csrf ?? ''},
        body: {
          'error_return_url': logInUrl,
          'mid': 'index',
          'vid': '',
          'ruleset': '@login',
          'success_return_url': 'https://meeco.kr/',
          'act': 'procMemberLogin',
          'xe_validator_id': 'modules/member/skin/default/login_form/1',
          'user_id': id,
          'password': pw,
          'keep_signed': 'Y',
          '_rx_csrf_token': csrf
        },
      );
      isLoggedIn = logInAction.statusCode == 302;
      notifyListeners();
    }
  }

  // Future<void> logOut() async {}

  Future<bool> attend() async {
    if (isLoggedIn) {
      final attendPage = await _get('/attendance');
      final greetings = parse(attendPage.body)
          .querySelector('input[name="greetings"]')
          ?.attributes['value'];
      final attendAction = await _post('/attendance', body: {
        'error_return_url': '/attendance',
        'vid': '',
        'ruleset': 'Attendanceinsert',
        'mid': 'attendance',
        'act': 'procAttendanceInsertAttendance',
        'xe_validator_id': 'modules/attendance/skins/default/attendanceinsert',
        'greetings': greetings,
        '_rx_csrf_token': _getCsrfToken(attendPage),
      });
      return attendAction.statusCode == 302;
    } else {
      return false;
    }
  }

  voteDoc(String url) async {
    var docPage = await _get(url);
    var urlList = url.split('/');
    var response = await _post(url, body: {
      'target_srl': urlList[2],
      'cur_mid': urlList[1],
      'mid': urlList[1],
      'module': 'document',
      'act': 'procDocumentVoteUp',
      '_rx_ajax_compat': 'XMLRPC',
      '_rx_csrf_token': _getCsrfToken(docPage),
      'vid': '',
    }, headers: {
      'x-csrf-token': _getCsrfToken(docPage) ?? '',
      'x-requested-with': 'XMLHttpRequest',
    });

    return response.statusCode;
  }

  Future<List<BoardItem>> fetchBoard(String board, int page) async {
    var docList = await _get(
        "/" + (page == 1 ? board : "index.php?mid=$board&page=$page"));
    var docListBody =
        parse(docList.body).querySelectorAll('table.ldn > tbody > tr').map((e) {
      final numData = e.querySelectorAll("td.num");

      var commentNum = e.querySelector("td.title > a.num")?.text.trim();
      commentNum = commentNum?.substring(1, commentNum.length - 1);

      final title = e.querySelector('td.title');
      return BoardItem(
        title?.querySelector("span")?.parentNode?.attributes['href'] ??
            title?.attributes['href'] ??
            '/$board',
        Category(
          title?.querySelector('a.boardname')?.text ?? '--',
          title?.querySelector('a.boardname')?.attributes['href'] ?? '--',
        ),
        title?.querySelector('span')?.text.trim() ?? title?.text.trim() ?? '제목',
        e.querySelector('td.author > a')?.text ?? '작성자',
        numData[1].text,
        board == 'PricePlus'
            ? int.parse(numData[2].querySelector('span')?.text ?? "0")
            : int.parse(numData[3].querySelector('span')?.text ?? "0"),
        board == 'PricePlus'
            ? 0
            : int.parse(numData[2].querySelector('span')?.text ?? "0"),
        int.parse(commentNum ?? "0"),
        isNotice: numData[0].text.trim() == "공지",
      );
    }).toList();

    if (page > 1) {
      docListBody = docListBody.where((element) => !element.isNotice).toList();
    }

    return docListBody;
  }

  Future<Document> fetchDoc(String? url) async {
    assert(url != null);

    final document = await _get(url!);
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
      if (sticker != null) {
        sticker.innerHtml = '<img class="sticker" src="' +
            RegExp('https?:\\/\\/(www\\.)?[-a-zA-Z0-9@:%._\\+~#=]{1,256}\\.[a-zA-Z0-9()]{1,6}\\b([-a-zA-Z0-9(@:%_\\+.~#?&//=]*)')
                .stringMatch(sticker.attributes['style']!)! +
            '"></img>';
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
        sticker != null
            ? sticker.innerHtml
            : cmtBody
                    ?.querySelector('div.xe_content')
                    ?.innerHtml
                    .replaceAll('img src="//', 'img src="https://') ??
                'body',
        int.parse(
            cmtBody?.querySelector('div.cmt-vote > a > span.num')?.text ?? '0'),
        replyTo: commentHeader?.querySelector('span.parent')?.text,
      );
    }).toList();

    return Document(
      infoUnderTitle?.querySelector('li.num')?.text ?? '--',
      Category('a', 'aaa'),
      header?.querySelector('h1.atc-title > a')?.text ?? '제목',
      Author(
        authorSrl == 'member_0' ? 0 : int.parse(authorSrl?.substring(7) ?? '0'),
        userData?.text ?? '작성자',
        profileUrl: header?.querySelector('img.bPf-img')?.attributes['src'],
      ),
      parsedDoc
              ?.querySelector('div.atc-wrap > div[class^="document"]')
              ?.innerHtml
              .replaceAll('img src="//', 'img src="https://') ??
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

  Future<int> insertStickerComment() async {
    final docPage = await _get('/free/33263537');
    final insertAction = await _post('/index.php', body: {
      '_filter': 'insert_comment',
      'error_return_url': '/free/33263537',
      'mid': 'free',
      'document_srl': '33263537',
      'parent_srl': '0',
      'content': '{@sticker:33170906|33170907} ',
      'use_html': 'Y',
      'module': 'board',
      'act': 'procBoardInsertComment',
    }, headers: {
      'x-csrf-token': _getCsrfToken(docPage) ?? '',
      'x-requested-with': 'XMLHttpRequest',
    });

    return insertAction.statusCode;
  }

  String? _getCsrfToken(http.Response page) {
    return parse(page.body)
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
  }

  Future<http.Response> _get(String url, {Map<String, String>? headers}) async {
    var getPage = await http.get(Uri.parse("https://meeco.kr" + url),
        headers: {'cookie': _cookie ?? '', ...?headers});
    _cookie = _replaceCookieCommaToSemicolon(
        getPage.headers['set-cookie'] ?? _cookie);
    return getPage;
  }

  Future<http.Response> _post(String url,
      {Map<String, String>? headers, Object? body}) async {
    var postPage = await http.post(Uri.parse("https://meeco.kr" + url),
        headers: {'cookie': _cookie ?? '', ...?headers}, body: body);
    _cookie = _replaceCookieCommaToSemicolon(
        postPage.headers['set-cookie'] ?? _cookie);
    return postPage;
  }

  _replaceCookieCommaToSemicolon(String? strCookie) {
    return strCookie?.split(RegExp(r'(?<=)(,)(?=[^;]+?=)')).join(';');
  }
}
