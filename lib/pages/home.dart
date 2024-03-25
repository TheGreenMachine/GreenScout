import 'package:green_scout/pages/admin.dart';
import 'package:green_scout/pages/bluetooth_selector.dart';
import 'package:green_scout/pages/create_new_match.dart';
import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:flutter/material.dart';

import 'matches_data.dart';

class HomePage extends StatefulWidget {
	const HomePage({
		super.key,
	});

	@override
	State<HomePage> createState() => _HomePage();
}

List<MatchInfo> allMatches = [
	const MatchInfo(1, 1816, false, 1),
];

class _HomePage extends State<HomePage> {
	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
				actions: const [
					NavigationMenu(),
					Spacer(),
				],
			),
			body: ListView(
				children: [
					isAdmin() ? Padding(
						padding: EdgeInsets.symmetric(
							horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75), 
							vertical: 15,
						),

						child: FloatingButton(
							labelText: "Admin Page",

							icon: const Icon(Icons.admin_panel_settings),
							color: Theme.of(context).colorScheme.primaryContainer.withBlue(255),

							onPressed: () => Navigator.pushReplacement(
								context,
								MaterialPageRoute(
									builder: (context) => const AdminPage(),
								),
							),
						),
					) : const Padding(padding: EdgeInsets.zero),

					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75), vertical: 15),

						child: FloatingButton(
							labelText: "Create New Match Form",

							icon: const Icon(Icons.create),
							color: Theme.of(context).colorScheme.inversePrimary,
							onPressed: () => Navigator.pushReplacement(
								context,
								MaterialPageRoute(
									builder: (context) => const MatchFormPage(),
								),
							),
						),
					),

					const Padding(padding: EdgeInsets.all(4)),

					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75), vertical: 0),

						child: FloatingButton(
							labelText: "Stream Data Through Bluetooth",

							icon: const Icon(Icons.bluetooth),
							color: Theme.of(context).colorScheme.inversePrimary.withBlue(255),
							onPressed: () => Navigator.pushReplacement(
								context,
								MaterialPageRoute(
									builder: (context) => const BluetoothSelectorPage(),
								),
							),
						),
					),

					// TODO: Finish this after the scrimmage.

					const Padding(padding: EdgeInsets.all(18)),

					const HeaderLabel("Assigned Matches"),

					const Padding(padding: EdgeInsets.all(4)),

					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),

						child: SizedBox(
							height: 250,

							child: ListView(
								children: [],
							),
						),
					),

					const Padding(padding: EdgeInsets.all(12)),

					const HeaderLabel("All Matches"),

					const Padding(padding: EdgeInsets.all(4)),

					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),

						child: SizedBox(
							height: 250,

							child: ListView.builder(
								itemBuilder: (context, index) => matchViewBuilder(context, index, allMatches),
								itemCount: allMatches.length,
							),
						),
					),
				],
			),
		);
	}

	Widget matchViewBuilder(BuildContext context, int index, List<MatchInfo> matches) {
		final match = matches[index];

		return GestureDetector(
			child: Row(
				children: [
					Text(
						match.team.toString(),
					),

					const Padding(padding: EdgeInsets.symmetric(horizontal: 2)),

					Text(
						match.matchNum.toString(),
					),

					const Padding(padding: EdgeInsets.symmetric(horizontal: 8)),

					SizedBox(

						child: Container( 
							width: 25,
							height: 25,

							color: match.isBlue
								? const Color.fromARGB(255, 0, 0, 255)
								: const Color.fromARGB(255, 255, 0, 0),

							child: Text(
								match.driveTeamNum.toString(),

								
							),
						),
					)
				],
			),

			onTap: () {
				Navigator.pushReplacement(
					context, 
					MaterialPageRoute(
						builder: (context) =>
							MatchFormPage(
								matchNum: match.matchNum.toString(),
								teamNum: match.team.toString(),
								isBlue: match.isBlue,
								driverNumber: match.driveTeamNum,
							),
					),
				);
			},
		);
	}
}