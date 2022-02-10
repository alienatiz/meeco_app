import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/constants.dart';
import 'package:provider/provider.dart';
import 'package:meeco_app/widgets/log_in_form.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.black),
        backgroundColor: Colors.transparent,
        // const Color(0xff4c5c84),
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            !apiProvider.isLoggedIn
                ? Center(
                    child: TextButton(
                      onPressed: () {
                        customModalBottomSheet(
                          context: context,
                          builder: (_) => const LogInForm(),
                        );
                      },
                      child: const Text(
                        '로그인 해주세요',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: secondaryColor,
                        ),
                      ),
                    ),
                  )
                : _buildLoggedInBody(),
            const SizedBox(height: 8),
            Text('앱  설정',
                style: Theme.of(context)
                    .textTheme
                    .bodyText1!
                    .copyWith(fontSize: 13)),
            _buildAppSettingListView(),
            const SizedBox(height: 16),
            if (apiProvider.isLoggedIn)
              Center(
                child: TextButton(
                  child: const Text(
                    '로그아웃',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    await apiProvider.logOut();
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  _buildAccountListView() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _buildListTile('프로필', Icons.account_circle),
        _buildListTile('작성한 글', Icons.article),
      ],
    );
  }

  _buildAppSettingListView() {
    return ListView(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _buildListTile('테마', Icons.dark_mode_outlined),
      ],
    );
  }

  _buildListTile(String title, IconData leading) {
    return ListTile(
      dense: true,
      title: Text(title,
          style: Theme.of(context)
              .textTheme
              .bodyText1!
              .copyWith(fontWeight: FontWeight.w700)),
      leading: Icon(
        leading,
        color: Theme.of(context).textTheme.bodyText1!.color,
      ),
      trailing: Icon(
        Icons.keyboard_arrow_right,
        color: Theme.of(context).textTheme.bodyText1!.color,
      ),
    );
  }

  _buildLoggedInBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // const Align(
        //   alignment: Alignment.center,
        //   child: CircleAvatar(
        //     radius: 50,
        //     backgroundImage: AssetImage('assets/test_image.jpeg'),
        //   ),
        // ),
        // const SizedBox(height: 8),
        // const Align(
        //   alignment: Alignment.center,
        //   child: Text(
        //     'Cide',
        //     style: TextStyle(
        //       fontSize: 32,
        //       fontWeight: FontWeight.w700,
        //     ),
        //   ),
        // ),
        // const SizedBox(height: 16),
        const Text('계정'),
        _buildAccountListView(),
      ],
    );
  }
}
