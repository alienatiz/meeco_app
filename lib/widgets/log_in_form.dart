import 'package:flutter/material.dart';
import 'package:meeco_app/backend/api_provider.dart';
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
                          apiProvider.loading
                              ? Colors.grey
                              : const Color(0xff4c5c84),
                        ),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40.0),
                            side: BorderSide(
                                color: apiProvider.loading
                                    ? Colors.grey
                                    : const Color(0xff4c5c84)),
                          ),
                        ),
                      ),
                      onPressed: () async {
                        if (!apiProvider.loading) {
                          FocusManager.instance.primaryFocus?.unfocus();
                          await apiProvider.logIn(
                              idController.text, pwController.text);
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
