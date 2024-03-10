import 'package:flutter/material.dart';
import 'login_as_guest.dart';
import 'match_form.dart';
import 'preference_helpers.dart';

final navigationLayout = <String, Widget Function(BuildContext)>{
	'/loginAsGuest': (context) => const LoginPageForGuest(),
	'/matchForm': (context) => const MatchFormPage(),
};

const loggedInRoute = '/matchForm';
const loggedOutRoute = '/loginAsGuest';

/*
 * - 'Divider' is special cased to produce a divider in the
 * place of a route. Sometimes we want the list to be split
 * visually
 * 
 * - Starting any key with '|' will make that key be ignored
 * when constructing the navigation menu. 
 */
const navigationLayoutNames = <String, String>{
	"|Match Form": "/matchForm",
	"Divider": "",
	"Logout": '/loginAsGuest',
};

/*
 * A global that I don't necessarily like, but need to make sure that
 * state will be consistent across pages.
 */
String currentRoute = "/";

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
					} else if (entry.key.startsWith("|")) {
						// Empty block since we want to ignore cases that start with '|'
					} else {
						result.add(
							PopupMenuItem(
								child: Text(entry.key), 
								onTap: () {
									if (entry.value != currentRoute) {
										Navigator.pushReplacementNamed(context, entry.value);
										currentRoute = entry.value;
									}
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