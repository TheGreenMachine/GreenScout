import 'package:GreenScout/pages/create_new_match.dart';
import 'package:GreenScout/pages/navigation_layout.dart';
import 'package:GreenScout/widgets/floating_button.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
	const HomePage({
		super.key,
	});

	@override
	State<HomePage> createState() => _HomePage();
}

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
					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75), vertical: 15),

						child: FloatingButton(
							labelText: "Create New Match Form",

							icon: const Icon(Icons.create),
							color: Theme.of(context).colorScheme.inversePrimary,
							onPressed: () => Navigator.push(
								context,
								MaterialPageRoute(
									builder: (context) => const CreateMatchFormPage(),
								),
							),
						),
					),
				],
			),
		);
	}
}