import 'package:flutter/material.dart';

class AdminAssignMatchesPage extends StatefulWidget {
	const AdminAssignMatchesPage({super.key});

	@override
	State<AdminAssignMatchesPage> createState() => _AdminAssignMatchesPage();
}

class _AdminAssignMatchesPage extends State<AdminAssignMatchesPage> {
	@override 
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,

				actions: const [
					Spacer(),
				],
			),
		);
	}
}