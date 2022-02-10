import 'package:flutter/material.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/constants.dart';

class BoardItemView extends StatelessWidget {
  final BoardItem? item;

  const BoardItemView({this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pushNamed(context, '/doc', arguments: item);
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Row(
              children: [
                if (item!.isNotice) const CategoryView('공지'),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${item?.title}',
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headline6,
                    softWrap: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('${item?.author}',
                    style: const TextStyle(fontSize: 15, color: textInfoDark)),
                const Spacer(),
                IconWithNum(icon: Icons.remove_red_eye, num: item!.viewNum),
                const SizedBox(width: 4),
                IconWithNum(icon: Icons.comment, num: item!.commentNum),
                const SizedBox(width: 4),
                IconWithNum(
                  icon: Icons.favorite,
                  num: item!.voteNum,
                  color: item!.voteNum > 3 ? voteColorLight : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class CategoryView extends StatelessWidget {
  final String category;
  const CategoryView(this.category, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4.0),
      child: Text(
        category,
        style: const TextStyle(
          fontSize: 15,
          color: Colors.black,
        ),
      ),
      decoration: const BoxDecoration(
        color: voteColorLight,
        borderRadius: BorderRadius.all(Radius.circular(8.0)),
      ),
    );
  }
}

class IconWithNum extends StatelessWidget {
  final IconData icon;
  final int? num;
  final Color color;

  const IconWithNum({Key? key, required this.icon, this.num, Color? color})
      : color = color ?? textInfoDark,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 15, color: color),
        const SizedBox(width: 4),
        Text(num.toString(), style: TextStyle(color: color)),
      ],
    );
  }
}
