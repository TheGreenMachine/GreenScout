import 'package:green_scout/pages/match_form.dart';
import 'package:green_scout/widgets/floating_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CreateMatchFormPage extends StatefulWidget {
	const CreateMatchFormPage({
		super.key,
	});

	@override
	State<CreateMatchFormPage> createState() => _CreateMatchFormPage();
}

class _CreateMatchFormPage extends State<CreateMatchFormPage> {
	final _matchController = TextEditingController();
	final _teamController = TextEditingController();

	String matchNum = "";
	String teamNum = "";

	@override 
	void dispose() {
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		_matchController.text = matchNum;
		_teamController.text = teamNum;
				
		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,
			),

			body: ListView(
				children: [
					const Padding(padding: EdgeInsets.all(8)),

					Padding(
						padding: EdgeInsets.symmetric(
							horizontal: MediaQuery.of(context).size.width * (1.0 - 0.74),
							vertical: 0.2,
						),
						
						child: TextField(
							controller: _matchController,

							onChanged: (value) => matchNum = value,

							keyboardType: TextInputType.number,
							keyboardAppearance: Theme.of(context).brightness,
							autocorrect: false,

							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodyMedium,

							inputFormatters: [
								FilteringTextInputFormatter.digitsOnly,
								LengthLimitingTextInputFormatter(2),
							],

							decoration: InputDecoration(
								helperStyle: Theme.of(context).textTheme.displaySmall,
								floatingLabelAlignment: FloatingLabelAlignment.center,
								floatingLabelBehavior: FloatingLabelBehavior.always,
								border: const OutlineInputBorder(),

								labelText: "Match #",	
							),
						),
					),

					const Padding(padding: EdgeInsets.all(8)),

					Padding(
						padding: EdgeInsets.symmetric(
							horizontal: MediaQuery.of(context).size.width * (1.0 - 0.74),
							vertical: 0.2,
						),
						
						child: TextField(
							controller: _teamController,

							onChanged: (value) => teamNum = value,

							keyboardType: TextInputType.number,
							keyboardAppearance: Theme.of(context).brightness,
							autocorrect: false,

							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodyMedium,

							inputFormatters: [
								FilteringTextInputFormatter.digitsOnly,
								LengthLimitingTextInputFormatter(5),
							],

							decoration: InputDecoration(
								helperStyle: Theme.of(context).textTheme.displaySmall,
								floatingLabelAlignment: FloatingLabelAlignment.center,
								floatingLabelBehavior: FloatingLabelBehavior.always,
								border: const OutlineInputBorder(),

								labelText: "Team #",	
							),
						),
					),

					const Padding(padding: EdgeInsets.all(8)),

					Padding(
						padding: EdgeInsets.symmetric(
							horizontal: MediaQuery.of(context).size.width * (1.0 - 0.68),
						),

						child: FloatingButton(
							labelText: "Create Form",
							icon: const Icon(Icons.create),

							color: Theme.of(context).colorScheme.inversePrimary,

							onPressed: () {
								Navigator.pop(context);

								Navigator.pushReplacement(
									context, 
									MaterialPageRoute(
										builder: (context) => const MatchFormPage(),
									),
								);
							},
						),
					),
				],
			),
		);
	}
} 