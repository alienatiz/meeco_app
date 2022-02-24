import 'package:flutter/material.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/constants.dart';

class BoardItemView extends StatelessWidget {
  final BoardItem item;

  const BoardItemView({required this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (item.isNotice) {
      return _buildNotice(context);
    } else {
      return GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.pushNamed(context, '/doc', arguments: item);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CategoryView(item.categoryText),
                  const Spacer(),
                  Text(
                    item.time.trim(),
                    style: const TextStyle(color: textInfoDark),
                  ),
                ],
              ),
              const SizedBox(height: 4.0),
              Text(
                item.title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline6,
                softWrap: false,
              ),
              const SizedBox(height: 4.0),
              Row(
                children: [
                  Text(item.author,
                      style:
                          const TextStyle(fontSize: 15, color: textInfoDark)),
                  const Spacer(),
                  IconWithNum(
                    icon: Icons.favorite,
                    num: item.voteNum,
                    color: item.voteNum > 3 ? voteColorLight : null,
                    size: 15,
                  ),
                  const SizedBox(width: 8),
                  Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40.0),
                        border: Border.all(color: textInfoDark, width: 1),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      child: IconWithNum(
                        icon: Icons.comment,
                        num: item.commentNum,
                        color: secondaryColor,
                        size: 13,
                      )),
                ],
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildNotice(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        Navigator.pushNamed(context, '/doc', arguments: item);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        width: MediaQuery.of(context).size.width,
        child: Row(
          children: [
            CategoryView(item.categoryText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                item.title,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.headline6,
                softWrap: false,
              ),
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
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      decoration: BoxDecoration(
        color: categoryColor[category] ?? secondaryColor,
        borderRadius: BorderRadius.circular(40.0),
      ),
      child: Text(
        category,
        style: TextStyle(
            fontSize: 13, color: category == '공지' ? textDark : textLight),
      ),
    );
  }
}

class IconWithNum extends StatelessWidget {
  final IconData icon;
  final int? num;
  final Color color;
  final double? size;

  const IconWithNum(
      {Key? key, required this.icon, this.num, this.size = 15, Color? color})
      : color = color ?? textInfoDark,
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: size, color: color),
        const SizedBox(width: 4),
        Text(num.toString(), style: TextStyle(fontSize: size, color: color)),
      ],
    );
  }
}
