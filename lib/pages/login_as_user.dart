import "dart:developer";

import "package:crypto/crypto.dart";
import "package:flutter/material.dart";
import 'dart:convert';

import "../globals.dart";

import "preference_helpers.dart";

import 'package:http/http.dart' as http;

class LoginPageForUsers extends StatefulWidget {
	const LoginPageForUsers({super.key});

	@override
	State<LoginPageForUsers> createState() => _LoginPageForUsers();
}

class _LoginPageForUsers extends State<LoginPageForUsers> {
	final _userController = TextEditingController();
	String userStr = "";
	final _passwordController = TextEditingController();
	String passwordStr = "";
	bool continueButtonPressed = false;

	bool hidePassword = true;

	@override 
	void dispose() {
		_userController.dispose();
		_passwordController.dispose();
		super.dispose();
	}

	String? validateLogin() {
		if (continueButtonPressed) {
			if (userStr.isEmpty) {
				return "Username field not filled out";
			}

			if (passwordStr.isEmpty) {
				return "Password field not filled out";
			}

			final path = Uri(scheme: 'http', host: serverHostName, path: 'login', port: 3333);

			log("Using this path: $path");

			http.post(
				path, 
				body: '''
					{
						"Username": "$userStr",
						"Password": "${sha256.convert(utf8.encode(passwordStr)).toString()}"
					}
				'''.trim()).then((value) {
					log(value.statusCode.toString());
					log(value.body);
					for (var entry in value.headers.entries) {
						log("${entry.key}: ${entry.value}");
					}
				}).catchError((error) { log(error.toString()); });
		}

		continueButtonPressed = false;
		return null;
	}


	void continueButtonOnPressed() {
	 	setState(() {
			continueButtonPressed = true;

			if (validateLogin() == null) {
				// setScouterName(_userController.text);
				// setLoginStatus(true);
// 
				// Navigator.of(context).pushReplacementNamed(loggedInRoute);
			}
	 	});
	}

	@override 
	Widget build(BuildContext context) {
		_userController.text = userStr;
		_passwordController.text = passwordStr;

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
								"Login",
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

							controller: _userController,

							onChanged: (value) => userStr = value,

							onFieldSubmitted: (_) => continueButtonOnPressed(),

							textAlign: TextAlign.start,

							decoration: InputDecoration(
								prefixIcon: const Icon(Icons.account_box_sharp),
								hintStyle: Theme.of(context).dialogTheme.contentTextStyle,
								border: const OutlineInputBorder(),
								// constraints: BoxConstraints.expand(width: 250, height: 37.5),

								floatingLabelAlignment: FloatingLabelAlignment.start,

								labelText: "User Name",

								// errorText: validateName(),
							),
						),
					),

					Padding( 
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1 - 0.85) * MediaQuery.of(context).size.aspectRatio, vertical: 5),

						child: TextFormField(
							autocorrect: false,
							autofocus: false,
							keyboardAppearance: Theme.of(context).brightness,
							textCapitalization: TextCapitalization.words,

							controller: _passwordController,

							onChanged: (value) => passwordStr = value,

							obscureText: hidePassword,

							onFieldSubmitted: (_) => continueButtonOnPressed(),

							textAlign: TextAlign.start,

							decoration: InputDecoration(
								prefixIcon: const Icon(Icons.star),
								hintStyle: Theme.of(context).dialogTheme.contentTextStyle,
								border: const OutlineInputBorder(),
								// constraints: BoxConstraints.expand(width: 250, height: 37.5),

								floatingLabelAlignment: FloatingLabelAlignment.start,

								labelText: "Password",

								suffix: TextButton(
									child: const Icon(Icons.remove_red_eye),

									onPressed: () { setState(() => hidePassword = !hidePassword); },

								),

								// errorText: validateName(),
							),
						),
					),

					const Padding(padding: EdgeInsets.all(17.5)),

					Padding( 
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75)),

						child: SizedBox(
							width: 200,
							height: 40,

							child: FloatingActionButton(
								onPressed: continueButtonOnPressed, 
								// icon: const Icon(Icons.forward), 
								child: Text(
									"Continue",
									style: Theme.of(context).textTheme.labelMedium,
									textAlign: TextAlign.center,
								),
							),
						),
					),

					const Padding(padding: EdgeInsets.all(12),),

					Padding(
						padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * (1.0 - 0.65)),

						child: GestureDetector(
							child: Text(
								"Login As Guest",

								textAlign: TextAlign.center,
								style: (Theme.of(context).textTheme.labelMedium ?? const TextStyle()).apply(
									color: Colors.blue,
									decoration: TextDecoration.underline,
								),
							),

							onTap: () {
								Navigator.pushNamed(context, '/loginAsGuest');
							},
						),
					),

					const Spacer(),

					Padding(
						padding: const EdgeInsets.only(bottom: 20),

						child: Text(
							"GreenScout is currently in beta.",
							textAlign: TextAlign.center,
							style: Theme.of(context).textTheme.bodySmall,
						),
					),
				],
			),
		);
	}
}