import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/widgets/board_item_view.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);
    final boardProvider = Provider.of<BoardProvider>(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.menu), onPressed: () {
          Navigator.pushReplacementNamed(context, '/menu');
        },),
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: const Color(0x78bfbfbf),
        // const Color(0xff4c5c84),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '미니기기 코리아',
          style: TextStyle(
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
          if (!apiProvider.isLoggedIn)
            TextButton(
                onPressed: () {
                  apiProvider.logIn('editionc18', 'somang0307@');
                },
                child: const Text(
                  '로그인',
                  style: TextStyle(color: Colors.black),
                ))
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            TextButton(
              child: const Text('IT+'),
              onPressed: () {
                Future.microtask(() => boardProvider.refresh('ITplus'));
              },
            ),
            TextButton(
              child: const Text('자유+'),
              onPressed: () {
                Future.microtask(() => boardProvider.refresh('FreePlus'));
              },
            ),
            TextButton(
              child: const Text('가격+'),
              onPressed: () {
                Future.microtask(() => boardProvider.refresh('PricePlus'));
              },
            ),
          ],
        ),
      ),
      body: _renderListView(),
    );
  }

  _renderListView() {
    final boardProvider = Provider.of<BoardProvider>(context);
    final items = boardProvider.items;

    if (boardProvider.loading && items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    } else {
      return ListView.builder(
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
