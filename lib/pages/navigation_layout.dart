import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:green_scout/globals.dart';
import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';
import 'login_as_guest.dart';
import 'preference_helpers.dart';

final navigationLayout = <String, Widget Function(BuildContext)>{
	'/loginAsGuest': (context) => const LoginPageForGuest(),
	'/loginAsUser': (context) => const LoginPageForUsers(),
	'/home': (context) => const HomePage(),
};

const loggedInRoute = '/home';
const loggedOutRoute = '/loginAsUser';

/*
 * - 'Divider' is special cased to produce a divider in the
 * place of a route. Sometimes we want the list to be split
 * visually
 */
const navigationLayoutNames = <String, String>{
	"Home": "/home",
	"Divider": "",
	"Logout": '/loginAsUser',
};

class NavigationMenuButton extends StatelessWidget {
	const NavigationMenuButton({super.key});

	@override 
	Widget build(BuildContext context) {
		return PopupMenuButton(
			icon: const Icon(Icons.menu_sharp),

			itemBuilder: (context) {
				var result = <PopupMenuEntry<Widget>>[];

				for (var entry in navigationLayoutNames.entries) {
					if (entry.key.toLowerCase() == "divider") {
						result.add(
							const PopupMenuDivider()
						);
					} else if (entry.key.toLowerCase() == "logout") {
						result.add(
							PopupMenuItem(
								child: Text(entry.key), 
								onTap: () {
									setLoginStatus(false);
									App.gotoPage(context, navigationLayout[entry.value]!(context));
								}
							)
						);
					} else {
						result.add(
							PopupMenuItem(
								child: Text(entry.key), 
								onTap: () {
									App.gotoPage(context, navigationLayout[entry.value]!(context));
								}
							)
						);
					}
				}

				return result;
			}
		);
	}
}

class NavigationLayoutDrawer extends StatelessWidget {
  const NavigationLayoutDrawer({super.key});
  
  @override 
  Widget build(BuildContext context) {
    double widthRatio = 0.75;

    const lowerLimit = 455;
    const upperLimit = 755;

    {
      final width = MediaQuery.of(context).size.width;

      final percent = clampDouble(((width - lowerLimit) / (upperLimit - lowerLimit)).abs(), 0.0, 1.0);

      widthRatio = (0.75 - 0.20 * percent);

      // if (width < lowerLimit) {
      //   widthRatio = 0.75;
      // }

      // if (width < upperLimit && width > lowerLimit) {
      //   widthRatio = 0.65;
      // }

      // if (width > upperLimit) {
      //   widthRatio = 0.55;
      // }
    }

    if (MediaQuery.of(context).size.width > 495) {
      widthRatio = 0.55;
      
      
    }
    
    final width = MediaQuery.of(context).size.width * widthRatio;
    final height = MediaQuery.of(context).size.height;

    return Drawer(
      width: width,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(1)),

      child: ListView(
        children: [
          const Padding(padding: EdgeInsets.all(6)),

          ListTile(
            // subtitle: Text("TODO User / Admin / Super"),
            visualDensity: VisualDensity.comfortable,

            dense: false,

            subtitle: Container(
              color: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraint) {
                return SizedBox( 
                  width: constraint.biggest.width,

                  child: Text(
                    "TODO User / Admin / Super",
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              }),
            ),

            leading: Container(
              color: Colors.transparent,
              child: LayoutBuilder(builder: (context, constraint) {
                return Icon(Icons.account_circle, size: constraint.biggest.height);
              }),
            ),

            title: Text(
              "William Shakespeare",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationButton(BuildContext context, Widget leading, String label, Widget page) {
    return Padding(padding: EdgeInsets.zero);
  }
}