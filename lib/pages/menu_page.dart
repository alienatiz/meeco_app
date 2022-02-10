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
        centerTitle: false,
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '메뉴',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/user');
            },
          )
        ],
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: const [
          // MenuItem(
          //   icon: Icons.calendar_today_outlined,
          //   title: '출석',
          //   color: voteColorLight,
          // ),
          // MenuItem(icon: Icons.storefront, title: '스티커'),
          MenuItem(icon: Icons.devices_other, title: 'IT+', url: 'ITplus'),
          MenuItem(
            icon: Icons.free_breakfast_outlined,
            title: '자유+',
            url: 'FreePlus',
          ),
          MenuItem(icon: Icons.sell_outlined, title: '가격+', url: 'PricePlus'),
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
        Provider.of<BoardProvider>(context, listen: false)
            .switchBoard(widget.url);
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
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(24.0),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
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
                      child: CategoryChip(widget.subBoard[index]),
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
}

class CategoryChip extends StatelessWidget {
  final String title;

  const CategoryChip(this.title, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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

class MenuItem extends StatelessWidget {
  final String url;
  final IconData icon;
  final String title;
  final Color? color;

  const MenuItem({
    required this.url,
    required this.icon,
    required this.title,
    this.color,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Provider.of<BoardProvider>(context, listen: false).switchBoard(url);
        Navigator.pushReplacementNamed(
          context,
          '/main',
          arguments: {
            'url': url,
            'title': title,
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color ?? Theme.of(context).primaryColor,
              radius: 16,
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12.0),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyText1!.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios, size: 18),
          ],
        ),
      ),
    );
  }
}
