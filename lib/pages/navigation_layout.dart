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

class NavigationMenu extends StatelessWidget {
	const NavigationMenu({super.key});

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
									Navigator.pushReplacementNamed(context, entry.value);
								}
							)
						);
					} else {
						result.add(
							PopupMenuItem(
								child: Text(entry.key), 
								onTap: () {
									Navigator.pushReplacementNamed(context, entry.value);
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