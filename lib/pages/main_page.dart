import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/widgets/board_item_view.dart';
import 'package:provider/provider.dart';

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
    final url = arg!['url']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/menu');
          },
        ),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0x78bfbfbf),
        // const Color(0xff4c5c84),
        elevation: 0,
        centerTitle: true,
        title: Text(
          arg['title']!,
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
              onPressed: () {}, icon: const Icon(Icons.account_circle_outlined))
          // if (!apiProvider.isLoggedIn)
          //   TextButton(
          //       onPressed: () {
          //         apiProvider.logIn('editionc18', 'somang0307@');
          //       },
          //       child: const Text(
          //         '로그인',
          //         style: TextStyle(color: Colors.black),
          //       ))
        ],
      ),
      body: _renderListView(url),
    );
  }

  _renderListView(String url) {
    final boardProvider = Provider.of<BoardProvider>(context);
    final items = boardProvider.items;

    if (boardProvider.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
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
          });
    }
  }
}
