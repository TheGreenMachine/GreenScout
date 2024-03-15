import 'package:green_scout/pages/navigation_layout.dart';
import 'package:green_scout/pages/preference_helpers.dart';
import 'package:green_scout/widgets/header.dart';
import 'package:green_scout/widgets/subheader.dart';
import 'package:flutter/material.dart';

class MatchDisplayAdminData {
	const MatchDisplayAdminData(this.match, this.team, this.isBlue, this.driverStation);

	final int match;
	final int team;

	final bool isBlue;
	final int driverStation;
}

class AdminPage extends StatefulWidget {
	const AdminPage({super.key});

	@override
	State<AdminPage> createState() => _AdminPage();
}

class _AdminPage extends State<AdminPage> {
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
					const Padding(padding: EdgeInsets.all(4)),

					const HeaderLabel("Welcome to the Admin Page!"),

					const Padding(padding: EdgeInsets.all(24)),

					const SubheaderLabel("Accounts"),
					const Padding(padding: EdgeInsets.all(2)),

					Padding( 
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),

						child: SizedBox( 
							width: null,
							height: 230,

							// TODO: Switch to ListView.builder
							child: ListView(
								children: [
									Text(getAccountDataForAdmins()),
								],
							),
						),
					),

					const Padding(padding: EdgeInsets.all(12)),

					const SubheaderLabel("Matches"),
					const Padding(padding: EdgeInsets.all(2)),

					Padding( 
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.85)),

						child: SizedBox( 
							width: null,
							height: 230,

							child: ListView(
								children: [
								],
							),
						),
					),

					const Padding(padding: EdgeInsets.all(24)),
				],
			),
		);
	}
}