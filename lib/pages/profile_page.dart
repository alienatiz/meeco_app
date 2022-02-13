import 'package:flutter/material.dart';
import 'package:meeco_app/backend/auth_provider.dart';
import 'package:meeco_app/backend/client.dart';
import 'package:meeco_app/backend/theme_provider.dart';
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
    final client = Provider.of<Client>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          !client.isLoggedIn
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
          _buildAppSettingListView(),
          const SizedBox(height: 16),
          if (client.isLoggedIn)
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
                  await authProvider.logOut();
                },
              ),
            ),
        ],
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
        Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '테마',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyText1!.color,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildThemeInfo(
                  themeMode: ThemeMode.light,
                  child: _buildCircle(color: bgLight),
                  text: '라이트',
                ),
                _buildThemeInfo(
                  themeMode: ThemeMode.dark,
                  child: _buildCircle(color: bgDark),
                  text: '다크',
                ),
                _buildThemeInfo(
                  themeMode: ThemeMode.system,
                  child: Stack(children: [
                    _buildCircle(color: bgDark),
                    ClipPath(
                      clipper: DiagonalClipPath(),
                      child: _buildCircle(color: bgLight),
                    ),
                  ]),
                  text: '시스템',
                ),
              ],
            ),
          ],
        )
      ],
    );
  }

  Column _buildThemeInfo({
    required Widget child,
    required String text,
    required ThemeMode themeMode,
  }) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    return Column(
      children: [
        GestureDetector(
            onTap: () {
              themeProvider.switchTheme(themeMode);
            },
            child: Stack(children: [
              child,
              if (themeProvider.themeMode == themeMode)
                const Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Icon(Icons.check, color: textInfoDark),
                ),
            ])),
        const SizedBox(height: 8),
        Text(
          text,
          style: Theme.of(context).textTheme.bodyText1!.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
        ),
      ],
    );
  }

  Container _buildCircle({required Color color}) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(100.0),
        border: Border.all(color: primaryColorDark, width: 2),
      ),
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

class DiagonalClipPath extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, 0);
    path.lineTo(0, size.height);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
