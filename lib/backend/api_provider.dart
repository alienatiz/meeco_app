import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/backend/data_model/category.dart';
import 'package:meeco_app/backend/data_model/document.dart';

// import 'dart:math';

class ApiProvider extends ChangeNotifier {
  final CookieJar _cookieJar = CookieJar();

  bool isLoggedIn = false;
  bool loading = false;

  Future<void> logIn({required String id, required String pw}) async {
    const String logInUrl = '/index.php?mid=index&act=dispMemberLoginForm';

    if (!isLoggedIn) {
      loading = true;
      notifyListeners();

      final logInPage = await _get(logInUrl);
      final csrf = _getCsrfToken(logInPage);

      final logInAction = await _post(
        logInUrl,
        headers: {'x-csrf-token': csrf ?? ''},
        body: {
          'act': 'procMemberLogin',
          'user_id': id,
          'password': pw,
          'keep_signed': 'Y',
          '_rx_csrf_token': csrf
        },
      );
      isLoggedIn = logInAction.statusCode == 302;
      loading = false;
      notifyListeners();
    }
  }

  Future<void> logOut() async {
    final logOutAction =
        await _get('/index.php?act=dispMemberLogout&mid=index');
    if (logOutAction.statusCode == 200) {
      isLoggedIn = false;
      notifyListeners();
    }
  }

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

  Future<int?> voteDoc(String url) async {
    var urlList = url.split('/');
    final mid = urlList[1];
    final srl = urlList[2];

    var docPage = await _get(url);
    final csrf = _getCsrfToken(docPage);

    var response = await _post('/', body: {
      'target_srl': srl,
      'cur_mid': mid,
      'mid': mid,
      'module': 'document',
      'act': 'procDocumentVoteUp',
      '_rx_ajax_compat': 'XMLRPC',
      '_rx_csrf_token': csrf,
      'vid': '',
    }, headers: {
      'x-csrf-token': csrf ?? '',
      'x-requested-with': 'XMLHttpRequest',
    });

    final jsonResponse = jsonDecode(response.body);
    if (jsonResponse['error'] == 0) {
      return jsonResponse['voted_count'];
    } else {
      return -1;
    }
  }

  Future<List<BoardItem>> fetchBoard(String board, int page) async {
    final url = "/" + (page == 1 ? board : "index.php?mid=$board&page=$page");
    var docList = await _get(url);

    var docListBody =
        parse(docList.body).querySelectorAll('table.ldn > tbody > tr').map((e) {
      final numData = e.querySelectorAll("td.num");
      var commentNum = e.querySelector("td.title > a.num")?.text.trim();
      commentNum = commentNum?.substring(1, commentNum.length - 1);

      final title = e.querySelector('td.title');

      var url = title?.querySelector("span")?.parentNode?.attributes['href'] ??
          title?.querySelector('a')?.attributes['href'];

      if (double.tryParse(url?.split('/').last ?? '') == null) {
        url = '/' +
            RegExp('mid=[A-Za-z]+').stringMatch(url!)!.substring(4) +
            '/' +
            RegExp('document_srl=[0-9]+').stringMatch(url)!.substring(13);
      }

      final boardName = title?.querySelector('a.boardname');
      final isNotice = numData[0].text.trim() == "공지";

      return BoardItem(
        url ?? '',
        Category(
          isNotice ? '공지' : boardName?.text ?? '--',
          boardName?.attributes['href'] ?? '--',
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
        isNotice: isNotice,
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
      Category('a', 'aaa'),
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

  Future<String> getProfileImageUrl() async {
    if (isLoggedIn) {
      final myPage =
          await _get('https://meeco.kr/index.php?act=dispMemberInfo');
      return parse(myPage.body)
              .querySelector('div.profile-img > img')
              ?.attributes['src'] ??
          'https://meeco.kr/layouts/colorize02_layout/images/profile.png';
    } else {
      return 'https://meeco.kr/layouts/colorize02_layout/images/profile.png';
    }
  }

  String? _getCsrfToken(http.Response page) {
    return parse(page.body)
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
  }

  Future<http.Response> _get(String url, {Map<String, String>? headers}) async {
    var getPage = await http.get(Uri.parse("https://meeco.kr" + url),
        headers: {'cookie': _cookieJar.toString(), ...?headers});
    _cookieJar.saveCookies(getPage.headers['set-cookie']);
    return getPage;
  }

  Future<http.Response> _post(String url,
      {Map<String, String>? headers, Object? body}) async {
    var postPage = await http.post(Uri.parse("https://meeco.kr" + url),
        headers: {'cookie': _cookieJar.toString(), ...?headers}, body: body);
    _cookieJar.saveCookies(postPage.headers['set-cookie']);
    return postPage;
  }
}

class CookieJar {
  Map<String, String>? cookies = {};

  saveCookies(String? rawCookies) {
    rawCookies?.split(RegExp(r'(?<=)(,)(?=[^;]+?=)')).forEach((e) {
      var cookie = e.split(';')[0].split('=');
      cookies![cookie[0]] = cookie[1];
    });
    cookies?.removeWhere((k, v) => v == 'deleted');
  }

  @override
  String toString() {
    List cookieToString = [];
    cookies?.forEach((k, v) => cookieToString.add('$k=$v'));
    return cookieToString.join(';');
  }
}
