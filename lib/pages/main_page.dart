import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/backend/board_provider.dart';
import 'package:meeco_app/widgets/board_item_view.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Map<String, String>? arg =
        ModalRoute.of(context)?.settings.arguments != null
            ? ModalRoute.of(context)?.settings.arguments as Map<String, String>
            : {'title': 'IT+', 'url': 'ITplus'};
    final url = arg!['url']!;

    return Scaffold(
      extendBodyBehindAppBar: true,
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

  Widget buildLoginForm(context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '로그인',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                TextField(
                  controller: idController,
                  cursorColor: Colors.black,
                  style: const TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 0.7,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: 'ID',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: pwController,
                  cursorColor: Colors.black,
                  obscureText: true,
                  style: const TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 0.7,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '비밀번호',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(40.0),
                      borderSide: const BorderSide(color: Colors.black54),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Colors.black),
                      borderRadius: BorderRadius.circular(40.0),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          const Color(0xff4c5c84),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: const BorderSide(color: Color(0xff4c5c84)),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        await apiProvider.logIn(
                            idController.text, pwController.text);
                        if (apiProvider.isLoggedIn) {
                          Navigator.pop(context);
                        }
                      },
                      child: const Text(
                        '로그인',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      )),
                )
              ],
            ),
          ),
        ],
      ),
    );
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
        !apiProvider.isLoggedIn
            ? IconButton(
                onPressed: () {
                  showModalBottomSheet(
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(24.0),
                        topRight: Radius.circular(24.0),
                      )),
                      context: context,
                      builder: buildLoginForm);
                },
                icon: const Icon(Icons.login),
              )
            : IconButton(
                icon: const Icon(Icons.account_circle_outlined),
                onPressed: () {
                  Navigator.pushNamed(context, '/user');
                },
              ),
      ],
    );
  }
}
