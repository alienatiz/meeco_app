import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
import 'package:meeco_app/constants.dart';
import 'package:provider/provider.dart';

class LogInForm extends StatefulWidget {
  const LogInForm({Key? key}) : super(key: key);

  @override
  _LogInFormState createState() => _LogInFormState();
}

class _LogInFormState extends State<LogInForm> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final apiProvider = Provider.of<ApiProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '로그인',
            style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                LogInTextField(
                  controller: idController,
                  hintText: 'ID',
                ),
                const SizedBox(height: 8),
                LogInTextField(
                  controller: pwController,
                  obscureText: true,
                  hintText: '비밀번호',
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: TextButton(
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all<Color>(
                          apiProvider.loading
                              ? bgTextFieldDark
                              : secondaryColor,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (!apiProvider.loading) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          await apiProvider.logIn(
                              id: idController.text, pw: pwController.text);
                        }
                        if (apiProvider.isLoggedIn && !apiProvider.loading) {
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
}

class LogInTextField extends StatelessWidget {
  final TextEditingController? controller;
  final bool obscureText;
  final String? hintText;

  const LogInTextField(
      {Key? key, this.controller, this.obscureText = false, this.hintText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(
        fontSize: 16.0,
        letterSpacing: 0.7,
      ),
      cursorColor: Theme.of(context).focusColor,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white30,
        isDense: true,
        hintText: hintText,
        focusedBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: UnderlineInputBorder(
          borderRadius: BorderRadius.circular(16.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
