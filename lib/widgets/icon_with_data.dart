import 'package:flutter/material.dart';

class IconWithData extends StatelessWidget {
  final IconData? icon;
  final int? data;
  final Color? color;

  const IconWithData({Key? key, this.icon, this.data, this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 15,
          color: color ?? Colors.black45,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(data.toString(), style: TextStyle(color: color ?? Colors.black45)),
      ],
    );
  }
}
