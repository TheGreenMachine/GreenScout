import 'package:green_scout/pages/admin.dart';
import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:green_scout/widgets/header.dart';

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
	const MatchInfo(1, 2502, false, 2),
	const MatchInfo(1, 2525, false, 3),
	const MatchInfo(1, 3021, true, 1),
	const MatchInfo(1, 12, true, 2),
	const MatchInfo(1, 19020, true, 3),
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
							// onPressed: () => Navigator.push(
							// 	context,
							// 	MaterialPageRoute(
							// 		builder: (context) => const CreateMatchFormPage(),
							// 	),
							// ),
							onPressed: () => Navigator.pushReplacement(
								context,
								MaterialPageRoute(
									builder: (context) => const MatchFormPage(),
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

							child: ListView.builder(
								itemBuilder: (context, index) => matchViewBuilder(context, index, allMatches),
								itemCount: allMatches.length,
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

					const Padding(padding: EdgeInsets.all(16)),
				],
			),
		);
	}

	Widget matchViewBuilder(BuildContext context, int index, List<MatchInfo> matches) {
		final match = matches[index];

		return ExpansionTile(
			leading: Text("${match.matchNum}${match.isBlue ? "B" : "R"}"),
			title: Text(match.team.toString()),

			shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.5)),
			collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2.5)),

			backgroundColor: match.isBlue
				? Theme.of(context).colorScheme.inversePrimary.withBlue(255) 
				: Theme.of(context).colorScheme.inversePrimary.withRed(255),

			collapsedBackgroundColor: match.isBlue
				? Theme.of(context).colorScheme.inversePrimary.withBlue(255) 
				: Theme.of(context).colorScheme.inversePrimary.withRed(255),

			// textColor: Theme.of(context).colorScheme.surface,
			// collapsedTextColor: Theme.of(context).colorScheme.surface,

			trailing: ElevatedButton(
				style: ElevatedButton.styleFrom(
					foregroundColor: Theme.of(context).colorScheme.background,
					backgroundColor: Theme.of(context).colorScheme.primary,
				),

				onPressed: () {
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

				child: const Text("+"),
			),

			children: [
				Text(
					match.isBlue ? "Team Color: Blue" : "Team Color: Red",
				),
				Text(
					"Team Number: ${match.team}",
				),
				Text(
					"Drive Team Number: ${match.driveTeamNum}",
				),
				const Padding(padding: EdgeInsets.all(1)),
			],
		);

		/*
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
		*/
	}
}