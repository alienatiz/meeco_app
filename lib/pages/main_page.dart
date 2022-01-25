import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/widgets/board_item_view.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final RefreshController refreshController =
      RefreshController(initialRefresh: false);

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? arg =
        ModalRoute.of(context)?.settings.arguments != null
            ? ModalRoute.of(context)?.settings.arguments as Map<String, String>
            : {'title': 'IT+', 'url': 'ITplus'};
    final url = arg!['url']!;

    return Scaffold(
      appBar: _buildAppBar(arg['title']!),
      body: _renderListView(url),
    );
  }

  _renderListView(String url) {
    final boardProvider = Provider.of<BoardProvider>(context);
    final items = boardProvider.items;

    if (boardProvider.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return SmartRefresher(
        controller: refreshController,
        onRefresh: _onRefresh,
        child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: items.length + 1,
            itemBuilder: (_, index) {
              if (index < items.length) {
                return BoardItemView(item: items[index]);
              }

              if (!boardProvider.loading) {
                Future.microtask(() => boardProvider.fetchItems());
              }

              return const Center(child: CircularProgressIndicator());
            }),
      );
    }
  }

  _buildAppBar(String title) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },
      ),
      iconTheme: const IconThemeData(color: Colors.black),
      backgroundColor: const Color(0x78bfbfbf),
      elevation: 0,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(color: Colors.transparent),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.account_circle_outlined),
          onPressed: () {
            Navigator.pushNamed(context, '/user');
          },
        ),
      ],
    );
  }

  _onRefresh() async {
    final boardProvider = Provider.of<BoardProvider>(context, listen: false);
    await boardProvider.refresh();
    refreshController.refreshCompleted();
  }
}
