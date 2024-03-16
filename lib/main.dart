import 'dart:async';
import 'dart:developer';

import 'package:green_scout/admin_data/accounts_info.dart';
import 'package:green_scout/pages/home.dart';
import 'package:green_scout/pages/login_as_user.dart';
import 'package:flutter/material.dart';

import 'pages/navigation_layout.dart';
import 'number_label_field.dart';
import 'pages/preference_helpers.dart';
import 'timer_button.dart';
import 'globals.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await App.start();

  Timer.periodic(const Duration(seconds: 15), (timer) async {
    final matches = getMatchCache();

    if (!loggedInAlready()) {
      return;
    }

    if (matches.isNotEmpty) {
      final path = Uri(
          scheme: 'http', host: serverHostName, path: 'dataEntry', port: 3333);

      for (var match in matches) {
        dynamic err;
        await http
            .post(
          path,
          headers: {"Certificate": getCertificate()},
          body: match,
        )
            .then((response) {
          log("Response status: ${response.statusCode}");
          log("Response body: ${response.body}");
        }).catchError((error) {
          err = error;
          log(error.toString());
        });

        if (err != null) {
          return;
        }
      }

      // A little safety check to ensure that we aren't getting
      // rid of data that just got put into the list.
      if (matches.length == getMatchCache().length) {
        resetMatchCache();
      }
    }
  });

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    // We aren't ready to work towards a fully working admin page.
    setAdminStatus(false);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: greenMachineGreen),
        useMaterial3: true,
      ),
      home: !loggedInAlready() ? const LoginPageForUsers() : const HomePage(),
      //   home: const LoginPageForGuest(),
      routes: navigationLayout,
    );
  }
}

class BoolLabelField extends StatefulWidget {
  const BoolLabelField(
      {super.key, this.labelText, this.width, this.height, this.onChanged});

  final String? labelText;

  final double? width;
  final double? height;

  final void Function(bool)? onChanged;

  @override
  State<BoolLabelField> createState() => _BoolLabelField();
}

class _BoolLabelField extends State<BoolLabelField> {
  bool checkValue = false;

