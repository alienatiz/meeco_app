import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '메뉴',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Colors.black,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.favorite_border,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(
              Icons.account_circle_outlined,
              color: Colors.black,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Row(
            children: [
              Container(
                width: MediaQuery.of(context).size.width / 2.0,
                padding: const EdgeInsets.fromLTRB(8, 8, 4, 4),
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xffefefef),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.red,
                        radius: 16,
                        child: Icon(
                          Icons.calendar_today_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '출석',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 24.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width / 2.0,
                padding: const EdgeInsets.fromLTRB(4, 8, 8, 4),
                child: Container(
                  height: 100,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: const Color(0xffefefef),
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: const [
                      CircleAvatar(
                        backgroundColor: Colors.teal,
                        radius: 16,
                        child: Icon(
                          Icons.storefront,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      Spacer(),
                      Text(
                        '스티커',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 24.0,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
          const BoardView('IT+', 'ITplus', ['소식', '미니', '음향', '리뷰', '대형']),
          const BoardView('자유+', 'FreePlus', ['자유', '유머', '갤러리', '대형']),
          const BoardView('가격+', 'PricePlus', ['특가', '장터', '홍보']),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class BoardView extends StatefulWidget {
  final String title;
  final String url;
  final List<String> subBoard;

  const BoardView(this.title, this.url, this.subBoard, {Key? key})
      : super(key: key);

  @override
  _BoardViewState createState() => _BoardViewState();
}

class _BoardViewState extends State<BoardView> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<BoardProvider>(context, listen: false).refresh(widget.url);
        Navigator.pushReplacementNamed(
          context,
          '/main',
          arguments: {
            'url': widget.url,
            'title': widget.title,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: const Color(0xffefefef),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.sort),
                ],
              ),
              const SizedBox(height: 24.0),
              SizedBox(
                height: 32,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemCount: widget.subBoard.length,
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: _buildClip(widget.subBoard[index]),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _buildClip(String title) {
    return Container(
      height: 24,
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: BorderRadius.circular(40.0),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
