import 'package:flutter/material.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/main_app_data_helper.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';

import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  const UserInfoPage({super.key});

  @override
  State<UserInfoPage> createState() => _UserInfoPage();
}

class _UserInfoPage extends State<UserInfoPage> {
  bool hasCustomImage = false;
  Image customImage = Image.asset("nuh uh");
  XFile xCustomImage = XFile("Fake");
  Reference displayName = Reference(MainAppData.displayName);

  //Yes this is dumb but i don't know dart's rules for shallow vs deep copying well and i didn't want to risk a ref copy
  int startingLbColor = Settings.selectedLeaderboardColor.ref.value.index;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    bool unlockedDisplayname = AchievementManager.displayNameUnlocked;
    bool unlockedPfp = AchievementManager.profileChangeUnlocked;
    bool unlockedColor =
        AchievementManager.greenUnlocked || AchievementManager.goldUnlocked;

    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.95, 0.95);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: widthPadding),
        child: ListView(
          children: [
            const HeaderLabel("User Information"),
            const Padding(padding: EdgeInsets.all(6)),
            if (unlockedDisplayname)
              createLabelAndTextInput("Display Name", widthPadding, width,
                  displayName.value, displayName),
            if (unlockedPfp)
              createLabelAndImagePicker("Profile Picture", widthPadding, width),
            if (unlockedColor)
              createLabelAndDropdown(
                  "Leaderboard Color",
                  widthPadding,
                  width,
                  LeaderboardColor.getUnlockedColors(),
                  Settings.selectedLeaderboardColor.ref,
                  Settings.selectedLeaderboardColor.value()),
            if (unlockedPfp || unlockedDisplayname)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: widthPadding),
                child: FloatingButton(
                  onPressed: () {
                    bool success = false;

                    () async {
                      if (unlockedColor) {
                        if (Settings.selectedLeaderboardColor.ref.value.index !=
                            startingLbColor) {
                          success = await MainAppData.updateLeaderboardColor(
                              Settings.selectedLeaderboardColor.ref.value);
                            
                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            MainAppData.displayName = displayName.value;

                            App.showMessage(context,
                                "Successfully updated color to ${Settings.selectedLeaderboardColor.ref.value.name}");
                          } else {
                            App.showMessage(context, "Unable to update color");
                          }
                        }
                      }

                      if (unlockedDisplayname) {
                        if (displayName.value != MainAppData.displayName) {
                          success = await MainAppData.updateDisplayName(
                              displayName.value);

                          if (!context.mounted) {
                            return;
                          }

                          if (success) {
                            MainAppData.displayName = displayName.value;
                            App.showMessage(context,
                                "Successfully updated display name to ${displayName.value}");
                          } else {
                            App.showMessage(
                                context, "Unable to update display name");
                          }
                        }
                      }

                      if (hasCustomImage) {
                        success = await MainAppData.updateUserPfp(xCustomImage);

                        if (!context.mounted) {
                          return;
                        }

                        if (success) {
                          App.setPfp(
                              Image.memory(await xCustomImage.readAsBytes()));
                          
                          if (!context.mounted) {
                            return;
                          }

                          App.showMessage(context, "Successfully updated pfp");
                        } else {
                          App.showMessage(context, "Unable to update pfp");
                        }
                      }
                    }();
                  },
                  labelText: "Submit",
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget createLabelAndTextInput<V>(String label, double widthPadding,
      double width, String initialValue, Reference refToChange) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widthPadding,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.65,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SizedBox(
            width: width * 0.25,
            child: TextFormField(
              initialValue: initialValue,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontSize: 18),
              onChanged: (value) => refToChange.value = value,
              maxLines: 1,
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(1.0)),
                ),
                isDense: false,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createLabelAndImagePicker<V>(
      String label, double widthPadding, double width) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widthPadding,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.65,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          GestureDetector(
              onTap: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? xFile = await picker.pickImage(
                    source: ImageSource.gallery, maxHeight: 512, maxWidth: 512);
                if (xFile != null) {
                  customImage = Image.memory(
                    await xFile.readAsBytes(),
                  );
                  xCustomImage = xFile;
                  hasCustomImage = true;
                  setState(() {});
                }
              },
              child: SizedBox(width: width * 0.25, child: getPFP()))
        ],
      ),
    );
  }

  Widget getPFP() {
    if (hasCustomImage) {
      return customImage;
    }
    return App.getPfp();
  }

  Widget createLabelAndDropdown<V>(
    String label,
    double widthPadding,
    double width,
    Map<String, V> entries,
    Reference<V> inValue,
    V defaultValue,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: widthPadding,
        vertical: 8,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: width * 0.65,
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ),
          SizedBox(
            width: width * 0.25,
            child: Dropdown<V>(
              entries: entries,
              inValue: inValue,
              defaultValue: defaultValue,
              textStyle: Theme.of(context).textTheme.labelMedium,
              padding: const EdgeInsets.only(left: 5),
            ),
          ),
        ],
      ),
    );
  }
}
