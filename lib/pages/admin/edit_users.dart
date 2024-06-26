import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/pages/leaderboard.dart';
import 'package:green_scout/utils/achievement_manager.dart';
import 'package:green_scout/utils/app_state.dart';
import 'package:green_scout/utils/data_for_admins.dart';
import 'package:green_scout/utils/general_utils.dart';
import 'package:green_scout/utils/reference.dart';
import 'package:green_scout/utils/action_bar.dart';
import 'package:green_scout/widgets/dropdown.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:image_picker/image_picker.dart';

/// Admin page that hosts an interface for
/// admins to modify user content like display names,
/// profile pictures and more...
class EditUsersAdminPage extends StatefulWidget {
  const EditUsersAdminPage({super.key});

  @override
  State<EditUsersAdminPage> createState() => _EditUsersAdminPage();
}

// TODO, this might be an interesing challenge for future devs:
///!!! We never frontend-implemented custom descriptions for badges. They exist on the backend, so if you want, future devs can implement it !!! - Tag///

class UserInfo {
  final String username;
  final String uuid;
  final Reference<String> displayName;
  final Reference<LeaderboardColor> selectedColor;
  int startingColor;
  String startingDisplayName;

  Widget pfp;
  bool hasChangedImage;
  XFile? xCustomImage;

  List<String> originalBadges;
  List<String> currentBadges;

  UserInfo(
      this.displayName, this.selectedColor, this.username, this.uuid, this.pfp,
      {this.hasChangedImage = false, this.currentBadges = const []})
      : startingColor = LeaderboardColor.values.indexOf(selectedColor.value),
        startingDisplayName = displayName.value.toString(),
        originalBadges = List.from(currentBadges);
}

class EncodableBadge {
  String id;
  String description;

  EncodableBadge({
    required this.id,
    required this.description,
  });

  Map<String, dynamic> toJson() => {
        'ID': id,
        'Description': description,
      };

  factory EncodableBadge.fromJson(Map<String, dynamic> json) {
    if (json['ID'] is! String || json['Description'] is! String) {
      throw TypeError();
    }
    return EncodableBadge(
      id: json['ID'] as String,
      description: json['Description'] as String,
    );
  }

  @override
  String toString() => jsonEncode(toJson());
}

class _EditUsersAdminPage extends State<EditUsersAdminPage> {
  TextEditingController displayNameController = TextEditingController();
  Reference<String> currentUser = Reference(AdminData.noActiveUserSelected);
  UserInfo currentUserInfo = UserInfo(
    Reference(""),
    Reference(LeaderboardColor.none),
    "Loading...",
    "Loading...",
    Image.asset("nuh uh"),
  );

  Image customImage = Image.asset("nuh uh");

