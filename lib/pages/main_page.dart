import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/backend/tab_provider.dart';
import 'package:meeco_app/pages/user_page.dart';
import 'package:meeco_app/widgets/board_item_view.dart';
import 'package:meeco_app/widgets/custom_circular_progress_indicator.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String>? arg =
        ModalRoute.of(context)?.settings.arguments != null
            ? ModalRoute.of(context)?.settings.arguments as Map<String, String>
            : {'title': 'IT+', 'url': 'ITplus'};
    final TabProvider tabProvider = Provider.of<TabProvider>(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
        ),
        title: Text(arg!['title']!),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {
              Navigator.pushNamed(context, '/user');
            },
          ),
        ],
      ),
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
            label: '설정',
          )
        ],
        onTap: (index) {
          tabProvider.currentIndex = index;
        },
      ),
    );
  }

  _buildBody() {
    switch (Provider.of<TabProvider>(context).currentIndex) {
      case 0:
        return const ListPage();
      case 1:
        return const Center(
          child: Text('알림이 없습니다.'),
        );
      case 2:
        return const UserPage();
      default:
        return Container();
    }
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