  @override
  Widget build(BuildContext context) {
    const paddingAmount = 2;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Row(
        children: [
          SizedBox(
            width: (widget.width ?? 1) / 2,
            height: widget.height,
            child: FittedBox(
              fit: BoxFit.fitHeight,
              alignment: Alignment.centerRight,
              child: Text(
                (widget.labelText ?? "")
                    .padRight((widget.labelText?.length ?? 0) + paddingAmount),
                textAlign: TextAlign.left,
                style: Theme.of(context).textTheme.labelMedium,
                // textHeightBehavior: const TextHeightBehavior(),
                // textScaler: TextScaler.linear(((width ?? 1) / 2) / (height ?? 1)),
              ),
            ),
          ),
          const Spacer(
            flex: 1,
          ),
          SizedBox(
            width: (widget.width ?? 1) / 2,
            height: widget.height,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Checkbox(
                    value: checkValue,
                    onChanged: (bValue) {
                      setState(() {
                        checkValue = bValue != null && bValue;

                        if (widget.onChanged != null) {
                          widget.onChanged!(checkValue);
                        }
                      });
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/*
 * TODO: Switch the cycle system to a clock and dropdown menu instead of using
 * a lap timer.
 * 
 * This will allow us to capture the type of the cycle and ensure that the menu
 * is less confusing. It will make it more streamlined.
 * 
 * Also, another idea I was considering was to add the timer and type of the cycle
 * as an item that follows you down the page. This would make it way easier to quickly 
 * click the timer.
 * 
 * If I remember correctly, a cycle is just the time from when the team picks up a note
 * and when they deposit into the either of the two spots. 
 */

class FormFillingPage extends StatefulWidget {
  const FormFillingPage({super.key});

  @override
  State<FormFillingPage> createState() => _FormFillingPage();
}

void onEndS(double value) {
  print("End time: $value");
}

class _FormFillingPage extends State<FormFillingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenMachineGreen,
        centerTitle: true,
        title: const Text(
          "Match Info",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
          textAlign: TextAlign.center,
        ),
      ),
      body: ListView(
        children: const [
          Center(
            child: NumberLabelField(
              labelText: "Match",
              hintText: "#",
              width: 150,
              height: 35,
              numberLengthLimit: 2,
            ),
          ),
          Center(
            child: BoolLabelField(
              labelText: "Replay?",
              width: 150,
              height: 35,
            ),
          ),
          Center(
            child: NumberLabelField(
              labelText: "Team",
              hintText: "#",
              width: 150,
              height: 35,
              numberLengthLimit: 5,
            ),
          ),
          Padding(padding: EdgeInsets.all(8)),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                  width: 250,
                  height: 35,
                  child:
                      FittedBox(fit: BoxFit.fitHeight, child: Text("Cycling"))),
              TimerButton(width: 250, height: 250, onEnd: onEndS, lap: true),
            ],
          ),
          Padding(padding: EdgeInsets.all(4)),
          Center(
              child: BoolLabelField(
            labelText: "Amp",
            width: 120,
            height: 35,
          )),
          Center(
              child: BoolLabelField(
            labelText: "Speaker",
            width: 120,
            height: 35,
          )),
          Padding(padding: EdgeInsets.all(12)),
          SizedBox(
              width: 150,
              height: 35,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text("Speaker Positions"),
              )),
          Center(
              child: BoolLabelField(
            labelText: "Top",
            width: 120,
            height: 35,
          )),
          Center(
              child: BoolLabelField(
            labelText: "Middle",
            width: 120,
            height: 35,
          )),
          Center(
              child: BoolLabelField(
            labelText: "Bottom",
            width: 120,
            height: 35,
          )),
          Padding(padding: EdgeInsets.all(12)),
          SizedBox(
              width: 150,
              height: 35,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text("Distance Shooting"),
              )),
          Center(
              child: BoolLabelField(
            labelText: "Can",
            width: 195,
            height: 35,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Average",
            hintText: "%",
            width: 195,
            height: 35,
            numberLengthLimit: 6,
          )),
          Padding(padding: EdgeInsets.all(12)),
          SizedBox(
              width: 150,
              height: 35,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text("Auto"),
              )),
          Center(
              child: BoolLabelField(
            labelText: "Can",
            width: 195,
            height: 35,
          )),
          Center(
              child: BoolLabelField(
            labelText: "Succeeded",
            width: 195,
            height: 35,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Scores",
            hintText: "#",
            width: 195,
            height: 35,
            numberLengthLimit: 6,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Misses",
            hintText: "#",
            width: 195,
            height: 35,
            numberLengthLimit: 6,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Ejects",
            hintText: "#",
            width: 195,
            height: 35,
            numberLengthLimit: 6,
          )),
          Divider(height: 12),
          SizedBox(
              width: 150,
              height: 35,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text("EndGame"),
              )),
          Center(
              child: BoolLabelField(
            labelText: "Parks",
            width: 195,
            height: 35,
          )),
          Padding(padding: EdgeInsets.all(12)),
          SizedBox(
              width: 150,
              height: 35,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text("Climb"),
              )),
          Center(
              child: BoolLabelField(
            labelText: "Can",
            width: 195,
            height: 35,
          )),
          Center(
              child: BoolLabelField(
            labelText: "Succeeded",
            width: 195,
            height: 35,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Attempts",
            hintText: "#",
            width: 215,
            height: 35,
            numberLengthLimit: 6,
          )),
          Padding(padding: EdgeInsets.all(12)),
          SizedBox(
              width: 150,
              height: 35,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Text("Trap"),
              )),
          Center(
              child: BoolLabelField(
            labelText: "Can",
            width: 195,
            height: 35,
          )),
          Center(
              child: BoolLabelField(
            labelText: "Succeeded",
            width: 195,
            height: 35,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Attempts",
            hintText: "#",
            width: 215,
            height: 35,
            numberLengthLimit: 6,
          )),
          Center(
              child: NumberLabelField(
            labelText: "Scores",
            hintText: "#",
            width: 215,
            height: 35,
            numberLengthLimit: 6,
          )),
          Padding(padding: EdgeInsets.all(14)),
          Center(
            child: BoolLabelField(
              labelText: "Coopertition",
              width: 195,
              height: 35,
            ),
          ),
          Padding(padding: EdgeInsets.all(24)),
        ],
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