  final badgesSelected = List.filled(
      AchievementManager.leaderboardBadges.length +
          AchievementManager.silentBadges.length,
      false);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      AdminData.updateUserRoster();
    });
  }

  @override
  void dispose() {
    displayNameController.dispose();
    super.dispose();
  }

  Widget buildUserInfoScreen(
      BuildContext context, double widthPadding, double width, UserInfo info) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widthPadding),
      child: Column(
        children: [
          const HeaderLabel("User Information"),
          const Padding(padding: EdgeInsets.all(6)),
          createLabelAndTextInput(
              "Display Name", widthPadding, width, info.displayName),
          buildBadgesView(width, widthPadding),
          createLabelAndImagePicker(
              "Profile Picture", widthPadding, width, info),
          createLabelAndDropdown(
              "Leaderboard Color",
              widthPadding,
              width,
              LeaderboardColor.values.asNameMap(),
              info.selectedColor,
              info.selectedColor.value),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: () async {
                bool success = false;

                // Hack to get async code to execute in a
                // synchronous scope.
                () async {
                  /// A quick little function to make the pattern of
                  /// doing something and reporting it centralized.
                  /// 
                  /// This is also so we can ensure that context never goes
                  /// invalid and make code look nicer too.
                  void doActionAndReport(
                    void Function() action,
                    String successfulMessage,
                    String failureMessage,
                  ) {
                    if (success) {
                      action();
                    }

                    // This guarding clause ensures the app doesn't crash when 
                    // you leave the page before the message pops up.
                    if (context.mounted) {
                      App.showMessage(
                        context, 
                        success
                        ? successfulMessage
                        : failureMessage,
                      );
                    }
                  }

                  if (info.selectedColor.value.index != info.startingColor) {
                    success = await AdminData.updateLeaderboardColor(
                      Settings.selectedLeaderboardColor.ref.value, 
                      info,
                    );

                    doActionAndReport(
                      () => info.startingColor = info.selectedColor.value.index, 
                      "Successfully updated leaderboard color of ${info.username} to ${Settings.selectedLeaderboardColor.ref.value.name}", 
                      "Unable to update color",
                    );
                  }

                  if (info.displayName.value != info.startingDisplayName) {
                    success = await AdminData.updateDisplayName(
                        info.displayName.value, info);

                    doActionAndReport(
                      () => info.startingDisplayName = info.displayName.value, 
                      "Successfully updated display name of ${info.username} to ${info.displayName.value}", 
                      "Unable to update display name",
                    );
                  }

                  if (info.hasChangedImage && info.xCustomImage != null) {
                    success = await AdminData.updateUserPfp(
                      info.xCustomImage!, 
                      info,
                    );

                    doActionAndReport(
                      () {}, // do nothing.
                      "Successfully updated pfp of ${info.username}", 
                      "Unable to update pfp",
                    );
                  }

                  if (!listEquals(info.currentBadges, info.originalBadges)) {
                    // Transforms the currentBadges list into a list of encodeable badges.
                    // Might be a little too terse.
                    final jsonToSend = info.currentBadges.map(
                      (badge) => EncodableBadge(id: badge, description: badge),
                    ).toList();

                    success = await App.httpRequest(
                      "/badgeConfig", 
                      jsonToSend.toString(),
                      headers: {
                        "username": info.username,
                      },
                    );

                    doActionAndReport(
                      // Copies the list content and makes a new object.
                      () => info.originalBadges = List.from(info.currentBadges), 

                      "Successfully updated badges of ${info.username}", 
                      "Unable to update badges",
                    );
                  }
                }();
              },
              child: const Text("Submit"),
            ),
          ),

          const Padding(padding: EdgeInsets.all(4)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (width, widthPadding) =
        screenScaler(MediaQuery.of(context).size.width, 670, 0.95, 0.95);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {});
        },
        child: ListView(
          children: [
            const Padding(padding: EdgeInsets.all(8)),
            const SubheaderLabel("User"),
            const Padding(padding: EdgeInsets.all(2)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal:
                    MediaQuery.of(context).size.width * (1.0 - 0.65) / 2,
              ),
              child: Dropdown<String>(
                padding: const EdgeInsets.only(left: 10),
                isExpanded: true,
                entries: AdminData.users,
                inValue: currentUser,
                defaultValue: AdminData.noActiveUserSelected,
                textStyle: null,
                alignment: Alignment.center,
                menuMaxHeight: 175,
                changeOnNewValue: true,
                onChanged: () async {
                  currentUserInfo = await AdminData.adminGetUserInfo(currentUser.value);
                  
                  displayNameController.text = currentUserInfo.displayName.value;

                  // Updates the selected badges based off of 
                  // what badges are currently equiped internally.
                  final allBadges = AchievementManager.allBadges();

                  for (final (index, badge) in allBadges.indexed) {
                    final hasIt = currentUserInfo.currentBadges.contains(badge.name);

                    badgesSelected[index] = hasIt;
                  }

                  setState(() {});
                },
              ),
            ),
            const Padding(padding: EdgeInsets.all(12)),
            if (currentUserInfo.displayName.value != "")
              buildUserInfoScreen(context, widthPadding, width, currentUserInfo)
          ],
        ),
      ),
    );
  }

  Widget createLabelAndTextInput(
      String label, double widthPadding, double width, Reference refToChange) {
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
              controller: displayNameController,
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

  Widget createLabelAndImagePicker(
      String label, double widthPadding, double width, UserInfo info) {
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
          InkWell(
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? xFile = await picker.pickImage(
                  source: ImageSource.gallery, maxHeight: 512, maxWidth: 512);
              if (xFile != null) {
                customImage = Image.memory(
                  await xFile.readAsBytes(),
                );
                info.xCustomImage = xFile;
                currentUserInfo.hasChangedImage = true;
                info.pfp = customImage;
                setState(() {});
              }
            },
            child: Ink(width: width * 0.25, child: info.pfp),
          ),
        ],
      ),
    );
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

  Widget buildBadgesView(double width, double widthPadding) {
    List<Widget> buildBadgeList() {
      final result = <Widget>[];
      final badges = AchievementManager.allBadges();

      for (final (index, badge) in badges.indexed) {
        result.add(
          Stack(
            alignment: Alignment.topRight,
            children: [
              InkWell(
                onLongPress: () {
                  App.showMessage(context, badge.description);
                },
                onTap: () {
                  badgesSelected[index] = !badgesSelected[index];
                  
                  // Updating all current badges every single time might
                  // be wasteful. Maybe come up with some other way of
                  // doing this?
                  updateCurrentUserBadges();
                  setState(() {});
                },
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: width / 8,
                    minWidth: width / 8,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(16)),
                      color: App.getThemeMode() == Brightness.light
                          ? Colors.grey.shade100
                          : Colors.grey.shade600,
                      border: Border.all(
                        color: badgesSelected[index]
                            ? Colors.lightGreen
                            : Colors.redAccent,
                        width: 3.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: badge.badge,
                          ),
                          const Padding(padding: EdgeInsets.all(4)),
                          Text(
                            badge.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              ClipPath(
                clipper: CustomClipPathTopContainer(),
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.only(topRight: Radius.circular(20)),
                    color: badgesSelected[index]
                        ? Colors.lightGreen
                        : Colors.redAccent,
                    border: Border.all(
                      color: badgesSelected[index]
                          ? Colors.lightGreen
                          : Colors.redAccent,
                      width: 5,
                    ),
                  ),
                ),
              ),
              Positioned(
                right: 5,
                top: 8,
                child: badgesSelected[index]
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                    : const Padding(padding: EdgeInsets.zero),
              ),
            ],
          ),
        );
      }

      return result;
    }

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 5,
      runSpacing: 5,
      children: buildBadgeList(),
    );
  }

  void updateCurrentUserBadges() {
    // Probably should cache this value elsewhere...
    // Or maybe the compiler will optimize this out?
    final allBadges = AchievementManager.allBadges();

    for (final (index, badgeSelected) in badgesSelected.indexed) {
      final badgeName = allBadges[index].name;
      final hasIt = currentUserInfo.currentBadges.contains(badgeName);
      
      // Add it if it's not already there.
      if (!hasIt && badgeSelected) {
        currentUserInfo.currentBadges.add(badgeName);
      } 

      // Remove it if it's already there.
      if (hasIt && !badgeSelected) {
        currentUserInfo.currentBadges.remove(badgeName);
      }
    }
  }
}

// Code comes from:
// https://stackoverflow.com/questions/73193650/in-flutter-how-to-design-container-with-tick-mark-in-top-right-edge-like-in-the
class CustomClipPathTopContainer extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path0 = Path();
    path0.moveTo(0, 0);
    path0.lineTo(size.width, 0);
    path0.lineTo(size.width, size.height);
    path0.lineTo(0, 0);
    return path0;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
