import 'package:flutter/material.dart';
import 'package:meeco_app/backend/data_model/board_item.dart';
import 'package:meeco_app/widgets/icon_with_data.dart';

class BoardItemView extends StatelessWidget {
  final BoardItem? item;

  const BoardItemView({this.item, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                if (item!.isNotice)
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4.0),
                        child: const Text(
                          '공지',
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        ),
                      ),
                      const SizedBox(width: 6),
                    ],
                  ),
                Expanded(
                  child: Text(
                    '${item?.title}',
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18),
                    softWrap: false,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Row(
              children: [
                Text('${item?.author}',
                    style: const TextStyle(color: Colors.black45)),
                const Spacer(),
                IconWithData(icon: Icons.remove_red_eye, data: item!.viewNum),
                const SizedBox(width: 4),
                IconWithData(icon: Icons.comment, data: item!.commentNum),
                const SizedBox(width: 4),
                IconWithData(
                    icon: Icons.favorite,
                    data: item!.voteNum,
                    color: (item!.voteNum > 3 ? Colors.red : null)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
