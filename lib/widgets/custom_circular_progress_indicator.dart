import 'package:flutter/material.dart';
import 'package:meeco_app/constants.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: CircularProgressIndicator(
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(
          Theme.of(context).brightness == Brightness.dark
              ? secondaryColorDark
              : secondaryColor,
        ),
      ),
    );
  }
}
