import "package:flutter/material.dart";

import "navigation_layout.dart";

import "preference_helpers.dart";

class LoginPageForGuest extends StatefulWidget {
	const LoginPageForGuest({super.key});

	@override
	State<LoginPageForGuest> createState() => _LoginPageForGuest();
}

class _LoginPageForGuest extends State<LoginPageForGuest> {
	final _controller = TextEditingController();
	bool continueButtonPressed = false;

	@override 
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	String? validateName() {
		if (continueButtonPressed) {
			if (_controller.text.isEmpty) {
				return "Expected A Name To Be Entered";
			}

			var words = _controller.text.split(" ");

			var invalidCondition = false;

			for (var word in words) {
				invalidCondition = invalidCondition || word.isEmpty;
				invalidCondition = invalidCondition || !RegExp("[A-Za-z]").hasMatch(word);

				/**
				 * These words are invalid since they cannot be cached with 
				 * shared preferences. We would like to avoid having any
				 * problems. Any additional words that should not be included
				 * in a scouter name can go here.
				 */
				for (var invalidWord in {
					"VGhpcyBpcyB0aGUgcHJlZml4IGZvciBhIGxpc3Qu",
					"VGhpcyBpcyB0aGUgcHJlZml4IGZvciBCaWdJbnRlZ2Vy",
					"VGhpcyBpcyB0aGUgcHJlZml4IGZvciBEb3VibGUu"
				}) {
					invalidCondition = invalidCondition || word.startsWith(invalidWord);
				}
			}
			

			if (invalidCondition) {
				return "Expected A First And Last Name";
			}
		}

		continueButtonPressed = false;
		return null;
	}

	void guestContinueButtonOnPressed() {
	 	setState(() {
			continueButtonPressed = true;

			if (validateName() == null) {
				setScouterName(_controller.text);
				setLoginStatus(true);

				Navigator.pop(context);
				Navigator.of(context).pushReplacementNamed(loggedInRoute);
			}
	 	});
	}

	@override 
	Widget build(BuildContext context) {
		// ignore: invalid_use_of_protected_member
		if (!_controller.hasListeners) {
			_controller.addListener(() => setState(() {}));
		}

		return Scaffold(
			appBar: AppBar(
				backgroundColor: Theme.of(context).colorScheme.inversePrimary,

				// actions: const [
				// 	NavigationMenu(),
				// 	Spacer(),
				// ],
			),
			body: Column(
				children: [
					const Padding(padding: EdgeInsets.all(12.0)),
					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1 - 0.85)),

						child: FittedBox( 
							fit: BoxFit.fill,
							alignment: Alignment.center,

							child: Text(
								"Login as Guest",
								style: Theme.of(context).textTheme.labelLarge,
								textScaler: const TextScaler.linear(16 / 9),
							),
						),
					),

					const Padding(padding: EdgeInsets.all(28),),

					Padding( 
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1 - 0.85) * MediaQuery.of(context).size.aspectRatio, vertical: 5),

						child: TextFormField(
							autocorrect: false,
							autofocus: true,
							keyboardAppearance: Theme.of(context).brightness,
							textCapitalization: TextCapitalization.words,

							controller: _controller,

							onFieldSubmitted: (_) => guestContinueButtonOnPressed(),

							textAlign: TextAlign.start,

							decoration: InputDecoration(
								prefixIcon: const Icon(Icons.account_box_sharp),
								hintStyle: Theme.of(context).dialogTheme.contentTextStyle,
								border: const OutlineInputBorder(),
								// constraints: BoxConstraints.expand(width: 250, height: 37.5),

								floatingLabelAlignment: FloatingLabelAlignment.start,

								labelText: "First & Last Name",

								errorText: validateName(),
							),
						),
					),

					Padding( 
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75), vertical: 25),

						child: SizedBox(
							width: 200,
							height: 40,

							child: FloatingActionButton(
								onPressed: guestContinueButtonOnPressed, 
								// icon: const Icon(Icons.forward), 
								child: Text(
									"Continue as Guest",
									style: Theme.of(context).textTheme.labelMedium,
									textAlign: TextAlign.center,
								),
							),
						),
					),

					const Spacer(),

					Padding(
						padding: const EdgeInsets.only(bottom: 20),

						child: Text(
							"GreenScout is currently in beta.\nThe ability to login with an account (other than a guest account) will come in a later version of the app.",
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodySmall,
						),
					),
				],
			),
		);
	}
}