import 'package:flutter/material.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/navigation_layout.dart';
import 'package:green_scout/widgets/subheader.dart';

class PhotoGalleryPage extends StatelessWidget {
  const PhotoGalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.95, 0.95);

    return Scaffold(
        drawer: const NavigationLayoutDrawer(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          actions: createEmptyActionBar(),
        ),
        body: Padding(
            padding: EdgeInsets.symmetric(horizontal: widthPadding),
            child: ListView(
              children: [
                const HeaderLabel("Ryan McGoff Photo Gallery"),
                const SubheaderLabel(
                    "Do you have more pictures of Ryan McGoff? Give them to the current app devs to add!"),
                const SubheaderLabel(
                    "If you need more photos, please contact George or Tag. Or take some yourself you bum"),
                buildGallery(6)
              ],
            )));
  }

  Widget buildGallery(int num) {
    List<Widget> children = [];
    for (int i = 0; i < num; i++) {
      children.add(App.getGalleryImage(i));
      children.add(const Padding(padding: EdgeInsets.all(4)));
    }
    return Column(
      children: children,
    );
  }
}
