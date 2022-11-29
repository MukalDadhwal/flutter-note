import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

import '../widgets/card_note.dart';
import '../models/card_model.dart';

class CardGrid extends StatelessWidget {
  final List<CardModel> pinnedCardsList;
  final List<CardModel> unpinnedCardsList;

  CardGrid({
    required this.pinnedCardsList,
    required this.unpinnedCardsList,
  });
  int _getCrossAxisCount(double screenWidth) {
    if (screenWidth <= 550 && screenWidth > 400) {
      return 2;
    } else if (screenWidth > 550) {
      return 3;
    } else {
      return 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('pinned'),
            ),
            MasonryGridView.count(
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(20.0),
              crossAxisCount: _getCrossAxisCount(width),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: pinnedCardsList.length,
              addRepaintBoundaries: false,
              itemBuilder: (BuildContext context, int index) {
                return ChangeNotifierProvider.value(
                  value: pinnedCardsList[index],
                  child: CardNote(),
                );
              },
            ),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Text('others'),
            ),
            MasonryGridView.count(
              shrinkWrap: true,
              primary: false,
              padding: const EdgeInsets.all(20.0),
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              itemCount: unpinnedCardsList.length,
              addRepaintBoundaries: false,
              itemBuilder: (BuildContext context, int index) {
                return ChangeNotifierProvider.value(
                  value: unpinnedCardsList[index],
                  child: CardNote(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
