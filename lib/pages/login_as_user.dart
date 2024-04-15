import "dart:developer";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:green_scout/pages/home.dart";
import "package:green_scout/pages/login_as_guest.dart";
import "package:green_scout/widgets/action_bar.dart";
import 'package:pointycastle/asymmetric/api.dart';
import 'package:encrypt/encrypt.dart';

import "../globals.dart";

import "preference_helpers.dart";

import 'package:http/http.dart' as http;

class LoginPageForUsers extends StatefulWidget {
  const LoginPageForUsers({super.key});

  @override
  State<LoginPageForUsers> createState() => _LoginPageForUsers();
}

// TODO: Redo this whole login screen. 
// It's sooooo bad....

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

  Future<RSAPublicKey> getPublicKey() async {
    final url =
        Uri(scheme: 'https', host: serverHostName, path: 'pub', port: 443);

    var response = await http.get(url);

    final parser = RSAKeyParser();

    return parser.parse(response.body) as RSAPublicKey;
  }

  Future<String> encryptPassword64(String plaintext) async {
    final publicKey = await getPublicKey();

    final encrypter = Encrypter(RSA(publicKey: publicKey));

    final encrypted = encrypter.encrypt(plaintext);

    return encrypted.base64;
  }

  Future<String?> validateLogin() async {
    if (continueButtonPressed) {
      if (userStr.isEmpty) {
        return "Username field not filled out";
      }

      if (passwordStr.isEmpty) {
        return "Password field not filled out";
      }

      storeCertificate("");

      await App.httpGet(
        "login",
        '''
        {
          "Username": "$userStr",
          "EncryptedPassword": "${await encryptPassword64(passwordStr)}"
        }
      ''',
        (response) {
          storeUserRole(response.headers["role"] ?? "None");
          print(getUserRole());
          storeUserUUID(response.headers["uuid"] ?? "");
          storeCertificate(response.headers["certificate"] ?? "");
        },
      );

      // if (getCertificate().isEmpty) {
      //   return "Invalid password or username";
      // }
    }

    continueButtonPressed = false;
    return null;
  }

  void continueButtonOnPressed() async {
    continueButtonPressed = true;

    if ((await validateLogin()) == null && getCertificate().isNotEmpty) {
      setScouterName(_userController.text);
      setLoginStatus(true);

      autoSetAdminStatus();

      if (mounted) {
        App.gotoPage(context, const HomePage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _userController.text = userStr;
    _passwordController.text = passwordStr;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: createEmptyActionBar(),
      ),
      body: Column(
        children: [
          const Padding(padding: EdgeInsets.all(12.0)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (1 - 0.85),
            ),
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
          const Padding(
            padding: EdgeInsets.all(28),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width *
                  (1 - 0.85) *
                  MediaQuery.of(context).size.aspectRatio,
              vertical: 5,
            ),
            child: TextFormField(
              autocorrect: false,
              autofocus: true,
              keyboardAppearance: Theme.of(context).brightness,
              textCapitalization: TextCapitalization.words,
              controller: _userController,
              onChanged: (value) => userStr = value,
              onFieldSubmitted: (_) => continueButtonOnPressed(),

              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp("[a-zA-Z0-9]")),
              ],

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
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width *
                  (1 - 0.85) *
                  MediaQuery.of(context).size.aspectRatio,
              vertical: 5,
            ),
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
                  onPressed: () {
                    setState(() => hidePassword = !hidePassword);
                  },
                ),

                // errorText: validateName(),
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.all(17.5)),
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: MediaQuery.of(context).size.width * (1.0 - 0.75)),
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
          const Padding(
            padding: EdgeInsets.all(20),
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width * (1.0 - 0.65),
            ),
            child: GestureDetector(
              child: Text(
                "Login As Guest",
                textAlign: TextAlign.center,
                style: (Theme.of(context).textTheme.labelMedium ??
                        const TextStyle())
                    .apply(
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              onTap: () {
                setScouterName("Guest");
                setAdminStatus(false);

                // The reasoning for this is simple: When 
                // logging in as a guest, you're unlikely to
                // want to encourage the user to stay as a guest.
                // 
                // This is because if they're a guest they can't
                // really sent data to the server.
                setLoginStatus(false);

                storeCertificate("");
                storeUserUUID("");

                App.gotoPage(context, const HomePage(),
                    canGoBack: true);

                App.showMessage(context, "Logged In As Guest!");
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
