import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/backend/tab_provider.dart';
import 'package:meeco_app/constants.dart';
import 'package:meeco_app/pages/profile_page.dart';
import 'package:meeco_app/widgets/board_item_view.dart';
import 'package:meeco_app/widgets/custom_circular_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:fluttertoast/fluttertoast.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late FToast fToast;

  @override
  void initState() {
    super.initState();
    fToast = FToast();
    fToast.init(context);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? arg =
        ModalRoute.of(context)?.settings.arguments != null
            ? ModalRoute.of(context)?.settings.arguments as Map<String, String>
            : {'title': 'IT+', 'url': 'ITplus'};
    final TabProvider tabProvider = Provider.of<TabProvider>(context);
    return Scaffold(
      appBar: _buildAppBar(arg!['title']!),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: tabProvider.currentIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_rounded),
            label: '메인',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: '알림',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle_outlined),
            label: '프로필',
          )
        ],
        onTap: (index) {
          tabProvider.currentIndex = index;
        },
      ),
    );
  }

  _buildAppBar(String title) {
    switch (Provider.of<TabProvider>(context).currentIndex) {
      case 0:
        return ListPageAppBar(title: title, fToast: fToast);
      case 1:
        return NotiPageAppBar();
      case 2:
        return ProfilePageAppBar();
    }
  }

  _buildBody() {
    switch (Provider.of<TabProvider>(context).currentIndex) {
      case 0:
        return const ListPage();
      case 1:
        return Center(
          child: Text(
            '알림 기능은 준비중에 있습니다.',
            style: Theme.of(context).textTheme.bodyText1,
          ),
        );
      case 2:
        return const UserPage();
      default:
        return Container();
    }
  }
}

class ListPageAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;
  ListPageAppBar({
    Key? key,
    required this.title,
    required this.fToast,
  })  : preferredSize = const Size.fromHeight(52.0),
        super(key: key);

  final String title;
  final FToast fToast;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },
      ),
      title: Text(title),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit_outlined),
          iconSize: 21,
          onPressed: () {
            // Navigator.pushNamed(context, '/write');
            fToast.showToast(
              child: Container(
                decoration: BoxDecoration(
                  color: secondaryColor,
                  borderRadius: BorderRadius.circular(40.0),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 10.0,
                ),
                child: const Text(
                  '글쓰기 기능은 준비 중에 있습니다.',
                  style: TextStyle(
                    color: textDark,
                  ),
                ),
              ),
              gravity: ToastGravity.BOTTOM,
            );
          },
        ),
      ],
    );
  }
}

class NotiPageAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  NotiPageAppBar({Key? key})
      : preferredSize = const Size.fromHeight(52.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('알림'));
  }
}

class ProfilePageAppBar extends StatelessWidget with PreferredSizeWidget {
  @override
  final Size preferredSize;

  ProfilePageAppBar({Key? key})
      : preferredSize = const Size.fromHeight(52.0),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(title: const Text('프로필'));
  }
}

class ListPage extends StatefulWidget {
  const ListPage({Key? key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final boardProvider = Provider.of<BoardProvider>(context);
    final items = boardProvider.items;

    if (boardProvider.loading && items.isEmpty) {
      return const Center(child: CustomCircularProgressIndicator());
    } else {
      return SmartRefresher(
        controller: refreshController,
        onRefresh: _onRefresh,
        child: ListView.separated(
          padding: const EdgeInsets.only(top: 8.0),
          physics: const BouncingScrollPhysics(),
          itemCount: items.length + 1,
          itemBuilder: (_, index) {
            if (index < items.length) {
              return BoardItemView(item: items[index]);
            }

            if (!boardProvider.loading) {
              Future.microtask(() => boardProvider.fetchItems());
            }

            return const Center(child: CustomCircularProgressIndicator());
          },
          separatorBuilder: (_, __) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: const Divider(),
            );
          },
        ),
      );
    }
  }

  _onRefresh() async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    await boardProvider.refresh();
    refreshController.refreshCompleted();
  }
}
