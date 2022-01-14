import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:meeco_app/backend/board_item.dart';
import 'package:meeco_app/backend/document.dart';

// import 'dart:math';

class ApiProvider extends ChangeNotifier {
  String? _cookie;
  bool isLoggedIn = false;

  Future<void> logIn(String id, String pw) async {
    const String logInUrl = '/index.php?mid=index&act=dispMemberLoginForm';

    if (!isLoggedIn) {
      final logInPage = await _get(logInUrl);
      final csrf = _getCsrfToken(logInPage);

      final logInAction = await _post(
        logInUrl,
        headers: {'x-csrf-token': csrf ?? '', 'cookie': _cookie ?? ''},
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

  write() {}

  Future<List<BoardItem>> fetchBoard(String board, int page) async {
    var docList = await _get(
        "/" + (page == 1 ? board : "index.php?mid=$board&page=$page"));
    var docListBody =
        parse(docList.body).querySelectorAll('table.ldn > tbody > tr').map((e) {
      final numData = e.querySelectorAll("td.num");
      var commentNum = e.querySelector("td.title > a.num")?.text.trim();
      commentNum = commentNum?.substring(1, commentNum.length - 1);
      return BoardItem(
        e
                .querySelector("td.title > a > span")
                ?.parentNode
                ?.attributes["href"] ??
            e.querySelector("td.title > a")?.attributes["href"] ??
            '/$board',
        e.querySelector("td.title > a > span")?.text.trim() ??
            e.querySelector("td.title > a")?.text.trim() ??
            '제목',
        e.querySelector('td.author > a')?.text ?? '작성자',
        board == 'PricePlus' ? numData[0].text : numData[1].text,
        board == 'PricePlus'
            ? int.parse(numData[2].querySelector('span')?.text ?? "0")
            : int.parse(numData[3].querySelector('span')?.text ?? "0"),
        board == 'PricePlus'
            ? int.parse(numData[1].querySelector('span')?.text ?? "0")
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
    final parsedDoc = parse(document.body).querySelector('article.bAtc')!;
    final header = parsedDoc.querySelector('header.atc-hd')!;
    final infoUnderTitle = header.querySelector('ul.ldd-title-under')!;
    final userData = infoUnderTitle.querySelector(
      'header.atc-hd > ul.ldd-title-under > li > a[class^="member_"]',
    )!;
    final comments = parsedDoc
        .querySelectorAll('section.bCmt > div.cmt-list > article')
        .map((e) {
      final header = e.querySelector('header.author')!;
      final isReply = header.querySelector('span.parent') != null;
      return Comment(
        isReply,
        header.querySelector('div.date')!.text,
        Author(
          int.parse(header.querySelector('a.member')!.attributes['class']!.split(' ')[0].substring(7)),
          header.querySelector('a.member')!.text,
          profileUrl: e.querySelector('img.bPf-img')!.attributes['src'],
        ),
        e.querySelector('div.cmt-el-body > div.xe_content')!.innerHtml,
        int.parse(e.querySelector('div.cmt-el-body > div.cmt-vote > span.num')?.text ?? '0'),
        replyTo: isReply ? header.querySelector('span.parent')!.text : null,
      );
    }).toList();

    return Document(
      infoUnderTitle.querySelector('li.num')!.text,
      header.querySelector('h1.atc-title > a')!.text,
      Author(
        int.parse(userData.attributes['class']!.substring(7)),
        userData.text,
        profileUrl: header.querySelector('img.bPf-img')!.attributes['src'],
      ),
      parsedDoc
          .querySelector('div.atc-wrap > div[class^="document"]')!
          .innerHtml,
      int.parse(infoUnderTitle.querySelector('li > span.num')!.text),
      int.parse(
          parsedDoc.querySelector('div.atc-wrap a.atc-vote-bt > span')!.text),
      int.parse(parsedDoc.querySelector('section.bCmt > div > span')!.text),
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

  /*

  Future<String?> uploadImage() async {
    final csrf = _getCsrfToken(await _post('/free/33263537'));
    print('csrf: $csrf');
    final nonce = "T" +
        DateTime.now().millisecondsSinceEpoch.toString() +
        "." +
        Random().nextDouble().toString();
    final boundary = '------WebKitFormBoundary' + _getRandomString(16);
    /*
    헤더에 이 놈을 넣어줘야 합니다.
    content-type: multipart/form-data; boundary=----WebKitFormBoundarymfMESFqVGzx7Ugms

    editor_sequence: 3
upload_target_srl: undefined
mid: free
act: procFileUpload

Content-Disposition: form-data; name="Filedata"; filename="신학 성능에 관해서 개인적인 평가 내리는것까진 괜찮은데.gif"
Content-Type: image/gif
*/
    final req = http.MultipartRequest('POST', Uri.parse('https://meeco.kr'));
    req.fields['editor_sequence'] = '3';
    req.fields['upload_target_srl'] = 'undefined';
    req.fields['nonce'] = nonce;
    req.fields['mid'] = 'free';
    req.fields['act'] = 'procFileUpload';
    req.files.add(await http.MultipartFile.fromPath('image', 'C:\\Users\\editi\\Downloads\\test_image.jpeg', filename: 'test_image.jpeg', contentType: MediaType('image', 'jpeg')));
    req.headers['x-csrf-token'] = csrf ?? '';
    req.headers['x-requested-with'] = 'XMLHttpRequest';
    req.headers['content-length'] = req.contentLength.toString();
    req.headers['User-Agent'] = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36 Edg/96.0.1054.62';


    final uploadAction = await http.Response.fromStream(await req.send());
    print(req.headers);
    print(uploadAction.headers);
    print(uploadAction.statusCode);
    print(uploadAction.body);



    return Future.delayed(Duration.zero, () => boundary);
  }
  */

  String? _getCsrfToken(http.Response page) {
    return parse(page.body)
        .querySelector('meta[name="csrf-token"]')
        ?.attributes['content'];
  }

  _replaceCookieCommaToSemicolon(String? strCookie) {
    return strCookie?.split(RegExp(r'(?<=)(,)(?=[^;]+?=)')).join(';');
  }

  // 쿠키를 사용하는 함수. http.Client로 뺄 지 고민해보자.
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

/*
  추후 사용할 함수 (이미지)

  String _getRandomString(int length) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(Random().nextInt(_chars.length))));
  }
   */
}
